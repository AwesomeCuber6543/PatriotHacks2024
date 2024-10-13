//
//  ProfileViewController.swift
//  DriveSafe
//
//  Created by yahia salman on 10/13/24.
//

import UIKit

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // Labels for each section
    let licenseFrontLabel: UILabel = {
        let label = UILabel()
        label.text = "Driver's License (Front)"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let licenseBackLabel: UILabel = {
        let label = UILabel()
        label.text = "Driver's License (Back)"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let insuranceLabel: UILabel = {
        let label = UILabel()
        label.text = "Insurance"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let registrationLabel: UILabel = {
        let label = UILabel()
        label.text = "Registration"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // ImageViews for each document
    let licenseFrontImageView = ProfileViewController.createImageView()
    let licenseBackImageView = ProfileViewController.createImageView()
    let insuranceImageView = ProfileViewController.createImageView()
    let registrationImageView = ProfileViewController.createImageView()

    // Selected image type identifier
    var selectedImageType: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Profile"
        self.view.backgroundColor = .white

        // Add the labels and image views to the view
        view.addSubview(licenseFrontLabel)
        view.addSubview(licenseBackLabel)
        view.addSubview(insuranceLabel)
        view.addSubview(registrationLabel)

        view.addSubview(licenseFrontImageView)
        view.addSubview(licenseBackImageView)
        view.addSubview(insuranceImageView)
        view.addSubview(registrationImageView)

        // Add tap gestures to the image views
        addTapGestures()

        // Setup layout constraints
        setupLayout()
    }

    // Static function to create a reusable image view for documents
    static func createImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "placeholder") // Placeholder image
        return imageView
    }

    // Add tap gestures to image views to trigger photo selection
    func addTapGestures() {
        let tapFrontLicense = UITapGestureRecognizer(target: self, action: #selector(selectFrontLicense))
        licenseFrontImageView.addGestureRecognizer(tapFrontLicense)
        licenseFrontImageView.isUserInteractionEnabled = true

        let tapBackLicense = UITapGestureRecognizer(target: self, action: #selector(selectBackLicense))
        licenseBackImageView.addGestureRecognizer(tapBackLicense)
        licenseBackImageView.isUserInteractionEnabled = true

        let tapInsurance = UITapGestureRecognizer(target: self, action: #selector(selectInsurance))
        insuranceImageView.addGestureRecognizer(tapInsurance)
        insuranceImageView.isUserInteractionEnabled = true

        let tapRegistration = UITapGestureRecognizer(target: self, action: #selector(selectRegistration))
        registrationImageView.addGestureRecognizer(tapRegistration)
        registrationImageView.isUserInteractionEnabled = true
    }

    // Methods to select images for different sections
    @objc func selectFrontLicense() {
        selectedImageType = "FrontLicense"
        presentImagePicker()
    }

    @objc func selectBackLicense() {
        selectedImageType = "BackLicense"
        presentImagePicker()
    }

    @objc func selectInsurance() {
        selectedImageType = "Insurance"
        presentImagePicker()
    }

    @objc func selectRegistration() {
        selectedImageType = "Registration"
        presentImagePicker()
    }

    // Function to present the image picker
    func presentImagePicker() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }

    // UIImagePickerController Delegate method
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            switch selectedImageType {
            case "FrontLicense":
                licenseFrontImageView.image = selectedImage
            case "BackLicense":
                licenseBackImageView.image = selectedImage
            case "Insurance":
                insuranceImageView.image = selectedImage
            case "Registration":
                registrationImageView.image = selectedImage
            default:
                break
            }
        }
        dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    // Setup the layout constraints
    func setupLayout() {
        let padding: CGFloat = 20
        let imageHeight: CGFloat = 120

        NSLayoutConstraint.activate([
            // License Front Label & ImageView
            licenseFrontLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: padding),
            licenseFrontLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            licenseFrontImageView.topAnchor.constraint(equalTo: licenseFrontLabel.bottomAnchor, constant: 10),
            licenseFrontImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            licenseFrontImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            licenseFrontImageView.heightAnchor.constraint(equalToConstant: imageHeight),

            // License Back Label & ImageView
            licenseBackLabel.topAnchor.constraint(equalTo: licenseFrontImageView.bottomAnchor, constant: padding),
            licenseBackLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            licenseBackImageView.topAnchor.constraint(equalTo: licenseBackLabel.bottomAnchor, constant: 10),
            licenseBackImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            licenseBackImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            licenseBackImageView.heightAnchor.constraint(equalToConstant: imageHeight),

            // Insurance Label & ImageView
            insuranceLabel.topAnchor.constraint(equalTo: licenseBackImageView.bottomAnchor, constant: padding),
            insuranceLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            insuranceImageView.topAnchor.constraint(equalTo: insuranceLabel.bottomAnchor, constant: 10),
            insuranceImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            insuranceImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            insuranceImageView.heightAnchor.constraint(equalToConstant: imageHeight),

            // Registration Label & ImageView
            registrationLabel.topAnchor.constraint(equalTo: insuranceImageView.bottomAnchor, constant: padding),
            registrationLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            registrationImageView.topAnchor.constraint(equalTo: registrationLabel.bottomAnchor, constant: 10),
            registrationImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            registrationImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            registrationImageView.heightAnchor.constraint(equalToConstant: imageHeight)
        ])
    }
}
