//
//  ViewController.swift
//  ContoursAIExampleiOS
//
//  Created by UrbanFT on 19/12/22.
//

import UIKit
import ContoursAI_SDK


class ViewController: UIViewController,CheckCaptureDelegate{
    
    private var frontImageView: UIImageView!
    private var backImageView: UIImageView!
    private var frontImagebutton: UIButton!
    private var backImagebutton: UIButton!
    private var buttonCheckScan: TabButton!
    private var buttonIdScan: TabButton!
    private var passport: TabButton!
    private var selfie: TabButton!

    let contoursSDK = ContoursAIFramework()
    var selectedDocumentType : ScanType = .check

    private let eyebrowLabel = UILabel()
    private let platformLabel = UILabel()
    private let versionLabel = UILabel()
    private let screenTitleLabel = UILabel()
    private let screenDescriptionLabel = UILabel()
    private let statusLabel = UILabel()
    private let frontTileTitleLabel = UILabel()
    private let backTileTitleLabel = UILabel()
    private var frontPreviewTile: UIStackView!
    private let backPreviewTile = UIStackView()
    private let tabContainer = UIView()
    private var frontPreviewSquareConstraint: NSLayoutConstraint?

    private let textStrong = UIColor(red: 0.094, green: 0.212, blue: 0.259, alpha: 1.0)
    private let textMuted = UIColor(red: 0.373, green: 0.467, blue: 0.510, alpha: 1.0)
    private let brandAccent = UIColor(red: 0.059, green: 0.463, blue: 0.431, alpha: 1.0)

    override func viewDidLoad() {
        super.viewDidLoad()
        buildAndroidStyleInterface()
        applyDocumentUI(for: .check, resetImages: false)
        setStatus("Preparing scanner...")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
  
    // MARK: - Intrenals function
    func openContoursSDKConcept(checkSide:Int) {
        ContoursAIFramework.shared.isLandscape = true
        setStatus(openingStatus(for: checkSide))
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
            self.view.layoutSubviews()
            switch checkSide {
            case 101:
                self.openFrontOfCheck()
            case 102:
                self.openRearOfCheck()
            default : break
            }
        })
    }
    
    func openFrontOfCheck(){
        let configModel = ContoursModel(clientId: "cyclops",
                                        captureType: CaptureType.both.rawValue,
                                        type: selectedDocumentType.rawValue,
                                        capturingSide: DocumentSide.front.rawValue,
                                        environmentType: "dev",
                                        delegate: self)
        let imageVC = contoursSDK.startContour(configModel: configModel,enableMultipleCapturing: false)
        let navigationController = UINavigationController(rootViewController: imageVC)
        navigationController.modalPresentationStyle = .fullScreen
        self.present(navigationController, animated: false)
    }
    
    func openRearOfCheck() {
        let configModel = ContoursModel(clientId: "<YOUR CLIENT ID>",
                                        captureType: CaptureType.both.rawValue,
                                        type: selectedDocumentType.rawValue,
                                        capturingSide: DocumentSide.back.rawValue,
                                        delegate: self)
        let imageVC = contoursSDK.startContour(configModel: configModel)
        let navigationController = UINavigationController(rootViewController: imageVC)
        navigationController.modalPresentationStyle = .fullScreen
        self.present(navigationController, animated: false)
    }
    
    func imageCaptured(frontImageCropped: UIImage?, rearImageCropped: UIImage?, frontImage: UIImage?, rearImage: UIImage?) {
        ContoursAIFramework.shared.isLandscape = false
        if frontImage != nil {
            frontImageView.image = frontImageCropped
            frontImageView.isHidden = false
            frontImagebutton.setTitle(nil, for: .normal)
        }
        if rearImage != nil {
            backImageView.image = rearImageCropped
            backImageView.isHidden = false
            backImagebutton.setTitle(nil, for: .normal)
        }
        setStatus(captureCompleteStatus(frontCaptured: frontImage != nil, backCaptured: rearImage != nil))
    }
    
    func onContourClose() {
        ContoursAIFramework.shared.isLandscape = false
        if frontImageView.image == nil && backImageView.image == nil {
            setStatus("\(activeDocumentName()) scan closed.")
        }
    }
    
    func eventCaptured(data: [String : Any]?) {
    }
    
    func selfieCaptured(image: UIImage?) {
        if image != nil {
            frontImageView.image = image
            frontImageView.isHidden = false
            frontImagebutton.setTitle(nil, for: .normal)
            setStatus("Selfie completed.")
        }
    }
    
    // MARK: - Actions
    
    @objc func documentButtonClicked(_ sender: UIButton) {
        openContoursSDKConcept(checkSide: sender.tag)
    }
    
    @objc func selectScanType(_ sender: UIButton) {
        switch sender.tag {
        case 102:
            applyDocumentUI(for: .id)
        case 103:
            applyDocumentUI(for: .passport)
        case 104:
            applyDocumentUI(for: .selfie)
        default:
            applyDocumentUI(for: .check)
        }
    
    }
}

private extension ViewController {
    struct DocumentContent {
        let type: ScanType
        let tabTag: Int
        let title: String
        let description: String
        let frontLabel: String
        let backLabel: String?
        let activeName: String
    }

    var documents: [DocumentContent] {
        [
            DocumentContent(type: .check, tabTag: 101, title: "Check Scan", description: "Capture the front or back side of the check.", frontLabel: "Front check", backLabel: "Rear check", activeName: "Check"),
            DocumentContent(type: .id, tabTag: 102, title: "ID Scan", description: "Capture the front and back side of the ID.", frontLabel: "Front ID", backLabel: "Rear ID", activeName: "ID"),
            DocumentContent(type: .passport, tabTag: 103, title: "Passport Scan", description: "Capture the passport front face only.", frontLabel: "Passport Front Face", backLabel: nil, activeName: "Passport"),
            DocumentContent(type: .selfie, tabTag: 104, title: "Take Selfie", description: "Capture your selfie", frontLabel: "User Selfie", backLabel: nil, activeName: "Selfie")
        ]
    }

    var currentDocument: DocumentContent {
        documents.first { $0.type == selectedDocumentType } ?? documents[0]
    }

    func buildAndroidStyleInterface() {
        view.subviews.forEach { $0.removeFromSuperview() }

        let backgroundView = GradientBackgroundView()
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backgroundView)

        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentInset = UIEdgeInsets(top: 24, left: 0, bottom: 120, right: 0)
        view.addSubview(scrollView)

        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        let heroCard = UIView()
        heroCard.translatesAutoresizingMaskIntoConstraints = false
        heroCard.backgroundColor = UIColor(red: 1.0, green: 0.988, blue: 0.973, alpha: 0.88)
        heroCard.layer.cornerRadius = 28
        heroCard.layer.borderWidth = 1
        heroCard.layer.borderColor = UIColor(red: 0.184, green: 0.278, blue: 0.341, alpha: 0.12).cgColor
        heroCard.layer.shadowColor = UIColor.black.cgColor
        heroCard.layer.shadowOpacity = 0.12
        heroCard.layer.shadowRadius = 18
        heroCard.layer.shadowOffset = CGSize(width: 0, height: 10)
        contentView.addSubview(heroCard)

        let cardStack = UIStackView()
        cardStack.translatesAutoresizingMaskIntoConstraints = false
        cardStack.axis = .vertical
        cardStack.spacing = 0
        heroCard.addSubview(cardStack)

        configureLabel(eyebrowLabel, text: "IDENTITY VERIFICATION", color: brandAccent, font: .systemFont(ofSize: 13, weight: .semibold), lines: 1)
        configureLabel(platformLabel, text: "Powered by Native iOS UIKit", color: textMuted, font: .systemFont(ofSize: 12, weight: .medium), lines: 1)
        configureLabel(versionLabel, text: "App Version \(appVersionName())", color: textMuted, font: .systemFont(ofSize: 12, weight: .regular), lines: 1)
        configureLabel(screenTitleLabel, text: nil, color: textStrong, font: .systemFont(ofSize: 34, weight: .light), lines: 0)
        configureLabel(screenDescriptionLabel, text: nil, color: textMuted, font: .systemFont(ofSize: 15, weight: .regular), lines: 0)
        configureLabel(statusLabel, text: nil, color: textMuted, font: .systemFont(ofSize: 14, weight: .regular), lines: 0)

        cardStack.addArrangedSubview(eyebrowLabel)
        cardStack.setCustomSpacing(6, after: eyebrowLabel)
        cardStack.addArrangedSubview(platformLabel)
        cardStack.setCustomSpacing(4, after: platformLabel)
        cardStack.addArrangedSubview(versionLabel)
        cardStack.setCustomSpacing(12, after: versionLabel)
        cardStack.addArrangedSubview(screenTitleLabel)
        cardStack.setCustomSpacing(12, after: screenTitleLabel)
        cardStack.addArrangedSubview(screenDescriptionLabel)
        cardStack.setCustomSpacing(20, after: screenDescriptionLabel)
        cardStack.addArrangedSubview(statusLabel)
        cardStack.setCustomSpacing(20, after: statusLabel)

        let previewStack = UIStackView()
        previewStack.axis = .vertical
        previewStack.spacing = 16
        cardStack.addArrangedSubview(previewStack)

        let frontTile = makePreviewTile(titleLabel: frontTileTitleLabel, imageTag: 101, buttonTag: 101)
        frontPreviewTile = frontTile.tile
        frontImageView = frontTile.imageView
        frontImagebutton = frontTile.button
        frontPreviewSquareConstraint = frontTile.previewSurface.widthAnchor.constraint(equalTo: frontTile.previewSurface.heightAnchor)
        previewStack.addArrangedSubview(frontTile.tile)

        let backTile = makePreviewTile(titleLabel: backTileTitleLabel, imageTag: 102, buttonTag: 102)
        backImageView = backTile.imageView
        backImagebutton = backTile.button
        backPreviewTile.axis = .vertical
        backPreviewTile.spacing = 0
        backPreviewTile.addArrangedSubview(backTile.tile)
        previewStack.addArrangedSubview(backPreviewTile)

        buildBottomTabs()
        view.addSubview(tabContainer)

        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),

            heroCard.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            heroCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            heroCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            heroCard.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            cardStack.topAnchor.constraint(equalTo: heroCard.topAnchor, constant: 24),
            cardStack.leadingAnchor.constraint(equalTo: heroCard.leadingAnchor, constant: 24),
            cardStack.trailingAnchor.constraint(equalTo: heroCard.trailingAnchor, constant: -24),
            cardStack.bottomAnchor.constraint(equalTo: heroCard.bottomAnchor, constant: -24),

            tabContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tabContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tabContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            tabContainer.heightAnchor.constraint(equalToConstant: 62)
        ])

        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeLeft.direction = .left
        scrollView.addGestureRecognizer(swipeLeft)

        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeRight.direction = .right
        scrollView.addGestureRecognizer(swipeRight)
    }

    func buildBottomTabs() {
        tabContainer.translatesAutoresizingMaskIntoConstraints = false
        tabContainer.backgroundColor = UIColor.white.withAlphaComponent(0.92)
        tabContainer.layer.cornerRadius = 20
        tabContainer.layer.borderWidth = 1
        tabContainer.layer.borderColor = UIColor(red: 0.184, green: 0.278, blue: 0.341, alpha: 0.12).cgColor
        tabContainer.layer.shadowColor = UIColor.black.cgColor
        tabContainer.layer.shadowOpacity = 0.14
        tabContainer.layer.shadowRadius = 14
        tabContainer.layer.shadowOffset = CGSize(width: 0, height: 8)

        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 4
        tabContainer.addSubview(stack)

        let checkButton = makeTabButton(title: "CHECK", tag: 101)
        let idButton = makeTabButton(title: "ID", tag: 102)
        let passportButton = makeTabButton(title: "PASSPORT", tag: 103)
        let selfieButton = makeTabButton(title: "Selfie", tag: 104)

        [checkButton, idButton, passportButton, selfieButton].forEach { stack.addArrangedSubview($0) }

        buttonCheckScan = checkButton
        buttonIdScan = idButton
        passport = passportButton
        selfie = selfieButton

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: tabContainer.topAnchor, constant: 8),
            stack.leadingAnchor.constraint(equalTo: tabContainer.leadingAnchor, constant: 8),
            stack.trailingAnchor.constraint(equalTo: tabContainer.trailingAnchor, constant: -8),
            stack.bottomAnchor.constraint(equalTo: tabContainer.bottomAnchor, constant: -8)
        ])
    }

    func makeTabButton(title: String, tag: Int) -> TabButton {
        let button = TabButton(type: .custom)
        button.tag = tag
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 12, weight: .semibold)
        button.layer.cornerRadius = 14
        button.addTarget(self, action: #selector(selectScanType(_:)), for: .touchUpInside)
        return button
    }

    func makePreviewTile(titleLabel: UILabel, imageTag: Int, buttonTag: Int) -> (tile: UIStackView, previewSurface: UIView, imageView: UIImageView, button: UIButton) {
        let tile = UIStackView()
        tile.axis = .vertical
        tile.alignment = .fill
        tile.spacing = 8

        configureLabel(titleLabel, text: nil, color: textStrong, font: .systemFont(ofSize: 13, weight: .bold), lines: 1)
        tile.addArrangedSubview(titleLabel)

        let previewSurface = PreviewSurfaceView()
        previewSurface.translatesAutoresizingMaskIntoConstraints = false
        previewSurface.layer.cornerRadius = 12
        previewSurface.clipsToBounds = true
        tile.addArrangedSubview(previewSurface)

        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tag = imageTag
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.isHidden = true
        previewSurface.addSubview(imageView)

        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tag = buttonTag
        button.setTitleColor(textMuted, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 13, weight: .regular)
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.textAlignment = .center
        button.addTarget(self, action: #selector(documentButtonClicked(_:)), for: .touchUpInside)
        previewSurface.addSubview(button)

        NSLayoutConstraint.activate([
            previewSurface.heightAnchor.constraint(equalToConstant: 110),
            imageView.topAnchor.constraint(equalTo: previewSurface.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: previewSurface.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: previewSurface.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: previewSurface.bottomAnchor),
            button.topAnchor.constraint(equalTo: previewSurface.topAnchor),
            button.leadingAnchor.constraint(equalTo: previewSurface.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: previewSurface.trailingAnchor),
            button.bottomAnchor.constraint(equalTo: previewSurface.bottomAnchor)
        ])

        return (tile, previewSurface, imageView, button)
    }

    func configureLabel(_ label: UILabel, text: String?, color: UIColor, font: UIFont, lines: Int) {
        label.text = text
        label.textColor = color
        label.font = font
        label.numberOfLines = lines
        label.adjustsFontForContentSizeCategory = true
    }

    func applyDocumentUI(for type: ScanType, resetImages: Bool = true) {
        selectedDocumentType = type
        let content = currentDocument

        screenTitleLabel.text = content.title
        screenDescriptionLabel.text = content.description
        frontTileTitleLabel.text = content.frontLabel
        frontImagebutton.setTitle(content.frontLabel, for: .normal)
        updateFrontPreviewLayout(isSelfie: type == .selfie)

        if let backLabel = content.backLabel {
            backTileTitleLabel.text = backLabel
            backImagebutton.setTitle(backLabel, for: .normal)
            backPreviewTile.isHidden = false
        } else {
            backPreviewTile.isHidden = true
        }

        if resetImages {
            resetPreviews()
        }

        [buttonCheckScan, buttonIdScan, passport, selfie].forEach { button in
            button?.isSelected = button?.tag == content.tabTag
        }

        setStatus("Ready to scan \(content.activeName.lowercased()).")
    }

    func updateFrontPreviewLayout(isSelfie: Bool) {
        frontPreviewTile.alignment = isSelfie ? .leading : .fill
        frontPreviewSquareConstraint?.isActive = isSelfie
    }

    func resetPreviews() {
        frontImageView.image = nil
        frontImageView.isHidden = true
        backImageView.image = nil
        backImageView.isHidden = true
        frontImagebutton.setTitle(currentDocument.frontLabel, for: .normal)
        backImagebutton.setTitle(currentDocument.backLabel, for: .normal)
    }

    @objc func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        let tags = documents.map { $0.tabTag }
        guard let currentIndex = tags.firstIndex(of: currentDocument.tabTag) else { return }
        let nextIndex: Int
        if gesture.direction == .left {
            nextIndex = min(currentIndex + 1, tags.count - 1)
        } else {
            nextIndex = max(currentIndex - 1, 0)
        }
        guard nextIndex != currentIndex else { return }
        let nextType = documents[nextIndex].type
        applyDocumentUI(for: nextType)
    }

    func setStatus(_ message: String) {
        statusLabel.text = message
    }

    func activeDocumentName() -> String {
        currentDocument.activeName
    }

    func openingStatus(for checkSide: Int) -> String {
        switch selectedDocumentType {
        case .passport:
            return "Opening front face..."
        case .selfie:
            return "Opening face..."
        default:
            return "Opening \(checkSide == 102 ? "back" : "front")..."
        }
    }

    func captureCompleteStatus(frontCaptured: Bool, backCaptured: Bool) -> String {
        if selectedDocumentType == .selfie {
            return "Selfie completed."
        }
        if frontCaptured && backCaptured {
            return "\(activeDocumentName()) front and back scan completed."
        }
        if backCaptured {
            return "\(activeDocumentName()) back scan completed."
        }
        return "\(activeDocumentName()) front completed."
    }

    func appVersionName() -> String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
    }
}

private final class GradientBackgroundView: UIView {
    private let gradientLayer = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        gradientLayer.colors = [
            UIColor(red: 0.969, green: 0.937, blue: 0.886, alpha: 1.0).cgColor,
            UIColor(red: 0.847, green: 0.910, blue: 0.937, alpha: 1.0).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        layer.addSublayer(gradientLayer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
}

private final class PreviewSurfaceView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(red: 0.925, green: 0.965, blue: 0.980, alpha: 1.0)
        layer.borderWidth = 1
        layer.borderColor = UIColor(red: 0.173, green: 0.251, blue: 0.310, alpha: 0.14).cgColor
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
