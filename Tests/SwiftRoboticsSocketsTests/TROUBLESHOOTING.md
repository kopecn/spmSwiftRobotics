# Troubleshooting Guide: macOS Network Security

## Issue: macOS Firewall Blocking Network Tests

When running tests, you may see macOS security prompts like:
```
"swift-testing" would like to accept incoming network connections.
[Deny] [Allow]
```

Or tests may fail with network errors when trying to bind to ports 50001 or 50002.

---

## ✅ Solution 1: Use Docker Host Gateway (RECOMMENDED for Docker)

**This is the easiest solution and works for local Docker testing!**

When using Docker with port forwarding (`-p 50001:50001 -p 50002:50002`), the robot inside the container needs to connect BACK to the host machine. Docker provides special hostnames for this:

- **macOS/Windows Docker Desktop:** `host.docker.internal`
- **Linux Docker:** `172.17.0.1` (Docker bridge gateway)

### Already Configured!

The default `TestConfiguration.hostCallbackIP` is now set to `"host.docker.internal"`:

```swift
// Tests/SwiftRoboticsSocketsTests/Infrastructure/TestConfiguration.swift
public static var hostCallbackIP: String {
    return "host.docker.internal"  // No firewall issues on macOS!
}
```

### Why This Works

- `host.docker.internal` is a **special DNS name** provided by Docker Desktop
- It resolves to the host machine's IP from inside the container
- It uses a **private loopback** interface that bypasses the firewall
- No firewall prompts!
- No need to modify system settings

### For Linux Docker Users

If you're running Docker on Linux (not Docker Desktop), change to:

```swift
public static var hostCallbackIP: String {
    return "172.17.0.1"  // Docker bridge gateway on Linux
}
```

### Run Tests

```bash
swift test
```

✅ **No firewall prompts should appear!**

---

## Solution 2: Add Firewall Exception (For Real Robot Testing)

If you're testing with a **real robot on the network** (not Docker), you need to use your machine's network IP address (e.g., `192.168.1.109`).

### Step 1: Run the Helper Script

We've included a script to add the Swift test runner to firewall exceptions:

```bash
./Scripts/allow-test-network.sh
```

This will ask for your admin password and add `/usr/bin/swift` to the firewall allow list.

### Step 2: Update Configuration

Edit `TestConfiguration.swift`:

```swift
public static var hostCallbackIP: String {
    return "192.168.1.109"  // Your machine's IP
}
```

### Step 3: Verify Firewall Settings

1. Open **System Settings** (or System Preferences)
2. Go to **Network** > **Firewall** (or **Security & Privacy** > **Firewall**)
3. Click **Options...** or **Firewall Options...**
4. Verify `swift` is in the list and set to **Allow incoming connections**

---

## Solution 3: Manual Firewall Configuration

### Option A: Via Command Line

```bash
# Add swift to firewall allow list
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --add /usr/bin/swift
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --unblockapp /usr/bin/swift

# Restart firewall
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate off
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on
```

### Option B: Via System Settings GUI

1. **System Settings** → **Network** → **Firewall**
2. Turn Firewall **On** if not already
3. Click **Options...** or **Firewall Options...**
4. Click **+** button
5. Navigate to `/usr/bin/swift` (press ⌘⇧G to open "Go to folder")
6. Add `swift` and set to **Allow incoming connections**
7. Click **OK**

---

## Solution 4: Temporarily Disable Firewall (NOT Recommended)

**⚠️ Only for isolated development environments!**

```bash
# Disable firewall
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate off

# Run tests
swift test

# Re-enable firewall
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on
```

---

## Solution 5: Code Sign Test Binary (Advanced)

For CI/CD or automated testing, you can code sign the test binary:

```bash
# Find the test binary
swift build --show-bin-path

# Code sign it (requires developer certificate)
codesign --force --sign "Your Developer ID" .build/debug/SwiftRoboticsPackageTests.xctest
```

---

## Troubleshooting: Port Already in Use

If you get "Address already in use" errors:

### Check What's Using the Port

```bash
lsof -i :50001
lsof -i :50002
```

### Kill Process on Port

```bash
# Find process ID
lsof -ti :50001

# Kill it
kill -9 $(lsof -ti :50001)
```

### Check Docker Containers

```bash
# List running containers
docker ps

# Stop all containers
docker stop $(docker ps -q)
```

---

## Troubleshooting: Connection Refused

If tests fail with "Connection refused":

### 1. Verify Docker is Running

```bash
docker ps
```

Should show the URSim container with ports exposed:
```
PORTS
0.0.0.0:29999->29999/tcp
0.0.0.0:30001->30001/tcp
0.0.0.0:50001->50001/tcp
0.0.0.0:50002->50002/tcp
```

### 2. Verify URSim is Ready

```bash
# Check URSim logs
docker logs <container_id>

# Access web interface
open http://localhost:6080
```

### 3. Test Port Connectivity

```bash
# Test if port is reachable
nc -zv localhost 29999
nc -zv localhost 30001
```

---

## Quick Reference: Test Configurations

### Local Docker Testing - macOS/Windows (Default)
```swift
public static let robotIP: String = "localhost"
public static var hostCallbackIP: String { "host.docker.internal" }
```
✅ No firewall issues!

### Local Docker Testing - Linux
```swift
public static let robotIP: String = "localhost"
public static var hostCallbackIP: String { "172.17.0.1" }
```
✅ No firewall issues!

### Real Robot on Same Network
```swift
public static let robotIP: String = "192.168.1.50"  // Robot's IP
public static var hostCallbackIP: String { "192.168.1.109" }  // Your Mac's IP
```
⚠️ Requires firewall exception (Solution 2)

### Real Robot on Different Network
```swift
public static let robotIP: String = "10.0.0.50"  // Robot's IP
public static var hostCallbackIP: String { "10.0.0.109" }  // Your Mac's IP
```
⚠️ Requires firewall exception + network routing

---

## CI/CD Considerations

For automated testing in CI/CD:

### GitHub Actions

```yaml
- name: Allow network for tests
  run: |
    sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate off
    swift test
    sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on
```

### Alternative: Use Docker Networking

Run tests inside a Docker container with network access:

```yaml
- name: Run tests in Docker
  run: |
    docker run --network="host" swift:latest bash -c "
      cd /workspace && swift test
    "
```

---

## Still Having Issues?

### Check Verbose Test Output

```bash
swift test --verbose
```

### Check System Logs

```bash
log stream --predicate 'subsystem contains "com.apple.network"' --level debug
```

### Verify Network Stack

```bash
# Show all listening ports
netstat -an | grep LISTEN

# Show firewall status
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate
```

---

## Summary

| Scenario | Solution | Firewall Prompts? |
|----------|----------|-------------------|
| Docker on localhost | Use `127.0.0.1` (default) | ❌ No |
| Real robot on network | Use network IP + firewall exception | ✅ One time only |
| CI/CD | Disable firewall temporarily | ❌ No |

**For 99% of development**: Just use the default `127.0.0.1` configuration! 🎉
