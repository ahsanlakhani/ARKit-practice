//
//  PlacingVirtualObjectsViewController.swift
//  ar-practice
//
//  Created by admin on 10/10/2017.
//  Copyright © 2017 admin. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class PlacingVirtualObjectsViewController: UIViewController,ARSCNViewDelegate {

    var sceneView: ARSCNView!
    
    //array which is going to hold all the planes because we need to extend the detected planes
    var planes = [OverlayPlane]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.sceneView = ARSCNView(frame: self.view.frame)
        
        //shows feature points and shows xyz coordinates
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints,ARSCNDebugOptions.showWorldOrigin]
        self.view.addSubview(self.sceneView)
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene()
        
        sceneView.scene = scene
        
        registerGestureRecognizers()
    }
    
    private func registerGestureRecognizers() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func tapped(recognizer: UIGestureRecognizer) {
        
        //finding out where is the view
        let sceneView = recognizer.view as! ARSCNView
        
        //finding out the tapped location
        let touchLocation = recognizer.location(in: sceneView)
        
        //finding out where u have hit or where the touch location actually resides
        let hitTestResult = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)//existingPlaneUsingExtent: A plane anchor already in the scene (detected with the planeDetection option), respecting the plane's limited size.
        
        if !hitTestResult.isEmpty {
            guard let hitResult = hitTestResult.first else {
                return
            }
            
            addBox(hitResult: hitResult)
        }
    }
    
    private func addBox(hitResult: ARHitTestResult) {
        
        let boxGeometry = SCNBox(width: 0.2, height: 0.2, length: 0.2, chamferRadius: 0)
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        
        boxGeometry.materials = [material]
        
        let boxNode = SCNNode(geometry: boxGeometry)
        
        //positioning box in our 3d world
        boxNode.position = SCNVector3(hitResult.worldTransform.columns.3.x,hitResult.worldTransform.columns.3.y + Float(boxGeometry.height/2),hitResult.worldTransform.columns.3.z)
        
        self.sceneView.scene.rootNode.addChildNode(boxNode)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        //for plane detection
        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    //didAdd function is going to be called whenever ARKit finds any anchors or plane
    //in this function it is passing a node and also the anchor so with these two things we can create a plane
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        if !(anchor is ARPlaneAnchor) {
            return
        }
        
        let plane = OverlayPlane(anchor: anchor as! ARPlaneAnchor)
        //appending every new plane found to the planes array
        self.planes.append(plane)
        node.addChildNode(plane)
    }
    
    //didUpdate function is used to find out when arkit notifies us about the updated anchors
    //its trying to find the anchors continuosly
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
        let plane = self.planes.filter { plane in
            return plane.anchor.identifier == anchor.identifier
            }.first
        
        if plane == nil {
            return
        }
        
        //if we find a new plane the update function will adjust width and height of the new plane
        //update function is in OverlayPlane class
        plane?.update(anchor: anchor as! ARPlaneAnchor)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
 

}
