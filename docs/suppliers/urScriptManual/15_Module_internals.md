15. Module internals
15.1. force()
Returns the force exerted at the TCP
Return the current externally exerted force at the TCP. The force is the norm of Fx, Fy, and Fz calculated
using get_tcp_force().
Return Value
The force in Newton (float)
Note: Refer to force_mode() for taring the sensor.
15.2. estimate_payload(poses, wrenches)
Parameters
• poses - A list of at least four TCP poses. The orientation of the poses should be as varied as
possible, in order to get a good estimate.
If the rotational distance between any two poses is less than Pi / (2*n) radians, where n is the
number of poses in poses, an exception will be thrown.
• TCP poses can be recorded with get_actual_tcp_pose().
wrenches - A list of wrenches resulting from gravity acting on the payload. Must have the same
length as poses. Each wrench in wrenches should be measured at the corresponding pose in
poses. The wrenches must be given at the tool flange but in robot base orientation. Wrenches in the
required orientation can be recorded with get_tcp_force() when in the desired pose.
Return value:
struct[mass, cog]
mass is a double representing the weight of the payload in kg.
cog is a 3d vector representing the offset from the tool flange to the payload center of
gravity in tool frame in meters.

Example usage (question)
repeat n times
movej(*some distinct pose*)
sleep(*long enough for the arm to stabilize*)
pose_list.append(get_tcp_force)
wrench_list.append(get_actual_tcp_pose)
payload = estimate_payload(pose_list, wrench_list)
set_payload(payload.mass, payload.cog)
Script Directory 51 e-Series
15. Module internals
15.3. get_actual_joint_positions()
Returns the actual angular positions read by the joint encoders
The angular actual positions are expressed in radians and returned as a vector of length 6. Note that the
output might differ from the output of get_target_joint_positions(), especially during
acceleration and heavy loads.
Return Value
The current actual joint angular position vector in rad : [Base, Shoulder, Elbow, Wrist1, Wrist2, Wrist3]
15.4. get_actual_joint_positions_history(steps=0)

Returns the actual past angular positions of all joints
This function returns the angular positions as reported by the function "get_actual_joint_
positions()" which indicates the number of controller time steps occurring before the current time
step.
An exception is thrown if indexing goes beyond the buffer size.
Parameters
steps: The number of controller time steps required to go back. 0 corresponds to "get_actual_
joint_positions()"
Return Value
The joint angular position vector in rad : [Base, Shoulder, Elbow, Wrist1, Wrist2, Wrist3] that was actual at
the provided number of steps before the current time step.
15.5. get_actual_joint_speeds()
Returns the actual angular velocities of all joints
The angular actual velocities are expressed in radians pr. second and returned as a vector of length 6.
Note that the output might differ from the output of get_target_joint_speeds(), especially during
acceleration and heavy loads.
Return Value
The current actual joint angular velocity vector in rad/s: [Base, Shoulder, Elbow, Wrist1, Wrist2, Wrist3]
15.6. get_actual_tcp_pose()
Returns the current measured tool pose
e-Series 52 Script Directory
15. Module internals
Returns the 6d pose representing the tool position and orientation specified in the base frame. The
calculation of this pose is based on the actual robot encoder readings.
Return Value
The current actual TCP vector [X, Y, Z, Rx, Ry, Rz]
15.7. get_actual_tcp_speed()
Returns the current measured TCP speed
The speed of the TCP retuned in a pose structure. The first three values are the cartesian speeds along
x,y,z, and the last three define the current rotation axis, rx,ry,rz, and the length |rz,ry,rz| defines the
angular velocity in radians/s.
Return Value
The current actual TCP velocity vector [X, Y, Z, Rx, Ry, Rz]
15.8. get_actual_tool_flange_pose()
Returns the current measured tool flange pose
Returns the 6d pose representing the tool flange position and orientation specified in the base frame,
without the Tool Center Point offset. The calculation of this pose is based on the actual robot encoder
readings.
Return Value
The current actual tool flange vector: [X, Y, Z, Rx, Ry, Rz]
Note: See get_actual_tcp_pose for the actual 6d pose including TCP offset.

15.9. get_base_acceleration()
Returns the robot base acceleration vector (see set_base_acceleration) currently active in the controller
and SCB kinematics and dynamics models.
Return Value
User specified robot base acceleration vector in m/s^2 as a 3D vector ([float, float, float])
15.10. get_controller_temp()
Returns the temperature of the control box
Script Directory 53 e-Series
15. Module internals
The temperature of the robot control box in degrees Celcius.
Return Value
A temperature in degrees Celcius (float)
15.11. get_forward_kin(q=’current_joint_positions’,
tcp=’active_tcp’)

Calculate the forward kinematic transformation (joint space -> tool space) using the calibrated robot
kinematics. If no joint position vector is provided the current joint angles of the robot arm will be used. If no
tcp is provided the currently active tcp of the controller will be used.
Parameters
q: joint position vector (Optional)
tcp: tcp offset pose (Optional)
Return Value
tool pose
Example command: get_forward_kin([0.,3.14,1.57,.785,0,0], p[0,0,0.01,0,0,0])
• Example Parameters:
• q = [0.,3.14,1.57,.785,0,0] -> joint angles of j0=0 deg, j1=180 deg, j2=90 deg, j3=45 deg,
j4=0 deg, j5=0 deg.
• tcp = p[0,0,0.01,0,0,0] -> tcp offset of x=0mm, y=0mm, z=10mm and rotation vector of rx=0
deg., ry=0 deg, rz=0 deg.
15.12. get_gravity()
Returns the gravity acceleration vector (see set_gravity) currently active in the controller and SCB
kinematics and dynamics models.
Return Value
User specified gravity acceleration vector in m/s^2 as a 3D vector ([float, float, float])
15.13. get_inverse_kin(x, qnear, maxPositionError =1e-
10,maxOrientationError =1e-10, tcp=’active_tcp’)
Calculate the inverse kinematic transformation (tool space -> joint space). If qnear is defined, the solution
closest to qnear is returned.
e-Series 54 Script Directory
15. Module internals
Otherwise, the solution closest to the current joint positions is returned. If no tcp is provided the currently
active tcp of the controller is used.
Parameters
x: tool pose
qnear: list of joint positions (Optional)
maxPositionError: the maximum allowed position error (Optional)
maxOrientationError: the maximum allowed orientation error (Optional)
tcp: tcp offset pose (Optional)
Return Value
joint positions
Example command: get_inverse_kin(p[.1,.2,.2,0,3.14,0], [0.,3.14,1.57,.785,0,0])
• Example Parameters:
• x = p[.1,.2,.2,0,3.14,0] -> pose with position of x=100mm, y=200mm, z=200mm and rotation
vector of rx=0 deg., ry=180 deg, rz=0 deg.
• qnear = [0.,3.14,1.57,.785,0,0] -> solution should be near to joint angles of j0=0 deg, j1=180
deg, j2=90 deg, j3=45 deg, j4=0 deg, j5=0 deg.
• maxPositionError is by default 1e-10 m
• maxOrientationError is by default 1e-10 rad
15.14. get_inverse_kin_has_solution(pose, qnear,
maxPositionError=1E-10, maxOrientationError=1e-10,
tcp="active_tcp")

Check if get_inverse_kin has a solution and return boolean (True) or (False).
This can be used to avoid the runtime exception of get_inverse_kin when no solution exists.
Parameters
pose: tool pose
qnear: list of joint positions (Optional)
maxPositionError: the maximum allowed position error (Optional)
maxOrientationError: the maximum allowed orientation error (Optional)
tcp: tcp offset pose (Optional)
Return Value
True if get_inverse_kin has a solution, False otherwise (bool)
Script Directory 55 e-Series
15. Module internals
15.15. get_joint_temp(j)
Returns the temperature of joint j
The temperature of the joint house of joint j, counting from zero. j=0 is the base joint, and j=5 is the last
joint before the tool flange.
Parameters
j: The joint number (int)
Return Value
A temperature in degrees Celcius (float)
15.16. get_joint_torques()

Returns the torques of all joints
The torque on the joints, corrected by the torque needed to move the robot itself (gravity, friction, etc.),
returned as a vector of length 6.
Return Value
The joint torque vector in Nm: [Base, Shoulder, Elbow, Wrist1, Wrist2, Wrist3]
15.17. get_steptime()
Returns the duration of the robot time step in seconds.
In every time step, the robot controller will receive measured joint positions and velocities from the robot,
and send desired joint positions and velocities back to the robot. This happens with a predetermined
frequency, in regular intervals. This interval length is the robot time step.
Return Value
duration of the robot step in seconds
15.18. get_target_joint_positions()
Returns the desired angular positions that are sent to all the joints at each time step
The angular target positions are expressed in radians and returned as a vector of length 6. Note that the
output might differ from the output of get_actual_joint_positions(), especially during acceleration and
heavy loads.
Return Value
The current target joint angular position vector in rad: [Base, Shoulder, Elbow, Wrist1, Wrist2, Wrist3]
e-Series 56 Script Directory
15. Module internals
15.19. get_target_joint_speeds()
Returns the desired angular velocities of all joints
The angular target velocities are expressed in radians pr. second and returned as a vector of length 6.
Note that the output might differ from the output of get_actual_joint_speeds(), especially during
acceleration and heavy loads.
Return Value
The current target joint angular velocity vector in rad/s: [Base, Shoulder, Elbow, Wrist1, Wrist2, Wrist3]
15.20. get_target_payload()
Returns the weight of the active payload
Return Value
The weight of the current payload in kilograms
15.21. get_target_payload_cog()
Retrieve the Center Of Gravity (COG) coordinates of the active payload.
This scripts returns the COG coordinates of the active payload, with respect to the tool flange
Return Value
The 3d coordinates of the COG [CoGx, CoGy, CoGz] in meters
15.22. get_target_payload_inertia()

Returns the most recently set payload inertia matrix.
This script function returns the inertia matrix of the active payload in tool flange coordinates, with origin at
the CoG.
Return Value
The six dimensional coordinates of the payload inertia matrix [Ixx, Iyy, Izz, Ixy, Ixz, Iyz] expressed in
kg*m^2.
Script Directory 57 e-Series
15. Module internals
15.23. get_target_tcp_pose()
Returns the current target tool pose
Returns the 6d pose representing the tool position and orientation specified in the base frame. The
calculation of this pose is based on the current target joint positions.
Return Value
The current target TCP vector [X, Y, Z, Rx, Ry, Rz]
15.24. get_target_tcp_speed()

Returns the current target TCP speed
The desired speed of the TCP returned in a pose structure. The first three values are the cartesian speeds
along x,y,z, and the last three define the current rotation axis, rx,ry,rz, and the length |rz,ry,rz| defines the
angular velocity in radians/s.
Return Value
The TCP speed (pose)
15.25. get_target_waypoint()
Returns the target waypoint of the active move
This is different from the get_target_tcp_pose() which returns the target pose for each time step. The get_
target_waypoint() returns the same target pose for movel, movej, movep or movec during the motion. It
returns the same as get_target_tcp_pose(), if none of the mentioned move functions are running.
This method is useful for calculating relative movements where the previous move command uses blends.
Return Value
The desired waypoint TCP vector [X, Y, Z, Rx, Ry, Rz]
15.26. get_tcp_force()
Returns the force/torque vector at the tool flange.
The function returns p[Fx(N), Fy(N), Fz(N), TRx(Nm), TRy(Nm), TRz(Nm)] where the forces: Fx, Fy, and
Fz in Newtons and the torques: TRx, TRy and TRz in Newtonmeters are all measured at the tool flange
with the orientation of the robot base coordinate system.
Return Value
The force/torque vector
e-Series 58 Script Directory
15. Module internals
Note:
Refer to zero_ftsensor() for taring sensor.
Example:
def get_wrench_at_tool_flange():
ft = get_tcp_force()
t_flange_in_base
= pose_trans(get_target_tcp_pose(), pose_inv(get_tcp_offset())) flange_rot
= pose_inv(p[0, 0, 0, t_flange_in_base[3], t_flange_in_base[4], t_flange_in_
base[5]])
f = pose_trans(flange_rot, p[ft[0], ft[1], ft[2], 0, 0, 0])
t = pose_trans(flange_rot, p[ft[3], ft[4], ft[5], 0, 0, 0])
return [f[0], f[1], f[2], t[0], t[1], t[2]]
end
def get_wrench_at_tcp():
return wrench_trans(get_tcp_offset(), get_wrench_at_tool_flange())
end
15.27. get_tcp_offset()
Gets the active tcp offset, i.e. the transformation from the output flange coordinate system to the TCP as a
pose.
Return Value
tcp offset pose

15.28. get_tool_accelerometer_reading()
Returns the current reading of the tool accelerometer as a three-dimensional vector.
The accelerometer axes are aligned with the tool coordinates, and pointing an axis upwards results in a
positive reading.
Return Value
X, Y, and Z composant of the measured acceleration in SI-units (m/s^2).
Script Directory 59 e-Series
15. Module internals
15.29. get_tool_current()
Returns the tool current
The tool current consumption measured in ampere.
Return Value
The tool current in ampere.
15.30. get_tool_temp()
Returns the most recently measured temperature of the tool.
Return Value
Measured tool temperature in degrees Celcius (float)

15.31. high_holding_torque_disable()
Disables automatically applying high hold torque when the robot is stationary, which is the default
behavior. The UR controller automatically applies high holding torque when the following is true:
• The program state is PROGRAM_STATE_RUNNING
• All actual joint movement <= 0.01 rad/s
• All target joint velocities == 0
Parameters:
None
Example command:
high_holding_torque_disable()
This function script disables the high holding torque behavior. Note that the default is restored to enabled
after restarting the controller.
See also:
high_holding_torque_enable()
Applications: Disable high holding torque if you want a stationary robot to issue a protective stop when
colling with an object. For example, if the robot is being transported on a linear rail or vertical lift. However,
if just the base of the robot collides with an object while moving, the protective stop may not be issued.
Adequate safety precautions should be put in place to guard against this situation.
e-Series 60 Script Directory
15. Module internals
15.32. high_holding_torque_enable()
Enables high hold torque when the robot is stationary. This function is used to reverse the behavior of the
high_holding_torque_disable() command.
Parameters:
None
Example command:
high_holding_torque_enable()
See also
high_holding_torque_disable()
15.33. is_steady()
The function will return true when the robot has been standing still with zero target velocity for 500ms
When the function returns true, the robot is able to adapt to large external forces and torques, e.g. from
screwdrivers, without issuing a protective stop.
Return Value
True when the robot able to adapt to external forces, false otherwise (bool)
15.34. is_within_safety_limits(position, qNear=current
joint configuration)

Checks if the given pose or joint positions are reachable and within the currently active safety limits of the
robot.
This check considers:
• Joint position limits
• Safety planes
• Tool orientation limit
• Physical range of the robot
Parameters
position: Pose or joint positions. When a pose is provided, it is recommended to also supply qNear to
ensure that the correct inverse kinematics solution is checked.
Script Directory 61 e-Series
15. Module internals
qNear: List of joint angles (optional). Only used for calculating inverse kinematics when position is a pose.
If not specified, the current joint positions are used.
Return Value
True if within limits, false otherwise (bool).
NOTICE
In order to simply check if a pose is physically reachable by the robot, use get_inverse_
kin_has_solution instead.
15.35. popup(s, title=’Popup’, warning=False,
error=False, blocking=False)

Display popup on GUI
Display message in popup window on GUI.
Parameters
s: message string
title: title string
warning: warning message?
error: error message?
blocking: if True, program will be suspended until "continue" is pressed
Example command: popup("here I am", title="Popup #1",blocking=True)
• Example Parameters:
• s popup text is "here I am"
• title popup title is "Popup #1"
• blocking = true -> popup must be cleared before other actions will be performed.
15.36. powerdown()
Shut down the robot, and power off the robot and controller.
15.37. protective_stop()
Trigger a protective stop, pausing the program and stopping motion on the planned trajectory.
Notes:
e-Series 62 Script Directory
15. Module internals
This function is not intended for use for simply pausing the running program (see Special keywords:
pause).
15.38. set_base_acceleration(a)
Sets the acceleration of the robot base. This function is used when the robot is attached to a moving base
such a linear rail or vertical lift. Specifying the base acceleration is used to prevent premature protective
stops by informing the control system that forces are being exerted on the robot through acceleration of
the base.
Parameters
a: the linear acceleration of the base in x, y, z directions
Example command:
set_base_acceleration([0.10 0.0 0.0])
Example Parameters:
a = [0.10 0 0] specifies acceleration in the linear X direction of 0.10 m/s²
15.39. set_baselight_off()
NOTICE
Only applies to UR20 / UR30
Turns the baselight completely off.

15.40. set_baselight_iec()
NOTICE
Only applies to UR20 / UR30
Make the baselight comply to the IEC 60204-1 standard and indicate whether the robot is in a safety stop,
in freedrive as well as the operational mode. Further details of the colors can be seen in the UR20 manual.
Script Directory 63 e-Series
15. Module internals
15.41. set_baselight_solid(r,g,b)
NOTICE
Only applies to UR20 / UR30
Set a color on the entire baselight ring as specified by the given RGB values in the range 0-255.
15.42. set_gravity(d)

Set the direction of the acceleration experienced by the robot. When the robot mounting is fixed, this
corresponds to an accleration of g away from the earth’s centre.
>>> set_gravity([0, 9.82*sin(theta), 9.82*cos(theta)])
will set the acceleration for a robot that is rotated "theta" radians around the x-axis of the robot base
coordinate system
Parameters
d: 3D vector, describing the direction of the gravity, relative to the base of the robot.
Example command: set_gravity[(0,9.82,0)]
• Example Parameters:
(1g).
• d is vector with a direction of y (direction of the robot cable) and a magnitude of 9.82 m/s^2
15.43. set_payload(m, cog)
Parameters
m: mass in kilograms
cog: Center of Gravity, a vector [CoGx, CoGy, CoGz] specifying the displacement (in meters) from the
toolmount.
Deprecated: See set_target_payload to set mass, CoG and payload inertia matrix at the same time.
Set payload mass and center of gravity while resetting payload inertia matrix
Sets the mass and center of gravity (abbr. CoG) of the payload.
This function must be called, when the payload mass or mass CoG offset changes - i.e. when the robot
picks up or puts down a workpiece.
Note: The force torque measurements are automatically zeroed when setting the payload. That ensures
the readings are compensated for the payload. This is similar to the behavior of zero_ftsensor()
Warnings:
e-Series 64 Script Directory
15. Module internals
• This script is deprecated since SW 5.10.0 because of the risk of inconsistent payload parameters.
Use the set_target_payload instead to set mass, CoG and inertia matrix.
• Omitting the cog parameter is not recommended. The Tool Center Point (TCP) will be used if the
cog parameter is missing with the side effect that later calls to set_tcp will change also the CoG to
the new TCP. Use the set_payload_mass function to change only the mass or use the get_
target_payload_cog as second argument to not change the CoG.
• Using this script function to modify payload parameters will reset the payload inertia matrix.
Example command:
• set_payload(3., [0,0,.3])
• Example Parameters:
• m = 3 → mass is set to 3 kg payload
• cog = [0,0,.3] Center of Gravity is set to x=0 mm, y=0 mm, z=300 mm from the
center of the tool mount in tool coordinates
• set_payload(2.5, get_target_payload_cog())
• Example Parameters:
• m = 2.5 → mass is set to 2.5 kg payload
• cog = use the current COG setting
15.44. set_payload_cog(CoG)
Deprecated: See set_target_payload to set mass, CoG and payload inertia matrix at the same time.
Set the Center of Gravity (CoG) and reset payload inertia matrix
Warning: Using this script function to modify payload parameters will reset the payload inertia matrix.
Note: The force torque measurements are automatically zeroed when setting the payload. That ensures
the readings are compensated for the payload. This is similar to the behavior of zero_ftsensor()

15.45. set_payload_mass(m)
Parameters
m: mass in kilograms
Deprecated: See set_target_payload to set mass, CoG and payload inertia matrix at the same time.
Set payload mass and reset payload inertia matrix
See also set_payload.
Sets the mass of the payload and leaves the center of gravity (CoG) unchanged.
Note: The force torque measurements are automatically zeroed when setting the payload. That ensures
the readings are compensated for the payload. This is similar to the behavior of zero_ftsensor()
Warnings:
Script Directory 65 e-Series
15. Module internals
• This script is deprecated since SW 5.10.0 because of the risk of inconsistent payload parameters.
Use the set_target_payload instead to set mass, CoG and inertia matrix.
• Using this script function to modify payload parameters will reset the payload inertia matrix.
15.46. set_target_payload(m, cog, inertia=[0, 0, 0, 0, 0,
0], transition_time=0)

Sets the mass, CoG (center of gravity), the inertia matrix of the active payload and the transition time for
applying new settings.
This function must be called when the payload mass, the mass displacement (CoG) or the inertia matrix
changes - (i.e. when the robot picks up or puts down a workpiece).
Parameters
m: mass in kilograms.
cog: Center of Gravity, a vector with three elements [CoGx, CoGy, CoGz] specifying the offset (in meters)
from the tool mount.
inertia: payload inertia matrix (in kg*m^2), as a vector with six elements [Ixx, Iyy, Izz, Ixy, Ixz, Iyz] with
origin in the CoG and the axes aligned with the tool flange axes.
transition_time: the duration of the payload property changes in seconds
Notes:
• This script should be used instead of the deprecated set_payload, set_payload_mass, and
set_payload_cog.
• The payload mass and CoG are required, the inertia matrix and transition time are optional.
• When inertia matrix is left out, a zero matrix will be used.
• When transition time is left out, the change will be applied instantaneously, identically to how
the deprecated set_payload, set_payload_mass and set_payload_cog work.
• The maximum value allowed for each of the components of the inertia matrix is +/- 133 kg*m^2. An
exception is thrown if limits are exceeded.
• The first three elements of the inertia matrix (i.e. Ixx, Iyy, Izz) cannot be negative. An exception is
thrown if either value is negative.
• The force/torque measurements are automatically zeroed when setting the payload. That ensures
the readings are compensated for the payload. This is similar to the behaviour of zero_ftsensor
().
• Setting a transition time larger than zero avoids the robot doing a small "jump" when payload
changes. This is useful when picking up or releasing heavy objects.
• The internal force/torque sensor in the robot tool is reset each time the payload is updated. This
means that the final reset will be performed at the end of the payload transition time. If the payload
is being accelerated at the time of the final reset, the force/torque measurement will be affected. It's
always recommended to call zero_ftsensor() to reset the force/torque sensor before using it,
e.g. in Force Mode.
e-Series 66 Script Directory
15. Module internals
15.47. set_tcp(pose, tcp_name="")
Sets the active tcp offset, i.e., the transformation from the output flange coordinate system to the TCP as a
pose, and assigns a name to the TCP. If no name is provided, the default name is an empty string.
Parameters
• pose: A pose describing the transformation.
• tcp_name (optional, default=""): A string that assigns a name to the TCP.
Example command: set_tcp(p[0.,.2,.3,0.,3.14,0.], "custom_tcp_name")
• Example Parameters:
• pose = p[0.,.2,.3,0.,3.14,0.] -> tool center point is set to x=0mm, y=200mm, z=300mm,
rotation vector is rx=0 deg, ry=180 deg, rz=0 deg. In tool coordinates.
• tcp_name = "custom_tcp_name" -> the name assigned to the TCP.
15.48. sleep(t)
Sleep for an amount of time
Parameters
t: time [s]
Example command: sleep(3.)
• Example Parameters:
• t = 3. -> time to sleep
15.49. time(mode=0)

Get current time from selected source.
Parameters
mode: integer, one of:
• 0: Controller execution time. Time counted since low level controller start. Guaranteed monotonic.
Reset on robot restart.
• 1: Reserved.
• 2: System time in GMT time zone. Not guaranteed to be monotonic - can go backwards when
system time is adjusted.
Return
Function retruns structure in format struct(sec, nanosec)
Example 1: Get seconds part of current time counted since low level controller start.
current_time_s = time().sec
Script Directory 67 e-Series
15. Module internals

Example 2: Get current system time in seconds including fraction of second.
t = time() global current_time_s = t.sec + t.nanosec / 1000000000
Example 3: Get current date derived from system clock. NOTE: time(2) function returns GMT time.
# Converts seconds since 1970.01.01 to date
# Based on http://howardhinnant.github.io/date_algorithms.html
# Returns:
# struct(year, month, day)
def seconds_to_date(z):
local d = struct(year = 0, month = 0, day = 0)
z = floor(z / 86400)
z = z + 719468
local era = floor(z/146097)
local doe = z - era * 146097
local yoe = floor((doe - floor(doe/1460) + floor(doe/36524) - floor
(doe/146096)) / 365)
d.year = yoe + era * 400
local doy = doe - (365*yoe + floor(yoe/4) - floor(yoe/100))
local mp = floor((5*doy + 2)/153)
d.day = doy - floor((153*mp + 2)/5) + 1
if(mp < 10):
d.month = mp + 3
else:
d.month = mp - 9
end
if(d.month <= 2):
d.year = d.year + 1
end
return d
end
date_gmt = seconds_to_date(time(2).sec)
Example 4: Get current GMT time derived from system clock.
Converts seconds since 1970.01.01 to time of day
# Returns:
# struct(hour, minute, second)
def seconds_to_time(z):
e-Series 68 Script Directory
15. Module internals
local t = struct(hour = 0, minute = 0, second = 0)
local sod = z % 86400
t.hour = floor(sod / 3600)
t.minute = floor((sod - t.hour * 3600) / 60)
t.second = sod % 60
return t
end
time_gmt = seconds_to_time(time(2).sec)
15.50. str_at(src, index)
Provides direct access to the bytes of a string.
This script returns a string containing the byte in the source string at the position corresponding to the
specified index. It may not correspond to an actual character in case of strings with special encoded
character (i.e. multi-byte or variable-length encoding)
The string is zero-indexed.
Parameters
src: source string.
index: integer specifying the position inside the source string.
Return Value
String containing the byte at position index in the source string. An exception is raised if the index is not
valid.
Example command:
• str_at("Hello", 0)
• returns "H"
• str_at("Hello", 1)
• returns "e"
• str_at("Hello", 10)
• error (index out of bound)
• str_at("", 0)
• error (source string is empty)

15.51. str_cat(op1, op2)
String concatenation
Script Directory 69 e-Series
15. Module internals

This script returns a string that is the concatenation of the two operands given as input. Both operands can
be one of the following types: String, Boolean, Integer, Float, Pose, List of Boolean / Integer / Float /
Pose. Any other type will raise an exception.
The resulting string cannot exceed 1023 characters, an exception is thrown otherwise.
Float numbers will be formatted with 6 decimals, and trailing zeros will be removed.
The function can be nested to create complex strings (see last example).
Parameters
op1: first operand
op2: second operand
Return Value
String concatenation of op1 and op2
Example command:
• str_cat("Hello", " World!")
• returns "Hello World!"
• str_cat("Integer ", 1)
• returns "Integer 1"
• str_cat("", p[1.0, 2.0, 3.0, 4.0, 5.0, 6.0])
• returns "p[1, 2, 3, 4, 5, 6]"
• str_cat([True, False, True], [1, 0, 1])
• returns "[True, False, True][1, 0, 1]"
• str_cat(str_cat("", str_cat("One", "Two")),str_cat(3, 4))
• returns "OneTwo34"
15.52. str_empty(str)
Returns true when str is empty, false otherwise.
Parameters
str: source string.
Return Value
True if the string is empty, false otherwise
Example command:
• str_empty("")
• returns True
• str_empty("Hello")
• returns False
e-Series 70 Script Directory
15. Module internals
15.53. str_find(src, target, start_from=0)
Finds the first occurrence of the substring target in src.
This script returns the index (i.e. byte) of the the first occurrence of substring target in str, starting from
the given (optional) position.
The result may not correspond to the actual position of the first character of target in case src contains
multi-byte or variable-length encoded characters.
The string is zero-indexed.
Parameters
src: source string.
target: substring to search.
start_from: optional starting position (default 0).
Return Value
The index of the first occurrence of target in src,
-1 if target is not found in src.
Example command:
• str_find("Hello World!", "o")
• returns 4
• str_find("Hello World!", "lo")
• returns 3
• str_find("Hello World!", "o", 5)
• returns 7
• str_find("abc", "z")
• returns -1
15.54. str_len(str)

Returns the number of bytes in a string.
Please not that the value returned may not correspond to the actual number of characters in sequences of
multi-byte or variable-length encoded characters.
The string is zero-indexed.
Parameters
str: source string.
Return Value
The number of bytes in the input string.
Example command:
Script Directory 71 e-Series
15. Module internals
• str_len("Hello")
• returns 5
• str_len("")
• returns 0
15.55. str_sub(src, index, len)

Returns a substring of src.
The result is the substring of src that starts at the byte specified by index with length of at most len bytes.
If the requested substring extends past the end of the original string (i.e. index + len > src
length), the length of the resulting substring is limited to the size of src.
An exception is thrown in case index and/or len are out of bounds. The string is zero-indexed.
Parameters
src: source string.
index: integer value specifying the initial byte in the range [0, src length]
len: (optional) length of the substring in the range [0, MAX_INT]. If len is not specified, the string in the
range [index, src length].
Return Value
the portion of src that starts at byte index and spans len characters.
Example command:
• str_sub("0123456789abcdefghij", 5, 3)
• returns "567"
• str_sub("0123456789abcdefghij", 10)
• returns "abcdefghij"
• str_sub("0123456789abcdefghij", 2, 0)
• returns "" (len is 0)
• str_sub("abcde", 2, 50)
• returns "cde"
• str_sub("abcde", -5, 50)
• error: index is out of bounds
15.56. sync()
Uses up the remaining "physical" time a thread has in the current frame.
e-Series 72 Script Directory
15. Module internals
15.57. textmsg(s1, s2=’’)
Send text message to log
Send message with s1 and s2 concatenated to be shown on the PolyScope log-tab.
The PolyScope log-tab is intended for general application status.
It is not recommended to add many messages at a high rate.
Parameters
s1: message string, variables of other types (int, bool poses etc.) can also be sent
s2: message string, variables of other types (int, bool poses etc.) can also be sent
Example command: textmsg("value=", 3)
• Example Parameters:
• s1 set first part of message to "value="
• s2 set second part of message to 3
• message in the log is "value=3"
15.58. to_num(str )
Converts a string to a number.
to_num returns an integer or a float depending on the presence of a decimal point in the input string. Only
’.’ is recognized as decimal point independent of locale settings.
Valid strings can contains optional leading white space(s) followed by an optional plus (’+’) or minus sign
(’-’) and then one of the following:
(i) A decimal number consisting of a sequence of decimal digits (e.g. 10, -5), an optional ’.’ to indicate a
float number (e.g. 1.5234, -2.0, .36) and a optional decimal exponent that indicates multiplication by a
power of 10 (e.g. 10e3, 2.5E-5, -5e-4).
(ii) A hexadecimal number consisting of "0x" or "0X" followed by a nonempty sequence of hexadecimal
digits (e.g. "0X3A", "0xb5").
(iii) An infinity (either "INF" or "INFINITY", case insensitive)
(iv) A Not-a-Number ("NAN", case insensitive)
Runtime exceptions are raised if the source string doesn’t contain a valid number or the result is out of
range for the resulting type.
Parameters
str: string to convert
Return Value
Integer or float number according to the input string.
Example command:

Script Directory 73 e-Series
15. Module internals
• to_num("10")
• returns 10 //integer
• to_num("3.14")
• returns 3.14 //float
• to_num("-3.0e5")
• to_num("+5.")
• to_num("123abc")
• returns -3.0e5 //float due to ’.’ in the input string
• returns 5.0 //float due to ’.’ in the input string
• error string doesn’t contain a valid number
15.59. to_str(val)

Gets string representation of a value.
This script converts a value of type Boolean, Integer, Float, Pose (or a list of those types) to a string.
The resulting string cannot exceed 1023 characters.
Float numbers will be formatted with 6 decimals, and trailing zeros will be removed.
Parameters
val: value to convert
Return Value
The string representation of the given value.
Example command:
• to_str(10)
• returns "10"
• to_str(2.123456123456)
• returns "2.123456"
• to_str(p[1.0, 2.0, 3.0, 4.0, 5.0, 6.0])
• returns "p[1, 2, 3, 4, 5, 6]"
• to_str([True, False, True])
• returns "[True, False, True]"
15.60. tool_contact(direction)
Detects when a contact between the tool and an object happens.
Parameters
e-Series 74 Script Directory
15. Module internals
direction: List of six floats. The first three elements are interpreted as a 3D vector (in the robot base
coordinate system) giving the direction in which contacts should be detected. If all elements of the list are
zero, contacts from all directions are considered.
Return Value
Integer. The returned value is the number of time steps back to just before the contact have started. A
value larger than 0 means that a contact is detected. A value of 0 means no contact.
15.61. tool_contact_examples()
Example of usage in conjunction with the "get_actual_joint_positions_history()" function to allow the robot
to retract to the initial point of contact:
>>> def testToolContact():
>>> while True:
>>> step_back = tool_contact()
>>> if step_back <= 0:
>>> # Continue moving with 100mm/s
>>> speedl([0,0,-0.100,0,0,0], 0.5, t=get_steptime())
>>> else:
>>> # Contact detected!
>>> # Get q for when the contact was first seen
>>> q = get_actual_joint_positions_history(step_back)
>>> # Stop the movement
>>> stopl(3)
>>> # Move to the initial contact point
>>> movel(q)
>>> break
>>> end
>>> end
>>> end
Example command: tool_contact(direction = get_target_tcp_speed())
• Example Parameters:
• direction=get_target_tcp_speed() will detect contacts in the direction of TCP movement
tool_contact(direction = [1,0,0,0,0,0])
• Example Parameters:
• direction=[1,0,0,0,0,0] will detect contacts in the direction robot base X