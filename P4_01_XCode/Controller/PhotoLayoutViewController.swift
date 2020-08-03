//
//  ViewController.swift
//  P4_01_XCode
//
//  Created by Fabrice Mourou on 19/06/2020.
//  Copyright © 2020 Fabrice Mourou. All rights reserved.
//

import UIKit








class PhotoLayoutViewController: UIViewController {
    
    // MARK: - Internal
    
    
    
    
    
    
    // MARK: Methods - Internal
    
    
    /// Gesture pour le partage de la photo
    @IBAction func didSwipeToShare(_ sender: UISwipeGestureRecognizer) {
        sharePhotoLayout()
    }
    
    @IBAction func didTapOnResetButton() {
        photoLayoutProvider.resetLayout()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayoutButtons()
        updateUIAccordingToOrientation()
        photoLayoutProvider.delegate = self
        
        photoLayoutProvider.selectedLayoutIndex = 1
        changeResetButtonVisibilityState()
    }
    
    
    // Gestion de la transition du label "Swipe"
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
    @IBOutlet private weak var resetButton: UIButton!
    
    private var selectedButtonIndex: Int?
    private var photoLayoutButtons: [UIButton] = []
    private let photoLayoutProvider = PhotoLayoutManager()
    private var photoButtons: [UIButton] = []
    
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
            button.addTarget(self, action: #selector(didTapOnLayoutButton(sender:)), for: .touchUpInside)
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
    
    /// Contrainte pour les boutons
    private func setupConstraintOnLayoutButton(button: UIButton) {
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.widthAnchor.constraint(equalToConstant: 30).isActive = true
        button.heightAnchor.constraint(equalTo: button.widthAnchor).isActive = true
    }
    
    @objc private func didTapOnLayoutButton(sender: UIButton) {
        photoLayoutProvider.selectedLayoutIndex = sender.tag
    }
    
    /// Création des calques
    private func setupLayout() {
        selectPhotoLayoutButton()
        cleanLayout()
        setupStackViewsFromLayout()
        updatePhotoButtonsWithModel()
    }
    /// Sélection du bouton  plus
    private func selectPhotoLayoutButton() {
        for (index, button) in photoLayoutButtons.enumerated()  {
            button.isSelected = index == photoLayoutProvider.selectedLayoutIndex
        }
    }
    
    
    /// RAZ de topStackView et de botStackView
    private func cleanLayout() {
        photoButtons.removeAll()
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
    private func setupStackViewsFromLayout() {
        let photoLayout = photoLayoutProvider.selectedLayout
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
        photoButtons.append(plusButton)
    }
    
    
    /// Ouverture de la galerie photo
    @objc private func displayImagePickerController(sender: UIButton) {
        
        selectedButtonIndex = photoButtons.firstIndex(of: sender)
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        present(imagePickerController, animated: true)
        
    }
    
    /// Gestion des labels "Swipe" - Portrait ou Paysage
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
    
    
    private func updatePhotoButtonsWithModel() {
        
        for (index, photoButton) in photoButtons.enumerated() {
            let photo = UIImage(data: photoLayoutProvider.photos[index] ?? Data()) ?? UIImage(named: "Plus")
            photoButton.setImage(photo, for: .normal)
        }
    }
    
    
    private func changeResetButtonVisibilityState() {
        resetButton.isHidden = !photoLayoutProvider.canBeReset
    }
}


extension PhotoLayoutViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    /// Transformation de l'image de la galerie en UIImage
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard
            let selectedImage = info[.originalImage] as? UIImage,
            let selectedButtonIndex = selectedButtonIndex
            else { return }
        //        selectedButton?.setImage(selectedImage, for: .normal)
        photoLayoutProvider.photos[selectedButtonIndex] = selectedImage.jpegData(compressionQuality: 1)
        
        
        dismiss(animated: true, completion: nil)
    }
    
}

extension PhotoLayoutViewController: PhotoLayoutManagerDelegate{
    func didChangePhotoLayout() {
        setupLayout()
    }
    
    func didChangePhotos() {
        print(#function)
        
        updatePhotoButtonsWithModel()
        
        changeResetButtonVisibilityState()
        
    }
    
    
}




