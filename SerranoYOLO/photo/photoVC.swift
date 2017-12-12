//
//  photoVC.swift
//  SerranoYOLO
//
//  Created by ZHONGHAO LIU on 11/26/17.
//  Copyright © 2017 Serrano. All rights reserved.
//

import UIKit
import AVFoundation
import Serrano
import SVProgressHUD

class YoloPhotoVC: UIViewController, AVCapturePhotoCaptureDelegate {

    ////////////////////////////////////////////////////////////////////////////////////////////////////
    //
    // MARK: - IBOUTLETS
    
    @IBOutlet var doneButton: UIButton!
    @IBOutlet var capButton: UIButton!
    @IBOutlet var captureView: UIView!
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    //
    // MARK: - Attributes
    
    var previewLayer: AVCaptureVideoPreviewLayer?
    var AVSession: AVCaptureSession?
    var photoOutput: AVCapturePhotoOutput?
    var dataCallbackQueue: DispatchQueue = DispatchQueue(label: "av_dispatch")
    var yoloModel: ComputationGraph?
    var inputTensor: Tensor = Tensor(repeatingValue: 0.0, tensorShape: TensorShape(dataType: .int, shape: [416, 416, 3]))
    var outputTensor: Tensor = Tensor(repeatingValue: 0.0, tensorShape: TensorShape(dataType: .int, shape: [13, 13, 125]))
    
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    //
    // MARK: - View process
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.request()
        
        self.doneButton.addTarget(self,
                                  action: #selector(self.doneBtnTouched),
                                  for: UIControlEvents.touchUpInside)
        
        self.capButton.addTarget(self, action: #selector(self.capPhoto), for: UIControlEvents.touchUpInside)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.configureCam()
        self.configureCaptureOutput()
        
        // show hud
        SVProgressHUD.show()
        self.setAllButtonsEnable(false)
        DispatchQueue.global(qos: .userInitiated).async {
            self.loadingModel()
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                self.setAllButtonsEnable(true)
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func request() {
        AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo) {
            (granted: Bool) -> Void in
            guard granted else {
                // TODO: PROCESSS deny
                return
            }
        }
    }
    
    func doneBtnTouched(sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func setAllButtonsEnable(_ control: Bool) {
        self.doneButton.isEnabled = control
        self.capButton.isEnabled = control
    }
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    //
    // MARK: - Cam
    
    func configureCam() {
        self.AVSession = AVCaptureSession()
        self.AVSession!.sessionPreset = AVCaptureSessionPreset352x288
        self.initialCam()
    }
    
    func adjustCamViewOrientation() {
        let connection = self.previewLayer!.connection!
        if !connection.isVideoOrientationSupported {
            return
        }
        connection.videoOrientation = .landscapeRight
    }
    
    
    /// Initial AVCaptureVideoPreviewLayer and display camera capture
    func initialCam() {
        guard let device = AVCaptureDevice.defaultDevice(withDeviceType: AVCaptureDeviceType.builtInWideAngleCamera,
                                                         mediaType: AVMediaTypeVideo,
                                                         position: AVCaptureDevicePosition.back) else {
                                                            //TODO: Better process
                                                            fatalError("No device available")
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: device)
            self.AVSession!.addInput(input)
        } catch {
            //TODO: Better process
            fatalError("Failed to add input")
        }
        
        guard let capLayer = AVCaptureVideoPreviewLayer(session: self.AVSession!) else{
            //TODO: Better process
            fatalError("Failed to create AVCaptureVideoPreviewLayer")
        }
        capLayer.frame = CGRect(x: 0, y: 0, width: self.captureView.bounds.width, height: self.captureView.bounds.height)
        capLayer.videoGravity = AVLayerVideoGravityResizeAspect
        self.captureView.layer.addSublayer(capLayer)
        self.captureView.setNeedsDisplay()
        self.AVSession!.startRunning()
        self.previewLayer = capLayer
        self.adjustCamViewOrientation()
    }
    
    func configureCaptureOutput() {
        self.photoOutput = AVCapturePhotoOutput()
        self.AVSession!.addOutput(self.photoOutput!)
    }
    
    
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    //
    // MARK: - YOLO MODEL
    
    func loadingModel() {
        self.yoloModel = YOLOModel.yoloModel()
        
        // bind input
        var inputTensorSymbol = self.yoloModel!.dataSymbols().filter {$0.symbolLabel == "input"}.first! as! TensorSymbol
        inputTensorSymbol.bindedData = self.inputTensor
        
        // bind output
        var outputTensorSymbol = self.yoloModel!.dataSymbols().filter {$0.symbolLabel == "output"}.first! as! TensorSymbol
        outputTensorSymbol.bindedData = self.outputTensor
        
        self.yoloModel!.forwardPrepare()
    }
    
    func capPhoto(sender: UIButton) {
        DispatchQueue.main.async {
            SVProgressHUD.show()
        }
        self.setAllButtonsEnable(false)
        let photoSettings1 = AVCapturePhotoSettings(format: [ kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA) ])
        self.photoOutput!.capturePhoto(with: photoSettings1, delegate: self)
    }
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    //
    // MARK: - AVCapturePhotoCaptureDelegate
    
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        guard let pixelBuffer = photo.pixelBuffer else {
            print("empty pixelBuffer")
            return
        }
        self.AVSession!.stopRunning()
        
        print("start attatch")
        pixelBuffer.tensor(attachTensor: self.inputTensor)
        print("end attatch")
       
        print("start compute")
        self.yoloModel!.forward(mode: .GPU)
        print("end compute")

        let boxes = YOLOModel.analyzeResult(self.outputTensor)
        
        let resultShow = ResultShowVC(nibName: "ResultShowVC", bundle: nil)
        resultShow.rgbTensor = self.inputTensor
        resultShow.boxes = boxes
        resultShow.modalPresentationStyle = .overFullScreen
        resultShow.view.bounds = UIScreen.main.bounds
        self.present(resultShow, animated: true) {
            self.AVSession!.startRunning()
            self.setAllButtonsEnable(true)
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
        }
    }
}
