//
//  IncognitoMessageHeaderViewController.swift
//  ColorNoteRemake
//
//  Created by LinhMAC on 30/07/2024.
//

import UIKit

class MenuViewController: UIViewController {
    
    @IBOutlet weak var menuBtn: UIButton!
    var didSelectBtn: ((Bool)-> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func buttonHandle(_ sender: UIButton) {
        switch sender {
        case menuBtn :
            print("menuBtn")
            menuBtn.isSelected.toggle()
            didSelectBtn?(menuBtn.isSelected)
        default:
            break
        }
    }
}
