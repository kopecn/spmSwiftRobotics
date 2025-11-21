/// Commands sent to the UR Dashboard Server.
enum URDashboardCommand {
    /// Loads a program on the robot.
    ///
    /// - Command format: `load <program.urp>`
    /// - Parameter: Name or path of the program file.
    case loadProgram(String)

    /// Starts the currently loaded program.
    ///
    /// - Command: `play`
    case play

    /// Stops the running program.
    ///
    /// - Command: `stop`
    case stop

    /// Pauses the running program.
    ///
    /// - Command: `pause`
    case pause

    /// Disconnects the client from the Dashboard Server.
    ///
    /// - Command: `quit`
    case quit

    /// Shuts down the robot.
    ///
    /// - Command: `shutdown`
    case shutdown

    /// Queries if a program is currently running.
    ///
    /// - Command: `running`
    case running

    /// Queries the current robot mode.
    ///
    /// - Command: `robotmode`
    case robotMode

    /// Gets the currently loaded program.
    ///
    /// - Command: `get loaded program`
    case getLoadedProgram

    /// Displays a popup on the robot's teach pendant.
    ///
    /// - Command format: `popup <text>`
    /// - Parameter: Text to display in the popup.
    case popup(String)

    /// Closes any active popup on the teach pendant.
    ///
    /// - Command: `close popup`
    case closePopup

    /// Adds a message to the robot's log.
    ///
    /// - Command format: `addToLog <message>`
    /// - Parameter: Log message text.
    case addToLog(String)

    /// Checks if the current program is saved.
    ///
    /// - Command: `isProgramSaved`
    case isProgramSaved

    /// Gets the current program state.
    ///
    /// - Command: `programState`
    case programState

    /// Queries the Polyscope version.
    ///
    /// - Command: `PolyscopeVersion`
    case polyscopeVersion

    /// Queries the robot's firmware version.
    ///
    /// - Command: `version`
    case version

    /// Sets the operational mode.
    ///
    /// - Command format: `set operational mode <mode>`
    /// - Parameter: Operational mode to set.
    case setOperationalMode(String)

    /// Gets the current operational mode.
    ///
    /// - Command: `get operational mode`
    case getOperationalMode

    /// Clears the operational mode control from the Dashboard Server.
    ///
    /// - Command: `clear operational mode`
    case clearOperationalMode

    /// Powers on the robot.
    ///
    /// - Command: `power on`
    case powerOn

    /// Powers off the robot.
    ///
    /// - Command: `power off`
    case powerOff

    /// Releases the robot's brakes.
    ///
    /// - Command: `brake release`
    case brakeRelease

    /// Queries the safety mode (deprecated).
    ///
    /// - Command: `safetymode`
    case safetyMode

    /// Queries the current safety status.
    ///
    /// - Command: `safetystatus`
    case safetyStatus

    /// Unlocks the protective stop.
    ///
    /// - Command: `unlock protective stop`
    case unlockProtectiveStop

    /// Closes the safety popup on the teach pendant.
    ///
    /// - Command: `close safety popup`
    case closeSafetyPopup

    /// Loads an installation file.
    ///
    /// - Command format: `load installation <installation>`
    /// - Parameter: Name or path of the installation.
    case loadInstallation(String)

    /// Restarts the safety system.
    ///
    /// - Command: `restart safety`
    case restartSafety

    /// Queries if the robot is in remote control.
    ///
    /// - Command: `is in remote control`
    case isInRemoteControl

    /// Queries the robot's serial number.
    ///
    /// - Command: `get serial number`
    case getSerialNumber

    /// Queries the robot model.
    ///
    /// - Command: `get robot model`
    case getRobotModel

    /// Generates a flight report.
    ///
    /// - Command format: `generate flight report <reportType>`
    /// - Parameter: Type of flight report to generate.
    case generateFlightReport(String)

    /// Generates a support file.
    ///
    /// - Command format: `generate support file <directoryPath>`
    /// - Parameter: Directory path for the support file.
    case generateSupportFile(String)

    /// The raw command string to send to the dashboard server.
    var commandString: String {
        switch self {
        case .loadProgram(let program):
            return "load \(program)"
        case .play:
            return "play"
        case .stop:
            return "stop"
        case .pause:
            return "pause"
        case .quit:
            return "quit"
        case .shutdown:
            return "shutdown"
        case .running:
            return "running"
        case .robotMode:
            return "robotmode"
        case .getLoadedProgram:
            return "get loaded program"
        case .popup(let text):
            return "popup \(text)"
        case .closePopup:
            return "close popup"
        case .addToLog(let message):
            return "addToLog \(message)"
        case .isProgramSaved:
            return "isProgramSaved"
        case .programState:
            return "programState"
        case .polyscopeVersion:
            return "PolyscopeVersion"
        case .version:
            return "version"
        case .setOperationalMode(let mode):
            return "set operational mode \(mode)"
        case .getOperationalMode:
            return "get operational mode"
        case .clearOperationalMode:
            return "clear operational mode"
        case .powerOn:
            return "power on"
        case .powerOff:
            return "power off"
        case .brakeRelease:
            return "brake release"
        case .safetyMode:
            return "safetymode"
        case .safetyStatus:
            return "safetystatus"
        case .unlockProtectiveStop:
            return "unlock protective stop"
        case .closeSafetyPopup:
            return "close safety popup"
        case .loadInstallation(let installation):
            return "load installation \(installation)"
        case .restartSafety:
            return "restart safety"
        case .isInRemoteControl:
            return "is in remote control"
        case .getSerialNumber:
            return "get serial number"
        case .getRobotModel:
            return "get robot model"
        case .generateFlightReport(let reportType):
            return "generate flight report \(reportType)"
        case .generateSupportFile(let directoryPath):
            return "generate support file \(directoryPath)"
        }
    }
}
