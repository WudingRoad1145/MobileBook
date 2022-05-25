//
//  DropViewController.swift
//  MobileBook
//
//  Created by Ada Zhang on 2022/3/31.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import CoreLocation

class DropViewController: UIViewController {
    var targetCoord: CLLocationCoordinate2D?
   
    var bookName = ""
    struct nameAndTime{
        var name, time: String
    }
    
    @IBAction func storeInfo(_ sender: Any) {
        var info = nameAndTime(name: InputViewController.bookNameGlobal, time: "\(datePicker.date)")
        print(info.name)
        let db = Firestore.firestore()
        db.collection("books").document(info.name).setData(["dropOffTime":info.time],merge:true){(error) in
            
            if error != nil{
                //show error message
                print("error saving book data ")
            }
        }
    }
    @IBOutlet weak var typeButton: UIButton!
    @IBOutlet weak var myButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBAction func datePickerChanged(_ sender: Any) {
        let dateFormatter = DateFormatter()

            dateFormatter.dateStyle = DateFormatter.Style.short
            dateFormatter.timeStyle = DateFormatter.Style.short

            let strDate = dateFormatter.string(from: datePicker.date)
            dateLabel.text = String("The time you have picked is: ") + strDate
    
    }
    //let datePicker = UIDatePicker()
    
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
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //createDatePicker()
        
        dateLabel.text = String("The time you have picked is: ")
        myButton.setTitle("Confirm", for: .normal)
        typeButton.setTitle("Enter Book Info Manually", for: .normal)
        
        dump(targetCoord)
    }
    
    
    
   
    /*func createDatePicker() {
        
        textField.textAlignment = .center
        //toolbar
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        //done button
        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
        toolbar.setItems([doneBtn], animated: true)
        
        //assign toolbar
        textField.inputAccessoryView = toolbar
        
        //assign date picker to the text field
        textField.inputView = datePicker
        
        //datePicker.datePickerMode = .dateAndTime
    }
    
    @objc func donePressed() {
        
        // Formatter
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        
        textField.text = "\(datePicker.date)"
        //textField.text = formatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }*/
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let VC = segue.destination as? InputViewController, let myCoord = targetCoord {
            VC.targetCoord = myCoord
        }
    }
    

}


