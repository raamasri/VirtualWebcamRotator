import XCTest
import AVFoundation
@testable import VirtualWebcamRotator

final class VirtualCameraManagerTests: XCTestCase {

    var virtualCameraManager: VirtualCameraManager!
    
    override func setUpWithError() throws {
        virtualCameraManager = VirtualCameraManager()
    }

    override func tearDownWithError() throws {
        virtualCameraManager?.stop()
        virtualCameraManager = nil
    }

    func testVirtualCameraManagerInitialization() throws {
        XCTAssertNotNil(virtualCameraManager)
        XCTAssertEqual(virtualCameraManager.rotationAngle, 0, "Initial rotation should be 0")
        XCTAssertNotNil(virtualCameraManager.availableCameras, "Available cameras array should be initialized")
    }
    
    func testRotationAngleProperty() throws {
        // Test setting rotation angles
        let testAngles = [90, 180, 270, 0]
        
        for angle in testAngles {
            virtualCameraManager.rotationAngle = angle
            XCTAssertEqual(virtualCameraManager.rotationAngle, angle, "Rotation angle should be set to \(angle)")
        }
    }
    
    func testCameraDiscovery() throws {
        // Test that camera discovery completes
        // Available cameras count depends on the system, so we just check it's not nil
        XCTAssertNotNil(virtualCameraManager.availableCameras)
        
        // On most Macs, there should be at least a built-in camera
        // But we won't make assumptions about the hardware
        print("Available cameras: \(virtualCameraManager.availableCameras.count)")
    }
    
    func testStartStopSequence() throws {
        // Test that start/stop methods don't crash
        // Note: These methods work with camera hardware, so we're just testing they don't crash
        
        virtualCameraManager.start()
        // Give it a moment to initialize
        let expectation = XCTestExpectation(description: "Wait for camera startup")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        virtualCameraManager.stop()
    }
    
    func testCameraSwitching() throws {
        // Test camera switching if cameras are available
        if !virtualCameraManager.availableCameras.isEmpty {
            let firstCamera = virtualCameraManager.availableCameras[0]
            virtualCameraManager.switchCamera(to: firstCamera)
            
            // Test that switching doesn't crash
            XCTAssert(true, "Camera switching should not crash")
        }
    }
}