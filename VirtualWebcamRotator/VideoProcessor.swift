import Foundation
import AVFoundation
import CoreImage
import CoreVideo

class VideoProcessor {
    private let context = CIContext()
    private let colorSpace = CGColorSpaceCreateDeviceRGB()
    
    var rotationAngle: Int = 0
    
    func processVideoFrame(_ sampleBuffer: CMSampleBuffer) -> CMSampleBuffer? {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return nil
        }
        
        // Create CIImage from pixel buffer
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        
        // Apply rotation if needed
        let rotatedImage = applyRotation(to: ciImage, angle: rotationAngle)
        
        // Create new pixel buffer with rotated image
        guard let rotatedPixelBuffer = createPixelBuffer(from: rotatedImage) else {
            return nil
        }
        
        // Create new sample buffer with rotated pixel buffer
        return createSampleBuffer(from: rotatedPixelBuffer, originalSampleBuffer: sampleBuffer)
    }
    
    private func applyRotation(to image: CIImage, angle: Int) -> CIImage {
        guard angle != 0 else { return image }
        
        let radians = CGFloat(angle) * .pi / 180.0
        let transform = CGAffineTransform(rotationAngle: radians)
        
        // Apply rotation around center
        let rotatedImage = image.transformed(by: transform)
        
        // Adjust the image to fit within bounds after rotation
        let extent = rotatedImage.extent
        let translation = CGAffineTransform(translationX: -extent.origin.x, y: -extent.origin.y)
        
        return rotatedImage.transformed(by: translation)
    }
    
    private func createPixelBuffer(from image: CIImage) -> CVPixelBuffer? {
        let extent = image.extent
        let width = Int(extent.width)
        let height = Int(extent.height)
        
        var pixelBuffer: CVPixelBuffer?
        let attributes: [String: Any] = [
            kCVPixelBufferCGImageCompatibilityKey as String: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey as String: true,
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
        ]
        
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            width,
            height,
            kCVPixelFormatType_32BGRA,
            attributes as CFDictionary,
            &pixelBuffer
        )
        
        guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
            return nil
        }
        
        context.render(image, to: buffer)
        return buffer
    }
    
    private func createSampleBuffer(from pixelBuffer: CVPixelBuffer, originalSampleBuffer: CMSampleBuffer) -> CMSampleBuffer? {
        var sampleBuffer: CMSampleBuffer?
        var timingInfo = CMSampleTimingInfo()
        
        // Copy timing information from original buffer
        CMSampleBufferGetSampleTimingInfo(originalSampleBuffer, at: 0, timingInfoOut: &timingInfo)
        
        // Create format description
        var formatDescription: CMVideoFormatDescription?
        let status = CMVideoFormatDescriptionCreateForImageBuffer(
            allocator: kCFAllocatorDefault,
            imageBuffer: pixelBuffer,
            formatDescriptionOut: &formatDescription
        )
        
        guard status == noErr, let format = formatDescription else {
            return nil
        }
        
        // Create sample buffer
        let createStatus = CMSampleBufferCreateReadyWithImageBuffer(
            allocator: kCFAllocatorDefault,
            imageBuffer: pixelBuffer,
            formatDescription: format,
            sampleTiming: &timingInfo,
            sampleBufferOut: &sampleBuffer
        )
        
        guard createStatus == noErr else {
            return nil
        }
        
        return sampleBuffer
    }
} 