13. Interpreter Mode

The interpreter mode enables the programmer to send and execute any valid script statement at runtime,
except declaration of new globals.
An internal interpreter thread is created at the start of execution of each primary program. The interpreter
socket(30020) accepts complete and valid UR-script statements when a program is running. When Interpreter
mode is active it compiles and links the received statements into the running program and executes them in
the scope of the interpreter thread. These statements become a part of the running program.
The scope of statements in the interpreter mode is inherited from the scope from which interpreter mode was
called. Be aware that declaring new global variables in interpreter mode is not supported.
When statements are sent at a faster rate than what the interpreter can handle, they are queued in an internal
buffer before they can be appended to the running program.
When the last statement received is executed, the interpreter thread will be idle until new statements are
received.
Interpreter mode can be stopped by calling end_interpreter() over the interpreter mode socket, or by
calling it from a thread in the main program. Interpreter mode also stops when the program is stopped.
Each statement should be sent in a single line, so the following statement:
def myFun():
mystring = "Hello Interpreter"
textmsg(mystring)
end
Should be formatted like below:
def myFun(): mystring = "Hello Interpreter" textmsg(mystring) end
With a newline character to end the statement. Multiple statements can be sent on a single line, and will only
be accepted if all can be compiled.

13.1. Interpreter Mode replies
Received valid commands and statements are always acknowledge with a reply on the socket in form of:
ack: <id>: <statements>
Where <id> is a consecutively unique id for the received <statement>.
If a program is not running or the statement results in a compilation or linker error, the interpreter will reply with
a discard message:
discard: <reason>: <statement>.
Note: There exists an upper limit to the size of the interpreted statements per interpreter mode. To avoid
reaching that limit clear_interpreter() can be called to clear up everything interpreted into the current
interpreter mode.
Important: It is important to remember that every time a statement is interpreted the size and the complexity of
the program will grow if interpreter mode is not cleared either on exit or with clear_interpreter(). Too
large programs should be avoided.
13.2. Entering Interpreter Mode
interpreter_mode(clearQueueOnEnter = True, clearOnEnd = True)
Script Directory 21 e-Series
13. Interpreter Mode

This is a blocking function that puts the controller in interpreter mode.
This function can only be called in the main thread, and nested interpreter modes are not supported. This
means that one can’t send an interpreter_mode() call to the interpreter socket.
Parameters
clearQueueOnEnter: If True queued statements will be cleared before interpreter mode is started.
It is possible to send statements to the interpreter socket before interpreter mode is run. These are put into
a queue, which by default is cleared when interpreter_mode() is called. However, setting the
clearQueueOnEnter argument to False will cause interpreter mode to start executing the statements
already in the queue when entering interpreter mode.
clearOnEnd: If True interpreted statements will be cleared when end_interpreter() is called.
Interpreted statements become part of the running program in the scope from which interpreter_mode
() was called, but are by default removed from the program again when end_interpreter() is called.
However, when entering interpreter mode it is possible to choose to have a persistent behavior by calling
interpreter_mode(clearOnEnd = False). The interpreted statements will in that case be a part of
the program until the end of program execution, thus they can be called/accessed in subsequent calls to
interpreter_mode().
Example statement:
• interpreter_mode()
• Starts interpreter mode with default behavior.
• interpreter_mode(clearQueueOnEnter = False)
• Starts interpreter mode by interpreting and executing the statements already in the
interpreter queue.
Important: It is the programmers responsibility to implement the synchronization necessary to ensure that
the program is in the wanted interpreter mode, and that it is ready to receive the statements. It is
insufficient to detect if interpreter mode is running, as multiple interpreter mode can exist in the same
program.
13.3. End Interpreter Mode
end_interpreter()
Ends the interpreter mode, and causes the interpreter_mode() function to return. This function can
be compiled into the program by sending it to the interpreter socket(30020) as any other statement, or can
be called from anywhere else in the program.
By default everything interpreted will be cleared when ending, though the state of the robot, the
modifications to local variables from the enclosing scope, and the global variables will remain affected by
any changes made. The interpreter thread will be idle after this call.
13.4. Clear Interpreter Mode
clear_interpreter()

13. Interpreter Mode
Clears all interpreted statements, objects, functions, threads, etc. generated in the current interpreter
mode. Threads started in current interpreter session will be stopped, and deleted. Variables defined
outside of the current interpreter mode will not be affected by a call to this function.
Only statements interpreted before the clear_interpreter() function will be cleared. Statements
sent after clear_interpreter() will be queued. When cleaning is done, any statements queued are
interpreted and responded to. Note that commands such as abort, skipbuffer and state commands are
executed as soon as they are received.
Note: This function can only be called from an interpreter mode.
Tip: To expedite the clean, skipbuffer can be sent right before clear_interpreter().
13.5. Aborting Current Function
abort
The interpreter mode offers a mechanism to abort limited number of script functions, even if they are
called from the main program. Currently only movej and movel can be aborted.
Aborting a movement will result in a controlled stop if no blend radius is defined.
If a blend radius is defined then a blend with the next movement will be initiated right away if not already in
an initial blend, otherwise the command is ignored.
Return value should be ignored
Note: abort must be sent in a line by itself, and thus cannot be combined with other commands or
statements.
13.6. Skip Non Executed Statements
skipbuffer

The interpreter mode furthermore supports the opportunity to skip already sent but not executed
statements. The interpreter thread will then (after finishing the currently executing statement) skip all
received but not executed statements.
After the skip, the interpreter thread will idle until new statements are received. skipbuffer will only skip
already received statements, new statements can therefore be send right away.
Return value should be ignored
Note: skipbuffer must be sent in a line by itself, and thus cannot be combined with other commands or
statements.
13.7. State Commands for Interpreter Mode
The state commands that can be used to get a status from interpreter mode are listed here. When the state
commands below responds with an id, it is the id given in the ackownlegde message at the time the statement
was recevied by the interpreter.
Script Directory 23 e-Series
13. Interpreter Mode
Note that these ids start at 1 and might wrap around to 1 in very long running programs. A 0 represents an
uninitialized or undefined value, such as the last executed statement if none has been executed yet.
statelastexecuted
Replies with the largest id of a statement that has started being executed.
state: <id>: statelastexecuted
statelastinterpreted
Replies with the latest interpreted id, i.e. the highest number of interpreted statement so far.
state: <id>: statelastinterpreted

statelastcleared
Replies with the id for the latest statement to be cleared from the interpreter mode. This clear can happen
when ending interpreter mode, or by calls to clear_interpreter()
state: <id>: statelastcleared
stateunexecuted
Replies with the number of non executed statements, i.e. the number of statements that would have be
skipped if skipbuffer was called instead.
state: <#unexecuted>: stateunexecuted
13.8. Interpreter mode log files
Statements acknowledged by the interpreter mode are logged to the file
/tmp/log/urcontrol/interpreter.log. The file contains basic information on when the log was
started, and for each statement a line:
e: <id_e> c: <id_a> : <statement>
Where <id_e> is the last statement for which execution has started when the statement <statement> with id
<id_a> was compiled into the program. To avoid filling the memory of the robot, the logfile is cleaned up
according to the following rules:
1. If the interpreter mode was entered with the parameter clearOnEnd=False, all statements in the
interpreter mode are appended to the file /tmp/log/urcontrol/interpreter.saved.log when
end_interpreter() is called.
2. Any other call to end_interpreter() or clear_interpreter() will cause the log to be moved to
/tmp/log/urcontrol/interpreter.0.log overwriting any data previously stored there.
All interpreter mode log files are included in failure report files.