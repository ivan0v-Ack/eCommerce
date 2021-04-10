//
//  FinishRegistretionViewController.swift
//  eCommerce
//
//  Created by Ivan Ivanov on 4/7/21.
//

import UIKit
import JGProgressHUD

class FinishRegistretionViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var surnameTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var doneBtnOutlet: UIButton!
    
    // MARK: - Vars
    
    let hud = JGProgressHUD(style: .dark)
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        nameTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: .editingChanged)
        surnameTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: .editingChanged)
        addressTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: .editingChanged)
    }
    
    // MARK: - IBActions
    
    
    @IBAction func doneBtnPressed(_ sender: UIButton) {
        
        finishOnBoarding()
    }
    
    @IBAction func cancelBtnPressed(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @objc func textFieldDidChange(sender: UITextField){
        updateDoneBtnStatus()
    }
    
    // MARK: - Helper
    
    private func updateDoneBtnStatus(){
        
        if nameTextField.text != "" && surnameTextField.text != "" && addressTextField.text != "" {
            
            doneBtnOutlet.backgroundColor = #colorLiteral(red: 1, green: 0.5305714011, blue: 0.5702815652, alpha: 1)
            doneBtnOutlet.isEnabled = true
        }else {
            doneBtnOutlet.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
            doneBtnOutlet.isEnabled = false
        }
    }
    
    
    private func finishOnBoarding(){
        let withValues = [kFIRSTNAME : nameTextField.text!, kLASTNAME : surnameTextField.text!, kONBOARD : true, kFULLADRESS : addressTextField.text!, kFULLNAME : (nameTextField.text! + " " + surnameTextField.text!)] as [String : Any]
        
        updateCurrentUserInFirestore(withValues) { (error) in
            if error == nil {
                self.hud.textLabel.text = "Updated!"
                self.hud.indicatorView = JGProgressHUDSuccessIndicatorView()
                self.hud.show(in: self.view)
                self.hud.dismiss(afterDelay: 2.0)
                
                self.dismiss(animated: true, completion: nil)
            }else {
                print("error updating user information :", error!.localizedDescription)
                
                self.hud.textLabel.text = error!.localizedDescription
                self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
                self.hud.show(in: self.view)
                self.hud.dismiss(afterDelay: 2.0)
            }
        }
    }
    
    
    
}
