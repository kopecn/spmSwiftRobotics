# Real-Time Data Exchange (RTDE) Guide

## Introduction

The Real-Time Data Exchange (RTDE) interface provides a way to synchronize external applications with the UR controller over a standard TCP/IP connection, without breaking any real-time properties of the UR controller. This functionality is useful for interacting with fieldbus drivers (e.g., Ethernet/IP), manipulating robot I/O, and plotting robot status (e.g., robot trajectories). The RTDE interface is by default available when the UR controller is running.

The synchronization is configurable and can involve the following data:

- **Output**: robot-, joint-, tool-, and safety status, analog and digital I/O’s, and general-purpose output registers.  
- **Input**: digital and analog outputs and general-purpose input registers.

The RTDE functionality is split into two stages: a setup procedure and a synchronization loop. On connection to the RTDE interface, the client sets up the variables to be synchronized. The client sends a setup list of named input and output fields to be included in the data synchronization packages. This list is known as a *recipe*. Each successfully configured input recipe receives a unique recipe ID. Supported field names and their associated data types are listed below.

When the synchronization loop starts, the RTDE interface sends the requested data to the client in the specified order. The client sends updated inputs to the RTDE interface when values change. Data synchronization uses serialized binary data. Packages share a general structure with a header and a payload, if applicable.

## Key Features

- **Real-time synchronization**: The RTDE typically generates output messages at 125 Hz. However, if the controller lacks computational resources, it will skip some output packages and only send the most recent data.  
- **Input messages**: Variables in the controller can be updated via multiple messages. Inputs retain their last received value, and only one RTDE client can control a specific variable at any time.  
- **Runtime environment**: An RTDE client can run on the UR Control Box PC or any external PC. Running the RTDE client on the Control Box avoids network latency but may compete with the UR controller for resources.  
- **Protocol changes**: The RTDE protocol may be updated by UR. RTDE clients can request specific protocol versions to ensure compatibility.

## Additional Resources

Reference implementation for RTDE protocol is available in a GitHub repository. API documentation of the Python library is available on the *RTDE Client Python Module* page.

## Field Names and Associated Types

### Robot Controller Inputs

| Name                          | Type     | Comment                                                                 | Introduced in Version |
|-------------------------------|----------|-------------------------------------------------------------------------|------------------------|
| `speed_slider_mask`           | UINT32   | 0 = don’t change speed slider, 1 = use `speed_slider_fraction`          |                        |
| `speed_slider_fraction`       | DOUBLE   | New speed slider value                                                  |                        |
| `standard_digital_output_mask`| UINT8    | Standard digital output bit mask                                        |                        |
| `standard_digital_output`     | UINT8    | Standard digital outputs                                                 |                        |
| `configurable_digital_output_mask` | UINT8 | Configurable digital output bit mask                                   |                        |
| `configurable_digital_output` | UINT8    | Configurable digital outputs                                             |                        |
| `standard_analog_output_mask` | UINT8    | Standard analog output mask (Bits 0–1: `standard_analog_output_0` \| `standard_analog_output_1`) | |
| `standard_analog_output_type` | UINT8    | Output domain {0=current[mA], 1=voltage[V]} (Bits 0–1: outputs 0 and 1) |                        |
| `standard_analog_output_0`    | DOUBLE   | Standard analog output 0 (ratio) [0..1]                                 |                        |
| `standard_analog_output_1`    | DOUBLE   | Standard analog output 1 (ratio) [0..1]                                 |                        |
| `input_bit_registers0_to_31`  | UINT32   | General purpose bits reserved for FieldBus/PLC interface usage         |                        |
| `input_bit_registers32_to_63` | UINT32   | General purpose bits reserved for FieldBus/PLC interface usage         |                        |
| `input_bit_register_X`        | BOOL     | 64 general-purpose bits (X: [64..127]) for external RTDE clients        | 5.3.0                  |
| `input_int_register_X`        | INT32    | 48 integer registers ([24..47] available to external RTDE clients)      | [24..47] 5.3.0         |
| `input_double_register_X`     | DOUBLE   | 48 double registers ([24..47] for external RTDE clients)                | [24..47] 5.3.0         |
| `external_force_torque`       | VECTOR6D | Input external wrench when using `ft_rtde_input_enable` built-in        |                        |

### Robot Controller Outputs

> **NOTE**: The robot controller requires that a client subscribes to at least one output. The client should read data periodically from the socket. The connection is closed by the robot controller when the receive buffer overflows.

| Name                             | Type         | Comment                                                                                     | Introduced in Version     |
|----------------------------------|--------------|---------------------------------------------------------------------------------------------|----------------------------|
| `timestamp`                       | DOUBLE       | Time elapsed since the controller was started [s]                                           |                            |
| `target_q`                        | VECTOR6D     | Target joint positions                                                                       |                            |
| `target_qd`                       | VECTOR6D     | Target joint velocities                                                                       |                            |
| `target_qdd`                      | VECTOR6D     | Target joint accelerations                                                                    |                            |
| `target_current`                  | VECTOR6D     | Target joint currents                                                                          |                            |
| `target_moment`                   | VECTOR6D     | Target joint moments (torques)                                                                 |                            |
| `actual_q`                        | VECTOR6D     | Actual joint positions                                                                         |                            |
| `actual_qd`                       | VECTOR6D     | Actual joint velocities                                                                         |                            |
| `actual_current`                  | VECTOR6D     | Actual joint currents                                                                           |                            |
| `actual_current_window`            | VECTOR6D     | Allowed deviations from target currents                                                        |                            |
| `actual_current_as_torque`        | VECTOR6D     | Actual joint currents converted to torques                                                     |                            |
| `joint_control_output`             | VECTOR6D     | Joint control currents                                                                           |                            |
| `actual_TCP_pose`                 | VECTOR6D     | (x,y,z,rx,ry,rz) actual Cartesian coords of the tool                                          |                            |
| `actual_TCP_speed`                | VECTOR6D     | Actual Cartesian speed (linear + rotational)                                                   |                            |
| `actual_TCP_force`                | VECTOR6D     | Generalized forces, compensating for payload                                                  |                            |
| `target_TCP_pose`                  | VECTOR6D     | Target (x,y,z,rx,ry,rz) for TCP                                                                  |                            |
| `target_TCP_speed`                 | VECTOR6D     | Target Cartesian speed (linear + rotational)                                                    |                            |
| `tcp_offset`                        | VECTOR6D     | Transformation from flange to TCP (x,y,z,rx,ry,rz)                                            |                            |
| `actual_TCP_acceleration`          | VECTOR6D     | Actual TCP acceleration (linear in m/s² + rotational in rad/s²)                                |                            |
| `target_TCP_acceleration`           | VECTOR6D     | Target TCP acceleration                                                                          |                            |
| `actual_digital_input_bits`        | UINT64       | State of digital inputs (0–7: standard, 8–15: configurable, 16–17: tool)                      |                            |
| `actual_configurable_digital_input_bits` | UINT64 | State of configurable digital inputs                                                           |                            |
| `joint_temperatures`               | VECTOR6D     | Temperatures of each joint in °C                                                                |                            |
| `actual_execution_time`             | DOUBLE       | Controller real-time thread execution time [ms]                                                 |                            |
| `target_execution_time`              | DOUBLE       | Desired execution time for real-time thread [ms]                                               |                            |
| `robot_mode`                        | INT32        | Robot mode                                                                                      |                            |
| `joint_mode`                        | VECTOR6INT32 | Joint control modes                                                                              |                            |
| `safety_mode`                       | INT32        | Safety mode                                                                                     |                            |
| `safety_status`                     | INT32        | Safety status                                                                                   |                            |
| … *and more fields* …               |              |                                                                                                 |                            |

### Time Scale Source

| Value | Description |
|---|---|
| -1 | Other |
| 0 | Program is not running |
| 1 | Speed is not scaled |
| 2 | Joint torque limit reached |
| 3 | Joint acceleration limit reached |
| 4 | Power supply limit reached |
| 5 | Momentum safety limit reached |
| 6 | Stopping time safety limit reached |
| 7 | Stopping distance safety limit reached |
| 8 | Tool speed safety limit reached |
| 9 | Elbow speed safety limit reached |
| 10 | Joint speed safety limit reached |
| 11 | Smooth transition after safety state change |
| 12 | Stopping distance defined through safety API reached |
| 13 | User-defined tool wrench limit reached |
| 14 | Scaling due to external axis speed limit |
| 15 | Scaling due to external axis stopping |
| *Unlisted values are reserved for internal use.*

## Data Types

| Name            | Description                           | Size (bits) |
|---|---|---|
| BOOL            | Boolean (0 = False, anything else = True) | 8 |
| UINT8           | Unsigned 8-bit integer                  | 8 |
| UINT32          | Unsigned 32-bit integer                 | 32 |
| UINT64          | Unsigned 64-bit integer                 | 64 |
| INT32           | Signed 32-bit integer (two’s complement) | 32 |
| DOUBLE          | IEEE 754 floating point                  | 64 |
| VECTOR3D        | 3 × DOUBLE                              | 3 × 64 |
| VECTOR6D        | 6 × DOUBLE                              | 6 × 64 |
| VECTOR6INT32    | 6 × INT32                               | 6 × 32 |
| VECTOR6UINT32   | 6 × UINT32                              | 6 × 32 |
| STRING          | ASCII char array (length × 8 bits)       | — (network byte order) |

## Protocol

- **EE** = External Executable  
- **CON** = Robot Controller  

**Direction**  
- Output: `CON → EE`  
- Input: `CON ← EE`

### Header

| Field name     | Data Type   |
|---|---|
| package size    | `uint16_t`  |
| package type    | `uint8_t`   |

All packages use this header.

Supported package types:

| Package name                              | Type | ASCII equivalent |
|---|---|---|
| `RTDE_REQUEST_PROTOCOL_VERSION`            | 86  | `V` |
| `RTDE_GET_URCONTROL_VERSION`               | 118 | `v` |
| `RTDE_TEXT_MESSAGE`                         | 77  | `M` |
| `RTDE_DATA_PACKAGE`                         | 85  | `U` |
| `RTDE_CONTROL_PACKAGE_SETUP_OUTPUTS`        | 79  | `O` |
| `RTDE_CONTROL_PACKAGE_SETUP_INPUTS`         | 73  | `I` |
| `RTDE_CONTROL_PACKAGE_START`                 | 83  | `S` |
| `RTDE_CONTROL_PACKAGE_PAUSE`                 | 80  | `P` |

### RTDE_REQUEST_PROTOCOL_VERSION

**Fields:**

| Field name       | Data Type  |
|---|---|
| package size     | `uint16_t` |
| package type     | `uint8_t`  |
| protocol version | `uint16_t` |

**Direction:** `EE → CON`  
**Return:**

| Field name   | Data Type |
|---|---|
| package size  | `uint16_t` |
| package type  | `uint8_t`  |
| accepted      | `uint8_t`  |

- The controller returns 1 (success) or 0 (failure).  
- On success, the EE should use the negotiated protocol version going forward.

### RTDE_GET_URCONTROL_VERSION

**Fields:**

| Field name | Data Type |
|---|---|
| package size | `uint16_t` |
| package type | `uint8_t` |
| major | `uint32_t` |
| minor | `uint32_t` |
| bugfix | `uint32_t` |
| build | `uint32_t` |

**Direction:** `EE → CON`  
**Return:** Same structure with version numbers of the controller.

### RTDE_TEXT_MESSAGE (protocol v.1)

**Request (EE → CON):**

| Field name     | Data Type |
|---|---|
| package size    | `uint16_t` |
| package type    | `uint8_t` |
| message type    | `uint8_t` |
| message         | `string`   |

**Response (CON → EE):**

| Field name       | Data Type |
|---|---|
| package size       | `uint16_t` |
| package type       | `uint8_t`  |
| message length     | `uint8_t`  |
| message            | `string`   |
| source length      | `uint8_t`  |
| source             | `string`   |
| warning level      | `uint8_t`  |

- Warning levels include: EXCEPTION, ERROR, WARNING, INFO  
- EE → CON: used to send exception, error, warning, or info message  
- CON → EE: used to indicate protocol failures or issues

### RTDE_TEXT_MESSAGE (protocol v.2)

**Fields:**

| Field name     | Data Type |
|---|---|
| package size     | `uint16_t` |
| package type     | `uint8_t`  |
| message length   | `uint8_t`  |
| message          | `string`   |
| source length    | `uint8_t`  |
| source           | `string`   |
| warning level    | `uint8_t`  |

**Direction:** Bilateral  
**Return:** Not available

### RTDE_DATA_PACKAGE

**Fields:**

| Field name     | Data Type |
|---|---|
| package size    | `uint16_t` |
| package type    | `uint8_t`  |
| recipe id       | `uint8_t`  |
| \<variable\>    | \<data type\> |

- The `<variable>` fields are serialized binary according to the recipe defined in SETUP.  
- Direction: Bilateral. No return package.

### RTDE_CONTROL_PACKAGE_SETUP_OUTPUTS (protocol v.1)

**Request (EE → CON):**

| Field name     | Data Type |
|---|---|
| package size    | `uint16_t` |
| package type    | `uint8_t`  |
| variable names  | `string`   |

**Response:**

| Field name     | Data Type |
|---|---|
| package size    | `uint16_t` |
| package type    | `uint8_t`  |
| variable types  | `string`   |

- Returns the types in the same order as requested variables.  
- Supported types: VECTOR6D, VECTOR3D, VECTOR6INT32, VECTOR6UINT32, DOUBLE, UINT64, UINT32, INT32, BOOL, UINT8  
- If a variable is not found, its type is returned as “NOT_FOUND” and the recipe is invalid.

### RTDE_CONTROL_PACKAGE_SETUP_OUTPUTS (protocol v.2)

**Request:**

| Field name        | Data Type |
|---|---|
| package size        | `uint16_t` |
| package type        | `uint8_t`  |
| output frequency    | `double`   |
| variable names      | `string`   |

- The frequency must be between 1 and 500 Hz. The effective output rate = `floor(500 / frequency)`.  
- Variables are comma-separated.

**Response:**

| Field name        | Data Type |
|---|---|
| package size        | `uint16_t` |
| package type        | `uint8_t`  |
| output recipe id    | `uint8_t`  |
| variable types       | `string`   |

- Same type list as v.1.  
- If any variable is “NOT_FOUND”, recipe id = 0 (invalid).

### RTDE_CONTROL_PACKAGE_SETUP_INPUTS

**Request (EE → CON):**

| Field name     | Data Type |
|---|---|
| package size    | `uint16_t` |
| package type    | `uint8_t`  |
| variable names  | `string`   |

- The controller supports up to 255 input recipes (0 is reserved).

**Response:**

| Field name      | Data Type |
|---|---|
| package size      | `uint16_t` |
| package type      | `uint8_t`  |
| input recipe id   | `uint8_t`  |
| variable types     | `string`   |

- Return “IN_USE” if a variable is claimed by another client.  
- Return “NOT_FOUND” if a variable does not exist.  
- If any are IN_USE or NOT_FOUND, recipe id = 0.

### RTDE_CONTROL_PACKAGE_START

**Request:**

| Field name   | Data Type |
|---|---|
| package size  | `uint16_t` |
| package type  | `uint8_t`  |

**Response:**

| Field name   | Data Type |
|---|---|
| package size  | `uint16_t` |
| package type  | `uint8_t`  |
| accepted      | `uint8_t`  |

- 1 = success, 0 = failure.

### RTDE_CONTROL_PACKAGE_PAUSE

**Request:**

| Field name   | Data Type |
|---|---|
| package size  | `uint16_t` |
| package type  | `uint8_t`  |

**Response:**

| Field name   | Data Type |
|---|---|
| package size  | `uint16_t` |
| package type  | `uint8_t`  |
| accepted      | `uint8_t`  |

- The controller always accepts a pause command (returns 1).

---

_This is based on the official RTDE guide from Universal Robots._ :contentReference[oaicite:0]{index=0}  
