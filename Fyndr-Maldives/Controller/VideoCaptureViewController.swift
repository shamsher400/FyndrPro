//
//  VideoCaptureViewController.swift
//  Fyndr
//
//  Created by BlackNGreen on 13/06/19.
//  Copyright © 2019 BNG. All rights reserved.
//

import UIKit
import UICircularProgressRing

class VideoCaptureViewController: SwiftyCamViewController, SwiftyCamViewControllerDelegate {
    
    @IBOutlet weak var captureButton    : SwiftyRecordButton!
    @IBOutlet weak var flipCameraButton : UIButton!
    @IBOutlet weak var flashButton      : UIButton!
    @IBOutlet weak var cancelButton      : UIButton!
    @IBOutlet weak var progressRing  : UICircularProgressRing!

    override func viewDidLoad() {
        shouldPrompToAppSettings = false
        cameraDelegate = self
        maximumVideoDuration = 15.0
        shouldUseDeviceOrientation = false
        allowAutoRotate = false
        audioEnabled = true
        flashMode = .auto
        flashButton.setImage(#imageLiteral(resourceName: "flashauto"), for: UIControl.State())
        captureButton.buttonEnabled = false
        defaultCamera = CameraSelection.front
        sendCameraActionToAnalytics(action: .frontCamera)
        videoQuality = .resolution352x288
        //videoQuality = .medium
        videoGravity = .resizeAspect
        
        super.viewDidLoad()
        self.setupProgressView()
        
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        AppAnalytics.log(.openScreen(screen: .recordVideo))
        TPAnalytics.log(.openScreen(screen: .recordVideo))
    }
    
    fileprivate func setupProgressView()
    {
        self.progressRing.minValue = 0
        self.progressRing.maxValue = 100
        self.progressRing.isHidden = true
        self.progressRing.startAngle = 270
        self.progressRing.endAngle = 270
        self.progressRing.innerRingColor = UIColor.appPrimaryColor
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        captureButton.delegate = self
        self.progressRing.resetProgress()
    }
    
    func swiftyCamSessionDidStartRunning(_ swiftyCam: SwiftyCamViewController) {
        print("Session did start running")
        captureButton.buttonEnabled = true
    }
    
    func swiftyCamSessionDidStopRunning(_ swiftyCam: SwiftyCamViewController) {
        print("Session did stop running")
        captureButton.buttonEnabled = false
    }
    
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didTake photo: UIImage) {
//        let newVC = PhotoViewController(image: photo)
//        self.present(newVC, animated: true, completion: nil)
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didBeginRecordingVideo camera: SwiftyCamViewController.CameraSelection) {
        print("Did Begin Recording")
       // captureButton.growButton()
        progressRing.startProgress(to: 100, duration: maximumVideoDuration) {
            print("Done animating!")
        }
        hideButtons()
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFinishRecordingVideo camera: SwiftyCamViewController.CameraSelection) {
        print("Did finish Recording")
      //  captureButton.shrinkButton()
        progressRing.pauseProgress()
        showButtons()
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFinishProcessVideoAt url: URL) {
        
        print("Recording video path : \(url.absoluteString)")
        let videoPreviewViewController = UIStoryboard.getViewController(identifier: "VideoPreviewViewController") as! VideoPreviewViewController
        videoPreviewViewController.videoURL = url
        videoPreviewViewController.viewOnly = false
        videoPreviewViewController.modalPresentationStyle = .fullScreen
        self.present(videoPreviewViewController, animated: true, completion: nil)
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFocusAtPoint point: CGPoint) {
        print("Did focus at point: \(point)")
        focusAnimationAt(point)
    }
    
    func swiftyCamDidFailToConfigure(_ swiftyCam: SwiftyCamViewController) {
        print("swiftyCamDidFailToConfigure")

        let message = NSLocalizedString("Unable to capture media", comment: "Something went wrong during capture session configuration")
        let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString(NSLocalizedString("OK", comment: ""), comment: "Alert OK button"), style: .cancel, handler: { action in
            self.dismiss(animated: true, completion: nil)
        }))
        present(alertController, animated: true, completion: nil)
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didChangeZoomLevel zoom: CGFloat) {
        print("Zoom level did change. Level: \(zoom)")
        print(zoom)
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didSwitchCameras camera: SwiftyCamViewController.CameraSelection) {
        print("Camera did change to \(camera.rawValue)")
        print(camera)
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFailToRecordVideo error: Error) {
        print("didFailToRecordVideo :", error)
        
    }

    
    func swiftyCamNotAuthorized(_ swiftyCam: SwiftyCamViewController) {
        print("swiftyCamNotAuthorized")
        let message = NSLocalizedString("AVCam doesn't have permission to use the camera, please change privacy settings", comment: "Alert message when the user has denied access to the camera")
        self.showPermissionAlert(message: message)        
    }
    
    func swiftyCamNotAuthorizedForAudio(_ swiftyCam: SwiftyCamViewController) {
        let message = NSLocalizedString("AVCam doesn't have permission to use the microphone, please change privacy settings", comment: "Alert message when the user has denied access to the audio")
        self.showPermissionAlert(message: message)
    }
    
    
    fileprivate func showPermissionAlert(message : String)
    {
        DispatchQueue.main.async(execute: { [unowned self] in
            let alertController = UIAlertController(title: Util.appName(), message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"), style: .cancel, handler: { action in
                self.dismiss(animated: true, completion: nil)
            }))
            alertController.addAction(UIAlertAction(title: NSLocalizedString("Settings", comment: "Alert button to open Settings"), style: .default, handler: { action in
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                } else {
                    if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.openURL(appSettings)
                    }
                }
            }))
            alertController.modalPresentationStyle = .fullScreen
            self.present(alertController, animated: true, completion: nil)
        })
    }

    
    @IBAction func cameraSwitchTapped(_ sender: Any) {
        switchCamera()
    }
    
    @IBAction func toggleFlashTapped(_ sender: Any) {
        //flashEnabled = !flashEnabled
        toggleFlashAnimation()
    }

    //MARK: - Button action
    @IBAction func cancelButtonTapped(_ sender: Any) {
        sendCameraActionToAnalytics(action: .close)
        self.dismiss(animated: true, completion: nil)
    }
}


// UI Animations
extension VideoCaptureViewController {
    
    fileprivate func hideButtons() {
        UIView.animate(withDuration: 0.25) {
            self.flashButton.alpha = 0.0
            self.flipCameraButton.alpha = 0.0
            self.cancelButton.alpha = 0.0
            self.captureButton.alpha = 0.0
            self.progressRing.isHidden = false
            self.progressRing.alpha = 1.0
        }
    }
    
    fileprivate func showButtons() {
        UIView.animate(withDuration: 0.25) {
            self.flashButton.alpha = 1.0
            self.flipCameraButton.alpha = 1.0
            self.cancelButton.alpha = 1.0
            self.captureButton.alpha = 1.0
            self.progressRing.isHidden = true
            self.progressRing.alpha = 0.0
        }
    }
    
    fileprivate func focusAnimationAt(_ point: CGPoint) {
        let focusView = UIImageView(image: #imageLiteral(resourceName: "focus"))
        focusView.center = point
        focusView.alpha = 0.0
        view.addSubview(focusView)
        
        UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseInOut, animations: {
            focusView.alpha = 1.0
            focusView.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
        }) { (success) in
            UIView.animate(withDuration: 0.15, delay: 0.5, options: .curveEaseInOut, animations: {
                focusView.alpha = 0.0
                focusView.transform = CGAffineTransform(translationX: 0.6, y: 0.6)
            }) { (success) in
                focusView.removeFromSuperview()
            }
        }
    }
    
    fileprivate func toggleFlashAnimation() {
        //flashEnabled = !flashEnabled
        if flashMode == .auto{
            flashMode = .on
            flashButton.setImage(#imageLiteral(resourceName: "flash"), for: UIControl.State())
        }else if flashMode == .on{
            flashMode = .off
            flashButton.setImage(#imageLiteral(resourceName: "flashOutline"), for: UIControl.State())
        }else if flashMode == .off{
            flashMode = .auto
            flashButton.setImage(#imageLiteral(resourceName: "flashauto"), for: UIControl.State())
        }
    }
}



