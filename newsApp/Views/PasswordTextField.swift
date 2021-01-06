//
//  PasswordTextField.swift
//  newsApp
//
//  Created by Abhijatya Gupta on 06/01/21.
//

import UIKit

class PasswordTextField: UITextField {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addShowPasswordButton()
        isSecureTextEntry = true
        font = UIFont.systemFont(ofSize: 16)
        placeholder = K.UIText.passwordPlaceholder
        textAlignment = .left
        backgroundColor = #colorLiteral(red: 0.2558659911, green: 0.2558728456, blue: 0.2558691502, alpha: 0.2911837748)
        keyboardAppearance = .dark
    }
    
    
    
    private func addShowPasswordButton() {
        let button = UIButton(frame: CGRect(x: 20, y: 0, width: ((frame.height) * 0.70), height: ((frame.height) * 0.70)))
        button.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        button.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(scale: .large), forImageIn: .normal)
        button.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        button.addTarget(self, action: #selector(showPassword), for: .touchUpInside)
        let customRightView = UIView(frame: CGRect(x: 0, y: 0, width: button.frame.width + 35, height: button.frame.height))
        customRightView.backgroundColor = .clear
        customRightView.addSubview(button)
        rightViewMode = .always
        rightView = customRightView
    }
    
    @objc private func showPassword() {
        if let customRightView = rightView, let button = customRightView.subviews[0] as? UIButton {
            let white = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            isSecureTextEntry = !(button.tintColor == white)
            button.setImage(UIImage(systemName: button.tintColor == white ? "eye" : "eye.slash"), for: .normal)
            button.tintColor = button.tintColor == white ? #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1) : white
        }
    }
    
    
}
