//
//  ViewController.swift
//  FaceDetectionInAR
//
//  Created by Edward Luo on 2021-06-10.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    @IBOutlet weak var scanButton: UIButton!

    var isDetectionAllowed: Bool = true
    var sourceImage: CGImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
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

    // MARK: - Button Methods
    @IBAction func scanButtonPressed(_ sender: Any) {
        guard isDetectionAllowed else {
            presentAlert(title: "Please try again later")
            return
        }
        detectFaces()
    }

    // MARK: - Detection Methods
    func detectFaces() {
        guard let capture = sceneView.session.currentFrame?.capturedImage else {
            presentAlert(title: "No AR capture")
            return
        }
        isDetectionAllowed = false
        let ciImage = CIImage(cvPixelBuffer: capture)
        let context = CIContext()

        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
            presentAlert(title: "Cant make cgImage")
            isDetectionAllowed = true
            return
        }

        let detectionRequestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        let faceDetectionRequest = VNDetectFaceRectanglesRequest(completionHandler: self.onFaceDetected(request:error:))
        faceDetectionRequest.preferBackgroundProcessing = true
        do {
            try detectionRequestHandler.perform([faceDetectionRequest])
        } catch {
            isDetectionAllowed = true
            presentAlert(title: "Error performing detection")
        }
    }

    func onFaceDetected(request: VNRequest, error: Error?) {
        defer { isDetectionAllowed = true }
        let visionResults = request.results?.compactMap { $0 as? VNFaceObservation }
        print(visionResults.debugDescription)
    }

    func presentAlert(title: String, message: String? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .destructive, handler: nil))
        self.present(alert, animated: true) {}
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
