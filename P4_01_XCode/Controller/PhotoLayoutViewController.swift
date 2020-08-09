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
    
    
    /// Gesture for sharing photo
    @IBAction func didSwipeToShare(_ sender: UISwipeGestureRecognizer) {
        sharePhotoLayout()
    }
    
    /// Launch the application
    override func viewDidLoad() {
        super.viewDidLoad()
      
        setupLayoutButtons()
        updateUIAccordingToOrientation()
        photoLayoutManager.delegate = self
    }
    
    
    /// Transition of the "Swipe" label
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
    
    private var selectedButtonIndex: Int?
    private var photoLayoutButtons: [UIButton] = []
    private let photoLayoutManager = PhotoLayoutManager()
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
    
    
    /// Transform layers into images for sharing
    private func renderGridViewAsImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: gridView.bounds)
        return renderer.image { rendererContext in
            gridView.layer.render(in: rendererContext.cgContext)
        }
    }
    
    /// Animation for sharing photo
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
    
    
    /// Display of buttons to choose the different configurations
    private func setupLayoutButtons() {
        for index in 0..<photoLayoutManager.layouts.count {
            let button = UIButton()
            
            setupLayoutButtonImage(button: button, index: index)
            setupConstraintOnLayoutButton(button: button)
            
            button.tag = index
            button.addTarget(self, action: #selector(didTapOnPhotoButton(sender:)), for: .touchUpInside)
            layoutButtonsStackView.addArrangedSubview(button)
            photoLayoutButtons.append(button)
        }
    }
    
    /// Creation of the button display, and the "Selected" image
    private func setupLayoutButtonImage(button: UIButton, index: Int) {
        let buttonImage = UIImage(named: "Layout \(index + 1)")
        button.setBackgroundImage(buttonImage, for: .normal)
        
        let buttonImageSelected = UIImage(named: "Selected")
        let buttonImageSelectedWithAlpha = buttonImageSelected?.alpha(0.6)
        button.setImage(buttonImageSelectedWithAlpha, for: .selected)
        
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
    }
    
    /// Constraint for Layout buttons
    private func setupConstraintOnLayoutButton(button: UIButton) {
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalTo: button.widthAnchor).isActive = true
    }
    
    /// Layout button management
    @objc private func didTapOnPhotoButton(sender: UIButton) {
        photoLayoutManager.selectLayoutWithIndex(sender.tag)
    }
    
    /// Creation of layers
    private func setupLayout() {
        selectPhotoLayoutButton()
        cleanLayout()
        setupStackViewsFromLayout()
        updatePhotoButtons()
    }
    /// Select the plus button
    private func selectPhotoLayoutButton() {
        for (index, button) in photoLayoutButtons.enumerated()  {
            button.isSelected = index == photoLayoutManager.selectedLayoutIndex
        }
    }
    
    
    /// Reset topStackView and botStackView
    private func cleanLayout() {
        photoButtons.removeAll()
        cleanStackView(stackView: topStackView)
        cleanStackView(stackView: botStackView)
    }
    
    
    /// Main Stack View reset
    private func cleanStackView(stackView: UIStackView) {
        for view in stackView.subviews {
            view.removeFromSuperview()
        }
    }
    
    
    /// Determines the combination of topStackView and botStackView
    private func setupStackViewsFromLayout() {
        guard let photoLayout = photoLayoutManager.selectedLayout else { return }
        addMultiplePhotoButtonsToStackView(amount: photoLayout.numberOfPhotosTop, stackView: topStackView)
        addMultiplePhotoButtonsToStackView(amount: photoLayout.numberOfPhotosBot, stackView: botStackView)
    }
    
    
    /// Add a button to each Stack View
    private func addMultiplePhotoButtonsToStackView(amount: Int, stackView: UIStackView) {
        for _ in 1...amount {
            addPhotoButtonToStackView(stackView: stackView)
        }
        
    }
    
    
    /// Creation of PhotoButton Plus
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
    
    
    /// Opening the photo gallery
    @objc private func displayImagePickerController(sender: UIButton) {
        
        selectedButtonIndex = photoButtons.firstIndex(of: sender)
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        present(imagePickerController, animated: true)
        
    }
    
    /// Management of "Swipe" labels - Portrait or Landscape
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
    
    /// display of the grid according to the chosen LayoutButton
    private func updatePhotoButtons() {
        
        for (index, photoButton) in photoButtons.enumerated() {
            let photoData = photoLayoutManager.photos[index] ?? Data()
            let photo = UIImage(data: photoData) ?? UIImage(named: "Plus")
            photoButton.setImage(photo, for: .normal)
        }
    }

}


extension PhotoLayoutViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    /// Transformation of gallery image to UIImage
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard
            let selectedImage = info[.originalImage] as? UIImage,
            let selectedImageData = selectedImage.jpegData(compressionQuality: 1),
            let selectedButtonIndex = selectedButtonIndex
            else {
                dismiss(animated: true, completion: nil)
                return
        }
       

        photoLayoutManager.insertPhotoDataAtIndex(selectedButtonIndex, data: selectedImageData)
        
        dismiss(animated: true, completion: nil)
    }
    
}

extension PhotoLayoutViewController: PhotoLayoutManagerDelegate{
    
    /// Grid display
    func didChangePhotoLayout() {
        setupLayout()
    }
    
    /// Managing the display of photos
    func didChangePhotos() {
        updatePhotoButtons()
    }
    
    
}




