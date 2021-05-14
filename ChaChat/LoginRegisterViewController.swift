//
//  LoginRegisterViewController.swift
//  ChaChat
//
//  Created by Sandeep Gautam on 02/05/2021.
//

import UIKit
import Firebase
import FirebaseAuth

class LoginRegisterViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(LoginRegisterViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard () {
        view.endEditing(true)
    }
    
    @IBAction func onClickLogin(_ sender: Any) {
        
        let isInputFormatted = checkInput()
        
        if isInputFormatted {
            let email = emailTextField.text
            let password = passwordTextField.text
            
            FirebaseAuth.Auth.auth().signIn(withEmail: email!, password: password!) { user, error in
                if let error = error {
                    Utilities().showAlert(title: "Error", message: error.localizedDescription, vc: self)
                    
                }
            }
        }
        else {return}
    }
    
    func checkInput () -> Bool {
        if let charCh = emailTextField.text?.count {
            if charCh < 5 {
                emailTextField.backgroundColor = UIColor.init(red: 0.8, green: 0, blue: 0, alpha: 0.2)
                return false
            }
        } else {
            emailTextField.backgroundColor = UIColor.white
        }
        
        if let charChP = passwordTextField.text?.count {
            if charChP < 5 {
                passwordTextField.backgroundColor = UIColor.init(red: 0.8, green: 0, blue: 0, alpha: 0.2)
                return false
            }
        } else {
            passwordTextField.backgroundColor = UIColor.white
        }
        
        return true
    }
    
    @IBAction func onClickRegister(_ sender: Any) {
        if (!checkInput()){
            return
        }
        
        let alert = UIAlertController(title: "Register", message: "Please confirm your password!", preferredStyle: UIAlertController.Style.alert)
        alert.addTextField { textField in
            textField.placeholder = "Password"
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil))
        alert.addAction(UIAlertAction(title: "Confirm", style: UIAlertAction.Style.default, handler: { action in
            let passConfirm = alert.textFields![0] as UITextField
            if (passConfirm.text!.isEqual(self.passwordTextField.text!)) {
                let email = self.emailTextField.text!
                let password = self.passwordTextField.text!
                
                FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password) { user, error in
                    if let error = error {
                        Utilities().showAlert(title: "Error", message: error.localizedDescription, vc: self)
                        return
                    }
                    self.dismiss(animated: true, completion: nil)
                }
            }
            
            else {
                Utilities().showAlert(title: "Error", message: "Passwords do not match!", vc: self)
            }
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func onClickForgotPassword(_ sender: Any) {
        let alert = UIAlertController(title: "Reset password", message: "Enter your email address to reset the password", preferredStyle: UIAlertController.Style.alert)
        alert.addTextField { textFieldEmail in
            textFieldEmail.placeholder = "Email address"
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil))
        alert.addAction(UIAlertAction(title: "Reset", style: UIAlertAction.Style.default, handler: { action in
            let email = alert.textFields![0] as UITextField
            if (email.text!.count > 5) {
                FirebaseAuth.Auth.auth().sendPasswordReset(withEmail: email.text!) { error in
                    if let error = error {
                        Utilities().showAlert(title: "Password Reset Error!", message: error.localizedDescription, vc: self)
                        return
                    }
                }
                Utilities().showAlert(title: "Success", message: "Check your email and follow the steps in the email to continue!", vc: self)
            } else {
                Utilities().showAlert(title: "Input Error", message: "Invalid email address, please check your email and try again!", vc: self)
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
