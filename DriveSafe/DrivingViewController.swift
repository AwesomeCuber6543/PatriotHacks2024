//
//  DrivingViewController.swift
//  DriveSafe
//
//  Created by yahia salman on 10/13/24.
//

import UIKit
import AVFoundation

class DrivingViewController: UIViewController {

    var name: String  // Passed from the previous view controller

    var captureSession: AVCaptureSession!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!

    // Button to start driving
    let startDriveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Start Drive", for: .normal)
        button.backgroundColor = .blue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // Initialize with the name passed from the previous view controller
    init(name: String) {
        self.name = name
        super.init(nibName: nil, bundle: nil)
    }
    
    // Required init method for the view controller
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        setupCamera()

        // Add the button to the view
        view.addSubview(startDriveButton)
        setupLayout()
        
        // Attach action to the button
        startDriveButton.addTarget(self, action: #selector(startDriveAndCheckUser), for: .touchUpInside)
    }
    
    // Setup the camera for the live preview
    func setupCamera() {
        captureSession = AVCaptureSession()
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if captureSession.canAddInput(videoInput) {
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

    // Setup layout constraints for the button
    func setupLayout() {
        NSLayoutConstraint.activate([
            startDriveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startDriveButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            startDriveButton.widthAnchor.constraint(equalToConstant: 150),
            startDriveButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    // Start drive and call the API
    @objc func startDriveAndCheckUser() {
        // Make sure the camera is running
        captureSession.startRunning()

        // Call the API to check the user and start the drive
        callStartDriveAPI()
    }

    // Call the /start_drive API and handle the response
    func callStartDriveAPI() {
        DispatchQueue.global(qos: .background).async {
            let url = URL(string: "http://localhost:5000/start_drive")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            // JSON body with the user's name
            let jsonBody = ["name_checked": self.name]
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: jsonBody, options: [])
                request.httpBody = jsonData
                
                // Send the POST request
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    if let error = error {
                        print("Error in API request: \(error.localizedDescription)")
                        return
                    }
                    
                    if let data = data {
                        do {
                            if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                               let passed = jsonResponse["Passed"] as? Bool {
                                
                                // Handle the response on the main thread
                                DispatchQueue.main.async {
                                    if passed {
                                        print("Drive started successfully")
                                    } else {
                                        // If passed is false, pop 3 view controllers and show a failure message
                                        self.handleFailedDrive()
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
    }

    // Handle the case when the drive fails
    func handleFailedDrive() {
        // Pop 3 view controllers
//
        let navigationController = self.navigationController
        navigationController!.popToRootViewController(animated: true)
        // Show alert to notify the user
        let alert = UIAlertController(title: "Warning", message: "Someone else was detected driving. You must restart the process.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
