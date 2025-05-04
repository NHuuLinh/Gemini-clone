//
//  IncognitoMessageHeaderViewController.swift
//  ColorNoteRemake
//
//  Created by LinhMAC on 30/07/2024.
//

import UIKit

class MenuViewController: UIViewController {
    
    @IBOutlet weak var menuBtn: UIButton!
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    var didSelectBtn: ((Bool)-> Void)?
    var menuSize :CGFloat = 0

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        leadingConstraint.constant = 0
    }

    @IBAction func buttonHandle(_ sender: UIButton) {
        switch sender {
        case menuBtn :
            print("menuBtn")
            menuBtn.isSelected.toggle()
            didSelectBtn?(menuBtn.isSelected)
            animationBtn()
            print("leadingConstraint:\(leadingConstraint.constant)")

        default:
            break
        }
    }
    func animationBtn(){
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else {return}
            leadingConstraint.constant = menuBtn.isSelected ? menuSize : 0
            view.layoutIfNeeded()
        }
    }
}
