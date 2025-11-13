14. Module motion
This module contains functions and variables built into the URScript programming language.
URScript programs are executed in real-time in the URControl RuntimeMachine (RTMa- chine). The
RuntimeMachine communicates with the robot with a frequency of 500hz.
Robot trajectories are generated online by calling the move functions movej, functions speedj, speedl.
movel and the speed
Joint positions (q) and joint speeds (qd) are represented directly as lists of 6 Floats, one for each robot joint.
Tool poses (x) are represented as poses also consisting of 6 Floats. In a pose, the first 3 coordinates is a
position vector and the last 3 an axis-angle (http://en.wikipedia.org/wiki/Axis_angle).
14.1. conveyor_pulse_decode(type, A, B)
Deprecated : Tells the robot controller to treat digital inputs number A and B as pulses for a conveyor
encoder. Only digital input 0, 1, 2 or 3 can be used.
Parameters
type:
An integer determining how to treat the inputs on A and B
0 is no encoder, pulse decoding is disabled.
1 is quadrature encoder, input A and B must be square waves with 90 degree offset. Direction of the
conveyor can be determined.
2 is rising and falling edge on single input (A).
3 is rising edge on single input (A).
4 is falling edge on single input (A).
The controller can decode inputs at up to 40kHz
A:
Encoder input A, values of 0-3 are the digital inputs 0-3.
B:
Encoder input B, values of 0-3 are the digital inputs 0-3.
Deprecated: This function is replaced by encoder_enable_pulse_decode and it should therefore not
be used moving forward.
>>> conveyor_pulse_decode(1,0,1)
This example shows how to set up quadrature pulse decoding with input A = digital_in[0] and input B =
digital_in[1]
>>> conveyor_pulse_decode(2,3)
This example shows how to set up rising and falling edge pulse decoding with input A = digital_in[3]. Note
that you do not have to set parameter B (as it is not used anyway).
Example command: conveyor_pulse_decode(1, 2, 3)

Script Directory 25 e-Series
14. Module motion
• Example Parameters:
• type = 1→ is quadrature encoder, input A and B must be square waves with 90 degree
offset. Direction of the conveyor can be determined.
• A = 2 → Encoder output A is connected to digital input 2
• B = 3 → Encoder output B is connected to digital input 3
14.2. encoder_enable_pulse_decode(encoder_index,
decoder_type, A, B)

Sets up an encoder hooked up to the pulse decoder of the controller.
>>> encoder_enable_pulse_decode(0,0,1,8,9)
This example shows how to set up encoder 0 for decoding a quadrature signal connected to pin 8 and 9.
Parameters
encoder_index: Index of the encoder to define. Must be either 0 or 1.
decoder_type:
An integer determining how to treat the inputs on A and B.
0 is no encoder, pulse decoding is disabled.
1 is quadrature encoder, input A and B must be square waves with 90 degree offset. Direction of the
conveyor can be determined.
2 is rising and falling edge on single input (A).
3 is rising edge on single input (A). 4 is falling edge on single input (A).
The controller can decode inputs at up to 40kHz
A:
Encoder input A pin. Must be 8-11.
B:
Encoder input B pin. Must be 8-11.
14.3. encoder_enable_set_tick_count(encoder_index,
range_id)
Sets up an encoder expecting to be updated with tick counts via the function encoder_set_tick_
count.
>>> encoder_enable_set_tick_count(0,0)
This example shows how to set up encoder 0 to expect counts in the range of [-2147483648 ;
2147483647].
Parameters

14. Module motion
encoder_index:
Index of the encoder to define. Must be either 0 or 1.
range_id:
decoder_index: Range of the encoder
(integer). Needed to handle wrapping nicely.
0 is a 32 bit signed encoder, range [-2147483648 ; 2147483647]
1 is a 8 bit unsigned encoder, range [0 ; 255]
2 is a 16 bit unsigned encoder, range [0 ; 65535]
3 is a 24 bit unsigned encoder, range [0 ; 16777215]
4 is a 32 bit unsigned encoder, range [0 ; 4294967295]
14.4. encoder_get_tick_count(encoder_index, opt="")
Returns the filtered tick count of the designated encoder.
>>> encoder_get_tick_count(0)
This example returns the current filtered tick count of encoder 0.
Parameters
encoder_index: Index of the encoder to query. Must be either 0 or 1.
opt: Optional option parameter. Default is opt="". Get the raw unfiltered integer value by opt="raw".
Return Value
The filtered conveyor encoder tick count (float) or the raw value (int32)
Example command 1: encoder_get_tick_count(0)
This example returns the current filtered tick count of encoder 0.
Use caution when subtracting encoder tick counts as it wraps around when reaching the maximum count
value. The range of the filtered encoder value is [0; 65536[.
Please see the function encoder_unwind_delta_tick_count.
Example command 2: encoder_get_tick_count(1, opt="raw")
This example returns the current raw tick count of encoder 1.
Use caution when subtracting encoder tick counts.
The range of the raw encoder value is [-2³¹, 2³¹[.

14.5. encoder_set_tick_count(encoder_index, count)
Tells the robot controller the tick count of the encoder. This function is useful for absolute encoders (e.g.
MODBUS).
>>> encoder_set_tick_count(0, 1234)
Script Directory 27 e-Series
14. Module motion
This example sets the tick count of encoder 0 to 1234. Assumes that the encoder is enabled using
encoder_enable_set_tick_count first.
Parameters
encoder_index: Index of the encoder to define. Must be either 0 or 1.
count: The tick count to set. Must be within the range of the encoder.
14.6. encoder_unwind_delta_tick_count(encoder_index,
delta_tick_count)

Returns the delta_tick_count. Unwinds in case encoder wraps around the range. If no wrapping has
happened the given delta_tick_count is returned without any modification.
Consider the following situation: You are using an encoder with a UINT16 range, meaning the tick count is
always in the [0; 65536[ range. When the encoder is ticking, it may cross either end of the range, which
causes the tick count to wrap around to the other end. During your program, the current tick count is
assigned to a variable (start:=encoder_get_tick_count(...)). Later, the tick count is assigned to another
variable (current:=encoder_get_tick_count(...)). To calculate the distance the conveyor has traveled
between the two sample points, the two tick counts are subtracted from each other.
For example, the first sample point is near the end of the range (e.g., start:=65530). When the conveyor
arrives at the second point, the encoder may have crossed the end of its range, wrapped around, and
reached a value near the beginning of the range (e.g., current:=864). Subtracting the two samples to
calculate the motion of the conveyor is not robust, and may result in an incorrect result
(delta=current-start=-64666).
Conveyor tracking applications rely on these kinds of encoder calculations. Unless special care is taken to
compensate the encoder wrapping around, the application will not be robust and may produce weird
behaviors (e.g., singularities or exceeded speed limits) which are difficult to explain and to reproduce.
This heuristic function checks that a given delta_tick_count value is reasonable. If the encoder wrapped
around the end of the range, it compensates (i.e., unwinds) and returns the adjusted result. If a delta_tick_
count is larger than half the range of the encoder, wrapping is assumed and is compensated. As a
consequence, this function only works when the range of the encoder is explicitly known, and therefore the
designated encoder must be enabled. If not, this function will always return nil.
Parameters
encoder_index: Index of the encoder to query. Must be either 0 or 1.
delta_tick_count: The delta (difference between two) tick count to unwind (float)
Return Value
The unwound delta_tick_count (float)
14.7. end_force_mode()
Resets the robot mode from force mode to normal operation.
e-Series 28 Script Directory
14. Module motion
This is also done when a program stops.
14.8. end_freedrive_mode()
Set robot back in normal position control mode after freedrive mode.
14.9. end_screw_driving()
Exit screw driving mode and return to normal operation.
14.10. end_teach_mode()
Deprecated:
Set robot back in normal position control mode after teach mode.
This function is replaced by end_freedrive_mode and it should therefore not be used moving forward.
14.11. force_mode(task_frame, selection_vector, wrench,
type, limits)

Set robot to be controlled in force mode
Parameters
task_frame: A pose vector that defines the force frame relative to the base frame.
selection_vector: A 6d vector of 0s and 1s. 1 means that the robot will be compliant in the
corresponding axis of the task frame.
wrench: The forces/torques the robot will apply to its environment. The robot adjusts its position
along/about compliant axis in order to achieve the specified force/torque. Values have no effect for non-
compliant axes.
Actual wrench applied may be lower than requested due to joint safety limits. Actual forces and torques
can be read using get_tcp_force function in a separate thread.
type:
An integer [1;3] specifying how the robot interprets the force frame.
1: The force frame is transformed in a way such that its y-axis is aligned with a vector pointing from the
robot tcp towards the origin of the force frame.
2: The force frame is not transformed.
Script Directory 29 e-Series
14. Module motion
3: The force frame is transformed in a way such that its x-axis is the projection of the robot tcp velocity
vector onto the x-y plane of the force frame.
limits: (Float) 6d vector. For compliant axes, these values are the maximum allowed tcp speed
along/about the axis. For non-compliant axes, these values are the maximum allowed deviation
along/about an axis between the actual tcp position and the one set by the program.
Note: Avoid movements parallel to compliant axes and high deceleration (consider inserting a short sleep
command of at least 0.02s) just before entering force mode. Avoid high acceleration in force mode as this
decreases the force control accuracy.
14.12. force_mode_example()

This is an example of the above force_mode() function
Example command: force_mode(p[0.1,0,0,0,0.785], [1,0,0,0,0,0],
[20,0,40,0,0,0], 2, [.2,.1,.1,.785,.785,1.57])
Example Parameters:
• Task frame = p[0.1,0,0,0,0.785] ! This frame is offset from the base frame 100 mm in the x direction
and rotated 45 degrees
• in the rz direction
• Selection Vector = [1,0,0,0,0,0] ! The robot is compliant in the x direction of the Task frame above.
• Wrench = [20,0,40,0,0,0] ! The robot apples 20N in the x direction. It also accounts for a 40N
external force in the z direction.
• Type = 2 ! The force frame is not transformed.
• Limits = [.1,.1,.1,.785,.785,1.57] ! max x velocity is 100 mm/s, max y deviation is 100 mm, max z
deviation is 100 mm, max rx deviation is 45 deg, max ry deviation is 45 deg, max rz deviation is 90
deg.
14.13. force_mode_set_damping(damping)
Sets the damping parameter in force mode.
Parameters
damping:
Between 0 and 1, default value is 0.005
A value of 1 is full damping, so the robot will decelerate quickly if no force is present. A value of 0 is no
damping, here the robot will maintain the speed.
The value is stored until this function is called again. Add this to the beginning of your program to ensure it
is called before force mode is entered (otherwise default value will be used).
e-Series 30 Script Directory
14. Module motion
14.14. force_mode_set_gain_scaling(scaling)
Scales the gain in force mode.
Parameters
scaling:
scaling parameter between 0 and 2, default is 1.
A value larger than 1 can make force mode unstable, e.g. in case of collisions or pushing against hard
surfaces.
The value is stored until this function is called again. Add this to the beginning of your program to ensure it
is called before force mode is entered (otherwise default value will be used).
14.15. freedrive_mode (freeAxes=[1, 1, 1, 1, 1, 1], feature=p
[0, 0, 0, 0, 0, 0])
Set robot in freedrive mode. In this mode the robot can be moved around by hand in the same way as by
pressing the "freedrive" button.
The robot will not be able to follow a trajectory (eg. a movej) in this mode.
The default parameters enables the robot to move freely in all directions. It is possible to enable
Constrained Freedrive by providing user specific parameters.
Parameters
freeAxes: A 6 dimensional vector that contains 0’s and 1’s, these indicates in which axes movement is
allowed. The first three values represents the cartesian directions along x, y, z, and the last three defines
the rotation axis, rx, ry, rz. All relative to the selected feature.
feature: A pose vector that defines a freedrive frame relative to the base frame. For base and tool
reference frames predefined constants "base", and "tool" can be used in place of pose vectors.
Example commands:
• freedrive_mode()
• Robot can move freely in all directions.
• freedrive_mode(freeAxes=[1,0,0,0,0,0], feature=p[0.1,0,0,0,0.785])
• Example Parameters:
• freeAxes = [1,0,0,0,0,0] -> The robot is compliant in the x direction relative to
the feature.
• feature = p[0.1,0,0,0,0.785] -> This feature is offset from the base frame with
100 mm in the x direction and rotated 45 degrees in the rz direction.
• freedrive_mode(freeAxes=[0,1,0,0,0,0], feature="tool")

Script Directory 31 e-Series
14. Module motion
• Example Parameters:
• freeAxes = [0,1,0,0,0,0] the "tool" feature.
-> The robot is compliant in the y direction relative to
• feature = "tool" -> The "tool" feature is located in the active TCP.
Note: Immediately before entering freedrive mode, avoid:
• movements in the non-compliant axes
• high acceleration in freedrive mode
• high deceleration in freedrive mode
High acceleration and deceleration can both decrease the control accuracy and cause protective stops.
14.16. freedrive_mode_no_incorrect_payload_check()

This method, like teach_mode() and freedrive_mode(), changes the robot mode to teach mode, but this
function does not check for an incorrect payload during the initial state change, nor if the payload is
updated during freedrive. For this reason, it is exceedingly important for users to be certain the payload is
correct.
It is possible for the user to exit teach mode/freedrive in the usual manner, using: end_teach_mode() or
end_freedrive_mode()
14.17. get_conveyor_tick_count()
Deprecated: Tells the tick count of the encoder, note that the controller interpolates tick counts to get more
accurate movements with low resolution encoders
Return Value
The conveyor encoder tick count
Deprecated: This function is replaced by encoder_get_tick_count and it should therefore not be
used moving forward.
14.18. get_freedrive_status()
Returns status of freedrive mode for current robot pose.
Constrained freedrive usability is reduced near singularities. Value returned by this function corresponds
to distance to the nearest singularity.
It can be used to advice operator to follow different path or switch to unconstrained freedrive.
Return Value
e-Series 32 Script Directory
14. Module motion
• 0 - Normal operation.
• 1 - Near singularity.
• 2 - Too close to singularity. High movement resistance in freedrive.
14.19. get_target_tcp_pose_along_path()
Query the target TCP pose as given by the trajectory being followed.
This script function is useful in conjunction with conveyor tracking to know what the target pose of the TCP
would be if no offset was applied.
Return Value
Target TCP pose
14.20. get_target_tcp_speed_along_path()
Query the target TCP speed as given by the trajectory being followed.
This script function is useful in conjunction with conveyor tracking to know what the target speed of the
TCP would be if no offset was applied.
Return Value
Target TCP speed as a vector
14.21. movec(pose_via, pose_to, a=1.2, v=0.25, r =0,
mode=0)

Move Circular: Move to position (circular in tool-space)
TCP moves on the circular arc segment from current pose, through pose_via to pose_to. Accelerates to
and moves with constant tool speed v. Use the mode parameter to define the orientation interpolation.
Parameters
pose_via: path point (note: only position is used). Pose_via can also be specified as joint positions, then
forward kinematics is used to calculate the corresponding pose.
pose_to: target pose (note: only position is used in Fixed orientation mode). Pose_to can also be
specified as joint positions, then forward kinematics is used to calculate the corresponding pose.
a: tool acceleration [m/s^2]
v: tool speed [m/s]
r: blend radius (of target pose) [m]
mode:
Script Directory 33 e-Series
14. Module motion
0: Unconstrained mode. Interpolate orientation from current pose to target pose (pose_to)
1: Fixed mode. Keep orientation constant relative to the tangent of the circular arc (starting from current
pose)
Example command: movec(p[x,y,z,0,0,0], pose_to, a=1.2, v=0.25, r=0.05, mode=1)
• Example Parameters:
• Note: first position on circle is previous waypoint.
• pose_via = p[x,y,z,0,0,0] → second position on circle.
• Note: Rotations are not used so they can be left as zeros.
• Note: This position can also be represented as joint angles [j0,j1,j2,j3,j4,j5] then
forward kinematics is used to calculate the corresponding pose
• pose_to → third (and final) position on circle
• a = 1.2 → acceleration is 1.2 m/s/s
• v = 0.25 → velocity is 250 mm/s
• r = 0 → blend radius (at pose_to) is 50 mm.
• mode = 1 → use fixed orientation relative to tangent of circular arc

14.22. movej(q, a=1.4, v=1.05, t=0, r =0)
Move to position (linear in joint-space)
When using this command, the robot must be at a standstill or come from a movej or movel with a blend.
The speed and acceleration parameters control the trapezoid speed profile of the move. Alternatively, the t
parameter can be used to set the time for this move. Time setting has priority over speed and acceleration
settings.
Parameters
q: joint positions (q can also be specified as a pose, then inverse kinematics is used to calculate the
corresponding joint positions)
a: joint acceleration of leading axis [rad/s^2]
v: joint speed of leading axis [rad/s]
t: time [S]
r: blend radius [m]
If a blend radius is set, the robot arm trajectory will be modified to avoid the robot stopping at the point.
However, if the blend region of this move overlaps with the blend radius of previous or following waypoints,
this move will be skipped, and an ’Overlapping Blends’ warning message will be generated.
Example command: movej([0,1.57,-1.57,3.14,-1.57,1.57], a=1.4, v=1.05, t=0,
r=0)
e-Series 34 Script Directory
14. Module motion
• Example Parameters:
• q = [0,1.57,-1.57,3.14,-1.57,1.57] base is at 0 deg rotation, shoulder is at 90 deg rotation,
elbow is at -90 deg rotation, wrist 1 is at 180 deg rotation, wrist 2 is at -90 deg rotation, wrist
3 is at 90 deg rotation. Note: joint positions (q can also be specified as a pose, then inverse
kinematics is used to calculate the corresponding joint positions)
• a = 1.4 → acceleration is 1.4 rad/s/s
• v = 1.05 → velocity is 1.05 rad/s
• t = 0 the time (seconds) to make move is not specified. If it were specified the command
would ignore the a and v values.
• r = 0 → the blend radius is zero meters.
14.23. optimovej(goal, a=0.3, v=0.3, r=0)
Move to the goal position (linear in joint-space)
OptiMove dynamically adapts speed and acceleration to perform smooth motions using jerk-limited speed
profiles. The speed and acceleration parameters control the speed profile of the move. Setting speed and
acceleration parameters to 1 causes the fastest cycle time the robot is capable of. This command is similar
to movej() but with smoother motions with less vibration.
Parameters
goal: (q, pose, struct{pose, frame}, string)- the target for the TCP motion can be defined in
different ways:
• (q) as robot joint positions.
• (pose) as a pose in robot base coordinate frame. The target joint positions will be calculated by
inverse kinematics.
• (struct{pose, frame}) as a pose and the name of a reference coordinate frame. The goal will be set
to this pose in this reference coordinate frame.
• (string) as the name of a world model object. The goal will be set to the object's pose.
a (optional): Joint acceleration as a fraction of what the joints are able to perform - a∈ (0.0,1.0]
v (optional): Joint speed as a fraction of how fast the joints can move during the motion - v∈ (0.0,1.0]
r (optional): Blend radius [m]
If a blend radius is set, the robot arm trajectory will be modified within the blend radius of the destination
position. If the blend region of this move overlaps with the blend radius of previous or following waypoints,
this move will be skipped, and an ’Overlapping Blends’ warning message will be generated in the log
screen.
Example command: optimovej([0, 1.57, -1.57, 3.14, -1.57, 1.57], a=0.4, v=0.6,
r=0.0)
• Example Parameters:
• goal = [0, 1.57, -1.57, 3.14, -1.57, 1.57] → joint positions with base at 0 deg rotation,
shoulder at 90 deg rotation, elbow at -90 deg rotation, wrist 1 at 180 deg rotation, wrist 2 at -
90 deg rotation, wrist 3 at 90 deg rotation.

Script Directory 35 e-Series
14. Module motion
• a = 0.4 → acceleration at either end of the motion is 40% of the acceleration the robot is
capable of producing in the specific joint configuration.
• v = 0.6 → velocity during motion cruise phase is 60% of the velocity the joints can move at.
• r = 0.0 → the blend radius is zero meters, meaning the robot will stop at the waypoint.
Notes:
• The absolute speed and acceleration of the robot depends on the joint configuration during the
move. A value of e.g. 0.4 might therefore produce a faster speed/acceleration in one area of the
robot's workspace and a slower speed/acceleration in another area of the robot's workspace.
Values of 1.0 will always give the highest speed and acceleration that are possible for a given robot
path.
• To avoid high accelerations that can cause dropped items in e.g. suction cup grippers, consider
using the command tool_wrench_limit_set() to limit the acceleration of the items held by the
gripper.
• It is possible to blend into this move type from movej/l and optimovej/l. When coming from other
movement types the robot should be at standstill when starting the move.

14.24. movel(pose, a=1.2, v=0.25, t=0, r=0)
Move to position (linear in tool-space)
See movej.
Parameters
pose: target pose (pose can also be specified as joint positions, then forward kinematics is used to
calculate the corresponding pose)
a: tool acceleration [m/s^2]
v: tool speed [m/s]
t: time [S]
r: blend radius [m]
Example command: movel(pose, a=1.2, v=0.25, t=0, r=0)
• Example Parameters:
• pose = p[0.2,0.3,0.5,0,0,3.14] -> position in base frame of x = 200 mm, y = 300 mm, z = 500
mm, rx = 0, ry = 0, rz = 180 deg
• a = 1.2 -> acceleration of 1.2 m/s^2
• v = 0.25 -> velocity of 250 mm/s
• t = 0 -> the time (seconds) to make the move is not specified.
• If it were specified the command would ignore the a and v values.
• r = 0 -> the blend radius is zero meters.
e-Series 36 Script Directory
14. Module motion
14.25. optimovel(goal, a=0.3, v=0.3, r=0)
Move to the goal position (linear in Cartesian space).
OptiMove dynamically adapts speed and acceleration to perform smooth motions using jerk-limited speed
profiles. The speed and acceleration parameters control the speed profile of the move. Setting speed and
acceleration parameters to 1 causes the fastest cycle time the robot is capable of.
This command is similar to movel() but with smoother motions with less vibration.
Parameters
goal: (q, pose, struct{pose, frame}, string) target for the TCP motion can be defined in
different ways:
• (q) as robot joint positions. The target pose will be calculated by forward kinematics.
• (pose) as a pose in robot base coordinate frame. The target joint positions will be calculated by
inverse kinematics.
• (struct{pose, frame}) as a pose and the name of a reference coordinate frame. The goal will be set
to this pose in this reference coordinate frame.
• (string) as the name of a world model object. The goal will be set to the object's pose.
a (optional): Tool acceleration as a fraction of what the robot is able to perform - a∈ (0.0,1.0]
v (optional): Tool speed as a fraction of the maximum Cartesian velocity the robot can travel at during the
trajectory, given the maximum joint speeds - v∈ (0.0,1.0]
r (optional): Blend radius [m]
If a blend radius is set, the robot arm trajectory will be modified within the blend radius of the destination
position. If the blend region of this move overlaps with the blend radius of previous or following waypoints,
this move will be skipped, and an ’Overlapping Blends’ warning message will be generated.
Example command: optimovel(pose, a=0.4, v=0.6, r=0.0)
• Example Parameters:
• goal = p[0.2, 0.3, 0.5, 0, 0, 3.14] -> position in base frame of x = 200 mm, y = 300 mm, z =500
mm, rx = 0 deg, ry = 0 deg, rz = 180 deg.
• a = 0.4 -> acceleration at either end of the motion is 40% of the acceleration the robot is
capable of producing in the specific joint configuration.
• v = 0.6 -> velocity during motion cruise phase is 60% of the velocity the joints can move at.
• r = 0.0 -> the blend radius is zero meters, meaning the robot will stop at the waypoint.

Notes:
• The absolute speed and acceleration of the robot depends on the joint configuration during the
move. A value of e.g. 0.4 might therefore produce a faster speed/acceleration in one area of the
robot's workspace and a slower speed/acceleration in another area of the robot's workspace
(typically close to singularities). Values of 1.0 will always give the highest speed and acceleration
that are possible for a given robot path.
• To avoid high accelerations that can cause dropped items in e.g. suction cup grippers, consider
using the command tool_wrench_limit_set() to limit the acceleration of the items held by the
Script Directory 37 e-Series
14. Module motion
gripper.
• It is possible to blend into this move type from movej/l and optimovej/l. When coming from other
movement types the robot should be at standstill when starting the move.
14.26. movep(pose, a=1.2, v=0.25, r=0)

Move Process
Blend circular (in tool-space) and move linear (in tool-space) to position. Accelerates to and moves with
constant tool speed v.
Parameters
pose: target pose (pose can also be specified as joint positions, then forward kinematics is used to
calculate the corresponding pose)
a: tool acceleration [m/s^2]
v: tool speed [m/s]
r: blend radius [m]
Example command: movep(pose, a=1.2, v=0.25, r=0)
• Example Parameters:
• pose = p[0.2,0.3,0.5,0,0,3.14] -> position in base frame of x = 200 mm, y = 300 mm, z = 500
mm, rx = 0, ry = 0, rz = 180 deg.
• a = 1.2 -> acceleration of 1.2 m/s^2
• v = 0.25 -> velocity of 250 mm/s
• r = 0 -> the blend radius is zero meters.
14.27. path_offset_disable(a=20)
Disable the path offsetting and decelerate all joints to zero speed.
Uses the stopj functionality to bring all joints to a rest. Therefore, all joints will decelerate at different
rates but reach stand-still at the same time.
Use the script function path_offset_enable to enable path offsetting
Parameters
a: joint acceleration [rad/s^2] (optional)
14.28. path_offset_enable()
Enable path offsetting.
e-Series 38 Script Directory
14. Module motion
Path offsetting is used to superimpose a Cartesian offset onto the robot motion as it follows a trajectory.
This is useful for instance for imposing a weaving motion onto a welding task, or to compensate for the
effect of moving the base of the robot while following a trajectory.
Path offsets can be applied in various frames of reference and in various ways. Please refer to the script
function path_offset_set for further explanation.
Enabling path offsetting doesn’t cancel the effects of previous calls to the script functions path_offset_
set_max_offset and path_offset_set_alpha_filter. Path offset configuration will persist
through cycles of enable and disable.
Using Path offset at the same time as Conveyor Tracking and/or Force can lead to program conflict. Do
not use this function togther with Conveyor Tracking and/or Force.
14.29. path_offset_get(type)
Query the offset currently applied.
Parameters
type: Specifies the frame of reference of the returned offset. Please refer to the path_offset_set
script function for a definition of the possible values and their meaning.
Return Value
Pose specifying the translational and rotational offset. Units are meters and radians.
14.30. path_offset_set(offset, type)

path_offset_set(offset, type)
Specify the Cartesian path offset to be applied.
Use the script function path_offset_enable beforehand to enable offsetting. The calculated offset is
applied during each cycle at 500Hz.
Discontinuous or jerky offsets are likely to cause protective stops. If offsets are not smooth the function
path_offset_set_alpha_filter can be used to engage a simple filter.
The following example uses a harmonic wave (cosine) to offset the position of the TCP along the Z-axis of
the robot base:
>>> thread OffsetThread():
>>> while(True):
>>> # 2Hz cosine wave with an amplitude of 5mm
>>> global x = 0.005*(cos(p) - 1)
>>> global p = p + 4*3.14159/500
>>> path_offset_set([0,0,x,0,0,0], 1)
>>> sync()
Script Directory 39 e-Series
14. Module motion
>>> end
>>> end
Parameters
offset: Pose specifying the translational and rotational offset.
type: Specifies how to apply the given offset. Options are:
1: (BASE) Use robot base coordinates when applying.
2: (TCP) Use robot TCP coordinates when applying.
3: (MOTION) Use a coordinate system following the un-offset trajectory when applying. This coordinate
system is defined as follows. X-axis along the tangent of the translational part of the un-offset trajectory
(rotation not relevant here). Y-axis perpendicular to the X-axis above and the Z-axis of the tool (X cross Z).
Z-axis given from the X and Y axes by observing the right-hand rule. This is useful for instance for
superimposing a weaving pattern onto the trajectory when welding.
4: (WORLD) This can be used to follow a trajectory in world (inertial) space, while the base coordinate
system of the robot is being translated and/or rotated by something external, e.g. a mobile robot or another
robot arm. The offset is thus the pose of the robot base relative to the world coordinate system, and it is
also the world coordinate system which the commanded trajectory should be understood relative to.

14.31. path_offset_set_alpha_filter(alpha)
Engage offset filtering using a simple alpha filter (EWMA) and set the filter coefficient.
When applying an offset, it must have a smooth velocity profile in order for the robot to be able to follow the
offset trajectory. This can potentially be cumbersome to obtain, not least as offset application starts,
unless filtering is applied.
The alpha filter is a very simple 1st order IIR filter using a weighted sum of the commanded offset and the
previously applied offset: filtered_offset= alpha*offset+ (1-alpha)*filtered_offset.
See more details and examples in the UR Support Site: Modify Robot Trajectory
Parameters
alpha: The filter coefficient to be used - must be between 0 and 1.
A value of 1 is equivalent to no filtering.
For welding; experiments have shown that a value around 0.1 is a good compromise between robustness
and offsetting accuracy.
The necessary alpha value will depend on robot calibration, robot mounting, payload mass, payload
center of gravity, TCP offset, robot position in workspace, path offset rate of change and underlying
motion.
14.32. path_offset_set_max_offset(transLimit, rotLimit)
Set limits for the maximum allowed offset.
e-Series 40 Script Directory
14. Module motion
Due to safety and due to the finite reach of the robot, path offsetting limits the magnitude of the offset to be
applied. Use this function to adjust these limits. Per default limits of 0.1 meters and 30 degrees (0.52
radians) are used.
Parameters
transLimit: The maximum allowed translational offset distance along any axis in meters.
rotLimit: The maximum allowed rotational offset around any axis in radians.
14.33. pause_on_error_code(code, argument)
Makes the robot pause if the specified error code occurs. The robot will only pause during program
execution.
This setting is reset when the program is stopped. Call the command again before/during program
execution to re-enable it.
>>> pause_on_error_code(173, 3)
In the above example, the robot will pause on errors with code 173 if its argument equals 3 (corresponding
to ’C173A3’ in the log).
>>> pause_on_error_code(173)
In the above example, the robot will pause on error code 173 for any argument value.
Parameters
code: The code of the error for which the robot should pause (int)
argument: The argument of the error. If this parameter is omitted the robot will pause on any argument
for the specified error code (int)
Notes:
• Error codes appear in the log as CxAy where 'x' is the code and 'y' is the argument.

14.34. position_deviation_warning(enabled,
threshold=0.8)
When enabled, this function generates warning messages to the log when the robot deviates from the
target position. This function can be called at any point in the execution of a program. It has no return
value.
>>> position_deviation_warning(True)
In the above example, the function has been enabled. This means that log messages will be generated
whenever a position deviation occurs. The optional "threshold" parameter can be used to specify the level
of position deviation that triggers a log message.
Parameters
enabled: (Boolean) Enable or disable position deviation log messages.
Script Directory 41 e-Series
14. Module motion
threshold: (Float) Optional value in the range [0;1], where 0 is no position deviation and 1 is the maximum
position deviation (equivalent to the amount of position deviation that causes a protective stop of the
robot). If no threshold is specified by the user, a default value of 0.8 is used.
Example command: position_deviation_warning(True, 0.8)
• Example Parameters:
• Enabled = True → Logging of warning is turned on
• Threshold = 0.8 80% of deviation that causes a protective stop causes a warning to be
logged in the log history file.
14.35. reset_revolution_counter(qNear=[0.0, 0.0, 0.0,
0.0, 0.0, 0.0])

Reset the revolution counter, if no offset is specified. This is applied on joints which safety limits are set to
"Unlimited" and are only applied when new safety settings are applied with limitted joint angles.
>>> reset_revolution_counter()
Parameters
qNear: Optional parameter, reset the revolution counter to one close to the given qNear joint vector. If not
defined, the joint’s actual number of revolutions are used.
Example command: reset_revolution_counter(qNear=[0.0, 0.0, 0.0, 0.0, 0.0,
0.0])
• Example Parameters:
• qNear = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0] -> Optional parameter, resets the revolution counter of
wrist 3 to zero on UR3 robots to the nearest zero location to joint rotations represented by
qNear.
14.36. screw_driving(f, v_limit)
Enter screw driving mode. The robot will exert a force in the TCP Z-axis direction at limited speed. This
allows the robot to follow the screw during tightening/loosening operations.
Parameters
f: The amount of force the robot will exert along the TCP Z-axis (Newtons).
v_limit: Maximum TCP velocity along the Z axis (m/s).
Notes:
Zero the F/T sensor without the screw driver pushing against the screw.
Call end_screw_driving when the screw driving operation has completed.
>>> def testScrewDriver():
>>> # Zero F/T sensor
e-Series 42 Script Directory
14. Module motion
>>> zero_ftsensor()
>>> sleep(0.02)
>>>
>>> # Move the robot to the tightening position
>>> # (i.e. just before contact with the screw)
>>>
...
>>>
>>> # Start following the screw while tightening
>>> screw_driving(5.0, 0.1)
>>>
>>> # Wait until screw driver reports OK or NOK
>>>
...
>>>
>>> # Exit screw driving mode
>>> end_screw_driving()
>>> end
14.37. servoj(q, a, v, t=0.002, lookahead_time=0.1,
gain=300)

Servoj can be used for online realtime control of joint positions.
The gain parameter works the same way as the P-term of a PID controller, where it adjusts the current
position towards the desired (q). The higher the gain, the faster reaction the robot will have.
The parameter lookahead_time is used to project the current position forward in time with the current
velocity. A low value gives fast reaction, a high value prevents overshoot.
Note: A high gain or a short lookahead time may cause instability and vibrations. Especially if the target
positions are noisy or updated at a low frequency
It is preferred to call this function with a new setpoint (q) in each time step (thus the default t=0.002)
You can combine with the script command get_inverse_kin() to perform servoing based on cartesian
positions:
>>> q = get_inverse_kin(x)
>>> servoj(q, lookahead_time=0.05, gain=500)
Here x is a pose variable with target cartesian positions, received over a socket or RTDE registers.
Example command: servoj([0.0,1.57,-1.57,0,0,3.14], 0, 0, 0.002, 0.1, 300)
Script Directory 43 e-Series
14. Module motion
• Example Parameters:
• q = [0.0,1.57,-1.57,0,0,3.14] shoulder, elbow, wrist1, wrist2 and wrist3
joint angles in radians representing rotations of base,
• a = 0 → not used in current version
• v = 0 → not used in current version
• t = 0.002 t [S].
• lookahead time = .1 time
time where the command is controlling the robot. The function is blocking for time
time [S], range [0.03,0.2] smoothens the trajectory with this lookahead
• gain = 300 proportional gain for following target position, range [100,2000]
14.38. set_conveyor_tick_count(tick_count, absolute_
encoder_resolution=0)

Deprecated:Tells the robot controller the tick count of the encoder. This function is useful for absolute
encoders, use conveyor_pulse_decode() for setting up an incremental encoder. For circular conveyors,
the value must be between 0 and the number of ticks per revolution.
Parameters
tick_count:
Tick count of the conveyor (Integer)
absolute_encoder_resolution:
Resolution of the encoder, needed to handle wrapping nicely. (Integer)
0 is a 32 bit signed encoder, range [-2147483648 ; 2147483647] (default)
1 is a 8 bit unsigned encoder, range [0 ; 255]
2 is a 16 bit unsigned encoder, range [0 ; 65535]
3 is a 24 bit unsigned encoder, range [0 ; 16777215]
4 is a 32 bit unsigned encoder, range [0 ; 4294967295]
Deprecated: This function is replaced by encoder_set_tick_count and it should therefore not be used
moving forward.
Example command: set_conveyor_tick_count(24543, 0)
• Example Parameters:
• Tick_count = 24543 absolute encoder
a value read from e.g. a MODBUS register being updated by the
• Absolute_encoder_resolution = 0 ;2147483647] (default)
0 is a 32 bit signed encoder, range [-2147483648
e-Series 44 Script Directory
14. Module motion
14.39. set_pos(q)
Set joint positions of simulated robot
Parameters
q: joint positions
Example command: set_pos([0.0,1.57,-1.57,0,0,3.14])
• Example Parameters:
• q = [0.0,1.57,-1.57,0,0,3.14] -> the position of the simulated robot with joint angles in radians
representing rotations of base, shoulder, elbow, wrist1, wrist2 and wrist3
14.40. set_safety_mode_transition_hardness(type)
Sets the transition hardness between normal mode, reduced mode and safeguard stop.
Parameters
type:
An integer specifying transition hardness.
0 is hard transition between modes using maximum torque, similar to emergency stop.
1 is soft transition between modes.
14.41. speedj(qd, a, t)

Joint speed
Accelerate linearly in joint space and continue with constant joint speed. The time t is optional; if provided
the function will return after time t, regardless of the target speed has been reached. If the time t is not
provided, the function will return when the target speed is reached.
Parameters
qd: joint speeds [rad/s]
a: joint acceleration [rad/s^2] (of leading axis)
t: time [s] before the function returns (optional)
Example command: speedj([0.2,0.3,0.1,0.05,0,0], 0.5, 0.5)
• Example Parameters:
• qd -> Joint speeds of: base=0.2 rad/s, shoulder=0.3 rad/s, elbow=0.1 rad/s, wrist1=0.05
rad/s, wrist2 and wrist3=0 rad/s
• a = 0.5 rad/s^2 -> acceleration of the leading axis (shoulder in this case)
• t = 0.5 s -> time before the function returns
Script Directory 45 e-Series
14. Module motion
14.42. speedl(xd, a, t, aRot=’a’)
Cartecian velocity control
Accelerate linearly in Cartesian space and continue with constant tool speed. The time t is optional; if
provided the function will return after time t, regardless of the target speed has been reached. If the time t
is not provided, the function will return when the target speed is reached.
Parameters
xd: tool speed [m/s] (spatial vector)
a: tool positional acceleration [m/s^2]
t: time [s] before function returns (optional)
aRot: tool rotational acceleration [rad/s^2] (optional). If not defined, position acceleration value in
[rad/s^2] will be used
Example command: speedl([0.5,0.4,0,1.57,0,0], 0.5, 0.5)
• Example Parameters:
• xd -> Tool speeds of: x=500 mm/s, y=400 mm/s, rx=90 deg/s, ry and rz=0 deg/s
• a = 0.5 m/s^2 -> acceleration of the tool
• t = 0.5 s -> time before the function returns

14.43. stop_conveyor_tracking(a=20)
Stop tracking the conveyor, started by track_conveyor_linear() or track_conveyor_circular(), and
decelerate all joint speeds to zero.
Parameters
a: joint acceleration [rad/s^2] (optional)
Example command: stop_conveyor_tracking(a=15)
• Example Parameters:
• a = 15 rad/s^2 -> acceleration of the joints
14.44. stopj(a)
Stop (linear in joint space)
Decelerate joint speeds to zero
Parameters
a: joint acceleration [rad/s^2] (of leading axis)
Example command: stopj(2)
e-Series 46 Script Directory
14. Module motion
• Example Parameters:
• a = 2 rad/s^2 -> rate of deceleration of the leading axis.
14.45. stopl(a, aRot=’a’)
Stop (linear in tool space)
Decelerate tool speed to zero
Parameters
a: tool accleration [m/s^2]
aRot: tool acceleration [rad/s^2] (optional), if not defined a, position acceleration, is used
Example command: stopl(20)
• Example Parameters:
• a = 20 m/s^2 -> rate of deceleration of the tool
• aRot -> tool deceleration [rad/s^2] (optional), if not defined, position acceleration, is used.
i.e. it supersedes the "a" deceleration.
14.46. tool_wrench_limit_set(frame_offset, Fx, Fy, Fz,
Mx, My, Mz)

Limit the wrench (forces and torques) caused by motion of the robot in a frame given relative to the tool
flange. The wrench is limited in normal and reduced mode operation, as well as during protective stops,
safeguard stops, 3PE stops and emergency stops. For this reason, it can affect robot motion speed to
ensure adherence to safety limits. Usage can help prevent dropping items by limiting accelerations as well
as reducing wrench applied to the attached tool.
This limitation does not affect the forces and torques that can be applied in force control.
Parameters:
frame_offset: Pose specifying frame relative to the tool flange similarly to how the TCP offset is
specified. The first three coordinates specify translational offset along the x- y- and z-axis in meters. The
last three specify the rotational offset using the axis-angle representation in radians.
Fx (optional): Float, setting maximum acceleration force along the X-axis in the specified frame.
Fy (optional): Float, setting maximum acceleration force along the Y-axis in the specified frame.
Fz (optional): Float, setting maximum acceleration force along the Z-axis in the specified frame.
Mx (optional): Float, setting maximum acceleration torque around the X-axis in the specified frame.
My (optional): Float, setting maximum acceleration torque around the Y-axis in the specified frame.
Mz (optional): Float, setting maximum acceleration torque around the Z-axis in the specified frame.
Any optional parameter not specified means the axis is only limited by standard robot limitations.
Script Directory 47 e-Series
14. Module motion
Example command: tool_wrench_limit_set(p[0, 0, 0.1, 0, 0, 1.57], Mx=10, My=15)
Example Parameters:
• frame_offset = p[0, 0, 0.1, 0, 0, 1.57] → limitation will be applied in a frame offset 10 cm in front of
the tool flange rotated by 45 degrees around the axis of displacement.
• Mx = 10 → acceleration torque will be limited to 10 Nm around the X-axis in the specified frame.
• My = 15 → acceleration torque will be limited to 15 Nm around the Y-axis in the specified frame.
Remaining forces and torques will not be limited by this algorithm.
Example command: tool_wrench_limit_set(get_tcp_offset(), Fz=50)
Example Parameters:
• frame_offset is equal to the active TCP offset.
• Fz = 50 → acceleration force is limited such that force does not exceed 50 N along the Z-axis in the
TCP frame.

NOTICE
The set limit is persisted until shutdown of the controller or until explicitly disabled by
executing tool_wrench_limit_disable().
14.47. tool_wrench_limit_disable()
Disable tool wrench limitation set by tool_wrench_limit_set.
14.48. teach_mode()
Deprecated :
Set robot in freedrive mode. In this mode the robot can be moved around by hand in the same way as by
pressing the "freedrive" button.
The robot will not be able to follow a trajectory (eg. a movej) in this mode.
Deprecated :
This function is replaced by freedrive_mode and it should therefore not be used moving forward.
14.49. track_conveyor_circular(center, ticks_per_
revolution, rotate_tool=’False’, encoder_index=0)
Makes robot movement (movej() etc.) track a circular conveyor.
>>> track_conveyor_circular(p[0.5,0.5,0,0,0,0],500.0, false)
e-Series 48 Script Directory
14. Module motion
The example code makes the robot track a circular conveyor with center in p[0.5,0.5,0,0,0,0] of the robot
base coordinate system, where 500 ticks on the encoder corresponds to one revolution of the circular
conveyor around the center.
Parameters
center: Pose vector that determines center of the conveyor in the base coordinate system of the robot.
ticks_per_revolution: How many ticks the encoder sees when the conveyor moves one revolution.
rotate_tool: Should the tool rotate with the coneyor or stay in the orientation specified by the trajectory
(movel() etc.).
encoder_index: The index of the encoder to associate with the conveyor tracking. Must be either 0 or
1. This is an optional argument, and please note the default of 0. The ability to omit this argument will allow
existing programs to keep working. Also, in use cases where there is just one conveyor to track consider
leaving this argument out.
Example command: track_conveyor_circular(p[0.5,0.5,0,0,0,0], 500.0, false)
• Example Parameters:
• center = p[0.5,0.5,0,0,0,0] • ticks_per_revolution = 500 location of the center of the conveyor
the number of ticks the encoder sees when the conveyor moves
one revolution
• rotate_tool = false specified by the trajectory (movel() etc.).
the tool should not rotate with the conveyor, but stay in the orientation
14.50. track_conveyor_linear(direction, ticks_per_meter,
encoder_index=0)

Makes robot movement (movej() etc.) track a linear conveyor.
>>> track_conveyor_linear(p[1,0,0,0,0,0],1000.0)
The example code makes the robot track a conveyor in the x-axis of the robot base coordinate system,
where 1000 ticks on the encoder corresponds to 1m along the x-axis.
Parameters
direction: Pose vector that determines the direction of the conveyor in the base coordinate system of
the robot
ticks_per_meter: How many ticks the encoder sees when the conveyor moves one meter
encoder_index: The index of the encoder to associate with the conveyor tracking. Must be either 0 or 1.
This is an optional argument, and please note the default of 0. The ability to omit this argument will allow
existing programs to keep working. Also, in use cases where there is just one conveyor to track consider
leaving this argument out.
Example command: track_conveyor_linear(p[1,0,0,0,0,0], 1000.0)
Script Directory 49 e-Series
14. Module motion
• Example Parameters:
• direction = p[1,0,0,0,0,0] Pose vector that determines the direction of the conveyor in the
base coordinate system of the robot
• ticks_per_meter = 1000. How many ticks the encoder sees when the conveyor moves one
meter.