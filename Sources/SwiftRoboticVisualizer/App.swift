
// MARK: - Linux
#if os(Linux)

import SwiftCrossUI
import DefaultBackend

@main
struct YourApp: App {
    @State var count = 0

    var body: some Scene {
        WindowGroup("YourApp") {
            HStack {
                Button("-") { count -= 1 }
                Text("Count: \(count)")
                Button("+") { count += 1 }
            }.padding()
        }
    }
}


// MARK: - macOS
///  Flagged off for now
#else  // #elseif os(macOS)
import SwiftUI

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
#endif