//
//  View.swift
//  ContoursAIExampleiOS
//

import UIKit
import ContoursAI_SDK

final class View {
    struct DocumentContent {
        let type: ScanType
        let tabTag: Int
        let title: String
        let description: String
        let frontLabel: String
        let backLabel: String?
    }

    private unowned let viewController: ViewController

    private var frontImageView: UIImageView!
    private var backImageView: UIImageView!
    private var frontImageButton: UIButton!
    private var backImageButton: UIButton!
    private var buttonCheckScan: TabButton!
    private var buttonIdScan: TabButton!
    private var passportButton: TabButton!
    private var selfieButton: TabButton!

    private let platformLabel = UILabel()
    private let versionLabel = UILabel()
    private let screenTitleLabel = UILabel()
    private let screenDescriptionLabel = UILabel()
    private let frontTileTitleLabel = UILabel()
    private let backTileTitleLabel = UILabel()
    private let backPreviewTile = UIStackView()
    private let tabContainer = UIView()

    private let textStrong = UIColor(red: 0.094, green: 0.212, blue: 0.259, alpha: 1.0)
    private let textMuted = UIColor(red: 0.373, green: 0.467, blue: 0.510, alpha: 1.0)
    private let brandAccent = UIColor(red: 0.059, green: 0.463, blue: 0.431, alpha: 1.0)

    private(set) var selectedDocumentType: ScanType = .check

    init(viewController: ViewController) {
        self.viewController = viewController
    }

    private var documents: [DocumentContent] {
        [
            DocumentContent(type: .check, tabTag: 101, title: "Check Scan", description: "Capture the front or back side of the check.", frontLabel: "Front check", backLabel: "Rear check"),
            DocumentContent(type: .id, tabTag: 102, title: "ID Scan", description: "Capture the front and back side of the ID.", frontLabel: "Front ID", backLabel: "Rear ID"),
            DocumentContent(type: .passport, tabTag: 103, title: "Passport Scan", description: "Capture the passport front.", frontLabel: "Passport Front", backLabel: nil),
            DocumentContent(type: .selfie, tabTag: 104, title: "Take Selfie", description: "Capture your selfie", frontLabel: "User Selfie", backLabel: nil)
        ]
    }

    private var currentDocument: DocumentContent {
        documents.first { $0.type == selectedDocumentType } ?? documents[0]
    }

    func buildInterface() {
        let view = viewController.view!
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

        configureLabel(platformLabel, text: "Powered by Native iOS UIKit", color: textMuted, font: .systemFont(ofSize: 12, weight: .medium), lines: 1)
        configureLabel(versionLabel, text: "App Version \(appVersionName())", color: textMuted, font: .systemFont(ofSize: 12, weight: .regular), lines: 1)
        configureLabel(screenTitleLabel, text: nil, color: textStrong, font: .systemFont(ofSize: 28, weight: .bold), lines: 0)
        configureLabel(screenDescriptionLabel, text: nil, color: textMuted, font: .systemFont(ofSize: 15, weight: .regular), lines: 0)

        cardStack.addArrangedSubview(screenTitleLabel)
        cardStack.setCustomSpacing(6, after: screenTitleLabel)
        cardStack.addArrangedSubview(platformLabel)
        cardStack.setCustomSpacing(4, after: platformLabel)
        cardStack.addArrangedSubview(versionLabel)
        cardStack.setCustomSpacing(12, after: versionLabel)
        cardStack.addArrangedSubview(screenDescriptionLabel)
        cardStack.setCustomSpacing(20, after: screenDescriptionLabel)

        let previewStack = UIStackView()
        previewStack.axis = .vertical
        previewStack.spacing = 16
        cardStack.addArrangedSubview(previewStack)

        let frontTile = makePreviewTile(titleLabel: frontTileTitleLabel, imageTag: 101, buttonTag: 101)
        frontImageView = frontTile.imageView
        frontImageButton = frontTile.button
        previewStack.addArrangedSubview(frontTile.tile)

        let backTile = makePreviewTile(titleLabel: backTileTitleLabel, imageTag: 102, buttonTag: 102)
        backImageView = backTile.imageView
        backImageButton = backTile.button
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

        let swipeLeft = UISwipeGestureRecognizer(target: viewController, action: #selector(ViewController.handleSwipe(_:)))
        swipeLeft.direction = .left
        scrollView.addGestureRecognizer(swipeLeft)

        let swipeRight = UISwipeGestureRecognizer(target: viewController, action: #selector(ViewController.handleSwipe(_:)))
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
        self.passportButton = passportButton
        self.selfieButton = selfieButton

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
        button.addTarget(viewController, action: #selector(ViewController.selectScanType(_:)), for: .touchUpInside)
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
        button.addTarget(viewController, action: #selector(ViewController.documentButtonClicked(_:)), for: .touchUpInside)
        previewSurface.addSubview(button)

        NSLayoutConstraint.activate([
            previewSurface.heightAnchor.constraint(equalToConstant: 220),
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
        frontImageButton.setTitle(content.frontLabel, for: .normal)

        if let backLabel = content.backLabel {
            backTileTitleLabel.text = backLabel
            backImageButton.setTitle(backLabel, for: .normal)
            backPreviewTile.isHidden = false
        } else {
            backPreviewTile.isHidden = true
        }

        if resetImages {
            resetPreviews()
        }

        [buttonCheckScan, buttonIdScan, passportButton, selfieButton].forEach { button in
            button?.isSelected = button?.tag == content.tabTag
        }
    }

    func resetPreviews() {
        frontImageView.image = nil
        frontImageView.isHidden = true
        backImageView.image = nil
        backImageView.isHidden = true
        frontImageButton.setTitle(currentDocument.frontLabel, for: .normal)
        backImageButton.setTitle(currentDocument.backLabel, for: .normal)
    }

    func showFrontImage(_ image: UIImage?) {
        frontImageView.image = image
        frontImageView.isHidden = false
        frontImageButton.setTitle(nil, for: .normal)
    }

    func showBackImage(_ image: UIImage?) {
        backImageView.image = image
        backImageView.isHidden = false
        backImageButton.setTitle(nil, for: .normal)
    }

    func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
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
