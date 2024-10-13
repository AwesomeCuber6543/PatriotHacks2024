import UIKit

class HomeViewController: UIViewController {
    
    // UI Elements
    let carImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "EnRoute"
        label.font = UIFont.boldSystemFont(ofSize: 32)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Make Sure Everyone Gets Home Safe!"
        label.font = UIFont.systemFont(ofSize: 20)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let startButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Start Your Engine", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        button.backgroundColor = UIColor(white: 0.9, alpha: 1)
        button.layer.cornerRadius = 25
        button.setImage(UIImage(systemName: "power.circle"), for: .normal)
        button.tintColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapStart), for: .touchUpInside)
        return button
    }()
    
    let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add User", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.setImage(UIImage(systemName: "plus.circle"), for: .normal)
        button.tintColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let profileButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Profile", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.setImage(UIImage(systemName: "person.circle"), for: .normal)
        button.tintColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapProfile), for: .touchUpInside)
        return button
    }()
    
    let settingsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Settings", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.setImage(UIImage(systemName: "gearshape.circle"), for: .normal)
        button.tintColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        // Add subviews
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(carImageView)
        view.addSubview(startButton)
        view.addSubview(addButton)
        view.addSubview(profileButton)
        view.addSubview(settingsButton)
        
        // Set up the layout constraints
        setupLayout()
        
        // Set the car image (you will replace this with your own image)
        if let carImage = UIImage(named: "MalibuPic") {
            carImageView.image = carImage
        } else {
            carImageView.backgroundColor = .lightGray // Placeholder background
        }
    }
    
    func setupLayout() {
        NSLayoutConstraint.activate([
            // Title Label Constraints
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Subtitle Label Constraints
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Car Image Constraints
            carImageView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 60),
            carImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            carImageView.heightAnchor.constraint(equalToConstant: 200), // Adjust size as needed
            carImageView.widthAnchor.constraint(equalToConstant: 300),
            
            // Start Button Constraints
            startButton.topAnchor.constraint(equalTo: carImageView.bottomAnchor, constant: 100),
            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startButton.heightAnchor.constraint(equalToConstant: 50),
            startButton.widthAnchor.constraint(equalToConstant: 250),
            
            // Add Button Constraints
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            
            // Profile Button Constraints
            profileButton.centerYAnchor.constraint(equalTo: addButton.centerYAnchor),
            profileButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Settings Button Constraints
            settingsButton.centerYAnchor.constraint(equalTo: addButton.centerYAnchor),
            settingsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
        ])
    }
    
    @objc func didTapStart() {
        let vc = HomeTableViewController()
//        vc.delegate = self
        let navigationController = UINavigationController(rootViewController: vc)
        navigationController.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func didTapProfile() {
        let profileVC = ProfileViewController()
        navigationController?.pushViewController(profileVC, animated: true)
    }
}
