import XCTest
import CoreImage
import AVFoundation
@testable import VirtualWebcamRotator

final class VideoProcessorTests: XCTestCase {

    var videoProcessor: VideoProcessor!
    
    override func setUpWithError() throws {
        videoProcessor = VideoProcessor()
    }

    override func tearDownWithError() throws {
        videoProcessor = nil
    }

    func testRotationAngleSetup() throws {
        // Test initial rotation angle
        XCTAssertEqual(videoProcessor.rotationAngle, 0, "Initial rotation angle should be 0")
        
        // Test setting different rotation angles
        let testAngles = [90, 180, 270, 0]
        for angle in testAngles {
            videoProcessor.rotationAngle = angle
            XCTAssertEqual(videoProcessor.rotationAngle, angle, "Rotation angle should be set to \(angle)")
        }
    }
    
    func testValidRotationAngles() throws {
        // Test that common rotation angles are accepted
        let validAngles = [0, 90, 180, 270]
        
        for angle in validAngles {
            videoProcessor.rotationAngle = angle
            XCTAssertEqual(videoProcessor.rotationAngle, angle, "Should accept rotation angle: \(angle)")
        }
    }
    
    func testVideoProcessorInitialization() throws {
        // Test that VideoProcessor initializes properly
        XCTAssertNotNil(videoProcessor)
        XCTAssertEqual(videoProcessor.rotationAngle, 0)
    }
    
    // Performance test for video processing
    func testVideoProcessingPerformance() throws {
        // This would require actual video frames to test properly
        // For now, we'll test the object creation performance
        self.measure {
            let processor = VideoProcessor()
            processor.rotationAngle = 90
            processor.rotationAngle = 180
            processor.rotationAngle = 270
            processor.rotationAngle = 0
        }
    }
}