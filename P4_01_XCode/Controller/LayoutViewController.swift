//
//  ViewController.swift
//  P4_01_XCode
//
//  Created by Fabrice Mourou on 19/06/2020.
//  Copyright © 2020 Fabrice Mourou. All rights reserved.
//

import UIKit

class LayoutViewController: UIViewController {
    
    // MARK: - Internal
    
    // MARK: Properties - Internal
    
    
    
    
    // MARK: Methods - Internal
    
    @IBAction func didSwipeToShare(_ sender: UISwipeGestureRecognizer) {
        sharePhotoLayout()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayoutButtons()


        updateUIAccordingToOrientation()
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        coordinator.animate(alongsideTransition: updateUIAccordingToOrientation)
    }
    
    
    
    
    
    // MARK: - Private
    
    // MARK: Properties - Private
    
    
    @IBOutlet private weak var swipeToShareRecognizer: UISwipeGestureRecognizer!
    @IBOutlet private weak var shareArrowImageView: UIImageView!
    @IBOutlet private weak var shareLabel: UILabel!
    @IBOutlet private weak var gridView: UIView!
    @IBOutlet private weak var topStackView: UIStackView!
    @IBOutlet private weak var botStackView: UIStackView!
    
    @IBOutlet private weak var layoutButtonsStackView: UIStackView!
    
    private var selectedButton: UIButton?
    
    private var photoLayoutButtons: [UIButton] = []
    
    private let photoLayoutProvider = PhotoLayoutProvider()
    
    private var windowInterfaceOrientation: UIInterfaceOrientation? {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.windows.first?.windowScene?.interfaceOrientation
        } else {
            return UIApplication.shared.statusBarOrientation
        }
    }
    
    private var shareXTranslationValue: CGFloat = 0
    private var shareYTranslationValue: CGFloat = 0
    
    
    // MARK: Methods - Private
    
    
    /// Transformation des calques en image pour effectuer le partage
    private func renderGridViewAsImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: gridView.bounds)
        return renderer.image { rendererContext in
            gridView.layer.render(in: rendererContext.cgContext)
        }
    }
    
    /// Animation pour le partage de la photo
    private func sharePhotoLayout() {
        UIView.animate(withDuration: 0.3) {
            self.gridView.transform = CGAffineTransform(
                translationX: self.shareXTranslationValue,
                y: self.shareYTranslationValue
            )
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
    
    
    /// Affichage des boutons  pour choisir les differentes configurations
    private func setupLayoutButtons() {
        for index in 0..<photoLayoutProvider.layouts.count {
            let button = UIButton()
            
            setupLayoutButtonImage(button: button, index: index)
            setupConstraintOnLayoutButton(button: button)
            
            button.tag = index
            button.addTarget(self, action: #selector(setupLayout(sender:)), for: .touchUpInside)
            layoutButtonsStackView.addArrangedSubview(button)
            photoLayoutButtons.append(button)
        }
    }
    /// Création de l'affichage des boutons, et de  l'image "Selected"
    private func setupLayoutButtonImage(button: UIButton, index: Int) {
        let buttonImage = UIImage(named: "Layout \(index + 1)")
        button.setBackgroundImage(buttonImage, for: .normal)
        
        let buttonImageSelected = UIImage(named: "Selected")
        let buttonImageSelectedWithAlpha = buttonImageSelected?.alpha(0.6)
        button.setImage(buttonImageSelectedWithAlpha, for: .selected)
        
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
    }
    /// Contraine pour les boutons
    private func setupConstraintOnLayoutButton(button: UIButton) {
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.widthAnchor.constraint(equalToConstant: 50).isActive = true
        button.heightAnchor.constraint(equalTo: button.widthAnchor).isActive = true
    }
    
    
    /// Création des calques
    @objc private func setupLayout(sender: UIButton) {
        selectPhotoLayoutButton(buttonIndexToSelect: sender.tag)
        cleanLayout()
        let layout = photoLayoutProvider.layouts[sender.tag]
        setupStackViewsFromLayout(photoLayout: layout)
    }
    ///
    private func selectPhotoLayoutButton(buttonIndexToSelect: Int) {
        for (index, button) in photoLayoutButtons.enumerated()  {
            button.isSelected = index == buttonIndexToSelect
        }
    }
    
    
    /// RAZ de topStackView et de botStackView
    private func cleanLayout() {
        cleanStackView(stackView: topStackView)
        cleanStackView(stackView: botStackView)
    }
    
    
    /// RAZ de Main Stack View
    private func cleanStackView(stackView: UIStackView) {
        for view in stackView.subviews {
            view.removeFromSuperview()
        }
    }
    
    
    /// Détermine la combinaison de topStackView et de botStackView demandé
    private func setupStackViewsFromLayout(photoLayout: PhotoLayout) {
        addMultiplePhotoButtonsToStackView(amount: photoLayout.numberOfPhotosTop, stackView: topStackView)
        addMultiplePhotoButtonsToStackView(amount: photoLayout.numberOfPhotosBot, stackView: botStackView)
    }
    
    
    /// AJoute un bouton à chaque Stack View
    private func addMultiplePhotoButtonsToStackView(amount: Int, stackView: UIStackView) {
        for _ in 1...amount {
            addPhotoButtonToStackView(stackView: stackView)
        }
        
    }
    
    
    /// Création du PhotoButton Plus
    private func addPhotoButtonToStackView(stackView: UIStackView) {
        let plusButton = UIButton()
        plusButton.backgroundColor = .white
        plusButton.imageView?.contentMode = .scaleAspectFill
        let plusImage = UIImage(named: "Plus")
        plusButton.setImage(plusImage, for: .normal)
        plusButton.addTarget(self, action: #selector(displayImagePickerController(sender:)), for: .touchUpInside)
        stackView.addArrangedSubview(plusButton)
    }
    
    
    /// Ouverture de la galerie photo
    @objc private func displayImagePickerController(sender: UIButton) {
        
        selectedButton = sender
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        present(imagePickerController, animated: true)
        
    }
    
    
    private func updateUIAccordingToOrientation(context: UIViewControllerTransitionCoordinatorContext? = nil) {
        guard let windowInterfaceOrientation = self.windowInterfaceOrientation else { return }
        
        if windowInterfaceOrientation.isLandscape {
            shareLabel.text = "Swipe left to share"
            shareArrowImageView.transform = CGAffineTransform(rotationAngle: -(.pi / 2))
            swipeToShareRecognizer.direction = .left
            shareXTranslationValue = -self.view.frame.width
            shareYTranslationValue = 0
        } else {
            shareLabel.text = "Swipe up to share"
            shareArrowImageView.transform = .identity
            swipeToShareRecognizer.direction = .up
            shareXTranslationValue = 0
            shareYTranslationValue = -self.view.frame.height
        }
    }
    
}


extension LayoutViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    /// Transformation de l'image de la galerie en UIImage
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.originalImage] as? UIImage else { return }
        selectedButton?.setImage(selectedImage, for: .normal)
        
        dismiss(animated: true, completion: nil)
    }
    
}




