10. Threads

Threads are supported in URScript using special commands.

To declare a new thread, use syntax similar to function declarations:

```
thread myThread():
    # Do some stuff
    return False
end
```

A thread cannot take parameters, and its return value is discarded. Threads can be nested, forming a thread hierarchy.

Running a Thread

```
thread myThread():
    # Do some stuff
    return False
end

thrd = run myThread()
```

run starts the thread and returns a handle to it. You can use this handle to control the thread later.

Waiting for a Thread

join thrd

This halts the calling thread until the specified thread finishes. If already finished, join has no effect.

Killing a Thread

kill thrd

Stops the running thread and invalidates its handle. If the thread has children, they are killed too.

Critical Sections

Critical sections prevent concurrent execution of certain code across threads.

```
thread myThread():
    enter_critical
    # Critical operations
    exit_critical
    return False
end
```

Note: Avoid time-demanding commands (sleep, sync, move, socketRead) inside critical sections.

10.1 Threads and Scope

The scoping rules for threads are exactly the same, as those used for functions. See 1.7 for a discussion of these rules.

10.2 Thread Scheduling

Because the primary purpose of the URScript scripting language is to control the robot, the scheduling policy is largely based upon the realtime demands of this task.
The robot must be controlled a frequency of 500 Hz, or in other words, it must be told what to do every 0.002 second (each 0.002 second period is called a frame). To achieve this, each thread is given a “physical” (or
robot) time slice of 0.002 seconds to use, and all threads in a runnable state is then scheduled in a 1 fashion.
Each time a thread is scheduled, it can use a piece of its time slice (by executing instructions that control the robot), or it can execute instructions that do not control the robot, and therefore do not use any “physical” time.
If a thread uses up its entire time slice, either by use of “physical” time or by computational heavy instructions
(such as an infinite loop that do not control the robot) it is placed in a non-runnable state, and is not allowed to
run until the next frame starts. If a thread does not use its time slice within a frame, it is expected to switch to a
non-runnable state before the end of 2
. The reason for this state switching can be a join instruction or simply
because the thread terminates.
---
1 Before the start of each frame the threads are sorted, such that the thread with the largest remaining time
slice is to be scheduled first.
2 If this expectation is not met, the program is stopped.
---

It should be noted that even though the sleep instruction does not control the robot, it still uses “physical”
time. The same is true for the sync instruction. Inserting sync or sleep will allow time for other threads to be
executed and is therefore recommended to use next to computational heavy instructions or inside infinite
loops that do not control the robot, otherwise an exception like "Lost communication with Controller" can be
raised with a consequent protective stop.