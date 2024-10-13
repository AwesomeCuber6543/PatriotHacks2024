//
//  CustomButton.swift
//  HackFax-AAAAT
//
//  Created by yahia salman on 2/16/24.
//

import UIKit

class CustomButton: UIButton {
    
    

    
    enum FontSize {
        case big
        case med
        case small
    }
    
    init(title: String, hasBackground: Bool = false, fontsize:FontSize, buttonColor: UIColor, titleColor: UIColor = .label, cornerRadius: CGFloat = 10){
        super.init(frame: .zero)
        self.setTitle(title, for: .normal)
        self.layer.cornerRadius = cornerRadius
        self.layer.masksToBounds = true
        
        self.backgroundColor = hasBackground ? buttonColor : .clear
        
        let titleColor: UIColor = hasBackground ? titleColor : titleColor
        self.setTitleColor(titleColor, for: .normal)
        
        switch fontsize {
        case .big:
            self.titleLabel?.font = .systemFont(ofSize: 22, weight: .bold)
        case .med:
            self.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        case .small:
            self.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
