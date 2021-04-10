//
//  CardInfoViewController.swift
//  eCommerce
//
//  Created by Ivan Ivanov on 4/9/21.
//

import UIKit
import Stripe

protocol CardInfoViewControllerDelegate {
    
    func didClickDone(_ token: STPToken)
    func didClickCancel()
}

class CardInfoViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var doneBtnOutlet: UIButton!
    
    // MARK: - Vars
    let paymentCardTextfield = STPPaymentCardTextField()
    var delegate: CardInfoViewControllerDelegate?
    
    
    // MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        paymentCardTextfield.delegate = self
        view.addSubview(paymentCardTextfield)
        setupConstraints()
        
    }
    
    // MARK: - IBActions
    @IBAction func doneBtnPressed(_ sender: UIButton) {
        processCard()
    }
    @IBAction func cancelBtnPressed(_ sender: UIButton) {
        delegate?.didClickCancel()
        dissmisView()
    }
    
    // MARK: - Helpers
    
    private func dissmisView(){
        self.dismiss(animated: true, completion: nil)
    }
    
    private func setupConstraints() {
        paymentCardTextfield.translatesAutoresizingMaskIntoConstraints = false
        
        paymentCardTextfield.topAnchor.constraint(equalTo: doneBtnOutlet.bottomAnchor, constant: 30).isActive = true
        paymentCardTextfield.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        paymentCardTextfield.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        
    }
    
    private func processCard() {
        let cardParams = STPCardParams()
        cardParams.number = paymentCardTextfield.cardNumber
        cardParams.expMonth = UInt(paymentCardTextfield.expirationMonth)
        cardParams.expYear = UInt(paymentCardTextfield.expirationYear)
        cardParams.cvc = paymentCardTextfield.cvc
        
        STPAPIClient.shared.createToken(withCard: cardParams) { (token, error) in
            if error == nil {
                
                self.delegate?.didClickDone(token!)
                self.dissmisView()
            }else {
                print("Error processing card token: ", error!.localizedDescription)
            }
        }
    }
    
}

extension CardInfoViewController: STPPaymentCardTextFieldDelegate {
    
    func paymentCardTextFieldDidChange(_ textField: STPPaymentCardTextField) {
        doneBtnOutlet.isEnabled = textField.isValid
    }
}
