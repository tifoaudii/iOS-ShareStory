//
//  ChatCell.swift
//  ShareStory
//
//  Created by Tifo Audi Alif Putra on 02/11/19.
//  Copyright © 2019 BCC FILKOM. All rights reserved.
//

import UIKit

class SenderKonselorChatCell: UITableViewCell {

    @IBOutlet weak var messageLabel: ChatLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setupCell(message: String) {
        self.messageLabel.text = message
    }
}
