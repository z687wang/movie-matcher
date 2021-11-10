//
//  Int+ACExtensions.swift
//
//  Created by Alejandro Cotilla on 3/2/19.
//  Copyright © 2019 Carolco LLC. All rights reserved.
//

import Foundation

extension Int {
    func isNearlyEqual(to number: Int, tolerance: Int = 1) -> Bool {
        return abs(self - number) < tolerance
    }
}
