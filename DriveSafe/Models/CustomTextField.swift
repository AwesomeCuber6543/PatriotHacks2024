//
//  CustomTextField.swift
//  HackFax-AAAAT
//
//  Created by yahia salman on 2/16/24.
//

import UIKit

class CustomTextField: UITextField {

    enum CustomTextFieldType {
        case username
        case email
        case password
        case friends
    }
    
    private let authFieldType: CustomTextFieldType
    
    init(fieldType: CustomTextFieldType, borderWidth: CGFloat = 0) {
        self.authFieldType = fieldType
        super.init(frame: .zero)
        
        self.backgroundColor = UIColor(cgColor: CGColor(red: 128/255, green: 128/255, blue: 128/255, alpha: 0.2))
        //self.layer.cornerRadius = 10
        self.layer.borderWidth = borderWidth
        //self.layer.borderColor = CGColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1)
        self.layer.borderColor = CGColor(red: 255/255, green: 65/255, blue: 54/255, alpha: 1)
        self.layer.cornerRadius = 10
        
        self.returnKeyType = .done
        self.autocorrectionType = .no
        self.autocapitalizationType = .none
        
        self.leftViewMode = .always
        self.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: self.frame.size.height))
        
        switch fieldType {
        case .username:
            //self.placeholder = "Username"
            self.attributedPlaceholder = NSAttributedString(
                string: "Username",
                attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
                )
        case .email:
            //self.placeholder = "Email Address"
            self.keyboardType = .emailAddress
            self.textContentType = .emailAddress
            self.attributedPlaceholder = NSAttributedString(
                string: "Email Address",
                attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
            )
            
        case .password:
            //self.placeholder = "Password"
            self.textContentType = .oneTimeCode
            self.isSecureTextEntry = true
                self.attributedPlaceholder = NSAttributedString(
                    string: "Password",
                    attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
                    )
        case .friends:
            self.attributedPlaceholder = NSAttributedString(
            string: "Add Friends",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
            )
        }
        
        
    }
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
