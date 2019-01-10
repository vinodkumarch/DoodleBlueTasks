//
//  CustomCell.swift
//  Demo
//
//  Created by MXMACMINI1 on 10/01/19.
//  Copyright © 2019 MB. All rights reserved.
//

import UIKit

class CustomCell: UITableViewCell {

    @IBOutlet weak var images: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
