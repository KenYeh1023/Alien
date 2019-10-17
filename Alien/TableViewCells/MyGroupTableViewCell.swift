//
//  MyGroupTableViewCell.swift
//  Alien
//
//  Created by Ken Yeh on 2019/9/10.
//  Copyright © 2019 Ken Yeh. All rights reserved.
//

import UIKit

class MyGroupTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var myGroupTitle: UILabel!
    
    @IBOutlet weak var myGroupGameName: UILabel!
    
    @IBOutlet weak var myGroupActivityTime: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    
}
