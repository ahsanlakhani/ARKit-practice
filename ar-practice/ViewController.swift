//
//  ViewController.swift
//  ar-practice
//
//  Created by admin on 09/10/2017.
//  Copyright © 2017 admin. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sceneView = ARSCNView(frame: self.view.frame)
        self.view.addSubview(self.sceneView)
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene()
        
        let box = SCNBox(width: 0.2, height: 0.2, length: 0.2, chamferRadius: 0)
        
        let material = SCNMaterial()
        material.name = "Color"
        material.diffuse.contents = UIColor.red
        
        let node = SCNNode()
        node.geometry = box
        node.geometry?.materials = [material]
        node.position = SCNVector3(0, 0.1, -0.5)
        
        scene.rootNode.addChildNode(node)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(objectTapped))
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
        
        // Set the scene to the view
        sceneView.scene = scene
    }
    
    @objc func objectTapped(recognizer: UIGestureRecognizer){
        let sceneView = recognizer.view as! SCNView
        let touchLocation = recognizer.location(in: sceneView)
        let hitResult = sceneView.hitTest(touchLocation, options: [:])
        
        if !hitResult.isEmpty{
            let node = hitResult[0].node
            let material = node.geometry?.material(named: "Color")
            
            material?.diffuse.contents = UIColor.random()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

}

extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}

extension UIColor {
    static func random() -> UIColor {
        return UIColor(red:   .random(),
                       green: .random(),
                       blue:  .random(),
                       alpha: 1.0)
    }
}
