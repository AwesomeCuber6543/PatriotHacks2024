//
//  LoginViewController.swift
//  DriveSafe
//
//  Created by yahia salman on 10/13/24.
//


import UIKit

class LoginViewController: UIViewController {
    
    
    
//    private let usernameLabel = CustomTextField(fieldType: .username)
//    private let passwordLabel = CustomTextField(fieldType: .password)
    private let loginButton = CustomButton(title: "Welcome", hasBackground: true , fontsize: .med, buttonColor: UIColor(red: 0/255, green: 97/255, blue: 255/255, alpha: 1), titleColor: .white)
    
    
    
    private let RouteLogo: UIImageView = {
       let RouteLogo = UIImageView(image: UIImage(named: "Logo"))
        return RouteLogo
    }()
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        self.setupUI()
        
        self.loginButton.addTarget(self, action: #selector(didTapLogin), for: .touchUpInside)
        
    }
    
    func setupUI(){
        
//        self.view.addSubview(usernameLabel)
//        self.view.addSubview(passwordLabel)
        self.view.addSubview(loginButton)
        self.view.addSubview(RouteLogo)
        
//        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
//        passwordLabel.translatesAutoresizingMaskIntoConstraints = false
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        RouteLogo.translatesAutoresizingMaskIntoConstraints = false
        
        
        
        NSLayoutConstraint.activate([
            
            self.RouteLogo.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.RouteLogo.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 150),
            self.RouteLogo.widthAnchor.constraint(equalToConstant: 300),
            self.RouteLogo.heightAnchor.constraint(equalToConstant: 300),
            
//            self.usernameLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
//            self.usernameLabel.topAnchor.constraint(equalTo: self.repsLogo.bottomAnchor, constant: 50),
//            self.usernameLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
//            self.usernameLabel.heightAnchor.constraint(equalToConstant: 45),
//            
//            
//            self.passwordLabel.topAnchor.constraint(equalTo: self.usernameLabel.bottomAnchor, constant: 10),
//            self.passwordLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
//            self.passwordLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
//            self.passwordLabel.heightAnchor.constraint(equalToConstant: 45),
            
            self.loginButton.topAnchor.constraint(equalTo: self.RouteLogo.bottomAnchor, constant: 10),
            self.loginButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            self.loginButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            self.loginButton.heightAnchor.constraint(equalToConstant: 60),
        
        
        
        ])
        
        
        
        
        
    }
    
    
    
    @objc func didTapLogin(){
//        let vc = HomePageViewController()
//        vc.modalPresentationStyle = .fullScreen // You can adjust the presentation style as needed
        
        
        let navigationController = UINavigationController(rootViewController: HomeViewController())
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true, completion: nil)
        
    }


}


