//
//  ViewController.swift
//  MLSC_CardShark
//
//  Created by Eric Miao on 12/4/21.
//

import UIKit
import CoreHaptics
import Vision

// Reference for camera feed and frames Extraction:
//   - stackoverflow.com/questions/28487146/how-to-add-live-camera-preview-to-uiview
//   - medium.com/ios-os-x-development/ios-camera-frames-extraction-d2c0f80ed05a
// Reference for using CoreHaptics: www.hackingwithswift.com/example-code/core-haptics/how-to-play-custom-vibrations-using-core-haptics

class ViewController: UIViewController, CardCounterDelegate {
    var engine: CHHapticEngine? // initialize haptic engine
//    var frameExtractor: FrameExtractor! // initialize FrameExtractor Delegate
    var gameStarted = false // current game status
    var ifIncognitoMode = false
    
    var txtField: UITextField = UITextField(frame: CGRect(x: 0, y: 0, width: 300.00, height: 50.00));
    @IBOutlet weak var cameraView: UIImageView!
    
    @IBOutlet weak var cardCount: UILabel!
    
    var videoCapture: VideoCapture!
    var objectDetection: ObjectDetection!
    var cardCounter: CardCounter?
    
    @IBOutlet weak var deckTemp1: UIImageView!
    @IBOutlet weak var deckTemp2: UIImageView!
    
    // side menu code:
    private var sideMenuViewController: SideMenuViewController!
    private var sideMenuShadowView: UIView!
    private var sideMenuRevealWidth: CGFloat = 260
    private let paddingForRotation: CGFloat = 150
    private var isExpanded: Bool = false
    private var draggingIsEnabled: Bool = false
    private var panBaseLocation: CGFloat = 0.0
    
    // Expand/Collapse the side menu by changing trailing's constant
    private var sideMenuTrailingConstraint: NSLayoutConstraint!
    private var revealSideMenuOnTop: Bool = true
    var gestureEnabled: Bool = true
    
    func reset(){
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        flipCameraButton.isEnabled = false
        checkCHHapticEngine();
//        frameExtractor = FrameExtractor()
//        frameExtractor.delegate = self
//        self.cameraView.addSubview(txtField);
        
//        cameraView.isHidden = true
        // Order below is important (in this order are layers being added)
        self.cardCounter = CardCounter()
        cardCounter?.delegate = self
        self.videoCapture = VideoCapture(self.cameraView.layer)
        self.objectDetection = ObjectDetection(self.cameraView.layer, videoFrameSize: self.videoCapture.getCaptureFrameSize(), cardCounter: self.cardCounter!)
        
        // When all components are setup, we can start capturing video
        let visionRequest = self.objectDetection.createObjectDetectionVisionRequest()
        self.videoCapture.startCapture(visionRequest)
        
        
        
        // Side menu code:
        self.sideMenuShadowView = UIView(frame: self.view.bounds)
        self.sideMenuShadowView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.sideMenuShadowView.backgroundColor = .black
        self.sideMenuShadowView.alpha = 0.0
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(TapGestureRecognizer))
        tapGestureRecognizer.numberOfTapsRequired = 1
        tapGestureRecognizer.delegate = self
        view.addGestureRecognizer(tapGestureRecognizer)
        if self.revealSideMenuOnTop {
            view.insertSubview(self.sideMenuShadowView, at: 1)
        }

        // Side Menu
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        self.sideMenuViewController = storyboard.instantiateViewController(withIdentifier: "SideMenuID") as? SideMenuViewController
        self.sideMenuViewController.defaultHighlightedCell = 0 // Default Highlighted Cell
        self.sideMenuViewController.delegate = self
        view.insertSubview(self.sideMenuViewController!.view, at: self.revealSideMenuOnTop ? 2 : 0)
        addChildViewController(self.sideMenuViewController!)
        self.sideMenuViewController!.didMove(toParentViewController: self)

        // Side Menu AutoLayout

        self.sideMenuViewController.view.translatesAutoresizingMaskIntoConstraints = false

        if self.revealSideMenuOnTop {
            self.sideMenuTrailingConstraint = self.sideMenuViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -self.sideMenuRevealWidth - self.paddingForRotation)
            self.sideMenuTrailingConstraint.isActive = true
        }
        
        
        NSLayoutConstraint.activate([
            self.sideMenuViewController.view.widthAnchor.constraint(equalToConstant: self.sideMenuRevealWidth),
            self.sideMenuViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            self.sideMenuViewController.view.topAnchor.constraint(equalTo: view.topAnchor)
        ])

        // Side Menu Gestures
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
        panGestureRecognizer.delegate = self
        view.addGestureRecognizer(panGestureRecognizer)
    }
    
    
    @IBAction open func revealSideMenu() {
        self.sideMenuState(expanded: self.isExpanded ? false : true)
//        self.view.sendSubview(toBack: cameraView)
//        self.cardCount.isHidden = true
//        print("what the fuck")
//        self.view.sendSubview(toBack: deckTemp1)
//        self.view.sendSubview(toBack: deckTemp2)
    }
    
    
    // Keep the state of the side menu (expanded or collapse) in rotation
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate { _ in
            if self.revealSideMenuOnTop {
                self.sideMenuTrailingConstraint.constant = self.isExpanded ? 0 : (-self.sideMenuRevealWidth - self.paddingForRotation)
            }
        }
    }

    func animateShadow(targetPosition: CGFloat) {
        UIView.animate(withDuration: 0.5) {
            // When targetPosition is 0, which means side menu is expanded, the shadow opacity is 0.6
            self.sideMenuShadowView.alpha = (targetPosition == 0) ? 0.6 : 0.0
        }
    }
    
    func sideMenuState(expanded: Bool) {
        if expanded {
            self.animateSideMenu(targetPosition: self.revealSideMenuOnTop ? 0 : self.sideMenuRevealWidth) { _ in
                self.isExpanded = true
                self.view.sendSubview(toBack: self.cameraView)
                self.view.sendSubview(toBack: self.cardCount)
                self.view.sendSubview(toBack: self.deckTemp1)
                self.view.sendSubview(toBack: self.deckTemp2)
            }
            // Animate Shadow (Fade In)
            UIView.animate(withDuration: 0.5) { self.sideMenuShadowView.alpha = 0.6 }
        }
        else {
            self.animateSideMenu(targetPosition: self.revealSideMenuOnTop ? (-self.sideMenuRevealWidth - self.paddingForRotation) : 0) { _ in
                self.isExpanded = false
            }
            // Animate Shadow (Fade Out)
            UIView.animate(withDuration: 0.5) { self.sideMenuShadowView.alpha = 0.0 }
        }
    }
    
    func animateSideMenu(targetPosition: CGFloat, completion: @escaping (Bool) -> ()) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: .layoutSubviews, animations: {
            if self.revealSideMenuOnTop {
                self.sideMenuTrailingConstraint.constant = targetPosition
                self.view.layoutIfNeeded()
            }
            else {
                self.view.subviews[1].frame.origin.x = targetPosition
            }
        }, completion: completion)
    }

    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func startGame (){
        self.cardCounter?.reset()
        self.cardCount.text = "Count: 0"
        self.ifIncognitoMode = false
    }
    
    
    func updateCardCountingUI(_ sender: CardCounter) {
        DispatchQueue.main.async {
            let updatedCount = self.cardCounter!.getCount()
            if updatedCount >= 5 {
                self.deckTemp1.setGIFImage(name: "fire")
                self.deckTemp2.setGIFImage(name: "fire")
                self.cardCount.textColor = UIColor.green;
            } else if updatedCount <= -5 {
                self.deckTemp1.setGIFImage(name: "freezing")
                self.deckTemp2.setGIFImage(name: "freezing")
                self.cardCount.textColor = UIColor.red;
            } else {
                self.deckTemp2.image = nil
                self.deckTemp1.image = nil
                self.cardCount.textColor = UIColor.black;
            }
            self.cardCount.text = "Count: " + String(updatedCount)
        }
        if (self.cardCounter!.getCount() > 0){
            vibrate(repeatCount: self.cardCounter!.getCount())
        }
        
    }
//

    
    
    
    // make sure haptics are supported on the current device using
    func checkCHHapticEngine(){
        // for vibration
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("There was an error creating the engine: \(error.localizedDescription)")
        }
    }
    
    
    @IBAction func testButtonPressed(_ sender: Any) {
        vibrate(repeatCount: 5)
    }
    
    
    // vibrate based on time
    func vibrate(repeatCount: Int){
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        var events = [CHHapticEvent]()
        for i in stride(from: 0, to: repeatCount, by: 1) {
            let event = CHHapticEvent(eventType: .hapticContinuous, parameters: [], relativeTime: Double(i)/2, duration: 0.4)
            events.append(event)
        }
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play pattern: \(error.localizedDescription).")
        }
    }
    
    
    
//    @IBAction func gameButtonPressed(_ sender: UIButton) {
//        gameStarted = !gameStarted
//        if gameStarted{
//            flipCameraButton.isEnabled = true
//            gameButton.setTitle("End", for: .normal)
//            frameExtractor.start();
//        }else{
//            gameButton.setTitle("Start", for: .normal)
//            flipCameraButton.isEnabled = false
//            frameExtractor.end();
//            DispatchQueue.main.async { // Does not work without this dispatch
//                self.cameraView.image = nil;
//            }
//
//        }
//
//    }
    
    
//    @IBAction func flipCameraButtonPressed(_ sender: UIButton) {
//        frameExtractor.flipCamera()
//    }
//
    
    
    func normalMode(){
        print("Normal Mode")
        DispatchQueue.main.async { // Does not work without this dispatch
            self.cameraView.isHidden = false
            self.view.backgroundColor = UIColor.white
        }
        
    }
    @IBAction func incognitoModeButtonPressed(_ sender: UIButton) {
        if ifIncognitoMode == false{
            incognitoMode();
            ifIncognitoMode = true
        }else{
            normalMode();
            ifIncognitoMode = false
        }
    }
    
    func incognitoMode(){
        print("Incognito Mode")
        DispatchQueue.main.async { // Does not work without this dispatch
            self.cameraView.isHidden = true
            self.view.backgroundColor = UIColor.black
        }
    }
}

extension UIImageView {
    func setGIFImage(name: String, repeatCount: Int = 0 ) {
        DispatchQueue.global().async {
            if let gif = UIImage.makeGIFFromCollection(name: name, repeatCount: repeatCount) {
                DispatchQueue.main.async {
                    self.setImage(withGIF: gif)
                    self.startAnimating()
                }
            }
        }
    }

    private func setImage(withGIF gif: GIF) {
        animationImages = gif.images
        animationDuration = gif.durationInSec
        animationRepeatCount = gif.repeatCount
    }
}


// GIF Code from : https://stackoverflow.com/questions/4386675/add-animated-gif-image-in-iphone-uiimageview
extension UIImage {
    class func makeGIFFromCollection(name: String, repeatCount: Int = 0) -> GIF? {
        guard let path = Bundle.main.path(forResource: name, ofType: "gif") else {
            print("Cannot find a path from the file \"\(name)\"")
            return nil
        }

        let url = URL(fileURLWithPath: path)
        let data = try? Data(contentsOf: url)
        guard let d = data else {
            print("Cannot turn image named \"\(name)\" into data")
            return nil
        }

        return makeGIFFromData(data: d, repeatCount: repeatCount)
    }

    class func makeGIFFromData(data: Data, repeatCount: Int = 0) -> GIF? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            print("Source for the image does not exist")
            return nil
        }

        let count = CGImageSourceGetCount(source)
        var images = [UIImage]()
        var duration = 0.0

        for i in 0..<count {
            if let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) {
                let image = UIImage(cgImage: cgImage)
                images.append(image)

                let delaySeconds = UIImage.delayForImageAtIndex(Int(i),
                                                                source: source)
                duration += delaySeconds
            }
        }

        return GIF(images: images, durationInSec: duration, repeatCount: repeatCount)
    }

    class func delayForImageAtIndex(_ index: Int, source: CGImageSource!) -> Double {
        var delay = 0.0

        // Get dictionaries
        let cfProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil)
        let gifPropertiesPointer = UnsafeMutablePointer<UnsafeRawPointer?>.allocate(capacity: 0)
        if CFDictionaryGetValueIfPresent(cfProperties, Unmanaged.passUnretained(kCGImagePropertyGIFDictionary).toOpaque(), gifPropertiesPointer) == false {
            return delay
        }

        let gifProperties:CFDictionary = unsafeBitCast(gifPropertiesPointer.pointee, to: CFDictionary.self)

        // Get delay time
        var delayObject: AnyObject = unsafeBitCast(
            CFDictionaryGetValue(gifProperties,
                                 Unmanaged.passUnretained(kCGImagePropertyGIFUnclampedDelayTime).toOpaque()),
            to: AnyObject.self)
        if delayObject.doubleValue == 0 {
            delayObject = unsafeBitCast(CFDictionaryGetValue(gifProperties,
                                                             Unmanaged.passUnretained(kCGImagePropertyGIFDelayTime).toOpaque()), to: AnyObject.self)
        }

        delay = delayObject as? Double ?? 0

        return delay
    }
}

class GIF: NSObject {
    let images: [UIImage]
    let durationInSec: TimeInterval
    let repeatCount: Int

    init(images: [UIImage], durationInSec: TimeInterval, repeatCount: Int = 0) {
        self.images = images
        self.durationInSec = durationInSec
        self.repeatCount = repeatCount
    }
}



extension ViewController: SideMenuViewControllerDelegate {
    func selectedCell(_ row: Int) {
        switch row {
        case 0:
            // Home
            print("row 1 pressed")
            startGame()
            normalMode()
            
            
        case 1: //Incognito Mode
            print("row 2 pressed")
            if ifIncognitoMode == false{
                incognitoMode()
                ifIncognitoMode = true
            }else{
                normalMode()
                ifIncognitoMode = false
            }
        default:
            break
        }

        // Collapse side menu with animation
        DispatchQueue.main.async { self.sideMenuState(expanded: false) }
    }
}

extension ViewController: UIGestureRecognizerDelegate {
    @objc func TapGestureRecognizer(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            if self.isExpanded {
                self.sideMenuState(expanded: false)
            }
        }
    }

    // Close side menu when you tap on the shadow background view
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if (touch.view?.isDescendant(of: self.sideMenuViewController.view))! {
            return false
        }
        return true
    }
    
    // Dragging Side Menu
    @objc private func handlePanGesture(sender: UIPanGestureRecognizer) {
        
        guard gestureEnabled == true else { return }

        let position: CGFloat = sender.translation(in: self.view).x
        let velocity: CGFloat = sender.velocity(in: self.view).x

        switch sender.state {
        case .began:

            // If the user tries to expand the menu more than the reveal width, then cancel the pan gesture
            if velocity > 0, self.isExpanded {
                sender.state = .cancelled
            }

            // If the user swipes right but the side menu hasn't expanded yet, enable dragging
            if velocity > 0, !self.isExpanded {
                self.draggingIsEnabled = true
            }
            // If user swipes left and the side menu is already expanded, enable dragging
            else if velocity < 0, self.isExpanded {
                self.draggingIsEnabled = true
            }

            if self.draggingIsEnabled {
                // If swipe is fast, Expand/Collapse the side menu with animation instead of dragging
                let velocityThreshold: CGFloat = 550
                if abs(velocity) > velocityThreshold {
                    self.sideMenuState(expanded: self.isExpanded ? false : true)
                    self.draggingIsEnabled = false
                    return
                }

                if self.revealSideMenuOnTop {
                    self.panBaseLocation = 0.0
                    if self.isExpanded {
                        self.panBaseLocation = self.sideMenuRevealWidth
                    }
                }
            }

        case .changed:

            // Expand/Collapse side menu while dragging
            if self.draggingIsEnabled {
                if self.revealSideMenuOnTop {
                    // Show/Hide shadow background view while dragging
                    let xLocation: CGFloat = self.panBaseLocation + position
                    let percentage = (xLocation * 150 / self.sideMenuRevealWidth) / self.sideMenuRevealWidth

                    let alpha = percentage >= 0.6 ? 0.6 : percentage
                    self.sideMenuShadowView.alpha = alpha

                    // Move side menu while dragging
                    if xLocation <= self.sideMenuRevealWidth {
                        self.sideMenuTrailingConstraint.constant = xLocation - self.sideMenuRevealWidth
                    }
                }
                else {
                    if let recogView = sender.view?.subviews[1] {
                        // Show/Hide shadow background view while dragging
                        let percentage = (recogView.frame.origin.x * 150 / self.sideMenuRevealWidth) / self.sideMenuRevealWidth

                        let alpha = percentage >= 0.6 ? 0.6 : percentage
                        self.sideMenuShadowView.alpha = alpha

                        // Move side menu while dragging
                        if recogView.frame.origin.x <= self.sideMenuRevealWidth, recogView.frame.origin.x >= 0 {
                            recogView.frame.origin.x = recogView.frame.origin.x + position
                            sender.setTranslation(CGPoint.zero, in: view)
                        }
                    }
                }
            }
        case .ended:
            self.draggingIsEnabled = false
            // If the side menu is half Open/Close, then Expand/Collapse with animation
            if self.revealSideMenuOnTop {
                let movedMoreThanHalf = self.sideMenuTrailingConstraint.constant > -(self.sideMenuRevealWidth * 0.5)
                self.sideMenuState(expanded: movedMoreThanHalf)
            }
            else {
                if let recogView = sender.view?.subviews[1] {
                    let movedMoreThanHalf = recogView.frame.origin.x > self.sideMenuRevealWidth * 0.5
                    self.sideMenuState(expanded: movedMoreThanHalf)
                }
            }
        default:
            break
        }
    }
}
