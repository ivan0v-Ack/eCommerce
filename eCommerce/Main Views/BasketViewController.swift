//
//  BasketViewController.swift
//  eCommerce
//
//  Created by Ivan Ivanov on 4/3/21.
//

import UIKit
import JGProgressHUD
import Stripe

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
    //var totalPrice = 0
    
    let hud = JGProgressHUD(style: .dark)
    
    
    
    // MARK: - IBActions
    
    @IBAction func checkBtnPressed(_ sender: Any) {
        
        if User.currentUser()!.onBoard {
            showPaymentOptions()
        }else {
            showNotification(text: "Please complete your profile!", isError: true)
            
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
    
    private func finishPayment(token: STPToken) {
        var totalPrice = 0
        
        purchasedItemIds = allItems.map({$0.id})
        totalPrice = allItems.reduce(0, {$0 + Int($1.price)}) * 100
        
        StripeClient.sharedClient.createAndConfirmPayment(token, amount: totalPrice) {
            (error) in
            
            if error == nil {
                
                self.addItemsToPurchasedHistory(self.purchasedItemIds)
                self.emptyTheBasket()
                self.updateTotalLabels(true)
                self.showNotification(text: "Payment succesfull", isError: false)
                
            }else {
                print("error: ", error!.localizedDescription)
                self.showNotification(text: error!.localizedDescription, isError: true)
                
            }
        }
    }
    
    private func showNotification(text: String, isError: Bool){
        if isError {
            hud.indicatorView = JGProgressHUDErrorIndicatorView()
        }else {
            hud.indicatorView = JGProgressHUDSuccessIndicatorView()
        }
        hud.textLabel.text = text
        hud.show(in: self.view)
        hud.dismiss(afterDelay: 2.0)
    }
    
    private func showPaymentOptions (){
        
        let alertController = UIAlertController(title: "Payment Options", message: "Choose prefered payment option", preferredStyle: .actionSheet)
        
        let cardAction = UIAlertAction(title: "Pay with Card", style: .default) { (action) in
            let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "cardInfoVC") as! CardInfoViewController
            vc.modalPresentationStyle = .fullScreen
            vc.delegate = self
            self.present(vc, animated: true, completion: nil)
            
            //show card number View
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(cardAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
        
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
            let itemToDelete = allItems[indexPath.row]
            allItems.remove(at: indexPath.row)
            tableView.reloadData()
            removeItemFromBaskte(itemId: itemToDelete.id)
            deleteItem(basket!, withValues: [kITEMIDS : basket!.itemIds])
        }
    }
    
    
}

extension BasketViewController: CardInfoViewControllerDelegate {
    func didClickDone(_ token: STPToken) {
        finishPayment(token: token)
    }
    
    func didClickCancel() {
        showNotification(text: "Payment Cancelled", isError: true)
    }
    
    
}
