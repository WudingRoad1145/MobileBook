//
//  TableViewController.swift
//  MobileBook
//
//  Created by Ada Zhang on 2022/4/1.
//

import UIKit
import Foundation


class myCustomCell: UITableViewCell{
    @IBOutlet weak var myLabel: UILabel!
    
    
}

class TableViewController: UITableViewController {

   struct Book: Codable {
        let kind, id, etag, selfLink: String
        let volumeInfo: VolumeInfo
        let saleInfo: SaleInfo
        let accessInfo: AccessInfo
    }

    struct AccessInfo: Codable {
        let country, viewability: String
        let embeddable, publicDomain: Bool
        let textToSpeechPermission: String
        let epub, pdf: Epub
        let webReaderLink, accessViewStatus: String
        let quoteSharingAllowed: Bool
    }

    struct Epub: Codable {
        let isAvailable: Bool
    }

    struct SaleInfo: Codable {
        let country, saleability: String
        let isEbook: Bool
    }

    struct VolumeInfo: Codable {
        let title: String
        let authors: [String]
        let publisher, publishedDate, description: String
        let industryIdentifiers: [IndustryIdentifier]
        let readingModes: ReadingModes
        let pageCount, printedPageCount: Int
        let dimensions: Dimensions
        let printType: String
        let categories: [String]
        let averageRating: Double
        let ratingsCount: Int
        let maturityRating: String
        let allowAnonLogging: Bool
        let contentVersion: String
            let panelizationSummary: PanelizationSummary
            let imageLinks: ImageLinks
            let language, previewLink, infoLink, canonicalVolumeLink: String
        }

        struct Dimensions: Codable {
            let height, width, thickness: String
        }

        struct ImageLinks: Codable {
            let smallThumbnail, thumbnail: String
        }

        struct IndustryIdentifier: Codable {
            let type, identifier: String
        }

        struct PanelizationSummary: Codable {
            let containsEpubBubbles, containsImageBubbles: Bool
        }

        struct ReadingModes: Codable {
            let text, image: Bool
        }
    
    var allToDos:[VolumeInfo] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.allToDos.count
    }
    
    func getAllData() {
            
        let headers = [
         "X-RapidAPI-Host": "google-books.p.rapidapi.com",
         "X-RapidAPI-Key": "01bfc36fc3mshabb6a6ed5de8325p134522jsnb754b72c90ff"
        ]

        let request = NSMutableURLRequest(url: NSURL(string: "https://google-books.p.rapidapi.com/volumes?key=AIzaSyCjevbu1d1pbMHOk9IWc1y2bICtva53M0Q")! as URL,
                                                cachePolicy: .useProtocolCachePolicy,
                                            timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers

        let session = URLSession.shared
        
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            // ensure there is no error for this HTTP response
            guard error == nil else {
                print ("Error: \(error!)") // local console message for debug

                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Error - ", message: "\(error!)", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true)
                }
                 
                return
            }
            
            // check response code
            
            // ensure there is data returned from this HTTP response
            guard let jsonData = data else {
                print("No data")
                return
            }

            do {
//                self.allTodos = Array(try JSONDecoder().decode(Book.self, from: jsonData).VolumeInfo[0..<50])
                self.allToDos = try JSONDecoder().decode([VolumeInfo].self, from: jsonData)

                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }

            } catch {
                DispatchQueue.main.async {
                   let alert = UIAlertController(title: "JSON Decode Error - ", message: "\(error)", preferredStyle: .alert)
                   alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                   self.present(alert, animated: true)
               }
            }
        })
        
        dataTask.resume()
        
        }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "My Cell", for: indexPath) as! myCustomCell
        
        cell.myLabel.text = allToDos[indexPath.row].title
        // Configure the cell...

        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
