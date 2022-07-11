// Copyright © 2022 Wells Consulting LLC. All rights reserved.

import Foundation
import AVFoundation
import UIKit

public class WCCameraScannerVC: UIViewController {
    
    struct Symbologies: OptionSet {
        let rawValue: Int

        static let aztec = Symbologies(rawValue: 1 << 0)
        static let code128 = Symbologies(rawValue: 1 << 1)
        static let code39 = Symbologies(rawValue: 1 << 2)
        static let code39Mod43 = Symbologies(rawValue: 1 << 3)
        static let code93 = Symbologies(rawValue: 1 << 4)
        static let datamatrix = Symbologies(rawValue: 1 << 5)
        static let ean8 = Symbologies(rawValue: 1 << 6)
        static let i2of5 = Symbologies(rawValue: 1 << 7)
        static let pdf417 = Symbologies(rawValue: 1 << 8)
        static let qrCode = Symbologies(rawValue: 1 << 9)
        static let upca = Symbologies(rawValue: 1 << 10) // Really an ean13
        static let upce = Symbologies(rawValue: 1 << 11)

        static let all: Symbologies = [
            .aztec, .code128, .code39, .code39Mod43, .code93, .datamatrix, .ean8, .i2of5, .pdf417, .qrCode, .upca, .upce,
        ]
    }
    
    public static let notification = Notification.Name("WCKit.ScannedBarcode")
    
    // MARK: Outlets

    @IBOutlet private var videoView: UIView!
    @IBOutlet private var cancelButton: UIButton!

    // MARK: Properties

    private var captureSession: AVCaptureSession?
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    private let processingQueue = DispatchQueue(label: "WCKit.CameraScanner")

    var enabledSymbologies = Symbologies()
    var overrideScanProcessor: ((Barcode) -> Void)?

    // MARK: Lifetime

    static func make() -> WCCameraScannerVC {
        let name = "\(Self.self)"

        let storyboard = UIStoryboard(
            name: name,
            bundle: Bundle(for: Self.self)
        )

        guard let vc = storyboard.instantiateViewController(withIdentifier: name) as? Self else {
            // We have to return a type T here. We could change the signature to return
            // a result type or an optional, but that would make all the call sites
            // quite ugly. So we deal with a trap here.
            fatalError("Could not find view controller with identifier \(name)")
        }
        
        return vc
    }

    // MARK: Overrides

   public  override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Sometimes this is shown from view controllers where the
        // navigation bar is hidden so we turn it back on here.
        navigationController?.isNavigationBarHidden = false

        if !Runtime.isSimulator {
            startCapture()
        } else {
            WCAlert.show(
                "Camera Scanner",
                title: "Simulator does not support AVFoundation",
                severity: .error,
                presentation: .modal
            )
        }
    }

    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        if !Runtime.isSimulator {
            stopCapture()
        }
    }

    // MARK: Actions

    @IBAction
    private func cancelButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    // MARK: Private Implementation

    private func stopCapture() {
        captureSession?.stopRunning()
    }

    private func startCapture() {
        guard let captureDevice = AVCaptureDevice.default(for: AVMediaType.video) else {
            Log.error("Could not create default capture device")
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)

            let captureSession = AVCaptureSession()
            captureSession.addInput(input)

            let output = AVCaptureMetadataOutput()
            captureSession.addOutput(output)

            output.setMetadataObjectsDelegate(self, queue: processingQueue)

            var barcodeTypes = [AVMetadataObject.ObjectType]()

            if enabledSymbologies.contains(.aztec) { barcodeTypes.append(AVMetadataObject.ObjectType.aztec) }
            if enabledSymbologies.contains(.code128) { barcodeTypes.append(AVMetadataObject.ObjectType.code128) }
            if enabledSymbologies.contains(.code39) { barcodeTypes.append(AVMetadataObject.ObjectType.code39) }
            if enabledSymbologies.contains(.code39Mod43) { barcodeTypes.append(AVMetadataObject.ObjectType.code39Mod43) }
            if enabledSymbologies.contains(.code93) { barcodeTypes.append(AVMetadataObject.ObjectType.code93) }
            if enabledSymbologies.contains(.datamatrix) { barcodeTypes.append(AVMetadataObject.ObjectType.dataMatrix) }
            if enabledSymbologies.contains(.ean8) { barcodeTypes.append(AVMetadataObject.ObjectType.ean8) }
            if enabledSymbologies.contains(.i2of5) { barcodeTypes.append(AVMetadataObject.ObjectType.interleaved2of5) }
            if enabledSymbologies.contains(.pdf417) { barcodeTypes.append(AVMetadataObject.ObjectType.pdf417) }
            if enabledSymbologies.contains(.qrCode) { barcodeTypes.append(AVMetadataObject.ObjectType.qr) }
            if enabledSymbologies.contains(.upca) { barcodeTypes.append(AVMetadataObject.ObjectType.ean13) }
            if enabledSymbologies.contains(.upce) { barcodeTypes.append(AVMetadataObject.ObjectType.upce) }

            output.metadataObjectTypes = barcodeTypes

            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreviewLayer?.frame = videoView.layer.bounds
            videoView.layer.addSublayer(videoPreviewLayer!)

            captureSession.startRunning()

            self.captureSession = captureSession
        } catch let error as NSError {
            Log.error("Error setting up video capture: " + error.localizedDescription)
            WCAlert.show(
                error.localizedDescription,
                title: "Video Capture",
                severity: .error,
                presentation: .modal
            )
        } catch {
            Log.error("Unknown error setting up video capture")
            WCAlert.show(
                "Unknown error",
                title: "Video Capture",
                severity: .error,
                presentation: .modal
            )
        }
    }
}

// MARK: - AVCaptureMetadataOutputObjectsDelegate

extension WCCameraScannerVC: AVCaptureMetadataOutputObjectsDelegate {
    public func metadataOutput(
        _: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from _: AVCaptureConnection
    ) {
        let objects = metadataObjects
            .compactMap { $0 as? AVMetadataMachineReadableCodeObject }
            .filter { $0.stringValue != nil }

        guard !objects.isEmpty else {
            return
        }

        let barcodes: [Barcode] = objects
            .compactMap {
                guard let text = $0.stringValue else {
                    return nil
                }
                switch $0.type {
                case AVMetadataObject.ObjectType.code128:
                    return Barcode(symbology: .code128, text: text)
                case AVMetadataObject.ObjectType.dataMatrix:
                    return Barcode(symbology: .datamatrix, text: text)
                case AVMetadataObject.ObjectType.ean13:
                    // EAN13 is the same as UPCA so we remap it here
                    return Barcode(symbology: .upca, text: text)
                default:
                    return nil
                }
            }

        guard let barcode = barcodes.first else { return }

        DispatchQueue.main.async {
            self.stopCapture()

            if let processor = self.overrideScanProcessor {
                processor(barcode)
            } else {
                NotificationCenter.default.post(
                    name: Self.notification,
                    object: barcode
                )
            }

            if self.isModalInPresentation {
                self.dismiss(animated: true, completion: nil)
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}
