//
//  ViewController.swift
//  ContoursAIExampleiOS
//
//  Created by UrbanFT on 19/12/22.
//

import UIKit
import ContoursAI_SDK


class ViewController: UIViewController,CheckCaptureDelegate{
    
    @IBOutlet var frontImageView : UIImageView!
    @IBOutlet var backImageView : UIImageView!
    @IBOutlet var frontImagebutton : UIButton!
    @IBOutlet var backImagebutton : UIButton!
    @IBOutlet weak var buttonCheckScan: TabButton!{
        didSet {
            buttonCheckScan.isSelected = true
        }
    }
    @IBOutlet weak var buttonIdScan: TabButton!{
        didSet {
            buttonIdScan.isSelected = false
        }
    }
    @IBOutlet weak var passport: TabButton!{
        didSet {
            passport.isSelected = false
        }
    }
   
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    let contoursSDK = ContoursAIFramework()
    var selectedDocumentType : ScanType = .check
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
  
    // MARK: - Intrenals function
    func openContoursSDKConcept(checkSide:Int) {
        ContoursAIFramework.shared.isLandscape = true
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
        let configModel = ContoursModel(clientId: "<YOUR CLIENT ID>",
                                        captureType: CaptureType.both.rawValue,
                                        type: selectedDocumentType.rawValue,
                                        capturingSide: DocumentSide.front.rawValue,
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
                                        capturingSide: DocumentSide.front.rawValue,
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
        }
        if rearImage != nil {
            backImageView.image = rearImageCropped
        }
    }
    
    func onContourClose() {
        ContoursAIFramework.shared.isLandscape = false
    }
    
    func eventCaptured(data: [String : Any]?) {
    }
    
    // MARK: - Actions
    
    @IBAction func documentButtonClicked(_ sender: Any) {
        let button =  sender as? UIButton
        openContoursSDKConcept(checkSide: button?.tag ?? 0)  //Function to  open Contours SDK
    }
    
    @IBAction func selectScanType(_ sender: UIButton) {
        self.frontImageView.image = nil
        self.backImageView.image = nil
        let button =  sender
        switch button.tag {
        case 101:
            selectedDocumentType = .check
            self.frontImagebutton.isHidden = false
            self.frontImageView.isHidden = false
            self.backImagebutton.isHidden = false
            self.backImageView.isHidden = false
            buttonIdScan.isSelected = false
            buttonCheckScan.isSelected =  true
            passport.isSelected =  false

        case 102:
            selectedDocumentType = .id
            buttonCheckScan.isSelected = false
            buttonIdScan.isSelected = true
            passport.isSelected =  false
            self.frontImagebutton.isHidden = false
            self.frontImageView.isHidden = false
            self.backImagebutton.isHidden = false
            self.backImageView.isHidden = false

        case 103:
            selectedDocumentType = .passport
            buttonCheckScan.isSelected = false
            buttonIdScan.isSelected = false
            passport.isSelected =  true

            self.frontImagebutton.isHidden = false
            self.frontImageView.isHidden = false
            self.backImagebutton.isHidden = true
            self.backImageView.isHidden = true
        case 104:
            buttonCheckScan.isSelected = false
            buttonIdScan.isSelected = false
            passport.isSelected =  false
            
            self.frontImagebutton.isHidden = false
            self.frontImageView.isHidden = false
            self.backImagebutton.isHidden = true
            self.backImageView.isHidden = true
            
        default:
            break
        }
    
    }
}
