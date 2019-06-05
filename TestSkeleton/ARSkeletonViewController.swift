//
//  ARViewController.swift
//  ARMatteExampleSwift
//
//  Created by Mac on 6/4/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit
import ARKit

class ARSkeletonViewController: UIViewController, ARSessionDelegate {

    @IBOutlet weak var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sceneView.session.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Run the view's session with BodyTrackingConfiguration
        let bodyBonfiguration = ARBodyTrackingConfiguration()
        self.sceneView.session.run(bodyBonfiguration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        self.sceneView.session.pause()
    }
    
    func configSession() {
        let configuration = ARBodyTrackingConfiguration()
        self.sceneView.session.run(configuration)
    }
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        
        for anch in anchors {
            if let anch = anch as? ARBodyAnchor {
                visualize(bodyAnchor: anch)
            }
        }
    }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        for anch in anchors {
            if let anch = anch as? ARBodyAnchor {
                visualize(bodyAnchor: anch)
            }
        }
    }
    
    
    func visualize(bodyAnchor:ARBodyAnchor) {
        
        
        for jointName in bodyAnchor.skeleton.definition.jointNames {
            
            let jointType = ARSkeleton.JointName(rawValue: jointName)
            
            if let transform = bodyAnchor.skeleton.modelTransform(for: jointType) {
                
                var matrix = SCNMatrix4(transform)
                
                matrix = SCNMatrix4Mult(matrix, SCNMatrix4(bodyAnchor.transform))
                let position = SCNVector3(matrix.m41, matrix.m42, matrix.m43)
                
                if let nodeToUpdate = self.sceneView.scene.rootNode.childNode(withName: jointName,
                                                                              recursively: false) {
                    
                    nodeToUpdate.isHidden = false
                    nodeToUpdate.position = position
                    
                } else {
                    
                    let jointNode = SphereNode(position: position)
                    jointNode.name = jointName
                    self.sceneView.scene.rootNode.addChildNode(jointNode)
                }

            } else {
                // hide node if it is already on screen
                if let nodeToHide = self.sceneView.scene.rootNode.childNode(withName: jointName,
                                                                            recursively: false) {
                    nodeToHide.isHidden = true
                }
            }
        }
    }
}

class SphereNode: SCNNode {
    
    static let radius: CGFloat = 0.02
    
    let sphereGeometry: SCNSphere
    
    required init?(coder aDecoder: NSCoder) {
        sphereGeometry = SCNSphere(radius: SphereNode.radius)
        super.init(coder: aDecoder)
    }
    
    init(position: SCNVector3) {
        self.sphereGeometry = SCNSphere(radius: SphereNode.radius)
        
        super.init()
        
        let sphereNode = SCNNode(geometry: self.sphereGeometry)
        sphereNode.position = position
        
        self.addChildNode(sphereNode)
    }
}
