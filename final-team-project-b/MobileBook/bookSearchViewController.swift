//
//  bookSearchViewController.swift
//  MobileBook
//
//  Created by 丁予哲 on 3/30/22.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class bookSearchViewController: UIViewController {
    @Published var books = [Book]()
    
    @IBOutlet var booktable: UITableView!
    
    let names = ["Sdsdf", "Gghjjt", "Gbtiuj", "Bekjjb", "Ouijphrt"]
    let authors = ["Hdgfjk Gdfk", "Fkdj ifperoj", "Vhcjdl cdjcl", "Thjc sdfjk", "Tdef rkkv"]
    var filteredNames: [String] = []
    var filteredAuthors: [String] = []
    
    var isFiltering: Bool {
        return searchController.isActive && !isSearchBarEmpty
    }
    var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Books"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        booktable.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let indexPath = booktable.indexPathForSelectedRow {
            booktable.deselectRow(at: indexPath, animated: true)
        }
    }

    func filterContentForSearchText(_ searchText: String) {
        filteredNames = []
        filteredAuthors = []
        for (n, author) in zip(names, authors) {
            if n.lowercased().contains(searchText.lowercased()) || author.lowercased().contains(searchText.lowercased()) {
                filteredNames.append(n)
                filteredAuthors.append(author)
            }
        }
        
        booktable.reloadData()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension bookSearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        filterContentForSearchText(searchBar.text!)
    }
}

extension bookSearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView,
                 numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filteredNames.count
        }
        return names.count
    }

    func tableView(_ tableView: UITableView,
                 cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "bookCell",
                                                 for: indexPath) as! bookTableViewCell
        let db = Firestore.firestore()
        let bookDB = db.collection("books")
        
        bookDB.addSnapshotListener{ [weak self] snapshot, error in
            guard let documents = snapshot?.documents, error == nil else{
                print("Error fetching document: \(error!)")
                return
            }
            self?.books = documents.compactMap{(booksSnapshot) -> Book? in
                let data = booksSnapshot.data()
                let name = data["bookName"] as? String ?? ""
                let author = data["author"] as? String ?? ""
                let year = data["year"] as? String ?? ""
                return Book(name:name,author:author,year:year)
            }
        }
        
        
        let name: String
        let author: String
        if isFiltering {
            name = filteredNames[indexPath.row]
            author = filteredAuthors[indexPath.row]
        } else {
            name = names[indexPath.row]
            author = authors[indexPath.row]
        }
        
        cell.bookName.text = name
        cell.bookAuthor.text = author
        return cell
    }
}


class bookTableViewCell: UITableViewCell {

    @IBOutlet var bookName: UILabel!
    @IBOutlet var bookAuthor: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func reserveTapped(_ sender: Any) {
    }
}
