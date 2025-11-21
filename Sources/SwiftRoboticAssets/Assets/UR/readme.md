# URScript Command and Control System - Living Specification

## Overview

This URScript implements a multi-threaded command and control system for Universal Robots (UR) controllers. The system provides discrete command execution, real-time motion streaming, and coordinated buffer management for smooth robot operation.

## System Architecture

### Three Primary Run Loops (Threads)

1. **Command and Control Thread** - Handles discrete commands with transaction-based protocol
2. **Streaming Handler Thread** - Manages motion data buffering and refill requests
3. **Motion Execution Thread** - Dequeues buffered commands and executes robot motion

All threads monitor for shutdown conditions and use `sync()` to conserve computational resources on the UR robot controller.

---

## Thread 1: Command and Control

### Purpose
Manages discrete command execution using a transaction-based protocol over a reverse socket connection to the host controller.

### Socket Configuration
- **Host IP**: Defined by `con.host_ip` (default: "192.168.3.2")
- **Port**: Defined by `con.command_port` (default: 50001)
- **Socket Name**: Defined by `con.command_socket_name` (default: "socket_cmd")
- **Connection Type**: Reverse socket (robot initiates connection to host)
- **Reconnect Logic**: Automatic retry with configurable delay (default: 1.0 seconds)

### Connection Behavior

The command control thread implements automatic reconnection:
1. On startup, attempts to connect to host
2. If connection fails, waits `con.reconnect_delay` seconds and retries
3. Continues retrying until either:
   - Connection succeeds, OR
   - `shutdown_requested` flag is set to True
4. Once connected, sends unsolicited event 1100 ("Command socket connected")

### Transaction Protocol

#### Command Format
```
<transactionID,command,arguments>
```

**Components:**
- `transactionID`: Integer from 1-899, assigned by host, wraps back to 1 after 899
- `command`: Command name (string)
- `arguments`: Optional comma-separated arguments (string)
- **Delimiters**: Commands must be enclosed in angle brackets `<` and `>`

**Example:**
```
<123,home,>
<456,moveto,1.57,-1.57,0.0,0.0,1.57,0.0>
```

**Socket Reading:**
The robot uses `socket_read_string()` with `prefix="<"` and `suffix=">"` to automatically extract commands:
- Only data between `<` and `>` is read
- The angle brackets are automatically stripped
- Multiple commands can be sent at once (e.g., `<123,home,><124,status,>`)
- The suffix defines where each message ends, preserving remaining data in socket buffer

#### Response Flow

1. **ACK (Acknowledgment)**
   ```
   <transactionID,ack,code>
   <transactionID,ack,code,verbiage>
   ```
   - Sent immediately after receiving and validating command
   - Optional verbiage field provides additional context for errors
   - `code = 0`: Command parsed and recognized, will execute
   - `code = 1`: Parse error, command rejected (verbiage contains malformed command string)
   - `code = 2`: Command not found/not recognized, command rejected (verbiage contains unrecognized command name)

2. **EVT (Event)** - Optional, during execution
   ```
   <transactionID,evt,eventCode,verbiage>
   ```
   - Sent during command execution for status updates
   - `eventCode`: Integer code identifying event type
   - `verbiage`: Human-readable description
   - Only fired during active transaction lifecycle

3. **RES (Result)** - Final response
   ```
   <transactionID,res,code>
   <transactionID,res,code,verbiage>
   ```
   - Marks end of transaction
   - Optional verbiage field provides additional context
   - `code = 0`: Success
   - `code = 1`: Error

#### Unsolicited Events (No Associated Transaction)

Events that are not related to a specific user command (unsolicited transactions) use a special transaction ID of `-1`:
```
<-1,evt,eventCode,verbiage>
```

**Definition**: An **unsolicited transaction** is an event initiated by the robot itself, not in response to a user command.

**Use Cases:**
- System-level events (connection established, disconnection warnings)
- Autonomous error detection (protective stops, joint limits reached)
- Status changes not triggered by commands (temperature warnings, mode changes)
- Critical errors requiring immediate attention

**Example:**
```
<-1,evt,1100,Command socket connected>
<-1,evt,9001,Emergency stop triggered>
<-1,evt,5001,Joint 4 approaching limit>
```

### Supported Commands

| Command | Arguments | Description |
|---------|-----------|-------------|
| `init` | None | Initialize robot system, reset state |
| `home` | None | Move robot to home position |
| `ver` | None | Return system version |
| `status` | None | Return current system status and buffer count |
| `currentpose` | None | Return current TCP pose |
| `currentposture` | None | Return current joint positions |
| `startstreaming` | None | Enable streaming mode |
| `stopstreaming` | None | Disable streaming mode, clear buffer |

### Event Codes

| Code | Description | Type |
|------|-------------|------|
| 1000 | Initializing robot system | Solicited |
| 1001 | Moving to home position | Solicited |
| 1002 | Version information | Solicited |
| 1003 | Status information | Solicited |
| 1004 | Current TCP pose | Solicited |
| 1005 | Current joint posture | Solicited |
| 1006 | Starting streaming mode | Solicited |
| 1007 | Stopping streaming mode | Solicited |
| 1100 | Command socket connected | **Unsolicited** |
| 9001 | Failed to connect to command socket | **Unsolicited** |

**Legend:**
- **Solicited**: Event occurs during execution of a user command (uses command's transaction ID)
- **Unsolicited**: Event occurs independently (uses transaction ID `-1`)

---

## Thread 2: Streaming Handler

### Purpose
Manages a real-time motion buffer by monitoring buffer levels and requesting data refills from the host when needed.

### Socket Configuration
- **Host IP**: Defined by `con.host_ip` (default: "192.168.3.2")
- **Port**: Defined by `con.streaming_port` (default: 50002)
- **Socket Name**: Defined by `con.streaming_socket_name` (default: "socket_stream")
- **Connection Type**: Reverse socket (robot initiates connection to host)
- **Reconnect Logic**: Automatic retry with configurable delay (default: 1.0 seconds)

### Connection Behavior

The streaming handler thread implements automatic reconnection:
1. On startup, attempts to connect to host
2. If connection fails, waits `con.reconnect_delay` seconds and retries
3. Continues retrying until either:
   - Connection succeeds, OR
   - `shutdown_requested` flag is set to True
4. Once connected, begins handling buffer refill operations when streaming is active

### Buffer Configuration

- **Buffer Size**: 250 samples (0.5 seconds at 500Hz control frequency)
- **Refill Threshold**: 25 samples (50ms at 500Hz)
- **Poses Per Fill**: 5 poses (30 floats / 6 joints per pose)
- **Data Type**: Target joint coordinates [q1, q2, q3, q4, q5, q6] in radians
- **Fill Duration**: Each buffer fill provides 10ms of motion data (5 poses × 2ms per pose)

### Buffer Management

#### Buffer Refill Protocol

1. Thread polls buffer level at sync frequency
2. When `count < con.buffer_refill_threshold`:
   - Send refill request: `<more>`
3. Host responds with 30 floats (5 complete poses)
4. Robot reads using `socket_read_ascii_float(30, socket_name, timeout)`
5. Data is parsed and 5 poses are added to ring buffer in batch
6. Ring buffer accepts all writes; if full, oldest data is automatically discarded

#### Buffer Structure

**Type**: **Ring Buffer (Circular Buffer / Circular Queue)** implemented as **URScript struct containing flat list with index arithmetic**

**Storage Format:**
```urscript
# Ring buffer implemented as struct with all state encapsulated
global ring_buffer = struct(
    data = make_list(con.buffer_size * 6, 0.0, con.buffer_size * 6),  # Flat list of joint positions
    head = 0,       # Write position
    tail = 0,       # Read position
    count = 0,      # Number of valid poses
    isPrimed = False,  # Flag indicating if buffer has received initial data from host
    trID = "-1"     # Transaction ID for the streaming session
)
# Total elements in data: 250 poses × 6 joints = 1500 floats
# Access pattern: ring_buffer.data[pose_index * 6 + joint_index]
```

**Ring Buffer Components:**

| Component | Struct Member | Description | Range |
|-----------|---------------|-------------|-------|
| **buffer (data)** | `ring_buffer.data` | Fixed-size flat list storing joint positions | 1500 floats |
| **head (write_index)** | `ring_buffer.head` | Index where next element will be written | 0 to 249 |
| **tail (read_index)** | `ring_buffer.tail` | Index where next element will be read | 0 to 249 |
| **capacity (N)** | `con.buffer_size` | Total number of poses the buffer can hold (constant) | 250 poses |
| **count** | `ring_buffer.count` | Number of valid (filled) entries | 0 to 250 |
| **isPrimed** | `ring_buffer.isPrimed` | Flag indicating if buffer has received data from host | True/False |
| **trID** | `ring_buffer.trID` | Transaction ID of the streaming session for response tracking | String |

**Index Arithmetic:**
- To access pose P, joint J: `buffer.data[P * 6 + J]`
- To write pose at index I: write to `buffer.data[I*6]` through `buffer.data[I*6+5]`
- To read pose at index I: read from `buffer.data[I*6]` through `buffer.data[I*6+5]`

**Ring Buffer Operation (True Circular Buffer Semantics):**
- **Writes always succeed**: New data is always accepted, even when buffer is full
- **Overwrite behavior**: When buffer is full and writing, oldest data is discarded (tail advances)
- Write position advances circularly: `ring_buffer.head = (ring_buffer.head + 1) % con.buffer_size`
- Read position advances circularly: `ring_buffer.tail = (ring_buffer.tail + 1) % con.buffer_size`
- Buffer wraps around: when index reaches 249, next index is 0
- **Full buffer writes**: If `ring_buffer.count == con.buffer_size`, tail advances to discard oldest pose
- `ring_buffer.count` tracks occupancy: increments only if `ring_buffer.count < con.buffer_size`, never exceeds capacity
- **Read protection**: Only reads when `buffer.count > 0` to prevent reading invalid data

**Why Use a Struct?**

The ring buffer is encapsulated in a URScript struct for several important reasons:
- **State encapsulation**: All buffer state (data, head, tail, count) grouped in single object
- **Cleaner code**: `buffer.head` is more readable than standalone `head` variable
- **Namespace clarity**: Avoids naming conflicts with other variables
- **Atomic passing**: Can pass entire buffer state to functions as single parameter
- **Better organization**: Makes it clear these variables are related components
- **Type safety**: URScript struct enforces consistent member types

**Buffer Initialization:**

The buffer is pre-filled with the **current joint position** at:
1. **Script startup** - Before threads start
2. **Init command** - When user runs `<ID,init,>`

**Why pre-fill with current position?**
- Prevents sudden motion jumps when streaming starts
- Ensures buffer always contains valid, safe positions
- Robot can safely execute from any buffer position
- Provides smooth transition when switching modes

**Why Flat List?**
- URScript does not support list of lists (nested lists)
- Flat array with index arithmetic is the proper URScript pattern
- More memory efficient and faster access
- Compatible with `make_list()` for proper initialization

#### Synchronization

**Critical Sections** protect buffer access:
- URScript provides a single global critical section using `enter_critical` and `exit_critical`
- Only one thread can be inside a critical section at any time
- All buffer operations (reading/writing head, tail, count, and data) must be protected

All buffer access is wrapped in critical sections to prevent race conditions.

### Data Format

The streaming handler uses URScript's `socket_read_ascii_float()` function to efficiently read binary float data.

**Expected format from host:**
```
( q1_p1, q2_p1, q3_p1, q4_p1, q5_p1, q6_p1, q1_p2, q2_p2, q3_p2, q4_p2, q5_p2, q6_p2, ..., q6_p5 )
```

Where:
- Format uses parentheses `( )` with comma-separated values
- Each `q` value is a joint angle in radians (ASCII formatted float)
- `_pN` denotes pose number (1 through 5)
- Total: 30 float values representing 5 complete 6-DOF joint configurations

**Example (5 poses, simplified):**
```
( 0.0, -1.57, 1.57, -1.57, -1.57, 0.0, 0.1, -1.56, 1.58, -1.56, -1.56, 0.01, ... )
```

**Function Return Format:**
```urscript
socket_read_ascii_float(30, socket_handle, timeout)
```
Returns: `[count, float1, float2, ..., float30]`
- `count` = number of floats successfully read (30 on success, 0 on failure)
- On failure: `[0, nan, nan, nan, ...]`
- On success: `[30, q1_p1, q2_p1, ..., q6_p5]`

**Processing:**
The robot extracts each pose from the returned array:
- Pose 1: indices 1-6
- Pose 2: indices 7-12
- Pose 3: indices 13-18
- Pose 4: indices 19-24
- Pose 5: indices 25-30

Each pose is then added to the motion buffer sequentially.

---

## Thread 3: Motion Execution

### Purpose
Dequeues target joint positions from the motion buffer and executes them using `servoj()` for smooth trajectory following.

### Control Configuration

- **Control Frequency**: 500Hz (2ms cycle time)
- **servoj Time**: 2ms (blocking time where command controls robot)
- **servoj Lookahead**: 0.1s (100ms trajectory smoothing, range [0.03-0.2])
- **servoj Gain**: 300 (proportional gain for position following, range [100-2000])
- **Max Joint Velocity**: 1.05 rad/s
- **Max Joint Acceleration**: 1.4 rad/s²

### Execution Logic

#### When Streaming Active

The motion execution thread implements a state machine with priming logic:

1. **Check if buffer is primed**:
   - If `isPrimed == False` and streaming is active:
     - Skip execution and `sync()` (wait for initial data from host)
     - Continue to next iteration

2. **If buffer is primed and has data**:
   - Read next pose from buffer (protected by critical section)
   - Execute `servoj()` with target joint positions
   - Advance tail and decrement count

3. **If buffer is primed but empty (no data available)**:
   - Check if robot is steady using `isRobotSteady()`:
     - If NOT steady: Hold current position using `servoj()`
     - If steady: Stop streaming and send RES success with stored transaction ID

4. **If motion disabled**:
   - Skip `servoj()` execution but continue buffer management

#### When Streaming Inactive

- Thread sleeps using `sync()` to conserve resources

### Robot Steady Detection

```urscript
def isRobotSteady():
    cVel = get_actual_tcp_speed()
    return cVel[0] < con.steadyThreshold and
           cVel[1] < con.steadyThreshold and
           cVel[2] < con.steadyThreshold and
           cVel[3] < con.steadyThreshold and
           cVel[4] < con.steadyThreshold and
           cVel[5] < con.steadyThreshold
end
```

**Purpose**: Determines if robot has come to a complete stop after buffer depletion, allowing for graceful streaming completion.

### Motion Commands

```urscript
servoj(target_joints, t=con.servoj_time, lookahead_time=con.servoj_lookahead, gain=con.servoj_gain)
```

**Parameters:**
- `target_joints`: Target joint positions [q1, q2, q3, q4, q5, q6]
- `t`: Time where command controls the robot (blocking time) = 0.002s (2ms)
- `lookahead_time`: Trajectory smoothing time horizon = 0.1s (100ms)
  - Low value (0.03s): Fast reaction, may overshoot
  - High value (0.2s): Prevents overshoot, may lag
- `gain`: Proportional gain for position control = 300
  - Higher gain: Faster reaction, may cause instability
  - Lower gain: Slower reaction, more stable

### Shutdown Behavior

On shutdown request:
- Execute `stopj()` with max acceleration to safely stop motion
- Thread terminates gracefully

---

## Configuration Constants

All system constants are defined in a single `con` struct at the top of the script for easy configuration.

### Configuration Struct

```urscript
global con = struct(
    host_ip = "192.168.3.2",              # Host controller IP address
    command_port = 50001,                  # Command and control port
    streaming_port = 50002,                # Streaming data port
    command_socket_name = "socket_cmd",    # Named socket for command/control
    streaming_socket_name = "socket_stream", # Named socket for streaming
    buffer_size = 250,                     # 0.5 seconds at 500Hz
    buffer_refill_threshold = 25,          # Request refill below this level (50ms)
    poses_per_fill = 5,                    # Number of poses per socket read (30 floats / 6 joints)
    home_position = [0.0, -1.04719, -2.09441, -1.57082, -1.57082, -1.57082], # Home joint positions (radians)
    max_joint_velocity = 1.05,             # Maximum joint velocity (rad/s)
    max_joint_acceleration = 1.4,          # Maximum joint acceleration (rad/s²)
    servoj_time = 0.002,                   # 2ms - time where command controls the robot (blocking time)
    servoj_lookahead = 0.1,                # 0.1s - trajectory smoothing lookahead time, range [0.03, 0.2]
    servoj_gain = 300,                     # Proportional gain for position following, range [100, 2000]
    socket_timeout = 2.0,                  # Socket timeout (seconds)
    reconnect_delay = 1.0,                 # Delay between reconnection attempts (seconds)
    ack_success = 0,                       # ACK code: success
    ack_parse_error = 1,                   # ACK code: parse error
    ack_cmd_not_found = 2,                 # ACK code: command not found
    res_suc = 0,                           # RES code: success
    res_error = 1,                         # RES code: error
    steadyThreshold = 0.0025               # Velocity threshold for determining if robot is steady (rad/s)
)
```

**Note**: The unsolicited transaction ID (`-1`) for events not tied to a user command is hardcoded in the implementation.

---

## Thread Synchronization and Safety

### Critical Sections in URScript

URScript provides a single global critical section mechanism for thread synchronization. This prevents concurrent execution of protected code across all threads.

**How Critical Sections Work:**
- URScript has ONE global critical section for the entire script
- When a thread executes `enter_critical`, it enters the critical section
- No other thread can enter a critical section until `exit_critical` is called
- This provides mutual exclusion for shared resource access

**Usage Pattern:**
```urscript
enter_critical
# Access shared resources here (buffer variables)
# Keep this section as short as possible
exit_critical
```

**Important Constraints:**
- **Minimize time in critical sections**: Keep critical section code as brief as possible
- **No blocking operations**: Avoid time-demanding commands inside critical sections:
  - NO `sleep()` or `sync()`
  - NO `socket_read()` or other I/O operations
  - NO motion commands (`movej`, `servoj`, etc.)
- **Only data access**: Critical sections should only contain variable reads/writes

**Critical Sections in This Implementation:**

1. **Reading buffer count** (for status checks):
   ```urscript
   enter_critical
   local buf_count = buffer.count
   exit_critical
   ```

2. **Writing poses to buffer** (streaming handler):
   ```urscript
   enter_critical
   # Write all 5 poses, update head, tail, count
   exit_critical
   ```

3. **Reading pose from buffer** (motion execution):
   ```urscript
   enter_critical
   # Read 6 joints, update tail, count
   exit_critical
   ```

**Thread Safety Strategy:**
1. Read data from buffer inside critical section, copy to local variables
2. Exit critical section immediately
3. Process data outside critical section (execute motion, format strings, etc.)
4. Re-enter critical section only when updating shared state

### Shutdown Mechanism

All threads monitor the `shutdown_requested` global flag:

```urscript
while shutdown_requested == False:
    # Thread work
    sync()
end
```

When shutdown is requested:
1. All threads exit their main loops
2. Sockets are closed gracefully
3. Motion is stopped safely with `stopj()`
4. Main thread waits for all threads using `join`

### Resource Conservation

All threads use `sync()` to yield control when:
- Waiting for data
- Buffer is full/empty
- Streaming is inactive
- No commands pending

This prevents excessive CPU usage on the UR controller.

---

## Implementation Notes

### Socket Usage in URScript

**Important**: URScript uses **named sockets** rather than socket handles. When you call `socket_open()`, it returns a boolean (True/False) indicating connection success, NOT a handle. All subsequent socket operations use the socket name string.

**Socket Lifecycle:**
1. **Open**: `socket_open(address, port, socket_name)` → Returns True/False
2. **Operations**: Use `socket_name` (string) for all read/write operations
3. **Close**: `socket_close(socket_name)`

**Example:**
```urscript
# Open socket with name "socket_cmd"
connected = socket_open("192.168.1.100", 50001, "socket_cmd")

if connected:
    # Use socket NAME (string) for all operations
    socket_send_string("hello", "socket_cmd")
    data = socket_read_string("socket_cmd")
    socket_close("socket_cmd")
end
```

**Our Implementation:**
- Command socket: Named `"socket_cmd"` (defined by `COMMAND_SOCKET_NAME`)
- Streaming socket: Named `"socket_stream"` (defined by `STREAMING_SOCKET_NAME`)
- Connection status stored in global booleans: `cmd_socket_connected`, `stream_socket_connected`

### Socket Communication Methods

**Command and Control**: Uses string-based protocol with prefix/suffix parsing for discrete commands. This is appropriate because:
- Commands are infrequent (not performance-critical)
- Human-readable format aids debugging
- Prefix/suffix automatic extraction simplifies parsing
- Supports multiple commands in buffer (suffix defines message boundaries)

**Implementation Details:**
```urscript
# Commands sent from host: <123,home,>
# Robot reads with automatic delimiter extraction:
cmd_data = socket_read_string(COMMAND_SOCKET_NAME, prefix="<", suffix=">", timeout=2.0)
# Returns: "123,home," (angle brackets removed automatically)
```

Benefits:
- Automatic message boundary detection
- No manual string trimming required
- Supports pipelined commands (multiple messages in socket buffer)
- More robust error handling (incomplete messages remain in buffer)

**Streaming Data**: Uses `socket_read_ascii_float()` for high-frequency motion data. This is preferred because:
- More efficient than manual string parsing
- Built-in URScript function optimized for performance
- Handles up to 30 floats per read (perfect for 5 poses)
- Automatic error detection (returns count + nan values on failure)
- Reduced parsing overhead at 500Hz control frequency

**Benefits of socket_read_ascii_float():**
1. Native URScript function - optimized and tested
2. Batch reading reduces socket overhead
3. Clear success/failure indication via return count
4. No manual string manipulation required
5. Consistent format with parentheses and commas

### Buffer Initialization Strategy

**Function**: `initialize_buffer_with_current_position()`

This function pre-fills the entire motion buffer with the robot's current joint position.

**When Called:**
1. At script startup (before threads begin)
2. When user executes `<ID,init,>` command

**Implementation:**
```urscript
def initialize_buffer_with_current_position():
    local current_joints = get_actual_joint_positions()

    # Fill all 250 pose slots with current position
    local pose_idx = 0
    while pose_idx < con.buffer_size:
        local buffer_offset = pose_idx * 6
        # Write 6 joints to each pose slot
        ring_buffer.data[buffer_offset + 0] = current_joints[0]
        # ... (for all 6 joints)
        pose_idx = pose_idx + 1
    end

    # Reset ring buffer indices with buffer full
    ring_buffer.head = 0
    ring_buffer.tail = 0
    ring_buffer.count = con.buffer_size  # Buffer is full
end
```

**Safety Benefits:**
- **No motion jumps**: Buffer contains only safe, known positions
- **Immediate readiness**: Robot can start streaming without waiting for buffer fill
- **Graceful degradation**: If streaming fails, robot executes current position (no motion)
- **Smooth transitions**: Switching from commanded motion to streamed motion is seamless

### Ring Buffer Overwrite Behavior

The buffer implements true ring buffer semantics with automatic overwrite:
- **Write operations always succeed**: No write operations are rejected
- **When buffer is full**: Oldest data is automatically discarded (tail advances with head)
- **Overwrite is intentional**: Ensures latest data is always available, prevents write stalls
- **Host responsibility**: Monitor buffer levels via `status` command to prevent unintended overwrites
- **Pre-initialization safety**: Buffer always contains valid positions (current pose at startup)
- **Smooth degradation**: If host falls behind, robot continues with most recent available data

### Error Handling

Current implementation provides basic error handling:
- Socket connection failures
- Parse errors
- Unknown commands

Production systems should add:
- Motion limit violations
- Protective stop handling
- Watchdog timers
- Connection recovery

### Performance Considerations

- **Control Frequency**: 500Hz (2ms) provides very smooth, high-performance motion control
- **Buffer Size**: 0.5s (250 samples) provides excellent stability and accommodates network latency
- **Batch Processing**: Reading 5 poses per socket operation reduces network overhead
- **Network Latency**: Host should account for round-trip time in buffer management
- **Buffer Refill Rate**: At 500Hz with 25-sample threshold, refills occur approximately every 50ms
- **Data Transfer Efficiency**: Using `socket_read_ascii_float()` is more efficient than string parsing
- **Command Parsing**: Prefix/suffix extraction eliminates manual string trimming overhead
- **Lookahead Time**: 0.1s lookahead smooths trajectory while maintaining responsiveness

---

## Usage Example

### Starting the System

1. Configure constants (IP, ports, home position)
2. Load script onto UR controller
3. Run script - threads start automatically
4. Wait for connection events

### Command Sequence

```
Host -> Robot: <1,init,>
Robot -> Host: <1,ack,0>
Robot -> Host: <1,evt,1000,Initializing robot system>
Robot -> Host: <1,res,0>

Host -> Robot: <2,home,>
Robot -> Host: <2,ack,0>
Robot -> Host: <2,evt,1001,Moving to home position>
Robot -> Host: <2,res,0>

Host -> Robot: <3,startstreaming,>
Robot -> Host: <3,ack,0>
Robot -> Host: <3,evt,1006,Starting streaming mode>
Robot -> Host: <3,res,0>

[Streaming thread sends <more> requests]
[Host sends joint positions]
[Execution thread performs motion]

Host -> Robot: <4,stopstreaming,>
Robot -> Host: <4,ack,0>
Robot -> Host: <4,evt,1007,Stopping streaming mode>
Robot -> Host: <4,res,0>

Host -> Robot: <5,unknowncommand,>
Robot -> Host: <5,ack,2,unknowncommand>
Robot -> Host: <5,res,1>

Host -> Robot: <malformed_no_transaction_id>
Robot -> Host: <0,ack,1,malformed_no_transaction_id>
```

**Notes**:
- Unknown command example: ACK code 2 with the unrecognized command name echoed back, followed by RES code 1 indicating error
- Parse error example: ACK code 1 with transaction ID 0 and the malformed command string echoed back; no RES sent since transaction ID could not be determined

---

## Future Enhancements

Potential improvements for production systems:

1. **Binary Protocol**: Replace text parsing with binary for efficiency
2. **Compression**: Compress streaming data for bandwidth optimization
3. **Predictive Buffering**: Implement adaptive buffer thresholds
4. **Error Recovery**: Add automatic reconnection and state recovery
5. **Telemetry**: Add performance metrics and diagnostics
6. **Force/Torque Integration**: Include force-torque sensor data in control loop
7. **Path Blending**: Implement advanced trajectory blending
8. **Safety Zones**: Add configurable workspace limits
9. **Multi-Robot**: Extend for coordinated multi-robot control
10. **Configuration File**: Load constants from external configuration

---

## Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 2.2.0 | 2025-11-12 | Initial | **Send Error Handling**: Added return value checking for all socket send operations; `send_message()`, `ack()`, `res()`, and `evt()` now return True/False status; All callers check return values and log errors via `textmsg()`; Buffer refill requests check send status and abort on failure; Command handlers check ACK/RES/EVT send status; No automatic reconnect at this layer (errors logged only); Improves visibility of communication failures without masking underlying issues |
| 2.1.0 | 2025-11-12 | Initial | **Socket Reconnect Logic**: Added automatic reconnection for both command control and streaming handler threads; Connection failures now trigger retry loop with configurable delay (RECONNECT_DELAY = 2.0s); Threads continue retry attempts until either connection succeeds or shutdown_requested is set; Prevents threads from exiting on initial connection failure; Added RECONNECT_DELAY constant; Updated documentation with connection behavior details for both threads |
| 2.0.0 | 2025-11-12 | Initial | **CRITICAL FIX - Proper Critical Section Usage**: Removed incorrect semaphore implementation; URScript has single global critical section, not per-variable semaphores; Replaced `acquire_semaphore()`/`release_semaphore()` with direct `enter_critical`/`exit_critical`; Minimized time spent in critical sections (no I/O, motion, or blocking operations); Optimized buffer access to copy data in critical section then process outside; Updated documentation to explain URScript critical section constraints; This is a breaking architectural change fixing fundamental concurrency bug |
| 1.9.0 | 2025-11-12 | Initial | **ACK/RES Verbiage Enhancement**: Added optional verbiage parameter to ACK and RES responses; ACK parse error (code 1) now echoes back malformed command string; ACK command not found (code 2) now echoes back unrecognized command name; Updated `send_ack()` and `send_result()` to support optional verbiage field; Response format: `<transactionID,ack/res,code,verbiage>` where verbiage is optional; Improved error diagnostics for host debugging |
| 1.8.0 | 2025-11-12 | Initial | **Command Validation Improvements**: Added new ACK code 2 (ACK_COMMAND_NOT_FOUND) for unrecognized commands; `process_command()` now returns ACK status code; Unknown commands receive ACK code 2 followed by RES_ERROR instead of an event; Removed event code 9999 (unknown command) from event table; Single location for command dispatch logic; Updated documentation with new ACK flow and usage examples |
| 1.7.0 | 2025-11-12 | Initial | **Buffer Struct Encapsulation**: Refactored ring buffer into URScript struct for better organization; All buffer state (data, head, tail, count) now encapsulated in single `buffer` struct; Access pattern changed from standalone variables to struct members (e.g., `head` → `buffer.head`, `motion_buffer` → `buffer.data`); Improved code clarity and namespace management; Added documentation explaining struct advantages |
| 1.6.0 | 2025-11-12 | Initial | **Ring Buffer Refactoring**: Renamed variables to standard ring buffer terminology (buffer_write_index→head, buffer_read_index→tail, buffer_count→count); Implemented true ring buffer semantics with automatic overwrite when full; Writes always succeed, oldest data discarded when buffer full; Updated all functions and documentation to reflect true circular buffer behavior |
| 1.5.0 | 2025-11-11 | Initial | Buffer initialization improvements: Pre-fill buffer with current joint position at startup and on init; Properly documented ring buffer (circular queue) components; Initialize motion_buffer at global level with make_list(); Added initialize_buffer_with_current_position() function |
| 1.4.0 | 2025-11-11 | Initial | **CRITICAL FIX**: Refactored motion_buffer to use flat list with index arithmetic (URScript doesn't support list of lists); Using make_list() for proper buffer initialization; Updated all buffer access to use index arithmetic (pose * 6 + joint) |
| 1.3.1 | 2025-11-11 | Initial | Clarified terminology: Renamed EVENT_NO_TRANSACTION to UNSOLICITED_TRANSACTION_ID; Added documentation for solicited vs unsolicited events; Refactored buffer management into handle_buffer_refill() function |
| 1.3.0 | 2025-11-11 | Initial | Added prefix/suffix parameters to socket_read_string for robust command parsing; Simplified parse_command function; Increased buffer to 250 samples (0.5s at 500Hz) |
| 1.2.0 | 2025-11-11 | Initial | Fixed socket implementation to use named sockets per URScript API; Validated against official URScript manual |
| 1.1.0 | 2025-11-11 | Initial | Refactored to use socket_read_ascii_float() for batch streaming; Updated to 500Hz control; Added 5-pose batch processing |
| 1.0.1 | 2025-11-11 | Initial | Updated semaphore to use enter_critical/exit_critical |
| 1.0.0 | 2025-11-11 | Initial | Initial specification and implementation |

---

## License

[Add your license information here]

## Support

[Add support contact information here]
