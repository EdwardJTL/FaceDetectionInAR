//
//  ViewController.swift
//  FaceDetectionInAR
//
//  Created by Edward Luo on 2021-06-10.
//

import UIKit
import SceneKit
import ARKit
import SwiftUI

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    @IBOutlet weak var scanButton: UIButton!
    @IBOutlet weak var resultsButton: UIButton!

    var isDetectionAllowed: Bool = true
    var sourceImage: UIImage? {
        didSet {
            modalViewModal.updateSource(with: sourceImage)
        }
    }
    var processedImage: UIImage? {
        didSet {
            modalViewModal.updateProcessed(with: processedImage)
        }
    }
    var detectedFaces: Int = 0 {
        didSet {
            modalViewModal.updateFacesCount(with: detectedFaces)
        }
    }

    var modalViewModal = ModalViewModel()

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

    @IBAction func resultButtonPressed(_ sender: Any) {
        let modalVC = UIHostingController(rootView: ModalView(viewModel: modalViewModal))
        present(modalVC, animated: true, completion: nil)
    }

    // MARK: - Detection Methods
    func detectFaces() {
        sourceImage = nil
        processedImage = nil
        guard let capture = sceneView.session.currentFrame?.capturedImage else {
            presentAlert(title: "No AR capture")
            return
        }
        isDetectionAllowed = false
        let ciImage = CIImage(cvPixelBuffer: capture)

        let tempContext = CIContext(options: nil)
        if let videoImage = tempContext.createCGImage(ciImage,
                                                      from: CGRect(x: 0, y: 0,
                                                                   width: CVPixelBufferGetWidth(capture),
                                                                   height: CVPixelBufferGetHeight(capture))) {
            sourceImage = UIImage(cgImage: videoImage)
        }


        let detectionRequestHandler = VNImageRequestHandler(cvPixelBuffer: capture, options: [:])
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
        detectedFaces = visionResults?.count ?? 0
        drawProcessedImage(detections: visionResults)
    }

    func drawProcessedImage(detections: [VNFaceObservation]?) {
        guard let sourceImage = sourceImage else {
            print("No source image, cant draw")
            return
        }
        guard let detections = detections else {
            processedImage = sourceImage
            return
        }
        let size = sourceImage.size
        let scale: CGFloat = 0
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            print("No context, cant draw")
            return
        }

        sourceImage.draw(at: CGPoint.zero)
        let rectangles = detections.map { getRoi(from: $0.boundingBox, to: size) }
        context.addRects(rectangles)
        context.setFillColor(.init(red: 1, green: 0, blue: 0, alpha: 1))
        context.drawPath(using: .fill)

        guard let finalImage = UIGraphicsGetImageFromCurrentImageContext() else {
            print("can't produce output")
            processedImage = sourceImage
            return
        }

        processedImage = finalImage
    }

    func getRoi(from normalizedRect: CGRect, to size: CGSize) -> CGRect {
        let imageWidth = size.width
        let imageHeight = size.height
        var toRect = CGRect()

        toRect.size.width = normalizedRect.size.width * imageWidth
        toRect.size.height = normalizedRect.size.height * imageHeight
        toRect.origin.y = imageHeight - (imageHeight * normalizedRect.origin.y) - toRect.size.height
        toRect.origin.x = normalizedRect.origin.x * imageWidth
        return toRect
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
