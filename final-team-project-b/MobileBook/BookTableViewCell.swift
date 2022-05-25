//
//  BookTableViewCell.swift
//  MobileBook
//
//  Created by Ada Zhang on 2022/4/13.
//

import UIKit

class BookTableViewCell: UITableViewCell {

    @IBOutlet var bookTitle: UILabel!
    @IBOutlet var bookAuth: UILabel!
    @IBOutlet var bookReview: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    static let identifier = "BookTableViewCell"
    
    static func nib() -> UINib{
        return UINib(nibName: "BookTableViewCell", bundle: nil)
    }
    
    func configure(with model: Info) {
        self.bookTitle.text = model.volumeInfo.title
        self.bookAuth.text = model.volumeInfo.language
        self.bookReview.text = model.volumeInfo.authors[0]
    }
    
}
