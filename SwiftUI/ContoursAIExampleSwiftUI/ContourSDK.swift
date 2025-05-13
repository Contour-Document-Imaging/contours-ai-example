//
//  ContoursSDK.swift
//  swiftUITest
//
//  Created by UrbanFT on 10/03/23.
//

import Foundation
import SwiftUI
import ContoursAI_SDK

struct ContoursSDK: UIViewControllerRepresentable {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var captureSide = DocumentSide.front.rawValue
    var docType = ScanType.check.rawValue

    @Binding  var frontImage: UIImage?
    @Binding  var rearImage: UIImage?
    
    /**
     * Initializes the Contour SDK using ContoursAIFramework().startContour.
     * @param configModel         The model containing the SDK configuration.
     * @param configModel.checkCapturingSide  Specifies the side (Front/Rear) to capture.
     * @param configModel.clientId            The client ID provided by UrbanFT.
     * @param configModel. captureType         The capture mode: Auto, Manual, or Both.
     * @param configModel.delegate            The delegate to receive callbacks from the Contour SDK.
     * @param configModel.type                The type of document to capture: Check, ID, or Passport.
     */
    func makeUIViewController(context: Context) -> UIViewController {
        let configModel = ContoursModel(clientId: "<YOUR CLIENT ID>",
                                        captureType: CaptureType.both.rawValue,
                                        type: docType,
                                        capturingSide: DocumentSide.front.rawValue,
                                        delegate: ContourCallback(self))
        let contourSDKVC = ContoursAIFramework().startContour(configModel: configModel,enableMultipleCapturing: false)
        let navVC = UINavigationController(rootViewController: contourSDKVC)
        navVC.modalPresentationStyle = .fullScreen
        return navVC
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // Update the view controller if needed
    }
    class ContourCallback: NSObject,CheckCaptureDelegate {
        let parent: ContoursSDK
        init(_ parent: ContoursSDK) {
            self.parent = parent
        }
        
        //Get callback when Contour SDK is close
        func onContourClose() {
            ContoursAIFramework.shared.isLandscape = false
        }
        
        /* Get callback when check is captured.
         * Param frontImageCropped - Cropped front check Image without any border
         * Param rearImageCropped - Cropped rear check Image without any border
         * Param frontImage - Original front check image
         * Param rearImage - Original rear check image
         */
        func imageCaptured(frontImageCropped: UIImage?, rearImageCropped: UIImage?, frontImage: UIImage?, rearImage: UIImage?) {
            ContoursAIFramework.shared.isLandscape = false
            if let uiImage = frontImage {
                parent.frontImage = uiImage
            }
            if let uiImage = rearImage {
                parent.rearImage = uiImage
            }
        }
    }
}

