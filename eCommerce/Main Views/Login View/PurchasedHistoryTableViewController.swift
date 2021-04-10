//
//  PurchasedHistoryTableViewController.swift
//  eCommerce
//
//  Created by Ivan Ivanov on 4/7/21.
//

import UIKit
import EmptyDataSet_Swift


class PurchasedHistoryTableViewController: UITableViewController {
    
    // MARK: - Vars
    
    var purchasedItems: [Item] = []
    
    // MARK: - view LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
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

extension PurchasedHistoryTableViewController: EmptyDataSetSource, EmptyDataSetDelegate {
    
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: "No items to display!")
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        return UIImage(named: "emptyData")
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: "Please Check back later!")
    }
    
}
