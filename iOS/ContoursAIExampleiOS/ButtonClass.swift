//
//  ButtonClass.swift
//  ContoursAIExampleiOS
//
//  Created by UrbanFT on 01/05/25.
//
import UIKit
class TabButton: UIButton {
    private let selectedFillColor = UIColor(red: 0.094, green: 0.212, blue: 0.259, alpha: 1.0)
    private let unselectedTitleColor = UIColor(red: 0.373, green: 0.467, blue: 0.510, alpha: 1.0)

    override var isSelected: Bool {
        didSet {
            applySelectionStyle()
        }
    }

    private func applySelectionStyle() {
        layer.borderColor = UIColor.clear.cgColor
        backgroundColor = isSelected ? selectedFillColor : .clear
        setTitleColor(isSelected ? .white : unselectedTitleColor, for: .normal)
    }
    
}
