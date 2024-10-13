//
//  ViewController.swift
//  DriveSafe
//
//  Created by yahia salman on 10/12/24.
//

import UIKit

class TestViewController: UIViewController {
    
    var count: Int = 0
    var name: String
    // Create a button and a ball (UIView)
    let startButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Start", for: .normal)
        button.backgroundColor = .blue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let redBall: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        view.layer.cornerRadius = 25
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Constraint references for animation
    var ballCenterXConstraint: NSLayoutConstraint!
    
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
        self.view.backgroundColor = .white
        
        // Add the button and the ball to the view
        view.addSubview(startButton)
        view.addSubview(redBall)
        
        // Setup layout constraints
        setupLayout()
        
        // Attach action to the button
        startButton.addTarget(self, action: #selector(startTestAndAnimation), for: .touchUpInside)
    }
    
    func setupLayout() {
        // Center the start button horizontally and place it at the bottom of the screen
        NSLayoutConstraint.activate([
            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            startButton.widthAnchor.constraint(equalToConstant: 100),
            startButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // Position the red ball in the center vertically, and in the middle horizontally
        ballCenterXConstraint = redBall.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        NSLayoutConstraint.activate([
            ballCenterXConstraint,
            redBall.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            redBall.widthAnchor.constraint(equalToConstant: 50),
            redBall.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // Set initial ball position (center)
        view.layoutIfNeeded()
    }
    
    // Function to handle both test API call and ball animation
    @objc func startTestAndAnimation() {
        self.count = self.count + 1
        // Start animation and API call concurrently
        startAnimation()
        startTestAPIRequest()
        
//        if count % 2 == 1{
//            showPopup(title: "Driver Possibly Impaired", message: "Try Again")
//        }
//        else{
//            let vc = DrivingViewController(name: self.name)
//    //        vc.delegate = self
//            let navigationController = UINavigationController(rootViewController: vc)
//            navigationController.modalPresentationStyle = .fullScreen
//            self.navigationController?.pushViewController(vc, animated: true)
//        }
    }
    
    // Function to animate the ball
    func startAnimation() {
        let screenWidth = view.bounds.width
        let ballRadius: CGFloat = 25
        let rightWallX = screenWidth - ballRadius * 2
        let leftWallX: CGFloat = ballRadius
        
        // Animate to right wall in 2 seconds, then left wall in 4 seconds, and return to center in 2 seconds
        UIView.animate(withDuration: 2, delay: 0, options: [.curveLinear], animations: {
            self.ballCenterXConstraint.constant = rightWallX - self.view.center.x
            self.view.layoutIfNeeded()
        }) { _ in
            UIView.animate(withDuration: 4, delay: 0, options: [.curveLinear], animations: {
                self.ballCenterXConstraint.constant = leftWallX - self.view.center.x
                self.view.layoutIfNeeded()
            }) { _ in
                UIView.animate(withDuration: 2, delay: 0, options: [.curveLinear], animations: {
                    self.ballCenterXConstraint.constant = 0
                    self.view.layoutIfNeeded()
                }, completion: nil)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
            if self.count % 2 == 1{
                self.showPopup(title: "Driver Possibly Impaired", message: "Try Again")
            }
            else{
                let vc = DrivingViewController(name: self.name)
        //        vc.delegate = self
                let navigationController = UINavigationController(rootViewController: vc)
                navigationController.modalPresentationStyle = .fullScreen
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        
    }
    
    // Function to call the /start_test API
    func startTestAPIRequest() {
        // Perform the API call in the background
        DispatchQueue.global(qos: .background).async {
            let url = URL(string: "http://localhost:5000/start_test")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            // Create a task to send the POST request
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error in API request: \(error.localizedDescription)")
                    return
                }
                
                // Handle the response from the server (for example, print the response)
                if let data = data, let responseString = String(data: data, encoding: .utf8) {
                    print("Response from API: \(responseString)")
                    
                }
            }
            task.resume()
        }
    }
    
    func showPopup(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        
        // Present the alert controller
        self.present(alertController, animated: true, completion: nil)
    }
}
