
#if os(macOS)

    import AppKit
    import SceneKit
    import SwiftUI

    struct SceneViewContainer: NSViewRepresentable {
        func makeNSView(context _: Context) -> SCNView {
            let sceneView = SCNView()

            // Create a basic scene
            let scene = SCNScene()

            // Add a camera
            let cameraNode = SCNNode()
            cameraNode.camera = SCNCamera()
            cameraNode.position = SCNVector3(x: 0, y: 0, z: 10)
            scene.rootNode.addChildNode(cameraNode)

            // Add a light
            let lightNode = SCNNode()
            lightNode.light = SCNLight()
            lightNode.light?.type = .omni
            lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
            scene.rootNode.addChildNode(lightNode)

            // Add a 3D object (like a box)
            let boxNode = SCNNode(geometry: SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0))
            scene.rootNode.addChildNode(boxNode)

            // Configure the view
            sceneView.scene = scene
            sceneView.allowsCameraControl = true
            sceneView.autoenablesDefaultLighting = true
            sceneView.backgroundColor = NSColor.controlBackgroundColor

            return sceneView
        }

        func updateNSView(_: SCNView, context _: Context) {
            // Update the scene if needed
        }
    }

#endif
