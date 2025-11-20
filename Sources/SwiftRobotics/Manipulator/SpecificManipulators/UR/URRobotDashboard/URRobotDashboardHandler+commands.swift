/// A client responsible for sending commands to the UR Dashboard Server via socket.
extension URRobotDashboardHandler {

    /// Sends a formatted dashboard command to the robot.
    private func sendCommand(_ command: URDashboardCommand) {
        let msg = command.commandString
        lastDashCommandSent = msg
        dashboardClientSocket?.send(msg)
    }

    /// Loads a program on the robot.
    ///
    /// - Parameter program: The name/path of the program to load (e.g., "program.urp").
    /// - Expected response:
    ///   - "Loading program: <program.urp>"
    ///   - "File not found: <program.urp>"
    ///   - "Error while loading program: <program.urp>"
    public func loadProgram(_ program: String) {
        sendCommand(.loadProgram(program))
    }

    /// Starts the currently loaded program.
    ///
    /// - Expected response:
    ///   - "Starting program"
    ///   - "Failed to execute: play"
    public func play() {
        sendCommand(.play)
    }

    /// Stops the running program.
    ///
    /// - Expected response:
    ///   - "Stopped"
    ///   - "Failed to execute: stop"
    public func stop() {
        sendCommand(.stop)
    }

    /// Pauses the running program.
    ///
    /// - Expected response:
    ///   - "Pausing program"
    ///   - "Failed to execute: pause"
    public func pause() {
        sendCommand(.pause)
    }

    /// Disconnects the client from the Dashboard Server.
    ///
    /// - Expected response: "Disconnected"
    public func quit() {
        sendCommand(.quit)
    }

    /// Shuts down the robot.
    ///
    /// - Expected response: "Shutting down"
    public func shutdown() {
        sendCommand(.shutdown)
    }

    /// Queries if a program is currently running.
    ///
    /// - Expected response:
    ///   - "Program running: true"
    ///   - "Program running: false"
    public func running() {
        sendCommand(.running)
    }

    /// Queries the current robot mode.
    ///
    /// - Expected response: "Robotmode: <mode>"
    public func robotMode() {
        sendCommand(.robotMode)
    }

    /// Gets the currently loaded program.
    ///
    /// - Expected response:
    ///   - "Loaded program: <path to loaded program file>"
    ///   - "No program loaded"
    public func getLoadedProgram() {
        sendCommand(.getLoadedProgram)
    }

    /// Displays a popup on the robot's teach pendant.
    ///
    /// - Parameter text: The message text to display.
    /// - Expected response: "showing popup"
    public func popup(_ text: String) {
        sendCommand(.popup(text))
    }

    /// Closes any active popup on the teach pendant.
    ///
    /// - Expected response: "closing popup"
    public func closePopup() {
        sendCommand(.closePopup)
    }

    /// Adds a message to the robot's log.
    ///
    /// - Parameter message: The log message to add.
    /// - Expected response:
    ///   - "Added log message"
    ///   - "No log message to add"
    public func addToLog(_ message: String) {
        sendCommand(.addToLog(message))
    }

    /// Checks if the current program is saved.
    ///
    /// - Expected response:
    ///   - "true <program.name>"
    ///   - "false <program.name>"
    public func isProgramSaved() {
        sendCommand(.isProgramSaved)
    }

    /// Gets the current program state.
    ///
    /// - Expected response:
    ///   - "STOPPED"
    ///   - "PLAYING"
    ///   - "PAUSED"
    public func programState() {
        sendCommand(.programState)
    }

    /// Queries the Polyscope version.
    ///
    /// - Expected response: e.g. "URSoftware 5.12.0.1101319 (Mar 22 2022)"
    public func polyscopeVersion() {
        sendCommand(.polyscopeVersion)
    }

    /// Queries the robot's firmware version.
    ///
    /// - Expected response: "<version number>"
    public func version() {
        sendCommand(.version)
    }

    /// Sets the operational mode.
    ///
    /// - Parameter mode: The operational mode to set.
    /// - Expected response:
    ///   - "Setting operational mode: <mode>"
    ///   - "Failed setting operational mode: <mode>"
    public func setOperationalMode(_ mode: String) {
        sendCommand(.setOperationalMode(mode))
    }

    /// Gets the current operational mode.
    ///
    /// - Expected response: "MANUAL", "AUTOMATIC", or "NONE"
    public func getOperationalMode() {
        sendCommand(.getOperationalMode)
    }

    /// Clears the operational mode control from the Dashboard Server.
    ///
    /// - Expected response: "operational mode is no longer controlled by Dashboard Server"
    public func clearOperationalMode() {
        sendCommand(.clearOperationalMode)
    }

    /// Powers on the robot.
    ///
    /// - Expected response: "Powering on"
    public func powerOn() {
        sendCommand(.powerOn)
    }

    /// Powers off the robot.
    ///
    /// - Expected response: "Powering off"
    public func powerOff() {
        sendCommand(.powerOff)
    }

    /// Releases the robot's brakes.
    ///
    /// - Expected response: "Brake releasing"
    public func brakeRelease() {
        sendCommand(.brakeRelease)
    }

    /// Queries the safety mode (deprecated).
    ///
    /// - Expected response: "Safetymode: <mode>"
    public func safetyMode() {
        sendCommand(.safetyMode)
    }

    /// Queries the current safety status.
    ///
    /// - Expected response: "Safetystatus: <status>"
    public func safetyStatus() {
        sendCommand(.safetyStatus)
    }

    /// Unlocks the protective stop.
    ///
    /// - Expected response:
    ///   - "Protective stop releasing"
    ///   - "Cannot unlock protective stop until 5s after occurrence. Always inspect cause of protective stop before unlocking"
    public func unlockProtectiveStop() {
        sendCommand(.unlockProtectiveStop)
    }

    /// Closes the safety popup on the teach pendant.
    ///
    /// - Expected response: "closing safety popup"
    public func closeSafetyPopup() {
        sendCommand(.closeSafetyPopup)
    }

    /// Loads an installation file.
    ///
    /// - Parameter installation: The name/path of the installation to load.
    /// - Expected response:
    ///   - "Loading installation: <installation>"
    ///   - "File not found: <installation>"
    ///   - "Failed to load installation: <installation>"
    public func loadInstallation(_ installation: String) {
        sendCommand(.loadInstallation(installation))
    }

    /// Restarts the safety system.
    ///
    /// - Expected response: (No explicit return documented)
    public func restartSafety() {
        sendCommand(.restartSafety)
    }

    /// Queries if the robot is in remote control.
    ///
    /// - Expected response: "true" or "false"
    public func isInRemoteControl() {
        sendCommand(.isInRemoteControl)
    }

    /// Queries the robot's serial number.
    ///
    /// - Expected response: e.g., "Serial number like '20175599999'"
    public func getSerialNumber() {
        sendCommand(.getSerialNumber)
    }

    /// Queries the robot model.
    ///
    /// - Expected response: "UR3", "UR5", "UR10", or "UR16"
    public func getRobotModel() {
        sendCommand(.getRobotModel)
    }

    /// Generates a flight report.
    ///
    /// - Parameter reportType: The type of flight report to generate.
    /// - Expected response:
    ///   - "report id"
    ///   - "Error Message on a failure"
    public func generateFlightReport(_ reportType: String) {
        sendCommand(.generateFlightReport(reportType))
    }

    /// Generates a support file.
    ///
    /// - Parameter directoryPath: The directory path where the support file will be saved.
    /// - Expected response:
    ///   - "Completed successfully: <result file name>"
    ///   - "Error message with possible cause of the error"
    public func generateSupportFile(_ directoryPath: String) {
        sendCommand(.generateSupportFile(directoryPath))
    }
}
