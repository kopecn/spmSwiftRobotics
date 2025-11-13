17. Module interfaces
17.1. enable_external_ft_sensor(enable, sensor_
mass=0.0, sensor_measuring_offset=[0.0, 0.0, 0.0],
sensor_cog=[0.0, 0.0, 0.0])
Deprecated:
This function is used for enabling and disabling the use of external F/T measurements in the controller. Be
aware that the following function is impacted:
• force_mode
• screw_driving
• freedrive_mode
The RTDE interface shall be used for feeding F/T measurements into the real-time control loop of the
robot using input variable external_force_torque of type VECTOR6D. If no other RTDE watchdog
has been configured (using script function rtde_set_watchdog), a default watchdog will be set to a
10Hz minimum update frequency when the external F/T sensor functionality is enabled. If the update
frequency is not met the robot program will pause.
Parameters
enable: enable or disable feature (bool)
sensor_mass: mass of the sensor in kilograms (float)
sensor_measuring_offset: [x, y, z] measuring offset of the sensor in meters relative to the tool
flange frame
sensor_cog: [x, y, z] center of gravity of the sensor in meters relative to the tool flange frame
Deprecated
When using this function, the sensor position is applied such that the resulting torques are computed with
opposite sign. New programs should use ft_rtde_input_enable in place of this.
Notes:
• The TCP Configuration in the installation must also include the weight and offset contribution of the
sensor.
• Only the enable parameter is required, sensor mass, offset and center of gravity are optional (zero
if not provided).
Example command: Please refer to ft_rtde_input_enable for some examples of usage

Script Directory 91 e-Series
17. Module interfaces
17.2. ft_rtde_input_enable(enable, sensor_mass=0.0,
sensor_measuring_offset=[0.0, 0.0, 0.0], sensor_cog=
[0.0, 0.0, 0.0])

This function is used for enabling and disabling the use of external F/T measurements in the controller. Be
aware that the following function is impacted:
• force_mode
• screw_driving
• freedrive_mode
The RTDE interface shall be used for feeding F/T measurements into the real-time control loop of the
robot using input variable external_force_torque of type VECTOR6D. If no other RTDE watchdog
has been configured (using script function rtde_set_watchdog), a default watchdog will be set to a
10Hz minimum update frequency when the external F/T sensor functionality is enabled. If the update
frequency is not met the robot program will pause.
Parameters
enable: enable or disable feature (bool)
sensor_mass: mass of the sensor in kilograms (float)
sensor_measuring_offset: [x, y, z] measuring offset of the sensor in meters relative to the tool
flange frame
sensor_cog: [x, y, z] center of gravity of the sensor in meters relative to the tool flange frame
Notes:
This function replaces the deprecated enable_external_ft_sensor.
The TCP Configuration in the installation must also include the weight and offset contribution of the
sensor.
Only the enable parameter is required; sensor (zero if not provided).
mass, offset and center of gravity are optional
Example command: ft_rtde_input_enable(True, 1.0, [0.1, 0.0, 0.0], [0.2, 0.1,
0.5])
• Example Parameters:
• enable -> Enabling the feed of an external F/T measurements in the controller.
• sensor_mass -> mass of F/T sensor is set to 1.0 Kg.
• sensor_measuring_offset -> sensor measuring offset is set to [0.1, 0.0, 0.0] m from
the tool flange in tool flange frame coordinates.
• sensor_cog -> Center of Gravity of the sensor is set to x=200 mm, y=100 mm, z=500
mm from the center of the tool flange in tool flange frame coordinates.
e-Series 92 Script Directory
17. Module interfaces
• ft_rtde_input_enable(True, 0.5)
• Example Parameters:
• enable S{ rarr} Enabling the feed of an external F/T measurements in the
controller.
• sensor_mass S{ rarr} mass of F/T sensor is set to 0.5 Kg.
• Both sensor measuring offset and sensor's center of gravity are zero.
• @example:
• C{ ft_rtde_input_enable(False)}
• Disable the feed of external F/T measurements in the controller (no other
parameters required)
17.3. get_analog_in(n)
Deprecated: Get analog input signal level
Parameters
n: The number (id) of the input, integer: [0:3]
Return Value
float, The signal level in Amperes, or Volts
Deprecated: The get_standard_analog_in and get_tool_analog_in replace this function. Ports
2-3 should be changed to 0-1 for the latter function. This function might be removed in the next major
release.
Note: For backwards compatibility n:2-3 go to the tool analog inputs.
Example command: get_analog_in(1)
• Example Parameters:
• n is analog input 1
• Returns value of analog output #1

17.4. get_analog_out(n)
Deprecated: Get analog output signal level
Parameters
n: The number (id) of the output, integer: [0:1]
Return Value
float, The signal level in Amperes, or Volts
Deprecated: The get_standard_analog_out replaces this function. This function might be removed
in the next major release.
Example command: get_analog_out(1)
Script Directory 93 e-Series
17. Module interfaces
• Example Parameters:
• n is analog output 1
• Returns value of analog output #1
17.5. get_configurable_digital_in(n)
Get configurable digital input signal level
See also get_standard_digital_in and get_tool_digital_in.
Parameters
n: The number (id) of the input, integer: [0:7]
Return Value
boolean, The signal level.
Example command: get_configurable_digital_in(1)
• Example Parameters:
• n is configurable digital input 1
• Returns True or False

17.6. get_configurable_digital_out(n)
Get configurable digital output signal level
See also get_standard_digital_outand get_tool_digital_out.
Parameters
n: The number (id) of the output, integer: [0:7]
Return Value
boolean, The signal level.
Example command: get_configurable_digital_out(1)
• Example Parameters:
• n is configurable digital output 1
• R'eturns True or False
17.7. get_digital_in(n)
Deprecated: Get digital input signal level
Parameters
e-Series 94 Script Directory
17. Module interfaces
n: The number (id) of the input, integer: [0:9]
Return Value
boolean, The signal level.
Deprecated: The get_standard_digital_in and get_tool_digital_in replace this function.
Ports 8-9 should be changed to 0-1 for the latter function. This function might be removed in the next major
release.
Note: For backwards compatibility n:8-9 go to the tool digital inputs.
Example command: get_digital_in(1)
• Example Parameters:
• n is digital input 1
• Returns True or False
17.8. get_digital_out(n)
Deprecated: Get digital output signal level
Parameters
n: The number (id) of the output, integer: [0:9]
Return Value
boolean, The signal level.
Deprecated: The get_standard_digital_out and get_tool_digital_out replace this function.
Ports 8-9 should be changed to 0-1 for the latter function. This function might be removed in the next major
release.
Note: For backwards compatibility n:8-9 go to the tool digital outputs.
Example command: get_digital_out(1)
• Example Parameters:
• n is digital output 1
• Returns True or False

17.9. get_flag(n)
Flags behave like internal digital outputs. They keep information between program runs.
Parameters
n: The number (id) of the flag, integer: [0:31]
Return Value
Boolean, The stored bit.
Example command: get_flag(1)
Script Directory 95 e-Series
17. Module interfaces
• Example Parameters:
• n is flag number 1
• Returns True or False
17.10. get_standard_analog_in(n)
Get standard analog input signal level
See also get_tool_analog_in.
Parameters
n: The number (id) of the input, integer: [0:1]
Return Value
float, The signal level in Amperes, or Volts
Example command: get_standard_analog_in(1)
• Example Parameters:
• n is standard analog input 1
• Returns value of standard analog input #1

17.11. get_standard_analog_out(n)
Get standard analog output signal level
Parameters
n: The number (id) of the output, integer: [0:1]
Return Value
float, The signal level in Amperes, or Volts
Example command: get_standard_analog_out(1)
• Example Parameters:
• n is standard analog output 1
• Returns value of standard analog output #1
17.12. get_standard_digital_in(n)
Get standard digital input signal level
See also get_configurable_digital_in and get_tool_digital_in.
Parameters
e-Series 96 Script Directory
17. Module interfaces
n: The number (id) of the input, integer: [0:7]
Return Value
boolean, The signal level.
Example command: get_standard_digital_in(1)
• Example Parameters:
• n is standard digital input 1
• Returns True or False
17.13. get_standard_digital_out(n)
Get standard digital output signal level
See also get_configurable_digital_out and get_tool_digital_out.
Parameters
n: The number (id) of the output, integer: [0:7]
Return Value
boolean, The signal level.
Example command: get_standard_digital_out(1)
• Example Parameters:
• n is standard digital output 1
• Returns True or False
17.14. get_tool_analog_in(n)

Get tool analog input signal level
See also get_standard_analog_in.
Parameters
n: The number (id) of the input, integer: [0:1]
Return Value
float, The signal level in Amperes, or Volts
Example command: get_tool_analog_in(1)
• Example Parameters:
• n is tool analog input 1
• Returns value of tool analog input #1
Script Directory 97 e-Series
17. Module interfaces
17.15. get_tool_digital_in(n)
Get tool digital input signal level
See also get_configurable_digital_in and get_standard_digital_in.
Parameters
n: The number (id) of the input, integer: [0:1]
Return Value
boolean, The signal level.
Example command: get_tool_digital_in(1)
• Example Parameters:
• n is tool digital input 1
• Returns True or False

17.16. get_tool_digital_out(n)
Get tool digital output signal level
See also get_standard_digital_out and get_configurable_digital_out.
Parameters
n: The number (id) of the output, integer: [0:1]
Return Value
boolean, The signal level.
Example command: get_tool_digital_out(1)
Example Parameters:
n is tool digital out 1
Returns True or False
17.17. modbus_add_signal(IP, slave_number, signal_
address, signal_type, signal_name, sequential_
mode=False, register_count=1)
Adds a new modbus signal for the controller to supervise. Expects no response. If the signal is an output
type, then until the first set_output_signal/register() command the function code will be 2/3, after the call it
will switch to 15/16.
e-Series 98 Script Directory
17. Module interfaces
Matrix of function codes used for accessing coils or discrete inputs:
Read Write
Signal type Single Coil Multiple
Coils
0 = Digital input 2 2 - -
1 = Digital output 1 1 15 15
15 = Multiple digital
outputs
1 1 15 Single Coil Multiple Coils
15
Matrix of function codes used for accessing coils or discrete inputs:
Read Write
Signal type Single
register
Multiple
registers
Single
register
2 = Register input 4 4 - -
3 = Register output 3 3 6 16
16 = Multiple register
outputs
3 3 16 Multiple
registers
16
>>> modbus_add_signal("172.140.17.11", 255, 5, 1, "output1")
Parameters
IP: A string specifying the IP address of the modbus unit to which the modbus signal is connected. The
IP can not be empty.
Note: Numerical IP addresses are recommended. DNS name resolution may lead to unexpected program
stops.
slave_number: An integer normally not used and set to 255, but is a free choice between 0 and 255.
signal_address: An integer specifying the address of the either the coil or the register that this new
signal should reflect. Consult the configuration of the modbus unit for this information. The value must be
greater or equal to 0.
signal_type: An integer specifying the type of signal to add. 0 = digital input, 1 = digital output, 2 =
register input, 3 = register output, 15 = multiple digital output, 16 = multiple register output. Note: this
function does notaccept23 = multiple read-write signaltype.
signal_name: A string uniquely identifying the signal. If a string is supplied which is equal to an already
added signal, the new signal will replace the old one. The length of the string can not exceed 20
characters. The signal name cannot be empty.
sequential_mode: Setting to True forces the modbus client to wait for a response before sending the
next request. This mode is required by some fieldbus units (Optional).
register_count: Number of registers/coils accessed by the signal [1-123] (Optional, the default value
is 1).

Example command 1: modbus_add_signal("172.140.17.11", 255, 5, 1, "output1")
Script Directory 99 e-Series
17. Module interfaces
• Example Parameters:
• IP address = 172.140.17.11
• Slave number = 255
• Signal address = 5
• Signal type = 1 digital output
• Signal name = output 1
Example command 2: modbus_add_signal("172.140.17.11", 255, 5, 16, "output2",
False, 10)
• Example Parameters:
• IP address = 172.140.17.11
• Slave number = 255
• Signal address = 5
• Signal type = 16 multiple register output
• Signal name = output 2
• sequential_mode = False
• register_count = 10

17.18. modbus_add_rw_signal(IP, slave_number, read_
address, read_register_count, write_address, write_
register_count, signal_name, sequential_mode=False)
Adds a new modbus signal for the controller to supervise. This function will use the function code 23. The
read and write addresses can overlap. Until the first set_output_register() command the function code will
be 3, after the call it will switch to 23.
>>> modbus_add_rw_signal("172.140.17.11", 255, 5, 10, 15, 10, "output1")
Parameters
IP: A string specifying the IP address of the modbus unit to which the modbus signal is connected. The
IP can not be empty.
slave_number: An integer normally not used and set to 255, but is a free choice between 0 and 255.
read_address: An integer specifying the address of the first register that this new signal should read
from.
read_register_count: Number of registers to read [1-123].
write_address: An integer specifying the address of the first register that this new signal should write
to.
write_register_count: Number of registers to write [1-123].
signal_name: A string uniquely identifying the signal. If a string is supplied which is equal to an already
added signal, the new signal will replace the old one. The length of the string can not exceed 20
characters. The signal name cannot be empty.
e-Series 100 Script Directory
17. Module interfaces
sequential_mode: Setting to True forces the modbus client to wait for a response before sending the
next request. This mode is required by some fieldbus units (Optional).
Example command: modbus_add_rw_signal("172.140.17.11", 255, 5, 10, 15, 10
"output1")
This example will create a signal that cyclically reads 10 registers from addresses 5-14, an writes 10
registers to addresses 10-19 Signal will use Function Code 3 to read register until first time modbus_set_
register_output(...) is called. Afterwards Function Code 23 will be used to both read and write registers in
remote device.
• Example Parameters:
• IP address = 172.140.17.11
• Slave number = 255
• Signal read address = 5
• Signal read register count = 10
• Signal write address = 15
• Signal write register count = 10
• Signal name = output 1
17.19. modbus_delete_signal(signal_name)
Deletes the signal identified by the supplied signal name.
>>> modbus_delete_signal("output1")
Parameters
signal_name: A string equal to the name of the signal that should be deleted. The signal name can not
be empty.
Example command: modbus_delete_signal("output1")
• Example Parameters:
• Signal name = output1

17.20. modbus_get_signal_status(signal_name, is_
secondary_program=False)
Reads the current value(s) of a specific signal. If the modbus watchdog is active, this will return the last
valid value(s). No error will be thrown within the watchdog time. If needed, the modus_get_error() or the
modbus_get_time_since_signal_invalid() can be used to detected that the signal is in an error state before
the watchdog expires.
>>> modbus_get_signal_status("output1",False)
Parameters
Script Directory 101 e-Series
17. Module interfaces
signal_name: A string equal to the name of the signal for which the value should be gotten. Can not be
empty.
is_secondary_program: A boolean for internal use only. Must be set to False. (Optional, default is
False)
Return Value
An integer or a boolean. For digital signals: True or False. For register signals: The register value
expressed as an unsigned integer. If the signal was declared to have access for multiple registers/coild,
then the return value will be an array of unsigned integers / booleans. The length of the returned array is
equal to the register_count of the signal.
Example command: modbus_get_signal_status("output1")
Example Parameters:
• Signal name = output 1
• Is_secondary_program = False by default

17.21. modbus_send_custom_command(IP, slave_
number, function_code, data)
Sends a command specified by the user to the modbus unit located on the specified IP address. Cannot
be used to request data, since the response will not be received. The user is responsible for supplying
data which is meaningful to the supplied function code. The builtin function takes care of constructing the
modbus frame, so the user should not be concerned with the length of the command.
>>> modbus_send_custom_command("172.140.17.11",103,6,
>>> [17,32,2,88])
The above example sets the watchdog timeout on a Beckhoff BK9050 to 600 ms. That is done using the
modbus function code 6 (preset single register) and then supplying the register address in the first two
bytes of the data array ([17,32] = [0x1120]) and the desired register content in the last two bytes ([2,88] =
[0x0258] = dec 600).
Parameters
IP: A string specifying the IP address locating the modbus unit to which the custom command should be
send. Can not be empty.
slave_number: An integer specifying the slave number to use for the custom command. Must be
between [0-255].
function_code: An integer specifying the function code for the custom command.
data: An array of integers in which each entry must be a valid byte (0-255) value.
Example command: modbus_send_custom_command("172.140.17.11", 103, 6,
[17,32,2,88])
e-Series 102 Script Directory
17. Module interfaces
• Example Parameters:
• IP address = 172.140.17.11
• Slave number = 103
• Function code = 6
• Data = [17,32,2,88]
• Function code and data are specified by the manufacturer of the slave Modbus device
connected to the UR controller
17.22. modbus_set_digital_input_action(signal_name,
action)
Sets the selected digital input signal to either a "default" or "freedrive" action.
>>> modbus_set_digital_input_action("input1", "freedrive")
Parameters
signal_name: A string identifying a digital input signal that was previously added. Can not be empty.
action: The type of action. The action can either be "default" or "freedrive". Can not be empty. (string)
Example command: modbus_set_digital_input_action("input1", "freedrive")
• Example Parameters:
• Signal name = "input1"
• Action = "freedrive"
17.23. modbus_set_output_register(signal_name,
register_value, is_secondary_program=False)

Sets the output register(s) signal identified by the given name to the given value.
>>> modbus_set_output_register("output1",300,False)
Parameters
signal_name: A string identifying an output register signal that in advance has been added. Can not be
empty.
register_value: An integer which must be a valid word (0-65535) value or a list of integer values. The
list can not be empty. The size of the list must be less than 123 and must be equal or less to the signal's
declared register count. Note: ifa shorter listisgiven as an input, then registers withgreater indexes will
keepprevious value
is_secondary_program: A boolean for internal use only. Must be set to False. (Optional, false by
default)
Example command 1: modbus_set_output_register("output1", 300, False)
Script Directory 103 e-Series
17. Module interfaces
• Example Parameters:
• Signal name = output1
• Register value = 300
• Is_secondary_program = False (Note: must be set to False)
Example command 2:
modbus_add_signal("127.0.0.1", 255, 0, 16, "output2", False, 10)
list_var:=[10,9,8,7,6,5,4,3,2,1]
modbus_set_output_register("output2", list_var)
• Example Parameters:
• Signal name = output2
• Register values = 10,9,8,7,6,5,4,3,2,1
• Is_secondary_program = False by default

17.24. modbus_set_output_signal(signal_name, digital_
value, is_secondary_program, False)
Sets the output digital signal(s) identified by the given name to the given value.
>>> modbus_set_output_signal("output2",True,False)
Parameters
signal_name: A string identifying an output digital signal that in advance has been added. Can not be
empty.
digital_value: A boolean to which value the signal will be set or a list of boolean values. The list can
not be empty. The size of the list must be less than 123 and must be equal or less to the signal's declared
register count. Note: ifa shorter listisgiven as an input, then coils withgreater indexes willkeepprevious
value
is_secondary_program: A boolean for internal use only. Must be set to False.
Example command 1: modbus_set_output_signal("output1", True, False)
• Example Parameters:
• Signal name = output1
• Digital value = True
• Is_secondary_program = False (Note: must be set to False)
Example command 2:
modbus_add_signal("127.0.0.1", 255, 0, 15, "output2", False, 5)
list_var:=[True, False, True, False, True]
modbus_set_output_signal("output2", list_var)
e-Series 104 Script Directory
17. Module interfaces
• Example Parameters:
• Signal name = output2
• Digital values = True, False, True, False, True
• Is_secondary_program = False by default.
17.25. modbus_set_signal_update_frequency(signal_
name, update_frequency)
Sets the frequency with which the robot will send requests to the Modbus controller to either read or write
the signal value.
>>> modbus_set_signal_update_frequency("output2",20)
Parameters
signal_name:A string identifying an output digital signal that in advance has been added. Can not be
empty.
update_frequency: An integer in the range 0-500 specifying the update frequency in Hz.
Note: The function accepts -1and0as a validinputas a specialvalue to create acyclic signals.
Note: Ifthe inputis 0the signalwillbe acyclic.
Example command: modbus_set_signal_update_frequency("output2", 20)
• Example Parameters:
• Signal name = output2
• Signal update frequency = 20 Hz
17.26. modbus_get_error(signal_name)

Returns the current error state of the signal.
>>> modbus_get_error("output1")
Parameters
signal_name: A string equal to the name of the signal. The signal name can not be empty.
error_source: Selects the type of the returned error. Integer, 0 = combined, 1 = device error, 2 =
connection error (Optional, default is 0 = combined)
Return Value
32 bit integer
0 = No error, Device errors
1 = Device error - illegal function code
2 = Device error - illegal data access
3 = Device error - illegal data value
Script Directory 105 e-Series
17. Module interfaces
4 = Device error - server failure
5 = Device error - acknowledge exception
6 = Device error - server busy
10 = Device error - gateway problem
11 = Device error - gateway target failure
Connection errors
Values from 1-113, see details in https://en.wikipedia.org/wiki/Errno.h and
https://www.ibm.com/docs/en/db2/11.5?topic=message-tcpip-errors
NOTICE
If combined errors are requested, then the returned value's upper 2 bytes will store the
connection error, the lower 2 bytes will store the device errors. Example returned value:
0xFFFE0004 (dec:-131068) -> upper 0xFFFE = -2 Disconnected ; lower 0x0004 =
Device error - server failure

Example command: modbus_get_error("output1")
• Example Parameters:
• Signal name = output1
17.27. modbus_get_time_since_signal_invalid(signal_
name)
Returns the time in seconds since the signal is invalid (has communication or device error).For input
signals function tells how long ago was last time when signal value was successfully read from remote
device. For output signals function tells how long ago was last time when signal value was successfully
written to remote device.
>>> modbus_get_time_since_signal_invalid("output1")
Parameters
signal_name: A string equal to the name of the signal. The signal name can not be empty.
Return Value
A float number representing the time in seconds since the signal is in a communication or device error.
Example command: modbus_get_time_since_signal_invalid("output1")
• Example Parameters:
• Signal name = output1
e-Series 106 Script Directory
17. Module interfaces
17.28. modbus_request_update_signal_value(signal_
name)
Request an update of the signal regardless of the used frequency.
>>> modbus_request_update_signal_value("output1")
Parameters
signal_name: A string equal to the name of the signal. The signal name can not be empty.
Example command: modbus_request_update_signal_value("output1")
• Example Parameters:
• Signal name = output1
17.29. modbus_reset_connection(connection_id, is_
blocking=True)
Tear down, and reconnect all signals to remote device. By default it will block as long as there are errors in
the connection.
>>> modbus_reset_connection("172.140.17.11")
Parameters
connection_id: A string specifying the IP address of the modbus unit to which the modbus signal is
connected. The IP can not be empty.
Example command: modbus_reset_connection("172.140.17.11")
Example Parameters:
• connection_id = 172.140.17.11
• is_blocking = True

17.30. modbus_set_signal_watchdog(signal_name, new_
timeout_in_sec)
Set tolerance for modbus errors (both communication, and device exceptions) as minimum time between
valid device responses. No error will be thrown within the watchdog time. If needed, the modus_get_error
() or the modbus_get_time_since_signal_invalid() can be used to detected that the signal is in an error
state before the watchdog expires.Default signal timeout is 2 seconds.
>>> modbus_set_signal_watchdog("signal1", 5)
Parameters
Script Directory 107 e-Series
17. Module interfaces
signal_name: A string identifying an output digital signal that in advance has been added. Can not be
empty.
new_timeout_in_sec: A number in range 0-300 representing seconds.
Example command: modbus_set_signal_watchdog("signal1", 10.5)
Example Parameters:
• signal_name = signal1
• new_timeout_in_sec = 10.5 seconds
17.31. read_input_boolean_register(address)

Reads the boolean from one of the input registers, which can also be accessed by a Field bus. Note, uses
it’s own memory space.
Parameters
address: Address of the register (0:127)
Return Value
The boolean value held by the register (True, False)
Note: The lower range of the boolean input registers [0:63] is reserved for FieldBus/PLC interface usage.
The upper range [64:127] cannot be accessed by FieldBus/PLC interfaces, since it is reserved for external
RTDE clients.
>>> bool_val = read_input_boolean_register(3)
Example command: read_input_boolean_register(3)
• Example Parameters:
• Address = input boolean register 3
17.32. read_input_float_register(address)
Reads the float from one of the input registers, which can also be accessed by a Field bus. Note, uses it’s
own memory space.
Parameters
address: Address of the register (0:47)
Return Value
The value held by the register (float)
Note: The lower range of the float input registers [0:23] is reserved for FieldBus/PLC interface usage. The
upper range [24:47] cannot be accessed by FieldBus/PLC interfaces, since it is reserved for external
RTDE clients.
>>> float_val = read_input_float_register(3)
Example command: read_input_float_register(3)
e-Series 108 Script Directory
17. Module interfaces
• Example Parameters:
• Address = input float register 3
17.33. read_input_integer_register(address)
Reads the integer from one of the input registers, which can also be accessed by a Field bus. Note, uses
it’s own memory space.
Parameters
address: Address of the register (0:47)
Return Value
The value held by the register [-2,147,483,648 : 2,147,483,647]
Note: The lower range of the integer input registers [0:23] is reserved for FieldBus/PLC interface usage.
The upper range [24:47] cannot be accessed by FieldBus/PLC interfaces, since it is reserved for external
RTDE clients.
>>> int_val = read_input_integer_register(3)
Example command: read_input_integer_register(3)
• Example Parameters:
• Address = input integer register 3
17.34. read_output_boolean_register(address)

Reads the boolean from one of the output registers, which can also be accessed by a Field bus. Note,
uses it’s own memory space.
Parameters
address: Address of the register (0:127)
Return Value
The boolean value held by the register (True, False)
Note: The lower range of the boolean output registers [0:63] is reserved for FieldBus/PLC interface usage.
The upper range [64:127] cannot be accessed by FieldBus/PLC interfaces, since it is reserved for external
RTDE clients.
>>> bool_val = read_output_boolean_register(3)
Example command: read_output_boolean_register(3)
• Example Parameters:
• Address = output boolean register 3
Script Directory 109 e-Series
17. Module interfaces
17.35. read_output_float_register(address)
Reads the float from one of the output registers, which can also be accessed by a Field bus. Note, uses it’s
own memory space.
Parameters
address: Address of the register (0:47)
Return Value
The value held by the register (float)
Note: The lower range of the float output registers [0:23] is reserved for FieldBus/PLC interface usage.
The upper range [24:47] cannot be accessed by FieldBus/PLC interfaces, since it is reserved for external
RTDE clients.
>>> float_val = read_output_float_register(3)
Example command: read_output_float_register(3)
• Example Parameters:
• Address = output float register 3

17.36. read_output_integer_register(address)
Reads the integer from one of the output registers, which can also be accessed by a Field bus. Note, uses
it’s own memory space.
Parameters
address: Address of the register (0:47)
Return Value
The int value held by the register [-2,147,483,648 : 2,147,483,647]
Note: The lower range of the integer output registers [0:23] is reserved for FieldBus/PLC interface usage.
The upper range [24:47] cannot be accessed by FieldBus/PLC interfaces, since it is reserved for external
RTDE clients.
>>> int_val = read_output_integer_register(3)
Example command: read_output_integer_register(3)
• Example Parameters:
• Address = output integer register 3
17.37. read_port_bit(address)
Reads one of the ports, which can also be accessed by Modbus clients
>>> boolval = read_port_bit(3)
e-Series 110 Script Directory
17. Module interfaces
Parameters
address: Address of the port (See port map on Support site, page "Modbus Server" )
Return Value
The value held by the port (True, False)
Example command: read_port_bit(3)
• Example Parameters:
• Address = port bit 3
17.38. read_port_register(address)
Reads one of the ports, which can also be accessed by Modbus clients
>>> intval = read_port_register(3)
Parameters
address: Address of the port (See port map on Support site, page "Modbus Server" )
Return Value
The signed integer value held by the port (-32768 : 32767)
Example command: read_port_register(3)
Example Parameters:
Address = port register 3
17.39. rpc_factory(type, url)

Creates a new Remote Procedure Call (RPC) handle. Please read the subsection ef{Remote Procedure
Call (RPC)} for a more detailed description of RPCs.
>>> proxy = rpc_factory("xmlrpc", "http://127.0.0.1:8080/RPC2")
Parameters
type: The type of RPC backed to use. Currently only the "xmlrpc" protocol is available.
url: The URL to the RPC server. Currently two protocols are supported: pstream and http. The pstream
URL looks like "<ip-address>:<port>", for instance "127.0.0.1:8080" to make a local connection on port
8080. A http URL generally looks like "http://<ip-address>:<port>/<path>", whereby the <path> depends
on the setup of the http server. In the example given above a connection to a local Python webserver on
port 8080 is made, which expects XMLRPC calls to come in on the path "RPC2".
Return Value
Script Directory 111 e-Series
17. Module interfaces
A RPC handle with a connection to the specified server using the designated RPC backend. If the server is
not available the function and program will fail. Any function that is made available on the server can be
called using this instance. For example "bool isTargetAvailable(int number, ...)" would be
"proxy.isTargetAvailable(var_1, ...)", whereby any number of arguments are supported (denoted by the
...).
Note: Giving the RPC instance a good name makes programs much more readable (i.e. "proxy" is not a
very good name).
Example command: rpc_factory("xmlrpc", "http://127.0.0.1:8080/RPC2")
• Example Parameters:
• type = xmlrpc
• url = http://127.0.0.1:8080/RPC2

17.40. rtde_set_watchdog(variable_name, min_
frequency, action=’pause’)
This function will activate a watchdog for a particular input variable to the RTDE. When the watchdog did
not receive an input update for the specified variable in the time period specified by min_frequency (Hz),
the corresponding action will be taken. All watchdogs are removed on program stop.
>>> rtde_set_watchdog("input_int_register_0", 10, "stop")
Parameters
variable_name: Input variable name (string), as specified by the RTDE interface
min_frequency: The minimum frequency (float) an input update is expected to arrive.
action: Optional: Either "ignore", "pause" or "stop" the program on a violation of the minimum frequency.
The default action is "pause".
Return Value
None
Note: Only one watchdog is necessary per RTDE input package to guarantee the specified action on
missing updates.
Example command: rtde set watchdog( "input int register 0" , 10, "stop" )
• Example Parameters:
• variable name = input int register 0
• min frequency = 10 hz
• action = stop the program
17.41. set_analog_inputrange(port, range)
Deprecated: Set range of analog inputs
e-Series 112 Script Directory
17. Module interfaces
Port 0 and 1 is in the controller box, 2 and 3 is in the tool connector.
Parameters
port: analog input port number, 0,1 = controller, 2,3 = tool
range: Controller analog input range 0: 0-5V (maps automatically onto range 2) and range 2: 0-10V.
range: Tool analog input range 0: 0-5V (maps automatically onto range 1), 1: 0-10V and 2: 4-20mA.
Deprecated: The set_standard_analog_input_domain and set_tool_analog_input_domain
replace this function. Ports 2-3 should be changed to 0-1 for the latter function. This function might be
removed in the next major release.
Note: For Controller inputs ranges 1: -5-5V and 3: -10-10V are no longer supported and will show an
exception in the GUI.
17.42. set_analog_out(n, f )
Deprecated: Set analog output signal level
Parameters
n: The number (id) of the output, integer: [0:1]
f: The relative signal level [0;1] (float)
Deprecated: The set_standard_analog_out replaces this function.
This function might be removed in the next major release.
Example command: set_analog_out(1,0.5)
• Example Parameters:
• n is standard analog output port 1
• f = 0.5, that corresponds to 5V (or 12mA depending on domain setting) on the output port

17.43. set_configurable_digital_out(n, b)
Set configurable digital output signal level
See also set_standard_digital_out and set_tool_digital_out.
Parameters
n: The number (id) of the output, integer: [0:7]
b: The signal level. (boolean)
Example command: set_configurable_digital_out(1,True)
• Example Parameters:
• n is configurable digital output 1
• b = True
Script Directory 113 e-Series
17. Module interfaces
17.44. set_digital_out(n, b)
Deprecated: Set digital output signal level
Parameters
n: The number (id) of the output, integer: [0:9]
b: The signal level. (boolean)
Deprecated: The set_standard_digital_out and set_tool_digital_out replace this function.
Ports 8-9 should be changed to 0-1 for the latter function. This function might be removed in the next major
release.
Example command: set_digital_out(1,True)
• Example Parameters:
• n is digital output 1
• b = True

17.45. set_flag(n, b)
Flags behave like internal digital outputs. They keep information between program runs.
Parameters
n: The number (id) of the flag, integer: [0:31]
b: The stored bit. (boolean)
Example command: set_flag(1,True)
• Example Parameters:
• n is flag number 1
• b = True will set the bit to True
17.46. set_standard_analog_out(n, f)
Set standard analog output signal level
Parameters
n: The number (id) of the output, integer: [0:1]
f: The relative signal level [0;1] (float)
Example command: set_standard_analog_out(1,1.0)
• Example Parameters:
• n is standard analog output port 1
• f = 1.0, that corresponds to 10V (or 20mA depending on domain setting) on the output port
e-Series 114 Script Directory
17. Module interfaces
17.47. set_standard_digital_out(n, b)
Set standard digital output signal level
See also set_configurable_digital_out and set_tool_digital_out.
Parameters
n: The number (id) of the output, integer: [0:7]
b: The signal level. (boolean)
Example command: set_standard_digital_out(1,True)
• Example Parameters:
• n is standard digital output 1
• f = True
17.48. set_tool_digital_out(n, b)
Set tool digital output signal level
See also set_configurable_digital_out and set_standard_digital_out.
Parameters
n: The number (id) of the output, integer: [0:1]
b: The signal level. (boolean)
Example command: set_tool_digital_out(1,True)
• Example Parameters:
• n is tool digital output 1
• b = True

17.49. set_tool_communication(enabled, baud_rate,
parity, stop_bits,
This function will activate or deactivate the ’Tool Communication Interface’ (TCI). The TCI will enable
communication with a external tool via the robots analog inputs hereby avoiding external wiring.
>>> set_tool_communication(True, 115200, 1, 2, 1.0, 3.5)
Parameters
enabled: Boolean to enable or disable the TCI (string). Valid values: True (enable), False (disable)
baud_rate: The used baud rate (int). Valid values: 9600, 19200, 38400, 57600, 115200, 1000000,
2000000, 5000000.
parity: The used parity (int). Valid values: 0 (none), 1 (odd), 2 (even).
Script Directory 115 e-Series
17. Module interfaces
stop_bits: The number of stop bits (int). Valid values: 1, 2.
rx_idle_chars: Amount of chars the RX unit in the tool should wait before marking a message as over /
sending it to the PC (float). Valid values: min=1.0 max=40.0.
tx_idle_chars: Amount of chars the TX unit in the tool should wait before starting a new transmission
since last activity on bus (float). Valid values: min=0.0 max=40.0.
Return Value
None
Note:
Enabling this feature will disable the robot tool analog inputs.
Example command:
set_tool_communication(True, 115200, 1, 2, 1.0, 3.5)
• Example Parameters:
• enabled = True
• baud rate = 115200
• parity = ODD
• stop bits = 2
• rx idle time = 1.0
• tx idle time = 3.5

17.50. set_tool_digital_output_mode (n, mode)
Sets the output mode of the tool output pin.
Parameters
n: The number (id) of the output, integer: [0:1]
Mode: The pin mode.
Integer: [1:3]
• 1=Sinking/NPN
• 2=Sourcing/PNP
• 3=Push-Pull
Example command: set_tool_digital_output_mode(0,2)
• Example Parameters:
• 0 is digital output pin 0.
• 2 is pin mode sourcing/PNP.
The pin sources current when it is set to 1.
The pin is high impedance when it is set to 0.
e-Series 116 Script Directory
17. Module interfaces
17.51. set_tool_output_mode (mode)
Sets the tool digital output mode.
Parameters
Mode: 1=power (dual pin) mode.
Example command: set_tool_output_mode(1)
• Example Parameters:
• 1 is the power (dual pin) mode.
The digital outputs are used as extra supply
17.52. set_tool_voltage(voltage)
Sets the voltage level for the power supply that delivers power to the connector plug in the tool flange of
the robot. The votage can be 0, 12 or 24 volts.
Parameters
voltage: The voltage (as an integer) at the tool connector, integer: 0, 12 or 24.
Example command: set_tool_voltage(24)
• Example Parameters:
• voltage = 24 volts
17.53. socket_close(socket_name=’socket_0’)

Closes TCP/IP socket communication
Closes down the socket connection to the server.
>>> socket_comm_close()
Parameters
socket_name: Name of socket (string)
Example command: socket_close(socket_name="socket_0")
• Example Parameters:
• socket_name = socket_0
17.54. socket_get_var(name, socket_name=’socket_0’)
Reads an integer from the server
Script Directory 117 e-Series
17. Module interfaces
Sends the message "GET <name>\n" through the socket, expects the response "<name> <int>\n" within 2
seconds. Returns 0 after timeout
Parameters
name: Variable name (string)
socket_name: Name of socket (string)
Return Value
an integer from the server (int), 0 is the timeout value
Example command: x_pos = socket_get_var("POS_X")
Sends: GET POS_X\n to socket_0, and expects response within 2s
• Example Parameters:
• name = POS_X -> name of variable
• socket_name = default: socket_0

17.55. socket_open(address, port, socket_
name=’socket_0’)
Open TCP/IP ethernet communication socket
Attempts to open a socket connection, times out after 2 seconds.
Parameters
address: Server address (string)
port: Port number (int)
socket_name: Name of socket (string)
Return Value
False if failed, True if connection succesfully established
Note: The used network setup influences the performance of client/server communication. For instance,
TCP/IP communication is buffered by the underlying network interfaces.
• Example command: socket_open("192.168.5.1", 50000, "socket_10")
• Example Parameters:
• address = 192.168.5.1
• port = 50000
• socket_name = socket_10
e-Series 118 Script Directory
17. Module interfaces
17.56. socket_read_ascii_float(number, socket_
name=’socket_0’, timeout=2)
Reads a number of ascii formatted floats from the socket. A maximum of 30 values can be read in one
command.
The format of the numbers should be in parantheses, and seperated by ",". An example list of four
numbers could look like "( 1.414 , 3.14159, 1.616, 0.0 )".
The returned list contains the total numbers read, and then each number in succession. For example a
read_ascii_float on the example above would return [4, 1.414, 3.14159, 1.616, 0.0].
A failed read or timeout will return the list with 0 as first element and then "Not a number (nan)" in the
following elements (ex. [0, nan, nan, nan] for a read of three numbers).
Parameters
number: The number of variables to read (int)
socket_name: Name of socket (string)
timeout: The number of seconds until the read action times out (float). A timeout of 0 or negative
number indicates that the function should not return until a read is completed.
Return Value
A list of numbers read (length=number+1, list of floats)
• Example command: list_of_four_floats = socket_read_ascii_float(4,"socket_
10")
• Example Parameters:
• number = 4 → Number of floats to read
• socket_name = socket_10
• returns list

17.57. socket_read_binary_integer(number, socket_
name=’socket_0’, timeout=2)
Reads a number of 32 bit integers from the socket. Bytes are in network byte order. A maximum of 30
values can be read in one command.
Returns (for example) [3,100,2000,30000], if there is a timeout or the reply is invalid, [0,-1,-1,-1] is
returned, indicating that 0 integers have been read
Parameters
number: The number of variables to read (int)
socket_name: Name of socket (string)
timeout: The number of seconds until the read action times out (float). A timeout of 0 or negative
number indicates that the function should not return until a read is completed.
Return Value
Script Directory 119 e-Series
17. Module interfaces
A list of numbers read (length=number+1, list of ints)
Example command: list_of_ints = socket_read_binary_integer(4,"socket_10")
• Example Parameters:
• number = 4 -> Number of integers to read
• socket_name = socket_10
17.58. socket_read_byte_list(number, socket_
name=’socket_0’, timeout=2)

Reads a number of bytes from the socket. A maximum of 30 values can be read in one command.
Returns (for example) [3,100,200,44], if there is a timeout or the reply is invalid, [0,-1,-1,-1] is returned,
indicating that 0 bytes have been read
Parameters
number: The number of bytes to read (int)
socket_name: Name of socket (string)
timeout: The number of seconds until the read action times out (float). A timeout of 0 or negative
number indicates that the function should not return until a read is completed.
Return Value
A list of numbers read (length=number+1, list of ints)
Example command: list_of_bytes = socket_read_byte_list(4,"socket_10")
• Example Parameters:
• number = 4 -> Number of byte variables to read
• socket_name = socket_10
17.59. socket_read_line(socket_name=’socket_0’,
timeout=2)
Deprecated : Reads the socket buffer until the first "\r\n" (carriage return and newline) characters or just the
"\n" (newline) character, and returns the data as a string. The returned string will not contain the "\n" nor
the "\r\n" characters.
Returns (for example) "reply from the server:", if there is a timeout or the reply is invalid, an empty line is
returned (""). You can test if the line is empty with an if-statement.
>>> if(line_from_server) :
>>> popup("the line is not empty")
>>> end
e-Series 120 Script Directory
17. Module interfaces
Parameters
socket_name: Name of socket (string)
timeout: The number of seconds until the read action times out (float). A timeout of 0 or negative
number indicates that the function should not return until a read is completed.
Return Value
One line string
Deprecated: The socket_read_string replaces this function. Set flag "interpret_escape" to "True" to
enable the use of escape sequences "\n" "\r" and "\t" as a prefix or suffix.
Example command: line_from_server = socket_read_line("socket_10")
• Example Parameters:
• socket_name = socket_10
17.60. socket_read_string(socket_name=’socket_0’,
prefix =’’, suffix =’’, interpret_escape=’False’, timeout=2)
Reads all data from the socket and returns the data as a string.
Returns (for example) "reply from the server:\n Hello World". if there is a timeout or the reply is invalid, an
empty string is returned (""). You can test if the string is empty with an if-statement.
Maxium length of received string including termination characters is limited to 1024 characters.
>>> if(string_from_server) :
>>> popup("the string is not empty")
>>> end
The optional parameters "prefix" and "suffix", can be used to express what is extracted from the socket.
The "prefix" specifies the start of the substring (message) extracted from the socket. The data up to the
end of the "prefix" will be ignored and removed from the socket. The "suffix" specifies the end of the
substring (message) extracted from the socket. Any remaining data on the socket, after the "suffix", will be
preserved.

By using the "prefix" and "suffix" it is also possible send multiple string to the controller at once, because
the suffix defines where the message ends. E.g. sending ">hello<>world<" and calling this script function
with the prefix=">" and suffix="<".
Note that leading spaces in the prefix and suffix strings are ignored in the current software and may cause
communication errors in future releases.
The optional parameter "interpret_escape" can be used to allow the use of escape sequences "\n", "\t" and
"\r" as part of the prefix or suffix.
Parameters
socket_name: Name of socket (string)
Script Directory 121 e-Series
17. Module interfaces
prefix: Defines a prefix (string)
suffix: Defines a suffix (string)
interpret_escape: Enables the interpretation of escape sequences (bool)
timeout: The number of seconds until the read action times out (float). A timeout of 0 or negative
number indicates that the function should not return until a read is completed.
Return Value
String
Example command: string_from_server = socket_read_string("socket_
10",prefix=">",suffix="<")
17.61. socket_send_byte(value, socket_name=’socket_
0’)

Sends a byte to the server
Sends the byte <value> through the socket. Expects no response. Can be used to send special ASCII
characters: 10 is newline, 2 is start of text, 3 is end of text.
Parameters
value: The number to send (byte)
socket_name: Name of socket (string)
Return Value
a boolean value indicating whether the send operation was successful
Example command: socket_send_byte(2,"socket_10")
• Example Parameters:
• value = 2
• socket_name = socket_10
• Returns True or False (sent or not sent)
17.62. socket_send_int(value, socket_name=’socket_0’)
Sends an int (int32_t) to the server
Sends the int <value> through the socket. Send in network byte order. Expects no response.
Parameters
value: The number to send (int)
socket_name: Name of socket (string)
Return Value
e-Series 122 Script Directory
17. Module interfaces
a boolean value indicating whether the send operation was successful
Example command: socket_send_int(2,"socket_10")
• Example Parameters:
• value = 2
• socket_name = socket_10
• Returns True or False (sent or not sent)
17.63. socket_send_line(str, socket_name=’socket_0’)
Sends a string with a newline character to the server - useful for communicating with the UR dashboard
server
Sends the string <str> through the socket in ASCII coding. Expects no response.
Parameters
str: The string to send (ascii)
socket_name: Name of socket (string)
Return Value
a boolean value indicating whether the send operation was successful
Example command: socket_send_line("hello","socket_10")
Sends: hello\n to socket_10
• Example Parameters:
• str = hello
• socket_name = socket_10
• Returns True or False (sent or not sent)

17.64. socket_send_string(str, socket_name=’socket_0’)
Sends a string to the server
Sends the string <str> through the socket in ASCII coding. Expects no response.
Parameters
str: The string to send (ascii)
socket_name: Name of socket (string)
Return Value
a boolean value indicating whether the send operation was successful
Example command: socket_send_string("hello","socket_10")
Sends: hello to socket_10
Script Directory 123 e-Series
17. Module interfaces
• Example Parameters:
• str = hello
• socket_name = socket_10
• Returns True or False (sent or not sent)
17.65. socket_set_var(name, value, socket_
name=’socket_0’)

Sends an integer to the server
Sends the message "SET <name> <value>\n" through the socket. Expects no response.
Parameters
name: Variable name (string)
value: The number to send (int)
socket_name: Name of socket (string)
Example command: socket_set_var("POS_Y",2200,"socket_10")
Sends string: SET POS_Y 2200\n to socket_10
• Example Parameters:
• name = POS_Y -> name of variable
• value = 2200
• socket_name = socket_10
17.66. write_output_boolean_register(address, value)
Writes the boolean value into one of the output registers, which can also be accessed by a Field bus. Note,
uses it’s own memory space.
Parameters
address: Address of the register (0:127)
value: Value to set in the register (True, False)
Note: The lower range of the boolean output registers [0:63] is reserved for FieldBus/PLC interface usage.
The upper range [64:127] cannot be accessed by FieldBus/PLC interfaces, since it is reserved for external
RTDE clients.
>>> write_output_boolean_register(3, True)
Example command: write_output_boolean_register(3,True)
e-Series 124 Script Directory
17. Module interfaces
• Example Parameters:
• address = 3
• value = True
17.67. write_output_float_register(address, value)
Writes the float value into one of the output registers, which can also be accessed by a Field bus. Note,
uses it’s own memory space.
Parameters
address: Address of the register (0:47)
value: Value to set in the register (float)
Note: The lower part of the float output registers [0:23] is reserved for FieldBus/PLC interface usage. The
upper range [24:47] cannot be accessed by FieldBus/PLC interfaces, since it is reserved for external
RTDE clients.
>>> write_output_float_register(3, 37.68)
Example command: write_output_float_register(3,37.68)
• Example Parameters:
• address = 3
• value = 37.68
17.68. write_output_integer_register(address, value)

Writes the integer value into one of the output registers, which can also be accessed by a Field bus. Note,
uses it’s own memory space.
Parameters
address: Address of the register (0:47)
value: Value to set in the register [-2,147,483,648 : 2,147,483,647]
Note: The lower range of the integer output registers [0:23] is reserved for FieldBus/PLC interface usage.
The upper range [24:47] cannot be accessed by FieldBus/PLC interfaces, since it is reserved for external
RTDE clients.
>>> write_output_integer_register(3, 12)
Example command: write_output_integer_register(3,12)
• Example Parameters:
• address = 3
• value = 12
Script Directory 125 e-Series
17. Module interfaces
17.69. write_port_bit(address, value)
Writes one of the ports, which can also be accessed by Modbus clients
>>> write_port_bit(3,True)
Parameters
address: Address of the port (See port map on Support site, page "Modbus Server" )
value: Value to be set in the register (True, False)
Example command: write_port_bit(3,True)
• Example Parameters:
• Address = 3
• Value = True

17.70. write_port_register(address, value)
Writes one of the ports, which can also be accessed by Modbus clients
>>> write_port_register(3,100)
Parameters
address: Address of the port (See port map on Support site, page "Modbus Server" )
value: Value to be set in the port (0 : 65536) or (-32768 : 32767)
Example command: write_port_register(3,100)
• Example Parameters:
• Address = 3
• Value = 100
17.71. zero_ftsensor()
Zeroes the TCP force/torque measurement from the builtin force/torque sensor by subtracting the current
measurement from the subsequent.
17.72. request_boolean_from_primary_client(message)
Request input from operator. Polyscope shows dialog box with "yes" and "no" buttons.
Function blocks until operator selects option on the Polyscope screen.
NOTE: Operator can also stop program by pressing "Cancel" button
e-Series 126 Script Directory
17. Module interfaces
Parameters
message: A string with a message shown on Polyscope dialog box. Can not be empty.
Return Value
True or False: Value selected by the operator.
Example command: mark_part = request_boolean_from_primary_client("Should part
be marked?")
Show message to the operator, and save reply to mark_part variable
17.73. request_float_from_primary_client(message)
Request input from operator. Polyscope shows dialog box with decimal number entry field.
Function blocks until operator enters value on the Polyscope screen.
NOTE: Operator can also stop program by pressing "Cancel" button
Parameters
message: A string with a message shown on Polyscope dialog box. Can not be empty.
Return Value
Float: Value entered by the operator.
Example command: offset_mm = request_float_from_primary_client("Enter gripping
offset [mm]")
Show message to the operator, and save reply to offset_mm variable
17.74. request_integer_from_primary_client(message)

Request input from operator. Polyscope shows dialog box with integer number entry field.
Function blocks until operator enters value on the Polyscope screen.
NOTE: Operator can also stop program by pressing "Cancel" button
Parameters
message: A string with a message shown on Polyscope dialog box. Can not be empty.
Return Value
Integer: Value entered by the operator.
Example command: number_of_parts = request_integer_from_primary_client("Enter
number of parts")
Show message to the operator, and save reply to number_of_parts variable
Script Directory 127 e-Series
17. Module interfaces
17.75. request_string_from_primary_client(message)
Request input from operator. Polyscope shows dialog box with string entry field.
Function blocks until operator enters value on the Polyscope screen.
NOTE: Operator can also stop program by pressing "Cancel" button
Parameters
message: A string with a message shown on Polyscope dialog box. Can not be empty.
Return Value
String: Value entered by the operator.
Example command: part_name = request_string_from_primary_client("Enter name of
the part")
Show message to the operator, and save reply to part_name variable