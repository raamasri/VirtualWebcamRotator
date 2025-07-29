# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

VirtualWebcamRotator is a macOS menu bar application that creates a virtual webcam with rotation capabilities. It captures video from physical cameras, applies rotation transformations, and outputs the processed video as a virtual camera device that can be used by other applications.

## Development Commands

### Building the Project
```bash
# Open the project in Xcode
open VirtualWebcamRotator.xcodeproj

# Build from command line (Debug)
xcodebuild -project VirtualWebcamRotator.xcodeproj -scheme VirtualWebcamRotator -configuration Debug

# Build from command line (Release)
xcodebuild -project VirtualWebcamRotator.xcodeproj -scheme VirtualWebcamRotator -configuration Release
```

### Running the Application
The application must be run from Xcode or as a built .app bundle. It requires camera permissions and runs as a menu bar application (LSUIElement = true).

## Architecture Overview

### Core Components

1. **AppDelegate.swift** - Main application entry point
   - Handles camera permissions on startup
   - Initializes VirtualCameraManager and MenuBarController
   - Manages application lifecycle as a menu bar app

2. **VirtualCameraManager.swift** - Core camera management
   - Manages AVCaptureSession for camera input
   - Handles camera discovery and switching
   - Coordinates with VideoProcessor for frame processing
   - Contains initial CoreMediaIO setup for virtual camera

3. **VideoProcessor.swift** - Video frame processing
   - Applies rotation transformations to video frames using CoreImage
   - Handles pixel buffer creation and manipulation
   - Creates new sample buffers with processed video data

4. **MenuBarController.swift** - UI controller (referenced in project but missing)
   - Should manage the menu bar interface
   - Provides user controls for camera selection and rotation

### Key Technologies
- **AVFoundation**: Camera capture and video processing
- **CoreMediaIO**: Virtual camera device creation
- **CoreImage**: Video frame transformations and rendering
- **CoreVideo**: Pixel buffer management

### Application Flow
1. App requests camera permissions on launch
2. VirtualCameraManager discovers available cameras
3. Capture session starts with selected camera
4. Video frames are processed through VideoProcessor
5. Processed frames are prepared for virtual camera output
6. Menu bar interface allows user control

## Important Notes

### Permissions and Entitlements
- Camera access (`com.apple.security.device.camera`)
- Microphone access (`com.apple.security.device.microphone`) 
- Unsigned executable memory (`com.apple.security.cs.allow-unsigned-executable-memory`)
- Disabled library validation (`com.apple.security.cs.disable-library-validation`)

### System Requirements
- macOS 11.0+ (MACOSX_DEPLOYMENT_TARGET)
- Camera hardware access required
- CoreMediaIO framework support

### Missing Implementation
The MenuBarController.swift file is referenced in the Xcode project but not present in the file system. This component needs to be implemented to provide the user interface for the menu bar application.