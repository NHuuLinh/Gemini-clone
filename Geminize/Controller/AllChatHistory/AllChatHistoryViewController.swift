//
//  AllChatHistoryViewController.swift
//  Geminize
//
//  Created by Huu Linh Nguyen on 15/4/25.
//

import UIKit

enum Section {
    case main
}

class AllChatHistoryViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var searchText: UITextField!
    @IBOutlet weak var allChatHistoryCLV: UICollectionView!
    
    var allChatHistory = [UserChatHistories]()
    var allChatHistoryFilter = [UserChatHistories]()

    var dataSource : UICollectionViewDiffableDataSource<Section, UserChatHistories>?
    var timer : Timer?
    var didSelectChatHistory : ((String)-> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        loadMessages()
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        customTextField()
    }
    @IBAction func textDidChange(_ sender: Any) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(filterChat), userInfo: searchText.text, repeats: false)
//        RealmManager.shared.createNewChatSession()
    }
    func customTextField(){
        searchText.attributedPlaceholder = NSAttributedString(string: "Tìm kiếm", attributes: [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 16)
        ])
        if let clearBtn = searchText.value(forKey: "_clearButton") as? UIButton {
            clearBtn.setImage(UIImage(systemName: "xmark.circle.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
        }
    }
    func loadMessages() {
        self.allChatHistory = RealmManager.shared.loadAllChat()
        self.allChatHistoryFilter = RealmManager.shared.loadAllChat()
        print("RealmManager.shared.loadAllChat():\(RealmManager.shared.loadAllChat())")
        applySnapshot()
    }
    @objc func filterChat(){
        let keyword = timer?.userInfo as? String ?? ""
        if keyword.isEmpty {
            self.allChatHistory = allChatHistoryFilter
            applySnapshot()
        } else {
            self.allChatHistory = allChatHistoryFilter.filter({ userChatHistory in
                userChatHistory.idChat.localizedCaseInsensitiveContains(keyword) ||
                userChatHistory.chatHistories.contains(where: { message in
                    (message.message?.localizedCaseInsensitiveContains(keyword) ?? false)
                })
            })
            applySnapshot()
        }
    }
    


}
extension AllChatHistoryViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func setupCollectionView(){
        let nib = UINib(nibName: "AllChatHistoryCollectionViewCell", bundle: nil)
        allChatHistoryCLV.delegate = self
//        allChatHistoryCLV.dataSource = dataSource
        allChatHistoryCLV.register(nib, forCellWithReuseIdentifier: "AllChatHistoryCollectionViewCell")
        dataSource = UICollectionViewDiffableDataSource<Section, UserChatHistories>(collectionView: allChatHistoryCLV) { collectionView, indexPath, data in
            collectionView.contentInset = .zero
            collectionView.scrollIndicatorInsets = .zero
            collectionView.contentOffset = CGPoint(x: 0, y: 0)
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AllChatHistoryCollectionViewCell", for: indexPath) as! AllChatHistoryCollectionViewCell
            cell.bindData(data: data)
            return cell
        }
    }
    func applySnapshot(animation: Bool = true){
        var snapShot = NSDiffableDataSourceSnapshot<Section, UserChatHistories>()
        snapShot.appendSections([.main])
        snapShot.appendItems(allChatHistory)
        dataSource?.apply(snapShot,animatingDifferences: animation)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSizeMake(collectionView.bounds.width, 20)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let idChat = allChatHistory[indexPath.row].idChat
        didSelectChatHistory?(idChat)
        print("load du lieu tro truyen cu")
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}
