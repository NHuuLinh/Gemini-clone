//
//  ShowLoading and Aleart.swift
//  Pods
//
//  Created by Huu Linh Nguyen on 6/4/25.
//


import Foundation
import MBProgressHUD

extension UIViewController {
    //show loading
    func showLoading(isShow: Bool) {
        if isShow {
            let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
            hud.label.text = "Loading"
        } else {
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
    // showAleart và thêm hành động ok
    func showAlert(title: String, message: String, completionHandler: (()->Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { _ in
            completionHandler?()
        }
        alert.addAction(action)
        self.present(alert, animated: true)
    }
    
    // showAleart và thêm hành động khi người dùng muốn thay đổi ngôn ngữ của app
    func showAlertAndAction(title: String, message: String, completionHandler: (() -> Void)? = nil, cancelHandler: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        // Thêm nút "OK" và hành động khi nhấn vào
        let okAction = UIAlertAction(title: "OK", style: .destructive) { _ in
            completionHandler?()
        }
        alert.addAction(okAction)

        // Thêm nút "Cancel" và hành động khi nhấn vào
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            cancelHandler?()
        }
        alert.addAction(cancelAction)

        // Hiển thị hộp thoại
        self.present(alert, animated: true)
    }

}
