//
//  LoginViewController.swift
//  IndoorTrackingClient
//
//  Created by Phillip McKenna on 30/9/17.
//  Copyright © 2017 IDC. All rights reserved.
//

import Foundation
import UIKit

class LoginViewController : UITableViewController {
    
    private var users = [User]()
    fileprivate var creationScreen: FormViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.separatorStyle = .none
        
        // Load all the users.
        reloadUsers()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        reloadUsers()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Does this really dequeue or is it creating it every time?
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "LoginCell") as? LoginTableViewCell else {
            fatalError("The dequeued cell was not the correct type: LoginTableViewCell")
        }
        
        cell.userLabel.text = "\(users[indexPath.row].firstName!) \(users[indexPath.row].lastName!)"
        
        //print(users[indexPath.row].firstName)
        //cell!.detailTextLabel?.text = users[indexPath.row].id.uuidString
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = users[indexPath.row]
        
        if(UserSettings.shared.login(user: user)) {
            
            performSegue(withIdentifier: "ShowTracker", sender: self)
            
            /*
            let menu = MenuTableViewController()
            let navigationController = UINavigationController(rootViewController: menu)
            self.present(navigationController, animated: true, completion: nil)
            */
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let tracker = segue.destination as? TrackerViewController {
            
        }
    }
    
    // Other
    // #####
    
    func reloadUsers() {
        User.all {
            self.gotUsers(users: $0)
        }
    }
    
    private func gotUsers(users: [User]) {
        self.users = users
        self.tableView.reloadData()
    }
}
