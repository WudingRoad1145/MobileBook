//
//  ListViewController.swift
//  MobileBook
//
//  Created by Yan on 4/19/22.
//


import UIKit
import FirebaseFirestore

class ListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let tableView = UITableView()
    var service: bookQuery?
    var allBooks = [books]() {
        didSet {
            DispatchQueue.main.async { [self] in
                varBooks = self.allBooks
            }
        }
    }
    
    var varBooks = [books]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
  
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        tableView.dataSource = self
        tableView.delegate = self
        service = bookQuery()
        service?.get(collectionID: "books") { [self] varBooks in
            self.allBooks = varBooks
        }
    }

    func setupTableView() {
        view.addSubview(tableView)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.allowsSelection = true
        tableView.isUserInteractionEnabled = true
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return varBooks.count
        }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
          let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
          cell.accessoryType = .disclosureIndicator
          cell.textLabel?.text = varBooks[indexPath.row].name
          cell.textLabel?.font = .systemFont(ofSize: 20, weight: .medium)
          cell.detailTextLabel?.text = varBooks[indexPath.row].author
            //print(varBooks[indexPath.row].coord ?? (Any).self)
          return cell
      }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
           let vc = storyboard?.instantiateViewController(withIdentifier: "pickVC") as? PickViewController
        vc?.vcbookName = varBooks[indexPath.row].name!
        vc?.vcyear = varBooks[indexPath.row].year!
        vc?.vcauthor = varBooks[indexPath.row].author!
        /*
        vc?.titleLabel?.text = varBooks[indexPath.row].name ?? ""
        vc?.authorLabel?.text = varBooks[indexPath.row].author ?? ""
        vc?.descriptionLabel?.text = String(varBooks[indexPath.row].year!)
         */
           navigationController?.pushViewController(vc!, animated: true)
    }
}




