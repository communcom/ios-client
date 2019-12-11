import AVFoundation
import UIKit

class QRScannerViewController: BaseViewController, AVCaptureMetadataOutputObjectsDelegate {
    // MARK: - Properties
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var completion: ((LoginCredential) -> Void)?
    
    // MARK: - Subviews
    lazy var errorView = ErrorView(
        title: "cannot use Back Camera".localized().uppercaseFirst,
        subtitle: "this app is not authorized to use Back Camera.\nPlease enable it in Settings".localized().uppercaseFirst,
        retryButtonTitle: "open Settings".localized().uppercaseFirst) {
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
    }
    
    override func setUp() {
        super.setUp()
        setLeftNavBarButtonForGoingBack(tintColor: .white)
        scan()
    }
    
    func setUpViews() {
        let scanQrArea = UIImageView(width: 260 * Config.heightRatio, height: 260 * Config.heightRatio, imageNamed: "scan-qr-area")
        view.addSubview(scanQrArea)
        scanQrArea.autoAlignAxis(toSuperviewAxis: .horizontal)
        scanQrArea.autoAlignAxis(toSuperviewAxis: .vertical)
        
        let scanQrTitle = UILabel.with(text: "scan QR".localized().uppercaseFirst, textSize: 30, weight: .bold, textColor: .white, textAlignment: .center)
        view.addSubview(scanQrTitle)
        scanQrTitle.autoAlignAxis(toSuperviewAxis: .vertical)
        scanQrTitle.autoPinEdge(.top, to: .bottom, of: scanQrArea, withOffset: 65 * Config.heightRatio)
        
        let gotoCommunTitle = UILabel.with(text: "go to commun.com and scan QR".localized().uppercaseFirst, textSize: 17, weight: .semibold, textColor: .white, textAlignment: .center)
        view.addSubview(gotoCommunTitle)
        gotoCommunTitle.autoAlignAxis(toSuperviewAxis: .vertical)
        gotoCommunTitle.autoPinEdge(.top, to: .bottom, of: scanQrTitle, withOffset: 16)
    }
    
    // MARK: - Methods
    override func bind() {
        super.bind()
        NotificationCenter.default.rx.notification(UIApplication.didBecomeActiveNotification)
            .subscribe(onNext: { (_) in
                switch AVCaptureDevice.authorizationStatus(for: .video) {
                    case .authorized: // The user has previously granted access to the camera.
                        self.scan()
                    
                    case .notDetermined: // The user has not yet been asked for camera access.
                        AVCaptureDevice.requestAccess(for: .video) { granted in
                            if granted {
                                self.scan()
                            }
                        }
                    
                    case .denied: // The user has previously denied access.
                        self.retryGrantingPermission()
                        return

                    case .restricted: // The user can't grant access due to restrictions.
                        self.retryGrantingPermission()
                        return
                    @unknown default:
                        self.failed()
                        return
                }
            })
            .disposed(by: disposeBag)
    }
    
    func scan() {
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            failed()
            return
        }
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            if (error as NSError).code == -11852 {
                retryGrantingPermission()
            }
            else {
                failed()
            }
            return
        }
        
        self.navigationItem.leftBarButtonItem?.tintColor = .white
        view.removeSubviews()
        view.backgroundColor = UIColor.black
        captureSession = AVCaptureSession()

        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failed()
            return
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        captureSession.startRunning()
        setUpViews()
    }
    
    func retryGrantingPermission() {
        self.navigationItem.leftBarButtonItem?.tintColor = .black
        view.addSubview(errorView)
        errorView.autoPinEdgesToSuperviewEdges()
        captureSession = nil
    }

    func failed() {
        self.navigationItem.leftBarButtonItem?.tintColor = .black
        view.backgroundColor = .white
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            found(code: stringValue)
        }
    }

    var isBlocking = false
    func found(code: String) {
        guard isBlocking == false else {return}
        // check
        guard let decodedData = Data(base64Encoded: code),
            let user = try? JSONDecoder().decode(QrCodeDecodedProfile.self, from: decodedData)
        else {
            isBlocking = false
            return
        }

        isBlocking = true
        
        // vibrate
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        
        // completion
        captureSession.stopRunning()
        
        self.backCompletion {
            self.completion?(LoginCredential(login: user.username, key: user.password))
        }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}
