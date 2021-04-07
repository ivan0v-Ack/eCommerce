//
//  WelcomeViewController.swift
//  eCommerce
//
//  Created by Ivan Ivanov on 4/4/21.
//

import UIKit
import JGProgressHUD
import NVActivityIndicatorView


class WelcomeViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var resendButton: UIButton!
    
    // MARK: - VARS
    
    let hud = JGProgressHUD(style: .dark)
    var activitiIndicator: NVActivityIndicatorView?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        resendButton.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        activitiIndicator = NVActivityIndicatorView(frame: CGRect(x: self.view.frame.width / 2 - 30, y: self.view.frame.height / 2 - 30, width: 60, height: 60), type: .ballPulse, color: #colorLiteral(red: 0.821133554, green: 0.2564511299, blue: 0.3796297014, alpha: 1), padding: .zero)
    }
    
    // MARK: - IBActions
    
    @IBAction func CancelBtnPressed(_ sender: UIButton) {
        dissmisView()
    }
    @IBAction func loginBtnPressed(_ sender: UIButton) {
        if checkTextFields(){
            signUp()
            
        }else  {
            hud.textLabel.text = "All Fields are required"
            hud.indicatorView = JGProgressHUDErrorIndicatorView()
            hud.show(in: self.view)
            hud.dismiss(afterDelay: 2.0, animated: true)
            print("Error all fields are required!")
        }
    }
    
    @IBAction func registerBtnPressed(_ sender: UIButton) {
        if checkTextFields() {
            registration()
        }else {
            hud.textLabel.text = "All Fields are required"
            hud.indicatorView = JGProgressHUDErrorIndicatorView()
            hud.show(in: self.view)
            hud.dismiss(afterDelay: 2.0, animated: true)
            print("Error all fields are required!")
        }
    }
    
    @IBAction func forgotBtnPressed(_ sender: UIButton) {
        if emailTextField.text != nil {
            resendThePassword()
        }else {
            self.hud.textLabel.text = "Please write your email adress"
            self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
            self.hud.show(in: self.view)
            self.hud.dismiss(afterDelay: 2.0, animated: true)
        }
    }
    
    @IBAction func resendEmailBtnPressed(_ sender: UIButton) {
        User.resendVerificationEmail(emailTextField.text!) { (error) in
            print("error resending emial adress", error?.localizedDescription)
        }
    }
    
    // MARK: - Register User
    
    private func registration(){
        showLoadingIndicator()
        User.registerUser(email: emailTextField.text!, password: passwordTextField.text!) { (error) in
            
            if error == nil {
                self.hud.textLabel.text = "Verification email send"
                self.hud.indicatorView = JGProgressHUDSuccessIndicatorView()
                self.hud.show(in: self.view)
                self.hud.dismiss(afterDelay: 2.0, animated: true)
                
            }else {
                print("error registering" , error!.localizedDescription)
                self.hud.textLabel.text = error!.localizedDescription
                self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
                self.hud.show(in: self.view)
                self.hud.dismiss(afterDelay: 2.0, animated: true)
            }
            self.hideLoadingIndicator()
        }
    }
    // MARK: - Login User
    private func signUp(){
        showLoadingIndicator()
        User.loginUserWith(email: emailTextField.text!, password: passwordTextField.text!) { (error, isVeryFied) in
            
            if error != nil {
                print("Error signUp" , error!.localizedDescription)
                self.hud.textLabel.text = error!.localizedDescription
                self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
                self.hud.show(in: self.view)
                self.hud.dismiss(afterDelay: 2.0, animated: true)
            }else {
                if !isVeryFied {
                    self.resendButton.isHidden = false
                    print("Please verify your email adress")
                    self.hud.textLabel.text = "Please verify your email adress"
                    self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
                    self.hud.show(in: self.view)
                    self.hud.dismiss(afterDelay: 2.0, animated: true)
                }else {
                    self.dissmisView()
                    print("Email is verified")
                }
            }
            self.hideLoadingIndicator()
        }
    }
    
    // MARK: - helper functions
    private func dissmisView(){
        self.dismiss(animated: true, completion: nil)
    }
    
    private func checkTextFields() -> Bool{
      return emailTextField != nil && passwordTextField != nil
    }
    private func resendThePassword(){
        User.resendPassword(emailTextField.text!) { (error) in
            if error == nil {
                
                self.hud.textLabel.text = "Reset password email sent!"
                self.hud.indicatorView = JGProgressHUDSuccessIndicatorView()
                self.hud.show(in: self.view)
                self.hud.dismiss(afterDelay: 2.0, animated: true)
            }else {
                print("error resend the new password", error!.localizedDescription)
                self.hud.textLabel.text = error!.localizedDescription
                self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
                self.hud.show(in: self.view)
                self.hud.dismiss(afterDelay: 2.0, animated: true)

            }
            
        }
    }
    
    // MARK: - Activity indicator
    
    private func showLoadingIndicator(){
        if activitiIndicator != nil {
            self.view.addSubview(activitiIndicator!)
        activitiIndicator?.startAnimating()
        }
    }
    private func hideLoadingIndicator(){
        if activitiIndicator != nil {
            activitiIndicator!.stopAnimating()
            activitiIndicator!.removeFromSuperview()
        }
    }
}
