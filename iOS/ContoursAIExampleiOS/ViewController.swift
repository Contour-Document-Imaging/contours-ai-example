//
//  ViewController.swift
//  ContoursAIExampleiOS
//
//  Created by UrbanFT on 19/12/22.
//

import UIKit
import ContoursAI_SDK

class ViewController: UIViewController, CheckCaptureDelegate {
    let contoursSDK = ContoursAIFramework()
    private lazy var uiController = View(viewController: self)

    override func viewDidLoad() {
        super.viewDidLoad()
        uiController.buildInterface()
        uiController.applyDocumentUI(for: .check, resetImages: false)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }

    func openContoursSDKConcept(checkSide: Int) {
        ContoursAIFramework.shared.isLandscape = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.view.layoutSubviews()
            switch checkSide {
            case 101:
                self.openFrontOfCheck()
            case 102:
                self.openRearOfCheck()
            default:
                break
            }
        }
    }

    func openFrontOfCheck() {
        let configModel = ContoursModel(
            clientId: "<YOUR CLIENT ID>",
            captureType: CaptureType.both.rawValue,
            type: uiController.selectedDocumentType.rawValue,
            capturingSide: DocumentSide.front.rawValue,
            delegate: self
        )
        let imageVC = contoursSDK.startContour(configModel: configModel, enableMultipleCapturing: false)
        let navigationController = UINavigationController(rootViewController: imageVC)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: false)
    }

    func openRearOfCheck() {
        let configModel = ContoursModel(
            clientId: "<YOUR CLIENT ID>",
            captureType: CaptureType.both.rawValue,
            type: uiController.selectedDocumentType.rawValue,
            capturingSide: DocumentSide.back.rawValue,
            delegate: self
        )
        let imageVC = contoursSDK.startContour(configModel: configModel)
        let navigationController = UINavigationController(rootViewController: imageVC)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: false)
    }

    func imageCaptured(frontImageCropped: UIImage?, rearImageCropped: UIImage?, frontImage: UIImage?, rearImage: UIImage?) {
        ContoursAIFramework.shared.isLandscape = false
        if frontImage != nil {
            uiController.showFrontImage(frontImageCropped)
        }
        if rearImage != nil {
            uiController.showBackImage(rearImageCropped)
        }
    }

    func onContourClose() {
        ContoursAIFramework.shared.isLandscape = false
    }

    func eventCaptured(data: [String: Any]?) {
    }

    func selfieCaptured(image: UIImage?) {
        if image != nil {
            uiController.showFrontImage(image)
        }
    }

    @objc func documentButtonClicked(_ sender: UIButton) {
        openContoursSDKConcept(checkSide: sender.tag)
    }

    @objc func selectScanType(_ sender: UIButton) {
        switch sender.tag {
        case 102:
            uiController.applyDocumentUI(for: .id)
        case 103:
            uiController.applyDocumentUI(for: .passport)
        case 104:
            uiController.applyDocumentUI(for: .selfie)
        default:
            uiController.applyDocumentUI(for: .check)
        }
    }

    @objc func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        uiController.handleSwipe(gesture)
    }
}
