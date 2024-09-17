//
//  FlagsTableViewCell.swift
//  Pingtype
//
//  Created by Peter Burkimsher on 24/02/24.
//

import Foundation
import UIKit

class FlagsTableViewCell: UITableViewCell {

    @IBOutlet weak var imgMain: UIImageView!
    @IBOutlet weak var lblMain: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        //imgMain.layer.cornerRadius = 5.0
        //imgMain.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureCell(image: UIImage, text: String){
        imgMain.image = image
        lblMain.text = text
    }

}
