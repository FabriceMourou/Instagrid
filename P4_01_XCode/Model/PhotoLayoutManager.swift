//
//  PhotoLayoutProvider.swift
//  P4_01_XCode
//
//  Created by Fabrice Mourou on 30/06/2020.
//  Copyright © 2020 Fabrice Mourou. All rights reserved.
//

import Foundation


protocol PhotoLayoutManagerDelegate: class {
    func didChangePhotos()
    func didChangePhotoLayout()
}


class PhotoLayoutManager {
    
    // MARK: - Internal
    
    
    // MARK: Properties - Internal
    
    let layouts = [
        PhotoLayout(numberOfPhotosTop: 1, numberOfPhotosBot: 2),
        PhotoLayout(numberOfPhotosTop: 2, numberOfPhotosBot: 1),
        PhotoLayout(numberOfPhotosTop: 2, numberOfPhotosBot: 2)
    ]
    
    var selectedLayoutIndex: Int = 0 {
        didSet {
            delegate?.didChangePhotoLayout()
        }
    }
    
    var selectedLayout: PhotoLayout? {
        guard selectedLayoutIndex >= 0 && selectedLayoutIndex < layouts.count else { return nil }
        return layouts[selectedLayoutIndex]
    }
    
    var photos: [Data?] = [nil, nil, nil, nil] {
        didSet {
            delegate?.didChangePhotos()
        }
    }
    
    weak var delegate: PhotoLayoutManagerDelegate?
    
    
    var canBeReset: Bool {
        var numberOfPhotosInPhotos = 0
        
        for photo in photos where photo != nil {
            numberOfPhotosInPhotos += 1
        }
        
        return numberOfPhotosInPhotos > 0
    }
    
    // MARK: Methods - Internal
    
    /// RAZ de la grille
    func resetLayout() {
        for index in 0..<photos.count {
            photos[index] = nil
        }
    }
    
    /// Select the layout coressponding to the index
    func selectLayoutWithIndex(_ index: Int) {
        selectedLayoutIndex = index
    }
    
    func insertPhotoDataAtIndex(_ index: Int, data: Data) {
        photos[index] = data
    }
    
}
