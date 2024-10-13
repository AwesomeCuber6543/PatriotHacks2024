//
//  IdentificationViewController.swift
//  DriveSafe
//
//  Created by yahia salman on 10/13/24.
//

import UIKit
import AVFoundation

class IdentificationViewController: UIViewController {
    
    var name: String
    var captureSession: AVCaptureSession!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    
    // Take Picture button
    let takePictureButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Take Picture", for: .normal)
        button.backgroundColor = .blue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // Initialize with name
    init(name: String) {
        self.name = name
        super.init(nibName: nil, bundle: nil)
    }
    
    // Required init for the view controller
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        setupCamera()
        
        // Add Take Picture Button to the view
        view.addSubview(takePictureButton)
        setupLayout()
        
        // Add action to the button
        takePictureButton.addTarget(self, action: #selector(takePicture), for: .touchUpInside)
    }
    
    // Set up the camera preview
    func setupCamera() {
        captureSession = AVCaptureSession()
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            return
        }
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.frame = view.layer.bounds
        videoPreviewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(videoPreviewLayer)
        
        captureSession.startRunning()
    }
    
    // Set up layout for the button
    func setupLayout() {
        NSLayoutConstraint.activate([
            takePictureButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            takePictureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            takePictureButton.widthAnchor.constraint(equalToConstant: 150),
            takePictureButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    // Handle picture taking and API call
    @objc func takePicture() {
        // Stop running the camera capture session
//        captureSession.stopRunning()
        
        // Call the API to check the person
        callCheckPersonAPI()
    }
    
    // Function to call the API
    func callCheckPersonAPI() {
        let url = URL(string: "http://127.0.0.1:5000/check_face")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonBody = ["name_checked": name]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: jsonBody, options: [])
            request.httpBody = jsonData
            
            let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error in API request: \(error.localizedDescription)")
                    return
                }
                
                if let data = data {
                    do {
                        if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                           let passed = jsonResponse["Passed"] as? Bool,
                           let message = jsonResponse["message"] as? String {
                            // Handle the response in the main thread
                            DispatchQueue.main.async {
                                if passed {
//                                    self.showPopup(title: "Success", message: "Identification successful: \(message)")
                                    let vc = TestViewController(name: self.name)
                            //        vc.delegate = self
                                    let navigationController = UINavigationController(rootViewController: vc)
                                    navigationController.modalPresentationStyle = .fullScreen
                                    self.navigationController?.pushViewController(vc, animated: true)
                                } else {
                                    self.showPopup(title: "Failed", message: "Identification failed: \(message)")
                                }
                            }
                        }
                    } catch {
                        print("Error parsing JSON: \(error.localizedDescription)")
                    }
                }
            }
            task.resume()
            
        } catch {
            print("Error serializing JSON: \(error.localizedDescription)")
        }
    }
    
    // Function to show a popup based on the result
    func showPopup(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        
        // Present the alert controller
        self.present(alertController, animated: true, completion: nil)
    }
}

