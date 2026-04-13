Check the status of SwiftRobotics package dependencies:

1. Run `swift package show-dependencies` to display the dependency tree
2. Check for any outdated dependencies
3. Report the versions of key dependencies:
   - `spmFoundationTools` (FoundationTransactions, FoundationTypes, FoundationInterfaces)
   - `spmMathTools`
   - `spmSocketHandlers` (NIOHandler)
   - `kvSIMD`
   - `OpenCombine`
   - `swift-log`
4. Flag if `spmSocketHandlers` `dev` branch still has the Swift 6 Sendable errors in `NIOHandlerServer.swift` (5 errors — `AnyHashable` captures at lines ~542, 615, 617, 672, 674)
5. Suggest any potential updates if available
