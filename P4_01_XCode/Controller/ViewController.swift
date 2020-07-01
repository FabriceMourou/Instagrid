//
//  ViewController.swift
//  P4_01_XCode
//
//  Created by Fabrice Mourou on 19/06/2020.
//  Copyright © 2020 Fabrice Mourou. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var topStackView: UIStackView!
    @IBOutlet weak var botStackView: UIStackView!
    
    @IBOutlet weak var layoutButtonsStackView: UIStackView!
    
    @IBOutlet weak var arrowUp: UIButton!
    @IBOutlet weak var arrowLeft: UIButton!
    
    
  
    
    private let photoLayoutProvider = PhotoLayoutProvider()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for (index, _) in photoLayoutProvider.layouts.enumerated() {
            let button = UIButton()
            let buttonImage = UIImage(named: "Layout \(index + 1)")
            button.setImage(buttonImage, for: .normal)
            button.tag = index
            button.addTarget(self, action: #selector(setupLayout(sender:)), for: .touchUpInside)
            layoutButtonsStackView.addArrangedSubview(button)
        }
    
    }
    
    @objc private func setupLayout(sender: UIButton) {
        cleanLayout()
        let layout = photoLayoutProvider.layouts[sender.tag]
        setupStackViewsFromLayout(photoLayout: layout)
    }
    
    private func cleanLayout() {
        cleanStackView(stackView: topStackView)
        cleanStackView(stackView: botStackView)
    }
    
    private func cleanStackView(stackView: UIStackView) {
        for view in stackView.subviews {
            view.removeFromSuperview()
        }
    }
    
    
    private func setupStackViewsFromLayout(photoLayout: PhotoLayout) {
        addMultipleWhiteViewToStackView(amount: photoLayout.numberOfPhotosTop, stackView: topStackView)
        addMultipleWhiteViewToStackView(amount: photoLayout.numberOfPhotosBot, stackView: botStackView)
    }
    
    private func addMultipleWhiteViewToStackView(amount: Int, stackView: UIStackView) {
        for _ in 1...amount {
            addWhiteViewToStackView(stackView: stackView)
        }
    }
    
    private func addWhiteViewToStackView(stackView: UIStackView) {
        let whiteView = UIView()
        whiteView.backgroundColor = .white
        stackView.addArrangedSubview(whiteView)
    }

    
    
}




