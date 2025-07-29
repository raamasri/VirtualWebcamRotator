import Cocoa
import AVFoundation

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var menuBarController: MenuBarController!
    var virtualCameraManager: VirtualCameraManager!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Request camera permission first
        requestCameraPermission { [weak self] granted in
            DispatchQueue.main.async {
                if granted {
                    self?.setupApplication()
                } else {
                    self?.showPermissionAlert()
                }
            }
        }
    }
    
    private func setupApplication() {
        // Initialize virtual camera manager
        virtualCameraManager = VirtualCameraManager()
        
        // Initialize menu bar controller
        menuBarController = MenuBarController(virtualCameraManager: virtualCameraManager)
        
        // Hide dock icon since this is a menu bar app
        NSApp.setActivationPolicy(.accessory)
        
        print("Virtual Webcam Rotator started successfully")
    }
    
    private func requestCameraPermission(completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                completion(granted)
            }
        case .denied, .restricted:
            completion(false)
        @unknown default:
            completion(false)
        }
    }
    
    private func showPermissionAlert() {
        let alert = NSAlert()
        alert.messageText = "Camera Permission Required"
        alert.informativeText = "Virtual Webcam Rotator needs camera access to function. Please grant camera permission in System Preferences."
        alert.addButton(withTitle: "Open System Preferences")
        alert.addButton(withTitle: "Quit")
        
        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Camera")!)
        }
        NSApp.terminate(nil)
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Cleanup virtual camera
        virtualCameraManager?.stop()
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        // Don't reopen windows - this is a menu bar app
        return false
    }
} 