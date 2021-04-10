//
//  SearchViewController.swift
//  eCommerce
//
//  Created by Ivan Ivanov on 4/8/21.
//

import UIKit
import NVActivityIndicatorView
import EmptyDataSet_Swift

class SearchViewController: UIViewController {
    
    // MARK: - IBOtlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchOptionView: UIView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchBtnOutlet: UIButton!
    
    // MARK: - Vars
    var searchResults: [Item] = []
    var activityIndicator: NVActivityIndicatorView?
    
    // MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        searchTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        activityIndicator = NVActivityIndicatorView(frame: CGRect(x: self.view.frame.width / 2 - 30, y: self.view.frame.height / 2 - 30, width: 60, height: 60), type: .ballPulse, color: #colorLiteral(red: 1, green: 0.5305714011, blue: 0.5702815652, alpha: 1), padding: .zero)
    }
    
    // MARK: - IBActions
    
    @IBAction func showSearchBtnPressed(_ sender: UIBarButtonItem) {
        dissmisKeyboard()
        showSearchField()
    }
    @IBAction func searchBtnPressed(_ sender: UIButton) {
        if searchTextField.text != nil {
            searchInFirebase(forName: searchTextField.text!)
            emptyTextField()
            animatSearchOptionsIn()
            dissmisKeyboard()
        }
    }
    
    // MARK: - searchDatabase
    private func searchInFirebase(forName: String){
        showActivityIndicator()
        searchAlgolia(searchString: forName) { (ItemIds) in
            downloadItemWithId(ItemIds) { (AllItems) in
                self.searchResults = AllItems
                self.tableView.reloadData()
                
                self.hideActivityIndicator()
            }
            
        }
        
    }
    
    // MARK: - helper functions
    
    private func emptyTextField(){
        searchTextField.text = ""
    }
    private func dissmisKeyboard(){
        self.view.endEditing(false)
    }
    
    @objc func textFieldDidChange(_ sender: UITextField) {
        
        searchBtnOutlet.isEnabled = sender.text != ""
        searchBtnOutlet.backgroundColor = sender.text != "" ? #colorLiteral(red: 1, green: 0.5305714011, blue: 0.5702815652, alpha: 1) : .lightGray
    }
    
    private func showSearchField(){
        searchBtnOutlet.isEnabled = false
        searchBtnOutlet.backgroundColor = .lightGray
        emptyTextField()
        animatSearchOptionsIn()
        
    }
    
    // MARK: - animations
    
    private func animatSearchOptionsIn(){
        UIView.animate(withDuration: 0.5) {
            self.searchOptionView.isHidden = !self.searchOptionView.isHidden
        }
    }
    // MARK: - activity indicator
    
    private func showActivityIndicator(){
        if activityIndicator != nil{
            view.addSubview(activityIndicator!)
            activityIndicator!.startAnimating()
        }
        
        
    }
    private func hideActivityIndicator(){
        if activityIndicator != nil {
            activityIndicator!.stopAnimating()
            activityIndicator?.removeFromSuperview()
            
        }
    }
    
    // MARK: - item Detail
    
    private func showItemView(_ item: Item){
        let itemVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "itemView") as! ItemViewController
        itemVC.item = item
        self.navigationController?.pushViewController(itemVC, animated: true)
    }
    
    
    
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ItemTableViewCell
        cell.generateCell(searchResults[indexPath.row])
        return cell
    }
    
    // MARK: - UITableViewCelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        showItemView(searchResults[indexPath.row])
    }
    
    
}
extension SearchViewController: EmptyDataSetSource, EmptyDataSetDelegate {
    
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: "No items to display!")
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        return UIImage(named: "emptyData")
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: "Please Check back later!")
    }
    
    func buttonImage(forEmptyDataSet scrollView: UIScrollView, for state: UIControl.State) -> UIImage? {
        
        UIImage(named: "Search")
        
    }
    
    func buttonTitle(forEmptyDataSet scrollView: UIScrollView, for state: UIControl.State) -> NSAttributedString? {
        return NSAttributedString(string: "Start Searching...")
    }
    
    func emptyDataSet(_ scrollView: UIScrollView, didTapButton button: UIButton) {
        showSearchField()
    }
    
}
