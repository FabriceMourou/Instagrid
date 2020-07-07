//
//  ViewController.swift
//  P4_01_XCode
//
//  Created by Fabrice Mourou on 19/06/2020.
//  Copyright © 2020 Fabrice Mourou. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var gridView: UIView!
    @IBOutlet weak var topStackView: UIStackView!
    @IBOutlet weak var botStackView: UIStackView!
    
    @IBOutlet weak var layoutButtonsStackView: UIStackView!
    
    @IBOutlet weak var arrowUp: UIButton!
    @IBOutlet weak var arrowLeft: UIButton!
    
    
    @IBAction func didSwipeToShare(_ sender: UISwipeGestureRecognizer) {
        sharePhotoLayout()
    }
    
    private let photoLayoutProvider = PhotoLayoutProvider()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPhotoLayoutButtons()
        

    }
    
    private func renderGridViewAsImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: gridView.bounds)
        return renderer.image { rendererContext in
            gridView.layer.render(in: rendererContext.cgContext)
        }
    }
    
    private func sharePhotoLayout() {
        UIView.animate(withDuration: 0.3) {
            self.gridView.transform = CGAffineTransform(translationX: 0, y: -self.view.frame.height)
        }
        
        let image = renderGridViewAsImage()

        let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        
        activityViewController.completionWithItemsHandler = { _, _, _, _ in
            UIView.animate(withDuration: 0.3) {
                self.gridView.transform = .identity
            }
        }
        
        present(activityViewController, animated: true)
    }
    
    private func setupPhotoLayoutButtons() {
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
        addMultiplePhotoButtonsToStackView(amount: photoLayout.numberOfPhotosTop, stackView: topStackView)
        addMultiplePhotoButtonsToStackView(amount: photoLayout.numberOfPhotosBot, stackView: botStackView)
    }
    
    private func addMultiplePhotoButtonsToStackView(amount: Int, stackView: UIStackView) {
        for _ in 1...amount {
            addPhotoButtonToStackView(stackView: stackView)
        }
        
    }
    
    private func addPhotoButtonToStackView(stackView: UIStackView) {
        let plusButton = UIButton()
        plusButton.backgroundColor = .white
        plusButton.imageView?.contentMode = .scaleAspectFill
        let plusImage = UIImage(named: "Plus")
        plusButton.setImage(plusImage, for: .normal)
        plusButton.addTarget(self, action: #selector(displayImagePickerController(sender:)), for: .touchUpInside)
        stackView.addArrangedSubview(plusButton)
    }
    
    var selectedButton: UIButton?
    
    
    @objc private func displayImagePickerController(sender: UIButton) {
        
        selectedButton = sender
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        present(imagePickerController, animated: true)
        
        
        print ("will display imagePickerController")
    }

}


extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.originalImage] as? UIImage else { return }
        selectedButton?.setImage(selectedImage, for: .normal)
        
        dismiss(animated: true, completion: nil)
    }
    
}




