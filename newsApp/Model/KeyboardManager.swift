//
//  KeyboardManager.swift
//  newsApp
//
//  Created by Abhijatya Gupta on 20/01/21.
//

import UIKit

class KeyboardManager {
    var keyboardHeight: CGFloat = 0
    var adjustmentViewHeight: CGFloat = 0
    var needsAdjustment: Bool = false
    var factor: CGFloat = 0
    
    init(){}
    
    init(_ adjustmentViewHeight: CGFloat) {
        self.adjustmentViewHeight = adjustmentViewHeight
    }
    
    @objc func calculateKeyboardHeight(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            keyboardHeight = keyboardFrame.cgRectValue.height
            if adjustmentViewHeight < keyboardHeight + 40 {
                needsAdjustment = true
                factor = keyboardHeight + 40 - adjustmentViewHeight
            }
        }
    }
}
