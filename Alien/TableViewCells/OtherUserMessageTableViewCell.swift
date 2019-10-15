//
//  OtherUserMessageTableViewCell.swift
//  Alien
//
//  Created by Ken Yeh on 2019/10/14.
//  Copyright © 2019 Ken Yeh. All rights reserved.
//

import UIKit

class OtherUserMessageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var otherUserImageView: UIImageView!
    @IBOutlet weak var otherUserMessageLabel: UILabel!
    @IBOutlet weak var otherUserNameLabel: UILabel!
    @IBOutlet weak var timeStampLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
