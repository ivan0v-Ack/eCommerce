//
//  ProfileTableViewController.swift
//  eCommerce
//
//  Created by Ivan Ivanov on 4/6/21.
//

import UIKit

class ProfileTableViewController: UITableViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var finishRegistrationBtn: UIButton!
    
    @IBOutlet weak var purchaseHistoryBtn: UIButton!
    
    // MARK: - Vars
    
    var editBtnOutlet: UIBarButtonItem!
    
    // MARK: - view LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkingLoginStatus()
        checkOnBoardingStatus()
    }
    
    
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    // MARK: - tableView Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Helpers func
    
    private func checkOnBoardingStatus(){
        if User.currentUser() != nil {
            if User.currentUser()!.onBoard {
                finishRegistrationBtn.setTitle("Account is Active", for: .normal)
                finishRegistrationBtn.isEnabled = false
            }else {
                finishRegistrationBtn.setTitle("Finish registration", for: .normal)
                finishRegistrationBtn.isEnabled = true
                finishRegistrationBtn.tintColor = .red
            }
            purchaseHistoryBtn.isEnabled = true
        }else {
            
            finishRegistrationBtn.setTitle("Logged out", for: .normal)
            finishRegistrationBtn.isEnabled = false
            purchaseHistoryBtn.isEnabled = false
        }
    }
    
    
    private func checkingLoginStatus() {
        if User.currentUser() == nil {
            createRightBarBtn("Login")
        }else {
            
            createRightBarBtn("Edit")
        }
    }
    
    private func createRightBarBtn(_ title: String){
        editBtnOutlet = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(rightBarBtnPressed))
        navigationItem.rightBarButtonItem = editBtnOutlet
    }
    // MARK: - IBActions
    
    @objc func rightBarBtnPressed(_ sender: UIBarButtonItem){
        if editBtnOutlet.title == "Login" {
            showLoginView()
        }else {
            goToEditProfile()
        }
    }
    
    private func showLoginView(){
        let loginView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "loginView")
        loginView.modalPresentationStyle = .fullScreen
        self.present(loginView, animated: true, completion: nil)
    }
    private func goToEditProfile(){
        performSegue(withIdentifier: "profileToEditSeg", sender: self)
    }
    
}
