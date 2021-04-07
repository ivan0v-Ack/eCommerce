//
//  EditProfileViewController.swift
//  eCommerce
//
//  Created by Ivan Ivanov on 4/7/21.
//

import UIKit
import JGProgressHUD

class EditProfileViewController: UIViewController {
    
    
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var surnameTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    
    // MARK: - Vars
    
    let hud = JGProgressHUD(style: .dark)
    
    
    // MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        loadUserInfo()
    }
    
    // MARK: - IBActions

    @IBAction func saveBarBtnPressed(_ sender: UIBarButtonItem) {
        print("click")
        dismissKeyboard()
        if textFieldsHaveText(){
            let withValues = [kFIRSTNAME : nameTextField.text!, kLASTNAME : surnameTextField.text!, kFULLNAME : (nameTextField.text! + " " + surnameTextField.text!), kFULLADRESS : addressTextField.text!]
            
            updateCurrentUserInFirestore(withValues) { (error) in
                if error == nil {
                    self.hud.textLabel.text = "Updated"
                    self.hud.indicatorView = JGProgressHUDSuccessIndicatorView()
                    self.hud.show(in: self.view)
                    self.hud.dismiss(afterDelay: 2.0)
                }else {
                    print("Error updating user info :", error!.localizedDescription)
                    self.hud.textLabel.text = error!.localizedDescription
                    self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
                    self.hud.show(in: self.view)
                    self.hud.dismiss(afterDelay: 2.0)
                }
            }
            
        }else {
            
            self.hud.textLabel.text = "All fields are required!"
            self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
            self.hud.show(in: self.view)
            self.hud.dismiss(afterDelay: 2.0)
        }
    }
    @IBAction func logOutBtnPressed(_ sender: UIButton) {
        logOutUser()
    }
    
    // MARK: - Update UI
    
    private func loadUserInfo(){
        if User.currentUser() != nil {
       
            let currentUser = User.currentUser()!
           
            nameTextField.text = currentUser.firstName
            surnameTextField.text = currentUser.lastName
            addressTextField.text = currentUser.fullAdress
            
            
        }
    }
    
    private func logOutUser(){
        User.logOutCurrentUser { (error) in
            if error == nil {
                print("log out")
                self.navigationController?.popViewController(animated: true)
            }else {
                print("logout error: ",error!.localizedDescription)
            }
        }
    }
    
    // MARK: - helper Func
    
    private func dismissKeyboard(){
        self.view.endEditing(false)
    }
    
    private func textFieldsHaveText() -> Bool {
        return nameTextField.text != "" && surnameTextField.text != "" && addressTextField.text != ""
    }
    
}
