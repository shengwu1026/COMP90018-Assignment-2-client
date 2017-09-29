//
//  UserListController.swift
//  IndoorTrackingClient
//
//  Created by Phillip McKenna on 16/9/17.
//  Copyright © 2017 IDC. All rights reserved.
//

import UIKit

class UserListController: UITableViewController {
    
    private var users = [User]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the tableview
        //self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        self.title = "All Users"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Create", style: .plain, target: self, action: #selector(didTapCreate))
        
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
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        if(cell == nil) {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        }
        
        cell!.textLabel?.text = "\(users[indexPath.row].firstName!) \(users[indexPath.row].lastName!)"
        //print(users[indexPath.row].firstName)
        cell!.detailTextLabel?.text = users[indexPath.row].id.uuidString

        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = users[indexPath.row]
        let chipAddController = UserChipController()
        chipAddController.user = user
        self.navigationController?.pushViewController(chipAddController, animated: true)
    }
    
    // Other
    // #####
    
    func reloadUsers() {
        User.all {
            self.gotUsers(users: $0)
        }
    }
    
    func didTapCreate() {
        let creationScreen = createForm()
        present(creationScreen, animated: true, completion: nil)
    }
    
    private func gotUsers(users: [User]) {
        self.users = users
        self.tableView.reloadData()
    }
    
    private func createForm() -> FormViewController {
        let userSection = Section(name: "USER DETAILS")
        userSection.addField(InputField(id: "first_name", title: "First Name", isRequired: true))
        userSection.addField(InputField(id: "last_name", title: "Last Name", isRequired: true))
        userSection.addField(InputField(id: "username", title: "Username", isRequired: true))
        userSection.addField(InputField(id: "password", title: "Password", isRequired: true))
        
        let formViewController = FormViewController(formTitle: "Create User", sections: [userSection])
        formViewController.delegate = self
        return formViewController
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension UserListController : FormDelegate {
    func willMoveToNextInput(_ next: InputField) {
        
    }
    
    func formShouldSubmitWithData(_ data: [String : String], complete: Bool, incompleteFieldIds: [String]?) -> Bool {
        if(!complete) {
            if let ids = incompleteFieldIds {
                shakeIncompleteFields(ids)
            }
            return false
        }
        
        return true
    }
    
    func formDidSubmitWithData(_ data: [String : String]) {
        User.create(parameters: data) { user in
            self.presentedViewController?.dismiss(animated: true, completion: nil)
            self.reloadUsers()
        }
    }
    
    fileprivate func shakeIncompleteFields(_ fieldIds: [String]) {
        for fieldId in fieldIds {
            if let viewController = self.presentedViewController as? FormViewController {
                if let cell = viewController.cellForFieldId(fieldId) {
                    cell.contentView.frame.origin.x = -50
                    UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 8, options: UIViewAnimationOptions.curveEaseOut, animations: { cell.contentView.frame.origin.x = 0 }, completion: nil)
                }
            }
        }
    }
}
