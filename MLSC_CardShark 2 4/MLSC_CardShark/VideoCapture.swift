//
//  VideoCapture.swift
//  ObjectDetectionDemo
//
//  Created by Jarek on 05/10/2020.
//  Copyright © 2020 Jarek. All rights reserved.
// https://www.codeproject.com/Articles/5286805/Building-an-Object-Detection-iOS-App-with-YOLO-Cor

import UIKit
import AVFoundation
import Vision

class VideoCapture: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    private let captureSession = AVCaptureSession()
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer! = nil
    private let videoDataOutput = AVCaptureVideoDataOutput()
    private let videoDataOutputQueue = DispatchQueue(label: "VideoDataOutput", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
    
    private var videoFrameSize: CGSize = .zero
    
    private var visionRequests =  [VNRequest]()
    
    init(_ viewLayer: CALayer) {
        super.init()
        self.setupPreview(viewLayer)
    }

    deinit {
        if (self.captureSession.isRunning) {
            self.captureSession.stopRunning()
        }
        
        self.videoPreviewLayer.removeFromSuperlayer()
        self.videoPreviewLayer = nil
    }
    
    private func setupPreview(_ viewLayer: CALayer) {
        var deviceInput: AVCaptureDeviceInput!
        
        // Select a video device, make an input
        let videoDevice = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back).devices.first
        do {
            deviceInput = try AVCaptureDeviceInput(device: videoDevice!)
        } catch {
            print("Could not create video device input: \(error)")
            return
        }
        
        captureSession.beginConfiguration()
        // Yolo model image size is 416x416, so capturing 640x480 images will be just fine.
        // We may increase this resolution to have clearer camera preview though.
        captureSession.sessionPreset = .vga640x480
        
        // We will process video frames in the portrait orientation, so they will be 480x640, not 640x480
        self.videoFrameSize = CGSize(width: 480, height: 640)

        // Add a video input
        guard captureSession.canAddInput(deviceInput) else {
            print("Could not add video device input to the session")
            captureSession.commitConfiguration()
            return
        }
        
        captureSession.addInput(deviceInput)
        if captureSession.canAddOutput(videoDataOutput) {
            captureSession.addOutput(videoDataOutput)
            
            // Add a video data output
            videoDataOutput.alwaysDiscardsLateVideoFrames = true
            videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
            videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        } else {
            print("Could not add video data output to the session")
            captureSession.commitConfiguration()
            return
        }
        
        let captureConnection = videoDataOutput.connection(with: .video)
        // Always process the frames
        captureConnection?.isEnabled = true

        // Force portrait orientation. It is rotated by 90 degrees by default.
        captureConnection?.videoOrientation = .portrait

        captureSession.commitConfiguration()

        self.videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        // If you change to .resizeAspect below (to have preview of the whole captured image),
        // you need to change scaling in the ObjectDetection.setupObjectDetectionLayer method accordingly
        self.videoPreviewLayer.videoGravity = .resizeAspectFill
        
        videoPreviewLayer.frame = viewLayer.bounds
        viewLayer.addSublayer(videoPreviewLayer)
    }
    
    public func getCaptureFrameSize() -> CGSize {
        return self.videoFrameSize
    }
    
    public func startCapture(_ visionRequest: VNRequest?) {
        if visionRequest != nil {
            self.visionRequests = [visionRequest!]
        } else {
            self.visionRequests = []
        }
        
        if !captureSession.isRunning {
            captureSession.startRunning()
        }
    }
    
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        // We are using fixed "up" orientation here
        let frameOrientation: CGImagePropertyOrientation = .up
        
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: frameOrientation, options: [:])
        do {
            try imageRequestHandler.perform(self.visionRequests)
        } catch {
            print(error)
        }
    }

    public func captureOutput(_ captureOutput: AVCaptureOutput, didDrop didDropSampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // Dropped frame(s) can be handled here
    }
}
