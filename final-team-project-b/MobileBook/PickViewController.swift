//
//  PickViewController.swift
//  MobileBook
//
//  Created by Tingnan Hu  on 2022/4/1.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore


class PickViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var myButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    var vcbookName = "test"
    var vcauthor = ""
    var vcyear = ""
    var reviews = [String]()
    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell"/*Identifier*/, for: indexPath as IndexPath)
//     cell.textLabel?.text = animals[indexPath.row]
//        return cell
//     }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//     return animals.count
//     }
    
    // MARK: - Table view data source
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myButton.setTitle("Reserve Pick-up", for: .normal)
        
        let db = Firestore.firestore()
        let thisBookDB = db.collection("books").document(vcbookName)
        
        thisBookDB.addSnapshotListener{ snapshot, error in
            guard let documents = snapshot, error == nil else{
                print("Error fetching document: \(error!)")
                return
            }
            self.vcauthor = documents.get("author") as? String ?? ""
            self.vcyear = documents.get("year") as? String ?? ""
        }
        titleLabel.text = vcbookName
        authorLabel.text = vcauthor
        descriptionLabel.text = vcyear
        // Do any additional setup after loading the view.
            
        db.collection("books").document(vcbookName).collection("reviews").getDocuments() { (QuerySnapshot, err) in
            if let err = err {
                print("Error getting documents : \(err)")
            }
            else {
                for document in QuerySnapshot!.documents {
                    let dbReview = document.get("review") as? String ?? ""
                    //let dbTime = document.get("time") as? String ?? ""
                    //let dbUser = document.get("author") as? String ?? ""
                    print(dbReview)
                    self.reviews.append(dbReview)
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(reviews)
        return reviews.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        cell.textLabel?.text = reviews[indexPath.row]
        print("testing")
        print(reviews[indexPath.row])

        return cell
    }

    // MARK: - Table view delegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // etc
    }
}
