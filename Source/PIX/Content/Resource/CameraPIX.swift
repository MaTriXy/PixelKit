//
//  CameraPIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-07-26.
//  Open Source - MIT License
//

import AVKit

#if os(iOS)
typealias _Orientation = UIInterfaceOrientation
#elseif os(macOS)
typealias _Orientation = Void
#endif

public class CameraPIX: PIXResource {
        
    override open var shader: String { return "contentResourceCameraPIX" }
    
    // MARK: - Private Properties
    
    var helper: CameraHelper?
    
    var access: Bool = false
    var orientation: _Orientation?
    
    // MARK: - Public Properties
    
    public enum CamRes: String, Codable, CaseIterable {
        case vga = "VGA"
        case _720p = "720p"
        #if os(iOS)
        case _1080p = "1080p"
        case _4K = "4K"
        #endif
        public var sessionPreset: AVCaptureSession.Preset {
            switch self {
            case .vga:
                return .vga640x480
            case ._720p:
                return .hd1280x720
            #if os(iOS)
            case ._1080p:
                return .hd1920x1080
            case ._4K:
                return .hd4K3840x2160
            #endif
            }
        }
        public var res: Res {
            switch self {
            case .vga: return .custom(w: 640, h: 480)
            case ._720p: return ._720p
            #if os(iOS)
            case ._1080p: return ._1080p
            case ._4K: return ._4K
            #endif
            }
        }
    }
    #if os(iOS)
    public var camRes: CamRes = ._1080p { didSet { setupCamera() } }
    #elseif os(macOS)
    public var camRes: CamRes = ._720p { didSet { setupCamera() } }
    #endif
    
    public enum Camera: String, Codable, CaseIterable {
        case front = "Front Camera"
        #if os(iOS)
        case back = "Back Camera"
        #endif
        var position: AVCaptureDevice.Position {
            switch self {
            case .front:
                return .front
            #if os(iOS)
            case .back:
                return .back
            #endif
            }
        }
        var mirrored: Bool { return self == .front }
    }
    #if os(iOS)
    public var camera: Camera = .back { didSet { setupCamera() } }
    #elseif os(macOS)
    public var camera: Camera = .front { didSet { setupCamera() } }
    #endif
    
    
    #if os(macOS)
    public var autoDetect: Bool = true
    #endif
    
    // MARK: - Property Helpers
    
    open override var uniforms: [CGFloat] {
        #if os(iOS)
        return [CGFloat(orientation?.rawValue ?? 0), camera.mirrored ? 1 : 0]
        #elseif os(macOS)
        return [0, camera.mirrored ? 1 : 0]
        #endif
    }
    
    // MARK: - Life Cycle
    
    public override init() {
        super.init()
        setupCamera()
        
        #if os(macOS)
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVCaptureDeviceWasConnected, object: nil, queue: nil) { (notif) -> Void in
            self.camAttatched(device: notif.object! as! AVCaptureDevice)
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVCaptureDeviceWasDisconnected, object: nil, queue: nil) { (notif) -> Void in
            self.camDeattatched(device: notif.object! as! AVCaptureDevice)
        }
        #endif
        
    }
    
    deinit {
        helper!.stop()
    }
    
    // MARK: Access
    
    func requestAccess(gotAccess: @escaping () -> ()) {
        if #available(OSX 10.14, *) {
            AVCaptureDevice.requestAccess(for: .video) { accessGranted in
                if accessGranted {
                    gotAccess()
                } else {
                    self.pixels.log(pix: self, .warning, .resource, "Camera Access Not Granted.")
                }
                self.access = accessGranted
            }
        } else {
            gotAccess()
            self.access = true
        }
    }
    
    // MARK: Setup
    
    func setupCamera() {
        if !access {
            requestAccess {
                DispatchQueue.main.async {
                    self.setupCamera()
                }
                return
            }
        }
        helper?.stop()
        helper = CameraHelper(camRes: camRes, cameraPosition: camera.position, setup: { _, orientation in
            self.pixels.log(pix: self, .info, .resource, "Camera setup.")
            // CHECK multiple setups on init
            self.orientation = orientation
            #if os(iOS)
            self.flop = [.portrait, .portraitUpsideDown].contains(orientation)
            #elseif os(macOS)
            self.flop = false
            #endif
        }, captured: { pixelBuffer in
            self.pixels.log(pix: self, .info, .resource, "Camera frame captured.", loop: true)
            self.pixelBuffer = pixelBuffer
            if self.view.res == nil || self.view.res! != self.resolution! {
                self.applyRes { self.setNeedsRender() }
            } else {
                self.setNeedsRender()
            }
        })
    }
    
    // MARK: - Camera Attatchment
    
    #if os(macOS)
    func camAttatched(device: AVCaptureDevice) {
        guard autoDetect else { return }
        self.pixels.log(pix: self, .info, .resource, "Camera Attatched.")
        setupCamera()
    }
    #endif
    
    #if os(macOS)
    func camDeattatched(device: AVCaptureDevice) {
        guard autoDetect else { return }
        self.pixels.log(pix: self, .info, .resource, "Camera Deattatched.")
        setupCamera()
    }
    #endif
    
}

class CameraHelper: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate, AVCapturePhotoCaptureDelegate {
    
    let pixels = Pixels.main
    
    let cameraPosition: AVCaptureDevice.Position
    let photoSupport: Bool
    
    let captureSession: AVCaptureSession
    let videoOutput: AVCaptureVideoDataOutput
    let photoOutput: AVCapturePhotoOutput?

    var lastUIOrientation: _Orientation

    var initialFrameCaptured = false
    var orientationUpdated = false
    
    let setupCallback: (CGSize, _Orientation) -> ()
    let capturedCallback: (CVPixelBuffer) -> ()
    
    init(camRes: CameraPIX.CamRes, cameraPosition: AVCaptureDevice.Position, photoSupport: Bool = false, setup: @escaping (CGSize, _Orientation) -> (), captured: @escaping (CVPixelBuffer) -> ()) {
        
        self.cameraPosition = cameraPosition
        self.photoSupport = photoSupport
        
        setupCallback = setup
        capturedCallback = captured
        
        #if os(iOS)
        lastUIOrientation = UIApplication.shared.statusBarOrientation
        #elseif os(macOS)
        lastUIOrientation = ()
        #endif
        
        captureSession = AVCaptureSession()
        videoOutput = AVCaptureVideoDataOutput()
        photoOutput = photoSupport ? AVCapturePhotoOutput() : nil
        
        
        super.init()
        
        
        let preset: AVCaptureSession.Preset = camRes.sessionPreset
        
        if captureSession.canSetSessionPreset(preset) {
            captureSession.sessionPreset = preset
        } else {
            captureSession.sessionPreset = .high
        }
        
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: pixels.bits.os]
        
//        print("->>>>>>> availableVideoCVPixelFormatTypes:", AVCaptureVideoDataOutput.recommendedVideoSettings(sessionOutput))
        //availableVideoCVPixelFormatTypes
        
        #if os(iOS)
        let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: cameraPosition)
        #elseif os(macOS)
        let device = AVCaptureDevice.default(for: .video)
        #endif
        
        if device != nil {
//            do {
//                try device!.lockForConfiguration()
//                device!.whiteBalanceMode = .locked
//            } catch {
//                pixels.log(.error, .resource, "Camera white balance failed to set.", e: error)
//            }
            do {
                let input = try AVCaptureDeviceInput(device: device!)
                if captureSession.canAddInput(input) {
                    captureSession.addInput(input)
                    if captureSession.canAddOutput(videoOutput){
                        captureSession.addOutput(videoOutput)
                        let queue = DispatchQueue(label: "se.hexagons.pixels.pix.camera.queue")
                        videoOutput.setSampleBufferDelegate(self, queue: queue)
                        start()
                    } else {
                        pixels.log(.error, .resource, "Camera can't add output.")
                    }
                } else {
                    pixels.log(.error, .resource, "Camera can't add input.")
                }
            } catch {
                pixels.log(.error, .resource, "Camera input failed to load.", e: error)
            }
        } else {
            pixels.log(.error, .resource, "Camera not found.")
        }
    
        #if os(iOS)
        NotificationCenter.default.addObserver(self, selector: #selector(deviceRotated), name: UIDevice.orientationDidChangeNotification, object: nil)
        #endif
        
    }
    
    #if os(iOS)
    @objc func deviceRotated() {
        if lastUIOrientation != UIApplication.shared.statusBarOrientation {
            orientationUpdated = true
        } else {
            forceDetectUIOrientation(new: {
                self.orientationUpdated = true
            })
        }
    }
    #endif
    
    #if os(iOS)
    func forceDetectUIOrientation(new: @escaping () -> ()) {
        let forceCount = pixels.fpsMax * 2
        var forceIndex = 0
        let forceTimer = Timer(timeInterval: 1 / Double(pixels.fpsMax), repeats: true, block: { timer in
            if self.lastUIOrientation != UIApplication.shared.statusBarOrientation {
                new()
                timer.invalidate()
            } else {
                forceIndex += 1
                if forceIndex >= forceCount {
                    timer.invalidate()
                }
            }
        })
        RunLoop.current.add(forceTimer, forMode: .common)
    }
    #endif
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            pixels.log(.error, .resource, "Camera buffer conversion failed.")
            return
        }
        
        DispatchQueue.main.async {
            
            if !self.initialFrameCaptured {
                self.setup(pixelBuffer)
                self.initialFrameCaptured = true
            } else if self.orientationUpdated {
                self.setup(pixelBuffer)
                self.orientationUpdated = false
            }
            
            self.capturedCallback(pixelBuffer)
            
        }
        
    }
    
    func setup(_ pixelBuffer: CVPixelBuffer) {
        
        #if os(iOS)
        let _orientation = UIApplication.shared.statusBarOrientation
        #elseif os(macOS)
        let _orientation: Void = ()
        #endif
        
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)

        let resolution: CGSize
        #if os(iOS)
        switch _orientation {
        case .portrait, .portraitUpsideDown:
            resolution = CGSize(width: height, height: width)
        case .landscapeLeft, .landscapeRight:
            resolution = CGSize(width: width, height: height)
        default:
            resolution = CGSize(width: width, height: height)
            pixels.log(.warning, .resource, "Camera orientation unknown.")
        }
        #elseif os(macOS)
        resolution = CGSize(width: width, height: height)
        #endif
        
        setupCallback(resolution, _orientation)
        
        lastUIOrientation = _orientation
        
    }
    
    func start() {
        captureSession.startRunning()
    }
    
    func stop() {
        captureSession.stopRunning()
    }
    
    // MARK: Photo
    
    func capture() {
        guard photoSupport else {
            pixels.log(.warning, .resource, "Photo Capture not enabled.")
            return
        }
        guard let availableRawFormat = photoOutput!.availableRawPhotoPixelFormatTypes.first else { return }
        let photoSettings = AVCapturePhotoSettings(rawPixelFormatType: availableRawFormat,
                                                   processedFormat: [AVVideoCodecKey : AVVideoCodecType.hevc])
        photoSettings.isAutoStillImageStabilizationEnabled = false // RAW is incompatible with image stabilization.
        photoOutput!.capturePhoto(with: photoSettings, delegate: self)
    }
    
    var rawImageFileURL: URL?
//    var compressedFileData: Data?
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        if photo.isRawPhoto {
            // Save the RAW (DNG) file data to a URL.
            let dngFileURL = self.makeUniqueTempFileURL(extension: "dng")
            do {
                try photo.fileDataRepresentation()!.write(to: dngFileURL)
                // ...
            } catch {
                fatalError("couldn't write DNG file to URL")
            }
        } else {
//            self.compressedFileData = photo.fileDataRepresentation()!
        }
        
    }

    func makeUniqueTempFileURL(extension type: String) -> URL {
        let temporaryDirectoryURL = FileManager.default.temporaryDirectory
        let uniqueFilename = ProcessInfo.processInfo.globallyUniqueString
        let urlNoExt = temporaryDirectoryURL.appendingPathComponent(uniqueFilename)
        let url = urlNoExt.appendingPathExtension(type)
        return url
    }
}

