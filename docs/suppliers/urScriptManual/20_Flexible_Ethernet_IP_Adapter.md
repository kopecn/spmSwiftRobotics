20. Flexible Ethernet/IP Adapter
Starting from Polyscope 5.16, Ethernet/IP Adapter allows for adding custom assemblies.
This feature is especially useful when interfacing with Robot Options on CNC machines, where CNC machine
is Ethernet/IP master, and expects specific data layout on Adapter device.
Performance
It is recommended to consider performance limitation before integrating custom Ethernet/IP Adapter with PLC
Scanner.
All read and write operations are delegated to non-realtime threads. In internal tests write/read turnaround
cycle with PLC RPI set to 5ms was on average 40ms, maximum at 90ms.
At this point it is not recommended to use custom assemblies for applications requiring RPI below 20ms.
Maximum recommended assembly size is 500 bytes.
Examples
Refer to Flexible Ethernet/IP URCap, and program examples available on Universal-Robots github to get
started quickly.
20.1. Configuration interface
Configuration interface is exposed on Ethernet/IP service XML-RPC server, port 40000.
20.1.1. add_configuration(Robot_to_PLC_inst_id, Robot_to_PLC_inst_
size, PLC_to_Robot_inst_id, PLC_to_Robot_inst_size)
Function creates one input, and one output instances that typically forms a Ethernet/IP connection object.
After function is called, external Ethernet/IP Scanner (on PLC, or CNC machine) can use new connection.
Some PLCs require connection object to be defined in EDS (Electronic Data Sheet) file. Separate guide is
available on request explaining how to add custom connections, and assemblies to existing Universal Robots
EDS file.

NOTICE
Universal Robots built-in instances 100, and 112 cannot be overwritten. Attempt to configure
those instances will result in an error.
Parameters
Robot_to_PLC_inst_id: An integer, unique Robot→PLC instance ID.
Robot_to_PLC_inst_size: An integer, Robot→PLC instance data size in bytes.
PLC_to_Robot_inst_id: An integer, unique PLC→Robot instance ID.
PLC_to_Robot_inst_size: An integer, PLC→Robot instance data size in bytes.
Returns
Script Directory 153 e-Series
20. Flexible Ethernet/IP Adapter
• True: If new assembly was created, or identical one already exists.
• False: If one of the instances already exists, or parameter error.
Example command 1 (called from URCap code):
Refer to Flexible Ethernet/IP example URCap on Universal-Robots github
Example command 2 (called from URScript):
global eip_handle=rpc_factory("xmlrpc", "http://127.0.0.1:40000/RPC2")
global result = eip_handle.add_configuration(101, 88, 111, 44)
eip_handle.closeXMLRPCClientConnection()
# pause for 1s while Ethernet/IP service is configuring data exchange files
for new instances
sleep(1)
Assembly with input and output instances is created in backend service.

20.1.2. is_instance_connected(PLC_to_Robot_inst_id)
Function checks if the given instance id has a connection.
NOTICE
The current implementation only checks for instance id for PLC_to_Robot.
Parameters
PLC_to_Robot_inst_id: An integer, unique PLC→Robot instance ID.
Returns
• True: If the given instance id is connected.
• False: If the given instance id is either not connected or not created.
20.2. Functions
Process data exchanged through the connection assembly instances is accessible using read and write
handle objects in the robot program. Typically handle would be opened once and data layout will be defined in
the "Before Start" section (or by script contributed from URCap). Afterwards individual reads and writes can be
executed with methods on the configured handles.
20.2.1. eip_reader_factory(instance_name, data_size)
Opens handle to PLC→Robot data. Typically placed in the "Before Start" section of the program.
Parameters
e-Series 154 Script Directory
20. Flexible Ethernet/IP Adapter
instance_name: A string, instance id.
data_size: An integer, instance data size in bytes.
Return Value
handle object The handle provides a read only access to the instance data.
Example global cnc_status = eip_reader_factory("111", 44)
Opens the handle to PLC→Robot instance with an id 111, and data size 44 bytes. Handle is saved into
cnc_status global variable.
20.2.2. eip_writer_factory(instance_name, data_size)
Opens handle to Robot→PLC data. Typically placed in "Before Start" section of the program.
Parameters
instance_name: A string, instance id.
data_size: An integer, instance data size in bytes.
Return Value
handle object The handle provides a write only access to the instance data.
Example global cnc_command = eip_writer_factory("101", 88)
Opens the handle to Robot→PLC instance with an id 101, and data size 88 bytes. Handle is saved into
cnc_command global variable.
20.3. Methods on reader and writer handles
Handles are used to define underlying assembly memory layout, and later read and write process data.
Methods are invoked on handles using '.' operator. Methods are grouped in 2 families:
• Memory layout definitions: informing handle on how data is visible to the external device, and assigning
labels. All methods in this family start with "define_...".
• Data access methods: read and write process data.

20.3.1. define_...(offset, data_name) - numeric fields
Family of functions defining single numeric field.
• define_uint8(offset, data_name)
• define_uint16(offset, data_name)
• define_int16(offset, data_name)
• define_int32(offset, data_name)
• define_float32(offset, data_name)
Methods define individual labels in assembly instances exchanged with PLC. Labels are later used by read,
and write methods.
Script Directory 155 e-Series
20. Flexible Ethernet/IP Adapter
NOTE: Overlapping data definitions are not allowed, except for overlap with bit fields.
Parameters
offset: An integer, position of the data in the instance in bytes.
data_name: A string, label.
Example cnc_status.define_uint8(11, "service_code")
Set label "service_code" to single byte at offset 11.
20.3.2. define_bit(offset, bit_number, data_name, bitfield_width=1)
Method defines individual label in the assembly instance exchanged with PLC. Label is later used by read, and
write methods.
NOTE: Overlapping bit definitions are not allowed, except for overlap with numeric fields.

Parameters
offset: An integer, position of the data in the instance in bytes.
bit_number most significant bit will be 7, 15, or 31.
: An integer, bit number in a word. 0 = least significant bit. Depending on the bitfield_width
data_name: A string, label.
bitfield_width: An integer, can be 1, 2 or 4 representing bit in byte, word, or double word. (Optional)
Example 1 cnc_status.define_bit(0, 0, "comm_check")
Set label "comm_check" to bit 0 in byte 0.
Example 2 cnc_status.define_bit(16, 9, "door_opened", 2)
Set label "door_opened" to bit 9 in word starting on byte 16.
20.3.3. define_..._array(offset, length, data_name) - arrays of numeric
fields
Family of functions defining arrays of numeric fields.
• define_uint8_array(offset, length, data_name)
• define_uint16_array(offset, length, data_name)
• define_int16_array(offset, length, data_name)
• define_int32_array(offset, length, data_name)
• define_float32_array(offset, length, data_name)
Methods define individual labels in assembly instances exchanged with PLC. Labels are later used by read,
and write methods.
NOTE: Overlapping data definitions are not allowed, except for overlap with bit fields.
Parameters
e-Series 156 Script Directory
20. Flexible Ethernet/IP Adapter
offset: An integer, position of the data in the instance in bytes.
length: An integer, number of elements of the array with base size specified by the data type (e.g. for
define_uint16_array length = 4 will use 8 bytes).
data_name: A string, label.
Example 1 cnc_command.define_uint8_array(48, 32, "work_number")
set label "work_number" to 32 byte long array starting at byte 48.
Example 2 cnc_command.define_int16_array(120, 3, "axes_offset")
Set label "axes_offset" to 3 words (6 byte long) array starting at byte 120.
20.3.4. define_string(offset, length, data_name)
Method defines individual label in the assembly instance exchanged with PLC. Label is later used by read, and
write methods.
NOTE: Overlapping data definitions are not allowed.
Parameters
offset: An integer, position of the data in the instance in bytes.
length: An integer, number of characters in the string. String should be terminated with 0 if it's shorter
than length.
data_name: A string, label.
Example cnc_command.define_string(200, 32, "program_name")
Set label "program_name" to up to 31 character long string starting at byte 200. Space should be left for
termination null character.
20.3.5. read(data_names)
Method reads one or more data labels written by external PLC. Latest data is read from internal buffer.

Parameters
data_names:
• Single string - one data label to read. Method returns basic data type.
• Array of strings - multiple data labels to read. Method returns structure with fields named with data
labels.
Return Value
Depending on the parameter method returns basic type, or complex type (struct with named fields)
Example 1 comm_check = cnc_status.read("comm_check")
Reads single bit to comm_check URScript variable.
Example 2 service_request = cnc_status.read(["door_closed", "service_code"])
Script Directory 157 e-Series
20. Flexible Ethernet/IP Adapter
Reads multiple fields that can be accessed as service_request struct members.
Individual basic types can be extracted from struct with '.' operator: service_request.door_closed,
service_request.service_code
20.3.6. write(data_struct)
Method writes one or more data labels to memory read external PLC.
All labels in struct are guaranteed to be written at the same time to the assembly instance data.
NOTE: method will do a range check based on the type of the data label. Numbers exceeding data type will
stop a program with runtime exception.

Parameters
data_struct:Struct where member names are data labels, and values are data contents
Example 1 cnc_command.write(struct(work_number = [1, 2, 3, 4], search_start =
True))
Set work_number label array, and search_start bit.
Example 2 cnc_command.write(struct(door_open = True))
Set single bit with "door_open" label.
Example 3
s = struct(robot_ready = False, machine_stop = False, robot_alarm = False)
s.robot_ready = True
cnc_command.write(s)
Define global struct, and reuse in calls to write method.
20.3.7. clear()
Method sets all memory managed by write handle to zero.
20.3.8. set_watchdog(frequency, action)
Registers a new watchdog on the handle. This can only be called on a read handle. After the call, the new
watchdog will start immediately.
Calling multiple times on the same handle reconfigures watchdog with new parameters.
Parameters
frequency: A float, minimum allowed communication frequency. Allowed values are greater then 0 and
lower or equal to 10 Hz. Fractional frequencies are allowed.

20. Flexible Ethernet/IP Adapter
action : An integer
• 0: Ignore - no reaction when the watchdog times out.
• 1: Pause - protective stop and the program will be paused.
• 2: Stop - protective stop and the program will be stopped.
Example cnc_status.set_watchdog(2.5, 1)
Pause program if no data was received from master for more than 400ms.
20.3.9. start_watchdog()
Method starts the watchdog. Throws a runtime error if watchdog is not registered.
NOTE: Watchdog starts automatically when it's created. This function can be used in combination with stop_
watchdog().
20.3.10. stop_watchdog()
Method disables the watchdog. Throws a runtime error if watchdog is not registered.
This method can be used to temporarily mute watchdog.
20.3.11. close()
Method closes handle object, and frees memory associated. It's recommended to close handles if they are
used only once in a program. If handle is used repeatedly then it's recommended to keep it open over the
lifespan of the program.
NOTE: The same handle can not be opened again, new handle has to be created.