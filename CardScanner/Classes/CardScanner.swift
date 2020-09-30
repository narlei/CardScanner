//
//  CardScanner.swift
//  CardScanner
//
//  Created by Narlei Moreira on 09/30/2020.
//  Copyright (c) 2020 Narlei Moreira. All rights reserved.
//

import AVFoundation
import CoreImage
import UIKit
import Vision

@available(iOS 13.0, *)
public class CardScanner: UIViewController {
    // MARK: - Private Properties

    private let captureSession = AVCaptureSession()
    private lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let preview = AVCaptureVideoPreviewLayer(session: self.captureSession)
        preview.videoGravity = .resizeAspect
        return preview
    }()

    private let device = AVCaptureDevice.default(for: .video)

    private var viewGuide: PartialTransparentView!

    private var creditCardNumber: String?
    private var creditCardName: String?
    private var creditCardCVV: String?
    private var creditCardDate: String?

    private let videoOutput = AVCaptureVideoDataOutput()

    // MARK: - Public Properties

    public var labelCardNumber: UILabel?
    public var labelCardDate: UILabel?
    public var labelCardCVV: UILabel?
    public var labelHintBottom: UILabel?
    public var labelHintTop: UILabel?
    public var buttonComplete: UIButton?

    public var hintTopText = "Center your card until the fields are recognized"
    public var hintBottomText = "Touch a recognized value to delete the value and try again"
    public var buttonConfirmTitle = "Confirm"
    public var buttonConfirmBackgroundColor: UIColor = .red

    // MARK: - Instance dependencies

    private var resultsHandler: (_ number: String?, _ date: String?, _ cvv: String?) -> Void?

    // MARK: - Initializers

    init(resultsHandler: @escaping (_ number: String?, _ date: String?, _ cvv: String?) -> Void) {
        self.resultsHandler = resultsHandler
        super.init(nibName: nil, bundle: nil)
    }

    public class func getScanner(resultsHandler: @escaping (_ number: String?, _ date: String?, _ cvv: String?) -> Void) -> UINavigationController {
        let viewScanner = CardScanner(resultsHandler: resultsHandler)
        let navigation = UINavigationController(rootViewController: viewScanner)
        return navigation
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func loadView() {
        view = UIView()
    }

    deinit {
        stop()
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        setupCaptureSession()
        captureSession.startRunning()
        title = "Scanner card"

        let buttomItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(scanCompleted))
        buttomItem.tintColor = .white
        navigationItem.leftBarButtonItem = buttomItem
    }

    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame = view.bounds
    }

    // MARK: - Add Views

    private func setupCaptureSession() {
        addCameraInput()
        addPreviewLayer()
        addVideoOutput()
        addGuideView()
    }

    private func addCameraInput() {
        guard let device = device else { return }
        let cameraInput = try! AVCaptureDeviceInput(device: device)
        captureSession.addInput(cameraInput)
    }

    private func addPreviewLayer() {
        view.layer.addSublayer(previewLayer)
    }

    private func addVideoOutput() {
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as NSString: NSNumber(value: kCVPixelFormatType_32BGRA)] as [String: Any]
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "my.image.handling.queue"))
        captureSession.addOutput(videoOutput)
        guard let connection = videoOutput.connection(with: AVMediaType.video),
            connection.isVideoOrientationSupported else {
            return
        }
        connection.videoOrientation = .portrait
    }

    private func addGuideView() {
        let widht = UIScreen.main.bounds.width - (UIScreen.main.bounds.width * 0.2)
        let height = widht - (widht * 0.45)
        let viewX = (UIScreen.main.bounds.width / 2) - (widht / 2)
        let viewY = (UIScreen.main.bounds.height / 2) - (height / 2) - 100

        viewGuide = PartialTransparentView(rectsArray: [CGRect(x: viewX, y: viewY, width: widht, height: height)])

        view.addSubview(viewGuide)
        viewGuide.translatesAutoresizingMaskIntoConstraints = false
        viewGuide.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        viewGuide.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        viewGuide.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        viewGuide.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        view.bringSubview(toFront: viewGuide)

        let bottomY = (UIScreen.main.bounds.height / 2) + (height / 2) - 100

        let labelCardNumberX = viewX + 20
        let labelCardNumberY = bottomY - 50
        labelCardNumber = UILabel(frame: CGRect(x: labelCardNumberX, y: labelCardNumberY, width: 100, height: 30))
        view.addSubview(labelCardNumber!)
        labelCardNumber?.translatesAutoresizingMaskIntoConstraints = false
        labelCardNumber?.leftAnchor.constraint(equalTo: view.leftAnchor, constant: labelCardNumberX).isActive = true
        labelCardNumber?.topAnchor.constraint(equalTo: view.topAnchor, constant: labelCardNumberY).isActive = true
        labelCardNumber?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        labelCardNumber?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(clearCardNumber)))
        labelCardNumber?.isUserInteractionEnabled = true

        let labelCardDateX = viewX + 20
        let labelCardDateY = bottomY - 90
        labelCardDate = UILabel(frame: CGRect(x: labelCardDateX, y: labelCardDateY, width: 100, height: 30))
        view.addSubview(labelCardDate!)
        labelCardDate?.translatesAutoresizingMaskIntoConstraints = false
        labelCardDate?.leftAnchor.constraint(equalTo: view.leftAnchor, constant: labelCardDateX).isActive = true
        labelCardDate?.topAnchor.constraint(equalTo: view.topAnchor, constant: labelCardDateY).isActive = true
        labelCardDate?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        labelCardDate?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(clearCardDate)))
        labelCardDate?.isUserInteractionEnabled = true

        let labelCardCVVX = viewX + 200
        let labelCardCVVY = bottomY - 90
        labelCardCVV = UILabel(frame: CGRect(x: labelCardCVVX, y: labelCardCVVY, width: 100, height: 30))
        view.addSubview(labelCardCVV!)
        labelCardCVV?.translatesAutoresizingMaskIntoConstraints = false
        labelCardCVV?.leftAnchor.constraint(equalTo: view.leftAnchor, constant: labelCardCVVX).isActive = true
        labelCardCVV?.topAnchor.constraint(equalTo: view.topAnchor, constant: labelCardCVVY).isActive = true
        labelCardCVV?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        labelCardCVV?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(clearCardCVV)))
        labelCardCVV?.isUserInteractionEnabled = true

        let labelHintTopY = viewY - 40
        labelHintTop = UILabel(frame: CGRect(x: labelCardCVVX, y: labelCardCVVY, width: widht, height: 30))
        view.addSubview(labelHintTop!)
        labelHintTop?.translatesAutoresizingMaskIntoConstraints = false
        labelHintTop?.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        labelHintTop?.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        labelHintTop?.topAnchor.constraint(equalTo: view.topAnchor, constant: labelHintTopY).isActive = true
        labelHintTop?.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        labelHintTop?.text = hintTopText
        labelHintTop?.numberOfLines = 0
        labelHintTop?.textAlignment = .center

        let labelHintBottomY = bottomY + 30
        labelHintBottom = UILabel(frame: CGRect(x: labelCardCVVX, y: labelCardCVVY, width: widht, height: 30))
        view.addSubview(labelHintBottom!)
        labelHintBottom?.translatesAutoresizingMaskIntoConstraints = false
        labelHintBottom?.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        labelHintBottom?.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        labelHintBottom?.topAnchor.constraint(equalTo: view.topAnchor, constant: labelHintBottomY).isActive = true
        labelHintBottom?.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        labelHintBottom?.text = hintBottomText
        labelHintBottom?.numberOfLines = 0
        labelHintBottom?.textAlignment = .center

        let buttonCompleteX = viewX
        let buttonCompleteY = UIScreen.main.bounds.height - 90
        buttonComplete = UIButton(frame: CGRect(x: buttonCompleteX, y: buttonCompleteY, width: 100, height: 50))
        view.addSubview(buttonComplete!)
        buttonComplete?.translatesAutoresizingMaskIntoConstraints = false
        buttonComplete?.leftAnchor.constraint(equalTo: view.leftAnchor, constant: viewX).isActive = true
        buttonComplete?.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: viewX * -1).isActive = true
        buttonComplete?.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -90).isActive = true
        buttonComplete?.heightAnchor.constraint(equalToConstant: 50).isActive = true
        buttonComplete?.setTitle(buttonConfirmTitle, for: .normal)
        buttonComplete?.backgroundColor = buttonConfirmBackgroundColor
        buttonComplete?.layer.cornerRadius = 10
        buttonComplete?.layer.masksToBounds = true
        buttonComplete?.addTarget(self, action: #selector(scanCompleted), for: .touchUpInside)
        
        view.backgroundColor = .black
    }

    // MARK: - Clear on touch

    @objc func clearCardNumber() {
        labelCardNumber?.text = ""
        creditCardNumber = nil
    }

    @objc func clearCardDate() {
        labelCardDate?.text = ""
        creditCardDate = nil
    }

    @objc func clearCardCVV() {
        labelCardCVV?.text = ""
        creditCardCVV = nil
    }

    // MARK: - Completed process

    @objc func scanCompleted() {
        resultsHandler(creditCardNumber, creditCardDate, creditCardCVV)
        stop()
        dismiss(animated: true, completion: nil)
    }

    private func stop() {
        captureSession.stopRunning()
    }

    // MARK: - Payment detection

    private func handleObservedPaymentCard(in frame: CVImageBuffer) {
        DispatchQueue.global(qos: .userInitiated).async {
            self.extractPaymentCardData(frame: frame)
        }
    }

    private func extractPaymentCardData(frame: CVImageBuffer) {
        let ciImage = CIImage(cvImageBuffer: frame)
        let widht = UIScreen.main.bounds.width - (UIScreen.main.bounds.width * 0.2)
        let height = widht - (widht * 0.45)
        let viewX = (UIScreen.main.bounds.width / 2) - (widht / 2)
        let viewY = (UIScreen.main.bounds.height / 2) - (height / 2) - 100 + height

        let resizeFilter = CIFilter(name: "CILanczosScaleTransform")!

        // Desired output size
        let targetSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)

        // Compute scale and corrective aspect ratio
        let scale = targetSize.height / ciImage.extent.height
        let aspectRatio = targetSize.width / (ciImage.extent.width * scale)

        // Apply resizing
        resizeFilter.setValue(ciImage, forKey: kCIInputImageKey)
        resizeFilter.setValue(scale, forKey: kCIInputScaleKey)
        resizeFilter.setValue(aspectRatio, forKey: kCIInputAspectRatioKey)
        let outputImage = resizeFilter.outputImage

        let croppedImage = outputImage!.cropped(to: CGRect(x: viewX, y: viewY, width: widht, height: height))

        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = false

        let stillImageRequestHandler = VNImageRequestHandler(ciImage: croppedImage, options: [:])
        try? stillImageRequestHandler.perform([request])

        guard let texts = request.results as? [VNRecognizedTextObservation], texts.count > 0 else {
            // no text detected
            return
        }

        let myText = texts.flatMap({ $0.topCandidates(10).map({ $0.string }) })

        for line in myText {
            print("Trying to parse: \(line)")

            let trimmed = line.replacingOccurrences(of: " ", with: "")

            if creditCardNumber == nil && trimmed.count > 10, let cardNumber = Int(trimmed) {
                if cardNumber > 0 && trimmed.count == 16 {
                    creditCardNumber = line
                    DispatchQueue.main.async {
                        self.labelCardNumber?.text = line
                        self.tapticFeedback()
                    }
                    continue
                }
            }

            if creditCardCVV == nil && trimmed.count == 3, let cardNumber = Int(trimmed) {
                if cardNumber > 0 {
                    creditCardCVV = line
                    DispatchQueue.main.async {
                        self.labelCardCVV?.text = line
                        self.tapticFeedback()
                    }
                    continue
                }
            }

            if creditCardDate == nil && trimmed.count > 4 && trimmed.count < 8, Int(trimmed) == nil, trimmed.isDate {
                creditCardDate = line
                DispatchQueue.main.async {
                    self.labelCardDate?.text = line
                    self.tapticFeedback()
                }
                continue
            }

            // Not used yet
            if creditCardName == nil && trimmed.count > 10, Int(trimmed) == nil, line.contains(" "), trimmed.isOnlyAlpha {
                creditCardName = line
                continue
            }
        }
    }

    private func tapticFeedback() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension CardScanner: AVCaptureVideoDataOutputSampleBufferDelegate {
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let frame = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            debugPrint("unable to get image from sample buffer")
            return
        }

        handleObservedPaymentCard(in: frame)
    }
}

// MARK: - Extensions

extension String {
    var isOnlyAlpha: Bool {
        return !isEmpty && range(of: "[^a-zA-Z]", options: .regularExpression) == nil
    }

    // Date Pattern MM/YY or MM/YYYY
    var isDate: Bool {
        let arrayDate = components(separatedBy: "/")
        if arrayDate.count == 2 {
            if let month = Int(arrayDate[0]), let year = Int(arrayDate[1]) {
                if month > 12 || month < 1 {
                    return false
                }
                if year < 50 && year > 20 {
                    return true
                }
                if year > 2020 && year < 2050 {
                    return true
                }
            }
        }
        return false
    }
}

// MARK: - Class PartialTransparentView

class PartialTransparentView: UIView {
    var rectsArray: [CGRect]?

    convenience init(rectsArray: [CGRect]) {
        self.init()

        self.rectsArray = rectsArray

        backgroundColor = UIColor.black.withAlphaComponent(0.6)
        isOpaque = false
    }

    override func draw(_ rect: CGRect) {
        backgroundColor?.setFill()
        UIRectFill(rect)

        guard let rectsArray = rectsArray else {
            return
        }

        for holeRect in rectsArray {
            let path = UIBezierPath(roundedRect: holeRect, cornerRadius: 10)

            let holeRectIntersection = rect.intersection(holeRect)

            UIRectFill(holeRectIntersection)

            UIColor.clear.setFill()
            UIGraphicsGetCurrentContext()?.setBlendMode(CGBlendMode.copy)
            path.fill()
        }
    }
}
