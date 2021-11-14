//
//  UINavigationController+ACExtensions.swift
//
//  Created by Alejandro Cotilla on 2/21/19.
//  Copyright © 2019 Carolco LLC. All rights reserved.
//

import UIKit

extension UINavigationController {
    
    #if os(iOS)
    /// Make UINavigationController update the status bar style based on their top level controller.
    /// Based on: https://medium.com/swiftindia/status-bar-throwing-tantrums-in-ios-9-ed567e3a8f3b
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return topViewController?.preferredStatusBarStyle ?? .default
    }
    #endif
}
