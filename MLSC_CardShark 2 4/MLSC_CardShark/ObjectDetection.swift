//
//  VisionModel.swift
//  ObjectDetectionDemo
//
//  Created by Jarek on 05/10/2020.
//  Copyright © 2020 Jarek. All rights reserved.
// https://www.codeproject.com/Articles/5286805/Building-an-Object-Detection-iOS-App-with-YOLO-Cor

import UIKit
import Vision
import Foundation

class ObjectDetection {
    private var objectDetectionLayer: CALayer!
    var cardCounter: CardCounter!

    init(_ viewLayer: CALayer, videoFrameSize: CGSize, cardCounter: CardCounter) {
        self.cardCounter = cardCounter
        self.setupObjectDetectionLayer(viewLayer, videoFrameSize)
    }
    
    public func createObjectDetectionVisionRequest() -> VNRequest? {
        // Setup Vision parts
        do {
            let model = cardshark2().model
            let visionModel = try VNCoreMLModel(for: model)
            let objectRecognition = VNCoreMLRequest(model: visionModel, completionHandler: { (request, error) in
                DispatchQueue.main.async(execute: {
                    // perform all the UI updates on the main queue
                    if let results = request.results {
                        self.processVisionRequestResults(results)
                    }
                })
            })
            
            // To make things simpler we use .scaleFill below (what will introduce some geomerty distortion to the image, but will ensure
            // that the whole visilble image is processed by the ML model.
            // If we would like to be 100% sure that no distortion is introduced, we would need to use .scaleFit and update
            // setupObjectDetectionLayer below to ensure proper scaling of returned results.
            objectRecognition.imageCropAndScaleOption = .scaleFill
            return objectRecognition
        } catch let error as NSError {
            print("Model loading error: \(error)")
            return nil
        }
    }
    
    private func setupObjectDetectionLayer(_ viewLayer: CALayer, _ videoFrameSize: CGSize) {
        self.objectDetectionLayer = CALayer() // container layer that has all the renderings of the observations
        self.objectDetectionLayer.name = "ObjectDetectionLayer"
        self.objectDetectionLayer.bounds = CGRect(x: 0.0,
                                         y: 0.0,
                                         width: videoFrameSize.width,
                                         height: videoFrameSize.height)
        self.objectDetectionLayer.position = CGPoint(x: viewLayer.bounds.midX, y: viewLayer.bounds.midY)
        
        viewLayer.addSublayer(self.objectDetectionLayer)

        // Scaling layer from video frame size to the actual size
        let bounds = viewLayer.bounds
        
        // NOTE: We need to use fmin() here, if we use videoPreviewLayer.videoGravity = .resizeAspect in the VideoCapture.
        //       We need to use fmax() here, if we use videoPreviewLayer.videoGravity = .resizeAspectFill in the VideoCapture.
        let scale = fmax(bounds.size.width  / videoFrameSize.width, bounds.size.height / videoFrameSize.height)
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        
        // We need to invert the y coordinates returned from the model to match screen coordinates
        self.objectDetectionLayer.setAffineTransform(CGAffineTransform(scaleX: scale, y: -scale))
        
        // center the layer
        self.objectDetectionLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        
        CATransaction.commit()
    }
    
    private func createBoundingBoxLayer(_ bounds: CGRect, identifier: String, confidence: VNConfidence) -> CALayer {
        let path = UIBezierPath(rect: bounds)
        
        let boxLayer = CAShapeLayer()
        boxLayer.path = path.cgPath
        boxLayer.strokeColor = UIColor.red.cgColor
        boxLayer.lineWidth = 2
        boxLayer.fillColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [0.0, 0.0, 0.0, 0.0])
        
        boxLayer.bounds = bounds
        boxLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        boxLayer.name = "Detected Object Box"
        boxLayer.backgroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [0.5, 0.5, 0.2, 0.3])
        boxLayer.cornerRadius = 6

        let textLayer = CATextLayer()
        textLayer.name = "Detected Object Label"
        
        textLayer.string = String(format: "\(identifier)\n(%.2f)", confidence)
        textLayer.fontSize = CGFloat(16.0)
        
        textLayer.bounds = CGRect(x: 0, y: 0, width: bounds.size.width - 10, height: bounds.size.height - 10)
        textLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
//        textLayer.alignmentMode = .center
        textLayer.foregroundColor =  UIColor.red.cgColor
        textLayer.contentsScale = 2.0 // retina rendering
        
        // We have inverted y axis to handle results returned from the model.
        // To avoid text labels being printed upside down, we need to invert y axis for text once again.
        textLayer.setAffineTransform(CGAffineTransform(scaleX: 1.0, y: -1.0))
        
        boxLayer.addSublayer(textLayer)
        
        return boxLayer
    }

    private func processVisionRequestResults(_ results: [Any]) {
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        
        self.objectDetectionLayer.sublayers = nil // remove all previously detected objects
        for observation in results where observation is VNRecognizedObjectObservation {
            guard let objectObservation = observation as? VNRecognizedObjectObservation else {
                continue
            }
            
            // Select only the label with the highest confidence.
            let topLabelObservation = objectObservation.labels[0]
            let objectBounds = VNImageRectForNormalizedRect(
                objectObservation.boundingBox,
                Int(self.objectDetectionLayer.bounds.width), Int(self.objectDetectionLayer.bounds.height))
            
            let bbLayer = self.createBoundingBoxLayer(objectBounds, identifier: topLabelObservation.identifier, confidence: topLabelObservation.confidence)
            self.objectDetectionLayer.addSublayer(bbLayer)
            if (topLabelObservation.confidence > 0.92){
                cardCounter.changeCount(card: topLabelObservation.identifier)
            }
        }
        
        CATransaction.commit()
    }
}
