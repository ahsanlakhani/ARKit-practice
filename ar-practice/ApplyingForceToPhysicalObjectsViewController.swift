//
//  ApplyingForceToPhysicalObjectsViewController.swift
//  ar-practice
//
//  Created by admin on 11/10/2017.
//  Copyright © 2017 admin. All rights reserved.
//

import UIKit
import ARKit
import SceneKit

class ApplyingForceToPhysicalObjectsViewController: UIViewController,ARSCNViewDelegate {

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
        tapGestureRecognizer.numberOfTapsRequired = 1
        
        //we will use the double tap gesture to apply force to physics
        let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        
        //we need to add a dependency, single tap recognizer will not wait for the double tap to happen so if there is double tap so single tap will be failed
        tapGestureRecognizer.require(toFail: doubleTapGestureRecognizer)
        
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
        self.sceneView.addGestureRecognizer(doubleTapGestureRecognizer)

    }
    
    @objc func doubleTapped(recognizer: UIGestureRecognizer) {
        
        let sceneView = recognizer.view as! ARSCNView
        let touch = recognizer.location(in: sceneView)
        
        
        let hitResults = sceneView.hitTest(touch, options: [:])
        
        //if hit result is not empty that means our touch has intercepted with something
        if !hitResults.isEmpty {
            guard let hitResult = hitResults.first else {
                return
            }
            
            //the node which we have touched we will store it in node variable
            let node = hitResult.node
            
            //once we have the node we will apply force to it
            //as impulse means applying force for example kicking a football
            //we are multiplying the coordinates to increase the force
//            node.physicsBody?.applyForce(SCNVector3(hitResult.worldCoordinates.x,hitResult.worldCoordinates.y,hitResult.worldCoordinates.z), asImpulse: true)
            node.physicsBody?.applyForce(SCNVector3(hitResult.worldCoordinates.x * Float(2.0), 2.0 ,hitResult.worldCoordinates.z * Float(2.0)), asImpulse: true)
        }
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
        
        //adding physics to box
        boxNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        //if we assign nil the scene kit will automatically assign the best shape
        //dynamic type: A physics body that can be affected by forces and collisions.
        //Use dynamic bodies for the elements of your scene that are moved by the physics simulation.
        //dynamic makes box move
        
        //for collision detection
        //categoryBitMask:A mask that defines which categories this physics body belongs to.
        //we will also update the overlay plane class
        boxNode.physicsBody?.categoryBitMask = BodyType.box.rawValue
        
        //positioning box in our 3d world
        boxNode.position = SCNVector3(hitResult.worldTransform.columns.3.x,hitResult.worldTransform.columns.3.y + Float(0.5),hitResult.worldTransform.columns.3.z)
        
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
