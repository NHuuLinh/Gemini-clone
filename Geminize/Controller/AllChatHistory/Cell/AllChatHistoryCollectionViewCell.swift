//
//  AllChatHistoryCollectionViewCell.swift
//  Geminize
//
//  Created by Huu Linh Nguyen on 15/4/25.
//

import UIKit

class AllChatHistoryCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var chatTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func bindData(data: UserChatHistories){
        chatTitle.text = data.idChat
        print("data:\(data)")
    }

}
