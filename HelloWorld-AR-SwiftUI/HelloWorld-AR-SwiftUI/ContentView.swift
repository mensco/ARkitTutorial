//
//  ContentView.swift
//  HelloWorld-AR-SwiftUI
//
//  Created by Katsuya Terahata on 2020/01/14.
//  Copyright © 2020 Katsuya Terahata. All rights reserved.
//

import SwiftUI
import RealityKit
import ARKit

struct ContentView : View {
    var body: some View {
        return ARViewContainer().edgesIgnoringSafeArea(.all)
    }
}

struct ARViewContainer: UIViewRepresentable {
    
    let faceAnchor = AnchorEntity()
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .zero) // 全画面用のインスタンス生成
        // when use face recogintion ↓ is needed.
        arView.session.delegate = context.coordinator
        // show 座標とか
//        arView.debugOptions = [.showFeaturePoints,
//                              .showWorldOrigin,
//                              .showAnchorOrigins]
        arView.debugOptions = [.showFeaturePoints,
                              .showWorldOrigin]
        
        
        
        // Load the "Box" scene from the "Experience" Reality File
//        let boxAnchor = try! Experience.loadBox()
        // instance生成
        
        // Add the box anchor to the scene
//        arView.scene.anchors.append(boxAnchor)
        
        return arView
        
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        let configuration = ARWorldTrackingConfiguration()
//        let configuration = ARFaceTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        uiView.session.run(configuration, options: [.resetTracking,
                                                    .removeExistingAnchors])
        
//        addTextAnchor(arView: uiView)
        for _ in 1...500{
            let randomDoubleX = Double.random(in: -1.0...1.0)
            let randomDoubleY = Double.random(in: -1.0...1.0)
            let randomDoubleZ = Double.random(in: -1.0...1.0)
            let colorList: [UIColor] = [UIColor.red, UIColor.green, UIColor.cyan, UIColor.yellow, UIColor.magenta, UIColor.orange, UIColor.purple]
            let randomColor = colorList.randomElement()!
            addSphereAnchor(arView: uiView, x: randomDoubleX, y:randomDoubleY, z:randomDoubleZ, color: randomColor)
            }
//        addData(arView: uiView)
//        uiView.scene.addAnchor(faceAnchor)
    }
    
//    func addTextAnchor(arView: ARView) {
//        let anchor = AnchorEntity(plane: .horizontal)
//        arView.scene.anchors.append(anchor)
//        
//        // generate text
//        let textMesh = MeshResource.generateText("Hello, world!",extrusionDepth: 0.1, font: .systemFont(ofSize: 2.0))
//        //system font: 1.0 = 1m
//        //extrusionDepth: Thickness
//        
//        // env of text
//        let textMaterial = SimpleMaterial(color: UIColor.white, roughness: 0.0, isMetallic: true)
//        let textModel = ModelEntity(mesh: textMesh, materials: [textMaterial])
//        textModel.position = SIMD3<Float>(0.0, 0.0, -0.2)
//        anchor.addChild(textModel)
//        
//        arView.scene.addAnchor(anchor)
//    }
    
    func addSphereAnchor(arView: ARView, x: Double ,y: Double, z: Double = -1.0, color: UIColor) {
        let anchor = AnchorEntity(world: SIMD3<Float>(Float(x), Float(y), Float(z)))
        let mesh = MeshResource.generateSphere(radius: 0.05)
        let material = SimpleMaterial(color: color, isMetallic: true)
        let sphere = ModelEntity(mesh: mesh, materials: [material])
        anchor.addChild(sphere)
        arView.scene.addAnchor(anchor)
    }
//
//    func addData(arView: ARView) {
//        let planeAnchor = AnchorEntity(plane: .horizontal,
//                                       minimumBounds: [1,1])
//        let plane = try! Entity.load(named: "toy_biplane")
//        planeAnchor.addChild(plane)
//        arView.scene.addAnchor(planeAnchor)
//    }
    
    
    func makeCoordinator() -> ARDelegateHandler {
        ARDelegateHandler(anchor: faceAnchor)
    }
    
    class ARDelegateHandler: NSObject, ARSessionDelegate {
        let faceAnchor: AnchorEntity // 同じAnchorを呼び続ける。
        //classが呼ばれた時に自動的に実行される
        init(anchor: AnchorEntity) {
            self.faceAnchor = anchor
            super.init()
        }
            
        func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
            // anchorの中からARFaceAnchorと認識している、Anchorを抜いてくる。
            for anchor in anchors {
                guard let anchor = anchor as? ARFaceAnchor else { continue }
                let leftPosition = simd_make_float3(simd_mul(anchor.transform, anchor.leftEyeTransform).columns.3)
                let rightPosition = simd_make_float3(simd_mul(anchor.transform, anchor.rightEyeTransform).columns.3)
                print("👀")
                print(anchor.transform)
                
                let mesh = MeshResource.generateSphere(radius: 0.02)
                let redMaterial = SimpleMaterial(color: .red, isMetallic: true)
                let leftSphere = ModelEntity(mesh: mesh, materials: [redMaterial])
                leftSphere.position = leftPosition
                faceAnchor.addChild(leftSphere)
                
                let greenMaterial = SimpleMaterial(color: .green, isMetallic: true)
                let rightSphere = ModelEntity(mesh: mesh, materials: [greenMaterial])
                rightSphere.position = rightPosition
                faceAnchor.addChild(rightSphere)

                }
            }
        
        
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
