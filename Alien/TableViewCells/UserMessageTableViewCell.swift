//
//  UserMessageTableViewCell.swift
//  Alien
//
//  Created by Ken Yeh on 2019/10/14.
//  Copyright © 2019 Ken Yeh. All rights reserved.
//

import UIKit

class UserMessageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userMessageLabel: UILabel!
    @IBOutlet weak var userTimeStampLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
