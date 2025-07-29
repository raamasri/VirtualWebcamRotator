import Foundation
import AVFoundation
import CoreMediaIO
import CoreMedia
import IOSurface

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
        // Enable CoreMediaIO device access for screen capture devices
        var property = CMIOObjectPropertyAddress(
            mSelector: CMIOObjectPropertySelector(kCMIOHardwarePropertyAllowScreenCaptureDevices),
            mScope: CMIOObjectPropertyScope(kCMIOObjectPropertyScopeGlobal),
            mElement: CMIOObjectPropertyElement(kCMIOObjectPropertyElementMain)
        )
        
        var allow: UInt32 = 1
        let dataSize: UInt32 = 4
        let zero: UInt32 = 0
        
        let result = CMIOObjectSetPropertyData(CMIOObjectID(kCMIOObjectSystemObject), &property, zero, nil, dataSize, &allow)
        
        if result != kCMIOHardwareNoError {
            print("Failed to enable CoreMediaIO screen capture devices: \(result)")
        } else {
            print("CoreMediaIO screen capture devices enabled")
        }
        
        // Create virtual camera device
        createVirtualCameraDevice()
    }
    
    private func createVirtualCameraDevice() {
        print("Virtual camera device creation initiated")
        
        // Note: Creating a true virtual camera device requires a CoreMediaIO DAL plugin
        // This is a complex process that involves:
        // 1. Creating a system extension or plugin
        // 2. Registering it with CoreMediaIO
        // 3. Implementing the DAL interface
        
        // For this basic implementation, we'll focus on the video processing pipeline
        // and prepare frames for virtual camera output
        
        // In a production version, you would typically:
        // - Use a third-party virtual camera solution like OBS Virtual Camera
        // - Create a proper CoreMediaIO DAL plugin
        // - Use screen capture APIs to create a virtual device
        
        print("Virtual camera ready for frame processing")
    }
    
    func getProcessedFrame(_ sampleBuffer: CMSampleBuffer) -> CMSampleBuffer? {
        return videoProcessor?.processVideoFrame(sampleBuffer)
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension VirtualCameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let videoProcessor = videoProcessor else { return }
        
        // Process the video frame (rotation, etc.)
        if let processedBuffer = videoProcessor.processVideoFrame(sampleBuffer) {
            // Send processed frame for virtual camera output
            // In a full implementation with DAL plugin, this would send to virtual camera
            sendFrameToVirtualCamera(processedBuffer)
        }
    }
    
    private func sendFrameToVirtualCamera(_ sampleBuffer: CMSampleBuffer) {
        // This is where you would send the frame to your virtual camera device
        // For demonstration purposes, we'll log frame information
        
        let timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        let timeValue = CMTimeGetSeconds(timestamp)
        
        if Int(timeValue * 10) % 10 == 0 { // Log every second
            print("Processed frame ready for virtual camera - timestamp: \(String(format: "%.1f", timeValue))s, rotation: \(rotationAngle)°")
        }
        
        // In a real implementation, you would:
        // 1. Send this to your CoreMediaIO DAL plugin
        // 2. Or use a third-party virtual camera framework
        // 3. Or implement screen sharing mechanisms
    }
} 