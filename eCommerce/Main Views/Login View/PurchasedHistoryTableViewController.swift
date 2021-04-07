//
//  PurchasedHistoryTableViewController.swift
//  eCommerce
//
//  Created by Ivan Ivanov on 4/7/21.
//

import UIKit

class PurchasedHistoryTableViewController: UITableViewController {
    
    // MARK: - Vars
    
    var purchasedItems: [Item] = []

    // MARK: - view LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadItems()
    }

    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return purchasedItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ItemTableViewCell
       cell.generateCell(purchasedItems[indexPath.row])
       return cell
    }
    
    // MARK: - loadItems
    
    private func loadItems(){
        downloadItemWithId(User.currentUser()!.purchasedItemIds) { (allItem) in
            self.purchasedItems = allItem
            self.tableView.reloadData()
        }
    }

}
