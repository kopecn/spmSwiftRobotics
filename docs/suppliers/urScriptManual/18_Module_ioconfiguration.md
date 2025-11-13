18. Module ioconfiguration
18.1. modbus_set_runstate_dependent_choice(signal_
name, runstate_choice)
Sets the output signal levels depending on the state of the program.
Parameters
signal_name:
A string identifying a digital or register output signal that in advance has been added. Can not be empty.
state:
0: Preserve signal state,
1: Set signal Low when program is not running,
2: Set signal High when program is not running,
3: Set signal High when program is running and low when it is stopped,
4: Set signal Low when program terminates unscheduled,
5: Set signal High from the moment a program is started and Low when a program terminates
unscheduled.
Note: An unscheduled program termination is caused when a Protective stop, Fault, Violation or Runtime
exception occurs.
Example command:
modbus_set_runstate_dependent_choice("output2", 3)
• Example Parameters:
• Signal name = output2
• Runstate dependent choice = 3 ! set Low when a program is stopped and High when a
program is running

18.2. set_analog_outputdomain(port, domain)
Set domain of analog outputs
Parameters
port: analog output port number
domain: analog output domain: 0: 4-20mA, 1: 0-10V
Example command: set_analog_outputdomain(1,1)
Script Directory 129 e-Series
18. Module ioconfiguration
• Example Parameters:
• port is analog output port 1 (on controller)
• domain = 1 (0-10 volts)
18.3. set_configurable_digital_input_action(port, action)
Using this method sets the selected configurable digital input register to either a "default" or "freedrive"

action.
See also:
• set_input_actions_to_default
• set_standard_digital_input_action
• set_tool_digital_input_action
• set_gp_boolean_input_action
Parameters
port: The configurable digital input port number. (integer)
action: The type of action. The action can either be "default" or "freedrive". (string)
Example command: set_configurable_digital_input_action(0, "freedrive")
• Example Parameters:
• n is the configurable digital input register 0
• f is set to "freedrive" action
18.4. set_gp_boolean_input_action(port, action)
Using this method sets the selected gp boolean input register to either a "default" or "freedrive" action.
Parameters
port: The gp boolean input port number. integer: [0:127]
action: The type of action. The action can either be "default" or "freedrive". (string)
Note: The lower range of the boolean input registers [0:63] is reserved for FieldBus/PLC interface usage.
The upper range [64:127] cannot be accessed by FieldBus/PLC interfaces, since it is reserved for external
RTDE clients.
See also:
set_input_actions_to_default
set_standard_digital_input_action
set_configurable_digital_input_action
set_tool_digital_input_action
Example command: set_gp_boolean_input_action(64, "freedrive")
e-Series 130 Script Directory
18. Module ioconfiguration
• Example Parameters:
• n is the gp boolean input register 0
• f is set to "freedrive" action
18.5. set_input_actions_to_default()
Using this method sets the input actions of all standard, configurable, tool, and gp_boolean input registers
to "default" action.
See also:
set_standard_digital_input_action
set_configurable_digital_input_action
set_tool_digital_input_action
set_gp_boolean_input_action
Example command: set_input_actions_to_default()
18.6. set_runstate_configurable_digital_output_to_value
(outputId, state)
Using this method assigns the output to one of the states. This will set the output signal level depending on

the state.
Example: Set configurable digital output 5 to high when program is not running.
>>> set_runstate_configurable_digital_output_to_value(5, 2)
Parameters
outputId:
The output signal number (id), integer: [0:7]
state:
0: Preserve signal state,
1: Set signal Low when program is not running,
2: Set signal High when program is not running,
3: Set signal High when program is running and low when it is stopped,
4: Set signal Low when program terminates unscheduled,
5: Set signal High from the moment a program is started and Low when a program terminates
unscheduled,
6: Set signal High when the robot has drive power,
7: Set signal Low when the robot has drive power.
Script Directory 131 e-Series
18. Module ioconfiguration
Note: An unscheduled program termination is caused when a Protective stop, Fault, Violation or Runtime
exception occurs.
Example command:
set_runstate_configurable_digital_output_to_value(5, 2)
• Example Parameters:
• outputid = configurable digital output on port 5
• Runstate choice = 4 ! configurable digital output on port 5 goes low when a program is
terminated unscheduled.
18.7. set_runstate_gp_boolean_output_to_value
(outputId, state)

Using this method assigns the output to one of the states. This will set the output value depending on the
state.
Parameters
outputId: The output signal number (id), integer: [0:127]
state:
0: Preserve signal state,
1: Set signal to False when program is not running,
2: Set signal to True when program is not running,
3: Set signal to True when program is running and False when it is stopped,
4: Set signal to False when program terminates unscheduled,
5: Set signal to True from the moment a program is started and False when a program terminates
unscheduled,
6: Set signal to True when the robot has drive power,
7: Set signal to False when the robot has drive power.
Notes:
• The lower range of the boolean output registers [0:63] is reserved for FieldBus/PLC interface
usage. The upper range [64:127] cannot be accessed by FieldBus/PLC interfaces, since it is
reserved for external RTDE clients.
• An unscheduled program termination is caused when a Protective stop, Fault, Violation or Runtime
exception occurs.
Example command:
set_runstate_gp_boolean_output_to_value(64, 2)
• Example Parameters:
• outputid = output on port 64
• Runstate choice = 2 ! sets signal on port 64 to True when program is not running
e-Series 132 Script Directory
18. Module ioconfiguration
18.8. set_runstate_standard_analog_output_to_value
(outputId, state)
Using this method assigns the output to one of the states. This will set the output signal level depending on
the state.
Example: Set standard analog output 1 to high when program is not running.
>>> set_runstate_standard_analog_output_to_value(1, 2)
Parameters
outputId: The output signal number (id), integer: [0:1]
state:
0: Preserve signal state,
1: Set signal Low when program is not running,
2: Set signal High when program is not running,
3: Set signal High when program is running and low when it is stopped,
4: Set signal Low when program terminates unscheduled,
5: Set signal High from the moment a program is started and Low when a program terminates
unscheduled,
6: Set signal High when the robot has drive power,
7: Set signal Low when the robot has drive power.
Note: An unscheduled program termination is caused when a Protective stop, Fault, Violation or Runtime
exception occurs.
Example command:
set_runstate_standard_analog_output_to_value(1, 2)
• Example Parameters:
• outputid = standard analog output on port 1
• Runstate choice = 2 ! analog output on port 1 goes High when program is not running

18.9. set_runstate_standard_digital_output_to_value
(outputId, state)
Using this method assigns the output to one of the states. This will set the output signal level depending on
the state.
Example: Set standard digital output 5 to high when program is not running.
>>> set_runstate_standard_digital_output_to_value(5, 2)
Parameters
outputId: The output signal number (id), integer: [0:7]
Script Directory 133 e-Series
18. Module ioconfiguration
state:
0: Preserve signal state,
1: Set signal Low when program is not running,
2: Set signal High when program is not running,
3: Set signal High when program is running and low when it is stopped,
4: Set signal Low when program terminates unscheduled,
5: Set signal High from the moment a program is started and Low when a program terminates
unscheduled,
6: Set signal High when the robot has drive power,
7: Set signal Low when the robot has drive power.
Note: An unscheduled program termination is caused when a Protective stop, Fault, Violation or Runtime
exception occurs.
Example command:
set_runstate_standard_digital_output_to_value(5, 2)
• Example Parameters:
• outputid = standard digital output on port 1
• Runstate choice = 2 ! sets digital output on port 1 to High when program is not running

18.10. set_runstate_tool_digital_output_to_value
(outputId, state)
Sets the output signal level depending on the state of the program (running or stopped).
Example: Set tool digital output 1 to high when program is not running.
>>> set_runstate_tool_digital_output_to_value(1, 2)
Parameters
outputId:
The output signal number (id), integer: [0:1]
state:
0: Preserve signal state,
1: Set signal Low when program is not running,
2: Set signal High when program is not running,
3: Set signal High when program is running and low when it is stopped,
4: Set signal Low when program terminates unscheduled,
5: Set signal High from the moment a program is started and Low when a program terminates
unscheduled.
e-Series 134 Script Directory
18. Module ioconfiguration
Note: An unscheduled program termination is caused when a Protective stop, Fault, Violation or Runtime
exception occurs.
Example command:
set_runstate_tool_digital_output_to_value(1, 2)
• Example Parameters:
• outputid = tool digital output on port 1
• Runstate choice = 2 ! digital output on port 1 goes High when program is not running
18.11. set_standard_analog_input_domain(port, domain)
Set domain of standard analog inputs in the controller box
For the tool inputs see set_tool_analog_input_domain.
Parameters
port: analog input port number: 0 or 1
domain: analog input domains: 0: 4-20mA, 1: 0-10V
Example command: set_standard_analog_input_domain(1,0)
• Example Parameters:
• port = analog input port 1
• domain = 0 (4-20 mA)
18.12. set_standard_digital_input_action(port, action)
Using this method sets the selected standard digital input register to either a "default" or "freedrive" action.

See also:
• set_input_actions_to_default
• set_configurable_digital_input_action
• set_tool_digital_input_action
• set_gp_boolean_input_action
Parameters
port: The standard digital input port number. (integer)
action: The type of action. The action can either be "default" or "freedrive". (string)
Example command: set_standard_digital_input_action(0, "freedrive")
• Example Parameters:
• n is the standard digital input register 0
• f is set to "freedrive" action
Script Directory 135 e-Series
18. Module ioconfiguration
18.13. set_tool_analog_input_domain(port, domain)
Set domain of analog inputs in the tool
For the controller box inputs see set_standard_analog_input_domain.
Parameters
port: analog input port number: 0 or 1
domain: analog input domains: 0: 4-20mA, 1: 0-10V
Example command: set_tool_analog_input_domain(1,1)
• Example Parameters:
• port = tool analog input 1
• domain = 1 (0-10 volts)

18.14. set_tool_digital_input_action(port, action)
Using this method sets the selected tool digital input register to either a "default" or "freedrive" action.
See also:
• set_input_actions_to_default
• set_standard_digital_input_action
• set_configurable_digital_input_action
• set_gp_boolean_input_action
Parameters
port: The tool digital input port number. (integer)
action: The type of action. The action can either be "default" or "freedrive". (string)
Example command: set_tool_digital_input_action(0, "freedrive")
• Example Parameters:
• n is the tool digital input register 0
• f is set to "freedrive" action