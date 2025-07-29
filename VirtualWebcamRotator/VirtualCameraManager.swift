import Foundation
import AVFoundation
import CoreMediaIO
import CoreMedia

class VirtualCameraManager: NSObject {
    private var captureSession: AVCaptureSession?
    private var videoInput: AVCaptureDeviceInput?
    private var videoOutput: AVCaptureVideoDataOutput?
    private var videoProcessor: VideoProcessor?
    
    // Virtual camera properties
    private var virtualCameraObjectID: CMIOObjectID = CMIOObjectID(kCMIOObjectUnknown)
    private var virtualCameraStreamID: CMIOStreamID = CMIOStreamID(kCMIOObjectUnknown)
    
    private let sessionQueue = DispatchQueue(label: "com.virtualwebcam.session", qos: .userInitiated)
    
    var availableCameras: [AVCaptureDevice] = []
    var selectedCamera: AVCaptureDevice?
    var rotationAngle: Int = 0 {
        didSet {
            videoProcessor?.rotationAngle = rotationAngle
        }
    }
    
    override init() {
        super.init()
        setupVideoProcessor()
        discoverCameras()
        setupVirtualCamera()
    }
    
    private func setupVideoProcessor() {
        videoProcessor = VideoProcessor()
    }
    
    private func discoverCameras() {
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera, .externalUnknown],
            mediaType: .video,
            position: .unspecified
        )
        availableCameras = discoverySession.devices
        
        // Select the first available camera by default
        if let firstCamera = availableCameras.first {
            selectedCamera = firstCamera
        }
    }
    
    func start() {
        sessionQueue.async { [weak self] in
            self?.startCaptureSession()
        }
    }
    
    func stop() {
        sessionQueue.async { [weak self] in
            self?.stopCaptureSession()
        }
    }
    
    private func startCaptureSession() {
        guard let selectedCamera = selectedCamera else {
            print("No camera selected")
            return
        }
        
        captureSession = AVCaptureSession()
        captureSession?.beginConfiguration()
        
        // Configure session preset for quality
        if captureSession?.canSetSessionPreset(.hd1280x720) == true {
            captureSession?.sessionPreset = .hd1280x720
        } else {
            captureSession?.sessionPreset = .medium
        }
        
        // Add video input
        do {
            videoInput = try AVCaptureDeviceInput(device: selectedCamera)
            if let videoInput = videoInput,
               captureSession?.canAddInput(videoInput) == true {
                captureSession?.addInput(videoInput)
            }
        } catch {
            print("Error creating video input: \(error)")
            return
        }
        
        // Add video output
        videoOutput = AVCaptureVideoDataOutput()
        videoOutput?.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
        ]
        videoOutput?.setSampleBufferDelegate(self, queue: sessionQueue)
        
        if let videoOutput = videoOutput,
           captureSession?.canAddOutput(videoOutput) == true {
            captureSession?.addOutput(videoOutput)
        }
        
        captureSession?.commitConfiguration()
        captureSession?.startRunning()
        
        print("Capture session started")
    }
    
    private func stopCaptureSession() {
        captureSession?.stopRunning()
        captureSession = nil
        videoInput = nil
        videoOutput = nil
        print("Capture session stopped")
    }
    
    func switchCamera(to device: AVCaptureDevice) {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            
            self.selectedCamera = device
            
            if self.captureSession?.isRunning == true {
                self.stopCaptureSession()
                self.startCaptureSession()
            }
        }
    }
    
    private func setupVirtualCamera() {
        // Enable CoreMediaIO device access
        var property = CMIOObjectPropertyAddress(
            mSelector: CMIOObjectPropertySelector(kCMIOHardwarePropertyAllowScreenCaptureDevices),
            mScope: CMIOObjectPropertyScope(kCMIOObjectPropertyScopeGlobal),
            mElement: CMIOObjectPropertyElement(kCMIOObjectPropertyElementMain)
        )
        
        var allow: UInt32 = 1
        let dataSize: UInt32 = 4
        let zero: UInt32 = 0
        
        CMIOObjectSetPropertyData(CMIOObjectID(kCMIOObjectSystemObject), &property, zero, nil, dataSize, &allow)
        
        print("Virtual camera system initialized")
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension VirtualCameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let videoProcessor = videoProcessor else { return }
        
        // Process the video frame (rotation, etc.)
        if let processedBuffer = videoProcessor.processVideoFrame(sampleBuffer) {
            // Here we would typically send the processed buffer to the virtual camera
            // For now, we'll just log that we're processing frames
            // In a full implementation, this would involve more complex CoreMediaIO setup
        }
    }
} 