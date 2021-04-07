//
//  BasketViewController.swift
//  eCommerce
//
//  Created by Ivan Ivanov on 4/3/21.
//

import UIKit
import JGProgressHUD

class BasketViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var totalBasketLabel: UILabel!
    @IBOutlet weak var totalItems: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var checkbtn: UIButton!
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = footerView
        setupPayPal()
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if User.currentUser() != nil {
            loadBasketItems()
        }else {
            self.updateTotalLabels(true)
        }
       
        
    }
    
    // MARK: - Vars
    
    var basket: Basket?
    var allItems: [Item] = []
    var purchasedItemIds: [String] = []
    
    let hud = JGProgressHUD(style: .dark)
    
    var environment: String = PayPalEnvironmentNoNetwork {
        willSet (newEnvironment) {
            if (newEnvironment != environment) {
                PayPalMobile.preconnect(withEnvironment: newEnvironment)
            }
        }
    }
    
    var payPalconfig = PayPalConfiguration()
    
    // MARK: - IBActions

    @IBAction func checkBtnPressed(_ sender: Any) {
        
        if User.currentUser()!.onBoard {
            
            payButtonPressed()
            
//            addItemsToPurchasedHistory(self.purchasedItemIds)
//            emptyTheBasket()
        }else {
            hud.textLabel.text = "Please complete your profile!"
            hud.indicatorView = JGProgressHUDErrorIndicatorView()
            hud.show(in: self.view)
            hud.dismiss(afterDelay: 2.0)
        }
    }
    // MARK: - download Basket
    private func loadBasketItems(){
        downloadBasketFromFirestore(User.currentId()) { (userBasket) in
            if userBasket != nil {
                self.basket = userBasket
                self.donloadItemsFromBasket()
            }
            
        }
    }
    
    private func donloadItemsFromBasket(){
        if basket != nil {
            downloadItemWithId(basket!.itemIds) { (Items) in
                self.allItems = Items
                self.tableView.reloadData()
                self.updateTotalLabels(Items.isEmpty)
                
            }
        }
       
    }
    // MARK: - Helper Functions

    
  
    
    private func updateTotalLabels(_ isEmpty: Bool) {
        if isEmpty {
            totalItems.text = "0"
            totalBasketLabel.text = returnBasketTotalPrice()
            
            
        }else {
            totalItems.text = String(allItems.count)
            totalBasketLabel.text = returnBasketTotalPrice()
        }
        updateCheckOutBtn(isEmpty)
    }
    
    private func returnBasketTotalPrice() -> String {
        let totalPrice = allItems.reduce(0, {$0 + $1.price})
        return "Total price: " + convertToCurrency(totalPrice)
    }
    private func updateCheckOutBtn(_ isEmpty: Bool){
        checkbtn.backgroundColor = isEmpty ? .gray : #colorLiteral(red: 1, green: 0.5305714011, blue: 0.5702815652, alpha: 1)
        checkbtn.isUserInteractionEnabled = isEmpty ? false : true
    }
    
    private func emptyTheBasket() {
        purchasedItemIds.removeAll()
        allItems.removeAll()
        tableView.reloadData()
        
        basket!.itemIds = []
        updateBasketInFirestore(basket!, withValues: [kITEMIDS : basket!.itemIds]) { (error) in
            if error != nil {
                print("Error updating Basket :", error!.localizedDescription)
            }
            self.loadBasketItems()
        }
    }
    private func addItemsToPurchasedHistory(_ itemIds : [String]) {
        if User.currentUser() != nil {
            let newItemIds = User.currentUser()!.purchasedItemIds + itemIds
            
            updateCurrentUserInFirestore([kPURCHASEDITEMIDS : newItemIds]) { (error) in
                if error != nil {
                    print("Error adding newItems in PurchasedHistory Basket :", error!.localizedDescription)
                }else {
                    self.loadBasketItems()
                }
                
            }
        }
        
    }
    
    // MARK: - Delete Item
    
    private func removeItemFromBaskte(itemId: String){
        for i in basket!.itemIds.indices {
            let id = basket!.itemIds[i]
            if id == itemId {
                basket!.itemIds.remove(at: i)
                return
            }
        }
        
    }
    
    private func deleteItem(_ basket: Basket, withValues: [String : Any]){
        updateBasketInFirestore(basket, withValues: withValues) { (error) in
            if error != nil {
                print("error delete Basket", error!.localizedDescription)
            }else {
                self.loadBasketItems()
            }
        }
    }
    
    // MARK: - PayPal
    
    private func setupPayPal() {
        payPalconfig.acceptCreditCards = false
        payPalconfig.merchantName = "iOS ackDevelopment eCommerce"
        payPalconfig.merchantPrivacyPolicyURL = URL(string: "https://www.paypal.com/webapps/mpp/ua/privacy-full")
        payPalconfig.merchantUserAgreementURL = URL(string: "https://www.paypal.com/webapps/mpp/ua/useragreement-full")
        
        payPalconfig.languageOrLocale = Locale.preferredLanguages[0]
        payPalconfig.payPalShippingAddressOption = .both
    }
    
    private func payButtonPressed() {
        var itemsToBuy : [PayPalItem] = []
        
        for item in allItems {
            let tempItem = PayPalItem(name: item.name, withQuantity: 1, withPrice: NSDecimalNumber(value: item.price), withCurrency: "USD", withSku: nil)
            purchasedItemIds.append(item.id)
            itemsToBuy.append(tempItem)
        }
        let subTotal = PayPalItem.totalPrice(forItems: itemsToBuy)
        //optioanl
        let shippingCoast = NSDecimalNumber(string: "50.0")
        let tax = NSDecimalNumber(string: "5.00")
        
        let paymentDetails = PayPalPaymentDetails(subtotal: subTotal, withShipping: shippingCoast, withTax: tax)
         
        let total = subTotal.adding(shippingCoast).adding(tax)
        let payment = PayPalPayment(amount: total, currencyCode: "USD", shortDescription: "Payment to ackDevelopment eCommerce", intent: .sale)
        
        payment.items = itemsToBuy
        payment.paymentDetails = paymentDetails
        
        if payment.processable {
            let paymentViewController = PayPalPaymentViewController(payment: payment, configuration: payPalconfig, delegate: self)
            
            present(paymentViewController!, animated: true, completion: nil)
        }else {
            print("payment not processable!")
        }
    }
    
}

extension BasketViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ItemTableViewCell
        cell.generateCell(allItems[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            print("DELETE")
            let itemToDelete = allItems[indexPath.row]
            allItems.remove(at: indexPath.row)
            tableView.reloadData()
            removeItemFromBaskte(itemId: itemToDelete.id)
           deleteItem(basket!, withValues: [kITEMIDS : basket!.itemIds])
        }
    }
    
    
}

extension BasketViewController: PayPalPaymentDelegate {
    func payPalPaymentDidCancel(_ paymentViewController: PayPalPaymentViewController) {
        print("paypal payment cancelled")
        paymentViewController.dismiss(animated: true, completion: nil)
    }
    
    func payPalPaymentViewController(_ paymentViewController: PayPalPaymentViewController, didComplete completedPayment: PayPalPayment) {
        paymentViewController.dismiss(animated: true) {
            self.addItemsToPurchasedHistory(self.purchasedItemIds)
            self.emptyTheBasket()
        }
    }
}
