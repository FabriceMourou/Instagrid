//
//  PhotoLayout.swift
//  P4_01_XCode
//
//  Created by Fabrice Mourou on 30/06/2020.
//  Copyright © 2020 Fabrice Mourou. All rights reserved.
//

import UIKit


struct PhotoLayout {
    
    // MARK: - Internal
    
    // MARK: Properties - Internal
    
    let numberOfPhotosTop: Int
    let numberOfPhotosBot: Int
    
    
    var totalNumberOfPhotos: Int {
        numberOfPhotosTop + numberOfPhotosBot
    }
}
