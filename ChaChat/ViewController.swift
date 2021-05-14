//
//  ViewController.swift
//  ChaChat
//
//  Created by Sandeep Gautam on 01/05/2021.
//

import UIKit
import FirebaseAuth
import Firebase

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    var messages: [DataSnapshot]! = [DataSnapshot]()
    var ref: DatabaseReference!
    private var _refHandle: DatabaseHandle!

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    deinit {
        self.ref.child("messages").removeObserver(withHandle: _refHandle)
    }
    
    func configureDatabase () {
        ref = Database.database().reference()
        
        _refHandle = self.ref.child("messages").observe(DataEventType.childAdded, with: { snapshot -> Void in
            self.messages.append(snapshot)
            self.tableView.insertRows(at: [IndexPath(row: self.messages.count-1, section: 0)], with: UITableView.RowAnimation.automatic)
        })
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "tableViewCell", for: indexPath)
        let messageSnap: DataSnapshot = self.messages[indexPath.row]
        let message = messageSnap.value as! Dictionary<String,String>
        if let text = message[Constants.MessageFields.text] as String? {
            cell.textLabel?.text = text
        }
        
        if let subText = message[Constants.MessageFields.dateTime] as String? {
            cell.detailTextLabel?.text = subText
        }
        return cell
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        
        let firebaseAuth = FirebaseAuth.Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            let alertBox = UIAlertController(title: "Error", message: signOutError.localizedDescription, preferredStyle: UIAlertController.Style.alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) { result in
                print("Ok")
            }
            alertBox.addAction(okAction)
            self.present(alertBox, animated: true, completion: nil)
        }
        
        
        if (FirebaseAuth.Auth.auth().currentUser == nil) {
            let vc = self.storyboard?.instantiateViewController(identifier: "firebaseLoginViewController")
            self.navigationController?.present(vc!, animated: true, completion: nil)
            
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        let data = [Constants.MessageFields.text: textField.text! as String]
        sendMessage(data: data)
        
        print("self ended")
        self.view.endEditing(true)
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.textField.delegate = self
        
        configureDatabase()
        
        /*NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillShow(_: )), name: UIResponder.keyboardWillShowNotification, object: self.view.window)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillHide(_: )), name: UIResponder.keyboardWillHideNotification, object: self.view.window)
        */
    }
    
    func sendMessage (data: [String: String]) {
        var packet = data
        packet[Constants.MessageFields.dateTime] = Utilities().getDate()
        self.ref.child("messages").childByAutoId().setValue(packet)
        textField.text = ""
    }
    
    @objc func keyboardWillHide (_ sender: NSNotification) {
        let userInfo = sender.userInfo! as NSDictionary
        let keyboardSize : CGSize = ((userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size)!
        
        self.view.frame.origin.y += keyboardSize.height
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: self.view.window)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: self.view.window)
    }
    
    @objc func keyboardWillShow(_ sender: NSNotification) {
        let userInfo = sender.userInfo! as NSDictionary
        let keyboardSize : CGSize = ((userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size)!
        let offset: CGSize = ((userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size)!
        
        if keyboardSize.height == offset.height {
            if self.view.frame.origin.y == 0 {
                UIView.animate(withDuration: 0.15) {
                    self.view.frame.origin.y -= keyboardSize.height
                }
            }
        }
        else {
            UIView.animate(withDuration: 0.15) {
                self.view.frame.origin.y += keyboardSize.height - offset.height
            }
        }
    }


}

