//
//  ViewController.swift
//  SceneKitEarthTest
//
//  Created by Shan Haq on 2/18/17.
//  Copyright © 2017 gRevolution. All rights reserved.
//

import UIKit
import SceneKit
import GLKit
import CoreLocation

class ViewController: UIViewController {

    @IBOutlet weak var earthView: SCNView!
    
    internal var earthNode : SCNNode!
    let geocoder: CLGeocoder = CLGeocoder()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let mainScene = SCNScene()

        let mainScreneCamera = SCNCamera()
        let mainSceneCameraNode = SCNNode()
        mainSceneCameraNode.camera = mainScreneCamera
        mainSceneCameraNode.position = SCNVector3(0, 0, 8)
        mainScene.rootNode.addChildNode(mainSceneCameraNode)
        
        let earthSphere = SCNSphere(radius: 2)
        earthSphere.segmentCount = 40
        let earthMaterial = SCNMaterial()
        
        earthMaterial.diffuse.contents  = UIImage(named: "earth")
        earthMaterial.emission.contents  = UIImage(named: "earthlights")

//      earthMaterial.diffuse.contents  = UIImage(named: "bwearth")
        
        earthMaterial.multiply.contents = UIColor(white: 0.7, alpha: 1.0)
        earthMaterial.shininess = 0.05
        earthSphere.firstMaterial = earthMaterial
        let earthSphereNode = SCNNode(geometry: earthSphere)
        self.earthNode = earthSphereNode
        mainScene.rootNode.addChildNode(earthSphereNode)

//        earthView.autoenablesDefaultLighting = true
        earthView.scene = mainScene
        earthView.allowsCameraControl = true
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if let location = touch?.location(in: self.view) {
            let hits = earthView.hitTest(location, options: [SCNHitTestOption.rootNode : self.earthNode, SCNHitTestOption.ignoreChildNodes : true])
            let firstHit = hits.first;
            let textureCoordinate = firstHit?.textureCoordinates(withMappingChannel: 0)
            let locationCoordinates = coordinatesFrom(point: textureCoordinate!)
            
            self.geocoder.reverseGeocodeLocation(locationCoordinates, completionHandler: { (placemarks, error) in
                if let country = placemarks?.first?.country {
                    let administrativeArea = placemarks?.first?.administrativeArea ?? ""
                    print("coordinates : (\(locationCoordinates.coordinate.latitude), \(locationCoordinates.coordinate.longitude)), Country : \(country), state : \(administrativeArea)")
                }
            })
        }
    }
    
    func coordinatesFrom(point: CGPoint) -> CLLocation {
        let x = Double(point.x);
        let y = Double(point.y);
        
        //NewValue = (((OldValue - OldMin) * (NewMax - NewMin)) / (OldMax - OldMin)) + NewMin
        // lat is 90 to - 90
        // long is -180 to 180
        
        let lat : CLLocationDegrees = (y * -180) + 90
        let lon : CLLocationDegrees = (x * 360) - 180
        
        return CLLocation(latitude: lat, longitude: lon)
    }
    
}

