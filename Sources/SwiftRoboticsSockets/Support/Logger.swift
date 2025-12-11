import Logging

public func setupLogging() {
    LoggingSystem.bootstrap { label in
        var handler = StreamLogHandler.standardOutput(label: label)
        handler.logLevel = .info  // Set global log level to debug
        return handler
    }
}

let logger: Logger = {
    setupLogging()
    return Logger(label: "SwiftRobotics")
}()
