//
//  ViewController.swift
//  Sprint1
//
//  Created by Alexis Ponce on 6/24/21.
//

import UIKit
import AVKit
import AVFoundation
import Photos
import ReplayKit
class ViewController: UIViewController, AVCaptureFileOutputRecordingDelegate, AVCaptureVideoDataOutputSampleBufferDelegate, RPPreviewViewControllerDelegate {
    
    
    var captureSession:AVCaptureMultiCamSession!
    var videoPreviewLayer:AVCaptureVideoPreviewLayer!
    var backVideoPreviewLayer:AVCaptureVideoPreviewLayer!
    var video:AVCaptureMovieFileOutput!
    var backVideo:AVCaptureMovieFileOutput!
    var photo:AVCapturePhotoOutput!
    var recordingInProgress:Int = 0;
    var assetWriter:AVAssetWriter!
    var screnRecorder:RPScreenRecorder!
    @IBOutlet weak var recordIcon: UIButton!
    
    @IBOutlet weak var fontView: UIView!
    @IBOutlet weak var backView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        showCameras();
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.captureSession.stopRunning()
        }
    }
    
    func showCameras(){
        guard AVCaptureMultiCamSession.isMultiCamSupported else {
            print("MultiCam is not supported")
            return
        }
        print("Just entered the show camera func")
        self.captureSession = AVCaptureMultiCamSession()
        self.video = AVCaptureMovieFileOutput()
        self.backVideo = AVCaptureMovieFileOutput()
        
        let frontCap = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
        let backCap = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
        let mic = AVCaptureDevice.default(.builtInMicrophone, for: .audio, position: .unspecified)
        
        var vidConnection1 = [AVCaptureInput.Port]()
        var videConnection2 = [AVCaptureInput.Port]()
        var micPortArray = [AVCaptureInput.Port]()
        
        var vidPort1:AVCaptureInput.Port!
        var vidPort2:AVCaptureInput.Port!
        var micPort:AVCaptureInput.Port!
        var micPort1:AVCaptureInput.Port!
        self.captureSession.beginConfiguration()
        do{
            let frontInput = try AVCaptureDeviceInput(device: frontCap!)
            vidConnection1 = frontInput.ports
            for port in vidConnection1{
                if(port.mediaType == .video){
                    vidPort1 = port
                }
            }
            if(self.captureSession.canAddInput(frontInput)){
                self.captureSession.addInputWithNoConnections(frontInput)
            }else{
                print("could not add the fontInput to the capture session")
            }
            
        }catch let error{
            print("something went wrong when trying to attach the camera input to the captureSession error: \(error.localizedDescription.description)")
        }
        
        self.captureSession.commitConfiguration()
        self.captureSession.beginConfiguration()
        
        do{
            let backInput = try AVCaptureDeviceInput(device: backCap!)
            videConnection2 = backInput.ports
            for port in videConnection2{
                if(port.mediaType == .video){
                    vidPort2 = port
                }
            }
            if(self.captureSession.canAddInput(backInput)){
                self.captureSession.addInputWithNoConnections(backInput)
            }else{
                print("Could not add the backInput to the capture session")
            }
            
        }catch let error{
            print("Something went wrong when trying to get the catorue device from the backCam with error \(error.localizedDescription.description)")
        }
        
        self.captureSession.commitConfiguration()
        self.captureSession.beginConfiguration()
        
        do{
            let micInput = try AVCaptureDeviceInput(device: mic!)
            micPortArray = micInput.ports
            for port in micPortArray{
                if(port.mediaType == .audio){
                    micPort = port;
                    micPort1 = port;
                }
            }
            if(self.captureSession.canAddInput(micInput)){
                self.captureSession.addInputWithNoConnections(micInput)
            }
        }catch let error{
            print("there was a problem adding the mic input to the captrue session \n \(error.localizedDescription)")
        }
        self.captureSession.commitConfiguration()
        self.captureSession.beginConfiguration()
        
        guard captureSession.canAddOutput(video) else {
            print("Could not add the ouput to the capture session")
           return
        }
        
        self.captureSession.addOutputWithNoConnections(video)
        
        
        guard captureSession.canAddOutput(self.backVideo) else{
            print("could not add the output to the capture session");
            return;
        }
        self.captureSession.addOutputWithNoConnections(self.backVideo)
        self.captureSession.commitConfiguration()
        
        
        self.backVideoPreviewLayer = AVCaptureVideoPreviewLayer()
        self.videoPreviewLayer = AVCaptureVideoPreviewLayer()
        //self.videoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        
        //self.videoPreviewLayer = AVCaptureVideoPreviewLayer()
        self.videoPreviewLayer.setSessionWithNoConnection(self.captureSession)
        self.videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.connection?.videoOrientation = .portrait
        
        //self.backVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
       
        self.backVideoPreviewLayer.setSessionWithNoConnection(self.captureSession)
        self.backVideoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.connection?.videoOrientation = .portrait
        
        let connection1 = AVCaptureConnection(inputPort: vidPort1, videoPreviewLayer: videoPreviewLayer)
        self.captureSession.addConnection(connection1)
        
        let connection4 = AVCaptureConnection(inputPort: vidPort2, videoPreviewLayer: backVideoPreviewLayer)
        self.captureSession.addConnection(connection4)
        
        let connection = AVCaptureConnection(inputPorts: [vidPort1], output: video)
        let audioConnection = AVCaptureConnection(inputPorts: [micPort1], output: video)
        
        self.captureSession.addConnection(audioConnection)
        
        let connection2 = AVCaptureConnection(inputPorts: [vidPort2], output: backVideo)
        let audioConnection1 = AVCaptureConnection(inputPorts: [micPort], output: backVideo)
        self.captureSession.addConnection(audioConnection1);
        

        self.captureSession.addConnection(connection2)
        self.captureSession.addConnection(connection)
      
        
        //self.videoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
//
//        //self.videoPreviewLayer = AVCaptureVideoPreviewLayer()
//        self.videoPreviewLayer.setSessionWithNoConnection(self.captureSession)
//        self.videoPreviewLayer.videoGravity = .resizeAspectFill
//        videoPreviewLayer.connection?.videoOrientation = .portrait
//
//        //self.backVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
//
//        self.backVideoPreviewLayer.setSessionWithNoConnection(self.captureSession)
//        self.backVideoPreviewLayer.videoGravity = .resizeAspectFill
//        videoPreviewLayer.connection?.videoOrientation = .portrait

        self.fontView.layer.addSublayer(self.videoPreviewLayer)
        self.backView.layer.addSublayer(self.backVideoPreviewLayer)
        
        self.view.addSubview(self.fontView)
        self.view.sendSubviewToBack(self.fontView)
        self.view.addSubview(self.backView)
        self.view.sendSubviewToBack(self.backView)
        
        DispatchQueue.main.async{
            self.captureSession.startRunning()
            self.videoPreviewLayer.frame = self.fontView.bounds
            self.backVideoPreviewLayer.frame = self.backView.bounds
        }
        
    }
    
    
    @IBAction func record(_ sender: Any) {
        self.screnRecorder = RPScreenRecorder.shared()
        print("Entered the record function")
        guard let movieOutput = self.video else {
            print("the videoOutput has not been initiated")
            return
        }
        
        if(self.recordingInProgress%2 != 0){
            self.recordIcon.setBackgroundImage(UIImage(systemName: "record.circle"), for: .normal)
            print("stop recording" )
            self.video.stopRecording()
            self.backVideo.stopRecording()
            screenRecording()
            self.recordingInProgress += 1
        }else{
            self.recordIcon.setBackgroundImage(UIImage(systemName: "record.circle.fill"), for: .normal)
            print("start recording")
            let outputFileName = NSUUID().uuidString
            let outPutFilePath = (NSTemporaryDirectory() as NSString).appendingPathComponent((outputFileName as NSString).appendingPathExtension("mov")!)
            let outputFileName1 = NSUUID().uuidString
            let outPutFilePath1 = (NSTemporaryDirectory() as NSString).appendingPathComponent((outputFileName1 as NSString).appendingPathExtension("mov")!)
            self.video.startRecording(to: URL(fileURLWithPath: outPutFilePath), recordingDelegate: self)
            self.backVideo.startRecording(to: URL(fileURLWithPath: outPutFilePath1), recordingDelegate: self)
            screenRecording();
            self.recordingInProgress += 1
        }
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        print("actually started to record")
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        
        print("Stopped recording")
        var succesfull = true;
        if(error != nil){
            succesfull = false;
            print("there was a problem when trying to save the file, currently in didFinishRecording delegate \(String(describing: error?.localizedDescription))");
        }
        if(succesfull){
            PHPhotoLibrary.requestAuthorization{ [self](status) in
                if(output == backVideo){
                    print("saving the backVideo output");
                    if(status == .authorized){
                        PHPhotoLibrary.shared().performChanges({
                            let options = PHAssetResourceCreationOptions();
                            options.shouldMoveFile = true;
                            let creationRequest = PHAssetCreationRequest.forAsset();
                            creationRequest.addResource(with: .video, fileURL: outputFileURL, options: options)
                            
                            //creationRequest could also save metada like location creationRequest.location = ?
                            creationRequest.creationDate = Date()
                        }, completionHandler: {(success,error) in
                            if(!success){
                                print("could not save moview file to the photoLibrary \(String(describing: error?.localizedDescription))")
                            }
                            cleanFile()
                        }
                        )
                    }else{
                        cleanFile()
                    }
                }else{//different file output
                    print("saving the other camera");
                    if(status == .authorized){
                        PHPhotoLibrary.shared().performChanges({
                            let options = PHAssetResourceCreationOptions();
                            options.shouldMoveFile = true;
                            let creationRequest = PHAssetCreationRequest.forAsset();
                            creationRequest.addResource(with: .video, fileURL: outputFileURL, options: options)
        
                            
                            //creationRequest could also save metada like location creationRequest.location = ?
                            creationRequest.creationDate = Date()
                        }, completionHandler: {(success,error) in
                            if(!success){
                                print("could not save moview file to the photoLibrary \(String(describing: error?.localizedDescription))")
                            }
                            cleanFile()
                        }
                        )
                    }else{
                        cleanFile()
                    }
                }//different file
            }
            
        }
        func cleanFile(){
            if(FileManager.default.fileExists(atPath: outputFileURL.path)){
                do{
                    try FileManager.default.removeItem(at: outputFileURL)
                }catch{
                    print("could not remove the file at clean up")
                }
            }
            
        }
    }
    
    func screenRecording(){
        if(self.screnRecorder.isRecording){
            self.screnRecorder.stopRecording{(viewController, error) in
                viewController?.previewControllerDelegate = self
                self.present(viewController!, animated: true, completion: nil)
            }
        }else{
            self.screnRecorder.startRecording{(error) in
                if(error != nil){
                    print("Something went wrong when trying to record the screen\(error?.localizedDescription)");
                }
            }
            self.screnRecorder.startCapture { (CMSampleBuffer, RPSampleBufferType, Error) in
                
            } completionHandler: { (Error) in
                
            }

        }
    }
    
    func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
        previewController.dismiss(animated: true, completion: nil)
    }

}

