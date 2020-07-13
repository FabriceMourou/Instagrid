//
//  UIImage+Alpha.swift
//  P4_01_XCode
//
//  Created by Fabrice Mourou on 12/07/2020.
//  Copyright © 2020 Fabrice Mourou. All rights reserved.
//

import UIKit

extension UIImage {

    func alpha(_ value: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(at: CGPoint.zero, blendMode: .normal, alpha: value)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}
