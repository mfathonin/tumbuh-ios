//
//  DetailVC.swift
//  tumbuh
//
//  Created by Fathoni on 28/04/22.
//

import UIKit

class DetailVC: UIViewController {
    @IBOutlet weak var transactionTableView: UITableView!
    var sections = [GroupedSection<Date, TransactionModel>]()
    var trasactionList: [TransactionModel] = [TransactionModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        trasactionList = TransactionRepository.instance.getTransactionList()
        registerCell()
        updateSectionList(transactionList: self.trasactionList)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupNavigationBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.updateTableViewData()
    }

    func updateSectionList(transactionList: [TransactionModel]) {
        self.sections = GroupedSection.group(rows: transactionList, by: {
            firstDayOfMonth(date: $0.createdAt)
        })
        self.sections.sort { lhs, rhs in
            lhs.sectionItem > rhs.sectionItem
        }
    }
    
    func updateTableViewData() {
        self.trasactionList = TransactionRepository.instance.getTransactionList()
        self.updateSectionList(transactionList: self.trasactionList)
        self.transactionTableView.reloadData()
    }
    
    func registerCell() {
        transactionTableView.register(UINib(nibName: "DetailItemCell", bundle: nil), forCellReuseIdentifier: "detailItemCellId")
    }
    
    func setupNavigationBar() {
        // Add and Settings button for Right barButtonItems
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))

        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.tabBarController?.navigationItem.title = "Detail Transaction"
        self.tabBarController?.navigationItem.leftBarButtonItems = []
        self.tabBarController?.navigationItem.rightBarButtonItems = [addButton]
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.hidesBarsOnSwipe = false
    }

    // MARK: Navigation
    @objc func addTapped() {
        print("AddTapped")
        performSegue(withIdentifier: "addTransactionMd", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addTransactionMd" {
            let destinationVC = segue.destination as! AddTransactionVC
            destinationVC.delegate = self
        }
    }
}

extension DetailVC: AddTransactionDelegate {
    func addTransaction(transaction: TransactionModel) {
        self.dismiss(animated: true) {
            self.updateTableViewData()
            
        }
    }
}

extension DetailVC: UITableViewDelegate {
}

extension DetailVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        22 + 16
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = self.sections[section]
        let date = section.sectionItem
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        
        return dateFormatter.string(from: date)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sections[section].rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = (tableView.dequeueReusableCell(withIdentifier: "detailItemCellId", for: indexPath) as? DetailItemCell)!
        
        let section = self.sections[indexPath.section]
        let transaction = section.rows[indexPath.row]
        
        cell.title.text = transaction.category.name
        cell.subtitle.text = transaction.desc
        let amountTransaction = transaction.amount
        cell.detailLabel.text = amountFormater(amount: CGFloat(amountTransaction), short: false)
        
        if amountTransaction > 0 {
            cell.detailLabel.textColor = UIColor(named: "primary")
        } else {
            cell.detailLabel.textColor = UIColor(named: "error")
        }
        
        return cell
    }
    
    
}
