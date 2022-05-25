//
//  InputViewController.swift
//  MobileBook
//
//  Created by Ada Zhang on 2022/4/2.
//

import UIKit
import Foundation
import CoreLocation
import Firebase
import FirebaseAuth
import FirebaseFirestore

class InputViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var inputName: UITextField!
    @IBOutlet weak var inputAuthor: UITextField!
    @IBOutlet weak var inputYear: UITextField!
    @IBOutlet weak var inputDescription: UITextField!
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var field: UITextField!
    
    var userId = Auth.auth().currentUser?.uid
    
    var targetCoord: CLLocationCoordinate2D?
    static var bookNameGlobal = ""
    
    struct userInput{
        var name, author, year, review: String
        //var image: UIIamge
    }
    
    // var inputArray = [userInput]()
    var input = userInput(name: "", author: "", year:"", review:"")
    var books = [Info]()
    
    struct ImageLinks: Codable {
        let smallThumbnail, thumbnail: String
    }
    
    struct IndustryIdentifier: Codable {
        let type, identifier: String
    }
    
    struct PanelizationSummary: Codable {
        let containsEpubBubbles, containsImageBubbles: Bool
    }
    
    @IBAction func dismiss(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        inputName.delegate = self
        inputAuthor.delegate = self
        inputYear.delegate = self
        inputDescription.delegate = self
        
        backButton.setTitle("Back", for: .normal)
        table.register(BookTableViewCell.nib(), forCellReuseIdentifier: BookTableViewCell.identifier)
        table.delegate = self
        table.dataSource = self
        field.delegate = self
        // Do any additional setup after loading the view.
        
        dump(targetCoord as Any)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func confirmTapped(_ sender: Any) {
        let bookName = inputName.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let db = Firestore.firestore()
        if targetCoord?.latitude != nil {
        db.collection("books").document(bookName).setData(["bookName":"test","dropOffLoc":[targetCoord!.latitude,targetCoord!.longitude]],merge: true)
        }else{
            db.collection("books").document(bookName).setData(["bookName":"test"],merge: true)
        }
        InputViewController.bookNameGlobal = bookName
        print(InputViewController.bookNameGlobal)
    }
    
    
    @IBAction func enterTapped(_ sender: Any) {
//        textView.text = "Book Name: \(inputName.text!)\nBook Author: \(inputAuthor.text!)\nProduction Year: \(inputYear.text!)\nAbout: \(inputDescription.text!)"
        let input = userInput(name: inputName.text!.trimmingCharacters(in: .whitespacesAndNewlines), author: inputAuthor.text!.trimmingCharacters(in: .whitespacesAndNewlines), year:inputYear.text!.trimmingCharacters(in: .whitespacesAndNewlines), review:inputDescription.text!.trimmingCharacters(in: .whitespacesAndNewlines))
        //inputArray.append(newInput)
//        textView.text = inputArray[0].review + inputArray[0].name
        print(input.name)
        print(input.author)
        print(input.self)
        
        
        let db = Firestore.firestore()
        //db.collection("books").document(bookName).setData(["bookName":"test", "author":input.author, "year": input.year,"dropOffLoc":targetCoord!],merge: true)
        db.collection("books").document(input.name).setData(["bookName":input.name, "author":input.author, "year": input.year],merge: true){(error) in
            
            if error != nil{
                //show error message
                print("error saving book data ")
            }
        }
        // upload review
        db.collection("books").document(input.name).collection("reviews").document(userId ?? "user").setData(["review":input.review,"time":DateFormatter().string(from:Date())], merge: true){(error) in
            
            if error != nil{
                //show error message
                print("error saving review data ")
            }
        }
        
        db.collection("users").document(userId ?? "user").collection("reviews").document(input.name).setData(["book":input.name,"review":input.review,"time":DateFormatter().string(from:Date())], merge: true){(error) in
            
            if error != nil{
                //show error message
                print("error saving review data ")
            }
        }

    }
    
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
//        print(segue.identifier!)
//        if segue.identifier == "BackToMap" {
//            let destVC2 = segue.destination as! homePageViewController
//            destVC2.name = input.name
//            destVC2.author = input.author
//        } else if segue.identifier == "EnterBookInfo" {
//            let destVC = segue.destination as! DropViewController
//            destVC.bookName = input.name
//        }
    }
     
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        inputYear.resignFirstResponder()
    }
    
    override func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            searchBooks()
            return true
    }
    
    func searchBooks() {
            field.resignFirstResponder()
            guard let text = field.text, !text.isEmpty else{
                return
            }
            
            let query = text.replacingOccurrences(of: " ", with: "%20")
            
            books.removeAll()
            
            URLSession.shared.dataTask(with: URL(string: "https://www.googleapis.com/books/v1/volumes?q=\(query)&key=AIzaSyCjevbu1d1pbMHOk9IWc1y2bICtva53M0Q")!, completionHandler: { data, response, error in
                guard let data = data, error == nil else {
                    return
                }
                
                var result: BookResult?
                do{
                    result = try JSONDecoder().decode(BookResult.self, from: data)
                }
                catch{
                    DispatchQueue.main.async {
                                       let alert = UIAlertController(title: "JSON Decode Error - ", message: "\(error)", preferredStyle: .alert)
                                       alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                       self.present(alert, animated: true)
                                   }
                }
                guard let finalResult = result else{
                    return
                }
                
                let newBooks = finalResult.items
                self.books.append(contentsOf: newBooks)
                
                DispatchQueue.main.async {
                    self.table.reloadData()
                }
                
            }).resume()
        }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return books.count
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: BookTableViewCell.identifier, for: indexPath) as! BookTableViewCell
        cell.configure(with: books[indexPath.row])
        return cell
    }
        
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    

}

struct BookResult: Codable {
    let items: [Info]
}

struct Info: Codable {
    let volumeInfo: Welcome
}

struct Item: Codable {
    let item: [Info]
}

// MARK: - Welcome
struct Welcome: Codable {
    let title, publishedDate: String
    //let description: String
    let authors: [String]
    /*let industryIdentifiers: [IndustryIdentifier]
    let readingModes: ReadingModes
    let pageCount: Int
    let printType: String
    let categories: [String]
    let ratingsCount: Int
    let averageRating: Double
    let maturityRating: String
    let allowAnonLogging: Bool
    let contentVersion: String
    let panelizationSummary: PanelizationSummary
    let previewLink, infoLink: String
    let canonicalVolumeLink: String
    let imageLinks: ImageLinks*/
    let language: String
    

//    enum CodingKeys: String, CodingKey {
//        case title, publishedDate
//        case description = "description"
//        case language
//        case industryIdentifiers, readingModes, pageCount, printType, maturityRating, allowAnonLogging, contentVersion, panelizationSummary, imageLinks, language, previewLink, infoLink, canonicalVolumeLink
//    }
}

// MARK: - ImageLinks
struct ImageLinks: Codable {
    let smallThumbnail, thumbnail: String
}

// MARK: - IndustryIdentifier
struct IndustryIdentifier: Codable {
    let type, identifier: String
}

// MARK: - PanelizationSummary
struct PanelizationSummary: Codable {
    let containsEpubBubbles, containsImageBubbles: Bool
}

// MARK: - ReadingModes
struct ReadingModes: Codable {
    let text, image: Bool
}


extension UIViewController: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
