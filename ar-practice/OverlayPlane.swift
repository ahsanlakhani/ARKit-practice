//
//  OverlayPlane.swift
//  ar-practice
//
//  Created by admin on 09/10/2017.
//  Copyright © 2017 admin. All rights reserved.
//

import Foundation
import ARKit
import SceneKit

class OverlayPlane: SCNNode {
    
    var anchor: ARPlaneAnchor
    var planeGeometry: SCNPlane!
    
    //initializing the class by passing an anchor
    //anchor means a position in real world for that object
    init(anchor: ARPlaneAnchor){
        self.anchor = anchor
        super.init()
        setup()
    }
    
    func update(anchor: ARPlaneAnchor) {
        
        
        
        self.planeGeometry.width = CGFloat(anchor.extent.x)
        self.planeGeometry.height = CGFloat(anchor.extent.z)
        self.position = SCNVector3Make(anchor.center.x, 0, anchor.center.z)
        
        //whenever the plane is updated we also need this physics body to be applied over there
        let planeNode = self.childNodes.first!
        planeNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: self.planeGeometry, options: nil))
    }
    
    private func setup() {
        //creating a plane(rectangular shape)
        //plane is just another type of shape
        self.planeGeometry = SCNPlane(width: CGFloat(self.anchor.center.x), height: CGFloat(self.anchor.extent.z))
        
        //creating a material with image
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "grid.png")
        
        //assigning image material to plane
        self.planeGeometry.materials = [material]
        
        //creating a node and assigning the plane to the node
        let planeNode = SCNNode(geometry: self.planeGeometry)
        
        //giving the plane some physics
        //type is static because plane is not going to go anywhere it will remain in its position
        planeNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: self.planeGeometry, options: nil))
        planeNode.physicsBody?.categoryBitMask = BodyType.plane.rawValue
        
        //giving the node a position
        planeNode.position = SCNVector3Make(anchor.center.x, 0, anchor.center.z)
        
        //rotating or transforming the node from vertical to horizontal
        planeNode.transform = SCNMatrix4MakeRotation(Float(-Double.pi / 2.0), 1.0, 0.0, 0.0)
        
        //add to the parent
        self.addChildNode(planeNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
