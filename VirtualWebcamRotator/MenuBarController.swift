import Cocoa
import AVFoundation

class MenuBarController: NSObject {
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    private let virtualCameraManager: VirtualCameraManager
    
    private var menu: NSMenu!
    private var cameraSubmenu: NSMenu!
    private var rotationSubmenu: NSMenu!
    
    init(virtualCameraManager: VirtualCameraManager) {
        self.virtualCameraManager = virtualCameraManager
        super.init()
        setupMenuBar()
    }
    
    private func setupMenuBar() {
        guard let button = statusItem.button else { return }
        
        // Set menu bar icon
        if let image = NSImage(systemSymbolName: "camera.rotate", accessibilityDescription: "Virtual Webcam Rotator") {
            image.size = NSSize(width: 18, height: 18)
            button.image = image
        } else {
            button.title = "📹"
        }
        
        // Create main menu
        menu = NSMenu()
        
        // Title item
        let titleItem = NSMenuItem(title: "Virtual Webcam Rotator", action: nil, keyEquivalent: "")
        titleItem.isEnabled = false
        menu.addItem(titleItem)
        menu.addItem(NSMenuItem.separator())
        
        // Camera selection submenu
        setupCameraSubmenu()
        
        // Rotation submenu
        setupRotationSubmenu()
        
        menu.addItem(NSMenuItem.separator())
        
        // Start/Stop controls
        let startItem = NSMenuItem(title: "Start Virtual Camera", action: #selector(startVirtualCamera), keyEquivalent: "")
        startItem.target = self
        menu.addItem(startItem)
        
        let stopItem = NSMenuItem(title: "Stop Virtual Camera", action: #selector(stopVirtualCamera), keyEquivalent: "")
        stopItem.target = self
        menu.addItem(stopItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Quit item
        let quitItem = NSMenuItem(title: "Quit", action: #selector(quitApplication), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
        
        statusItem.menu = menu
    }
    
    private func setupCameraSubmenu() {
        cameraSubmenu = NSMenu()
        let cameraMenuItem = NSMenuItem(title: "Select Camera", action: nil, keyEquivalent: "")
        cameraMenuItem.submenu = cameraSubmenu
        menu.addItem(cameraMenuItem)
        
        updateCameraMenu()
    }
    
    private func setupRotationSubmenu() {
        rotationSubmenu = NSMenu()
        let rotationMenuItem = NSMenuItem(title: "Rotation", action: nil, keyEquivalent: "")
        rotationMenuItem.submenu = rotationSubmenu
        menu.addItem(rotationMenuItem)
        
        // Add rotation options
        let rotationAngles = [0, 90, 180, 270]
        for angle in rotationAngles {
            let item = NSMenuItem(title: "\(angle)°", action: #selector(setRotation(_:)), keyEquivalent: "")
            item.target = self
            item.tag = angle
            item.state = angle == 0 ? .on : .off
            rotationSubmenu.addItem(item)
        }
    }
    
    private func updateCameraMenu() {
        cameraSubmenu.removeAllItems()
        
        for (index, camera) in virtualCameraManager.availableCameras.enumerated() {
            let item = NSMenuItem(title: camera.localizedName, action: #selector(selectCamera(_:)), keyEquivalent: "")
            item.target = self
            item.tag = index
            item.state = camera == virtualCameraManager.selectedCamera ? .on : .off
            cameraSubmenu.addItem(item)
        }
        
        if virtualCameraManager.availableCameras.isEmpty {
            let noDevicesItem = NSMenuItem(title: "No cameras available", action: nil, keyEquivalent: "")
            noDevicesItem.isEnabled = false
            cameraSubmenu.addItem(noDevicesItem)
        }
    }
    
    @objc private func selectCamera(_ sender: NSMenuItem) {
        let cameraIndex = sender.tag
        guard cameraIndex < virtualCameraManager.availableCameras.count else { return }
        
        let selectedCamera = virtualCameraManager.availableCameras[cameraIndex]
        virtualCameraManager.switchCamera(to: selectedCamera)
        
        // Update menu checkmarks
        for item in cameraSubmenu.items {
            item.state = item.tag == cameraIndex ? .on : .off
        }
    }
    
    @objc private func setRotation(_ sender: NSMenuItem) {
        let angle = sender.tag
        virtualCameraManager.rotationAngle = angle
        
        // Update menu checkmarks
        for item in rotationSubmenu.items {
            item.state = item.tag == angle ? .on : .off
        }
        
        print("Rotation set to \(angle)°")
    }
    
    @objc private func startVirtualCamera() {
        virtualCameraManager.start()
        print("Virtual camera started")
    }
    
    @objc private func stopVirtualCamera() {
        virtualCameraManager.stop()
        print("Virtual camera stopped")
    }
    
    @objc private func quitApplication() {
        virtualCameraManager.stop()
        NSApp.terminate(nil)
    }
    
    func refreshCameraList() {
        updateCameraMenu()
    }
}