import SwiftUI
struct ContentView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Hello from Swift Package UI!")
                .padding()
                .frame(width: 300, height: 200)
            SceneViewContainer()
                .edgesIgnoringSafeArea(.all)
        }
    }
}