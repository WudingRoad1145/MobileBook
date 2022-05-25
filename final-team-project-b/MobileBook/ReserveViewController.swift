//
//  ReserveViewController.swift
//  MobileBook
//
//  Created by Tingnan Hu  on 2022/4/1.
//

import UIKit
import Foundation

class ReserveViewController: UIViewController {
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var reserveTimePicker: UIDatePicker!
    @IBOutlet weak var dateShow: UILabel!
    @IBOutlet weak var bookImage: UIImageView!
    @IBOutlet weak var bookInfo: UILabel!
    
    @IBAction func pickDate(_ sender: Any) {
        let dateFormatter = DateFormatter()

            dateFormatter.dateStyle = DateFormatter.Style.short
            dateFormatter.timeStyle = DateFormatter.Style.short

            let strDate = dateFormatter.string(from: reserveTimePicker.date)
            dateShow.text = String("The time you have picked is: ") + strDate
    }
    
    
    @IBAction func didTapButton(_ sender: Any) {
        // create the alert
        let alert = UIAlertController(title: "My Title", message: "You have seccussefully reserved the book!", preferredStyle: .alert)

                // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))

                // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        confirmButton.setTitle("confirm", for: .normal)

        // Do any additional setup after loading the view.
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
