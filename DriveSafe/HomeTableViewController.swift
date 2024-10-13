//
//  HomeTableViewController.swift
//  DriveSafe
//
//  Created by yahia salman on 10/13/24.
//

import UIKit

class HomeTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // Predefined array of names
    let names = ["yahia", "amaya", "hadeel"]
    
    // TableView to display the names
    let tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set title for the page
        title = "Names List"
        
        // Set background color
        view.backgroundColor = .white
        
        // Add tableView to the view
        view.addSubview(tableView)
        
        // Set up delegates and data source
        tableView.delegate = self
        tableView.dataSource = self
        
        // Register a UITableViewCell for reuse
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "nameCell")
        
        // Set up constraints for tableView
        setupLayout()
    }
    
    // Setup the layout for the table view
    func setupLayout() {
        NSLayoutConstraint.activate([
            // Pin the table view to all edges of the view
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
    
    // MARK: - UITableView DataSource Methods
    
    // Number of rows in the table (equal to the number of names in the array)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return names.count
    }
    
    // Populate each cell with a name from the names array
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "nameCell", for: indexPath)
        cell.textLabel?.text = names[indexPath.row]
        return cell
    }
    
    // Handle row selection (optional)
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Print the selected name (for example)
        let selectedName = names[indexPath.row]
        print("Selected: \(selectedName)")
        let identificationVC = IdentificationViewController(name: selectedName)
        navigationController?.pushViewController(identificationVC, animated: true)
    }
}
