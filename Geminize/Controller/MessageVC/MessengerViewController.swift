//
//  MessengerViewController.swift
//  ColorNoteRemake
//
//  Created by LinhMAC on 01/08/2024.
//

import UIKit
import MessageKit
import InputBarAccessoryView

class MessengerViewController: BaseMessageViewController{
    
    private let viewModel = MessageViewModel()
    var reloadMessage : (() -> Void)?
    private var refeshControl = UIRefreshControl()
    let menuWidth :CGFloat = 200.0
    let allChatSubview = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
    private var allChatLeadingConstraint: NSLayoutConstraint!
    private var messagesLeadingConstraint: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.startNewChat()
        setupCustomConstraints()
    }
    
    override func viewIsAppearing(_ animated: Bool) {

    }
    override func viewDidAppear(_ animated: Bool) {
//        addHeadderBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = true
        registerDelegte()
        loadChatHistory()
    }
    private func setupCustomConstraints() {
        messagesCollectionView.translatesAutoresizingMaskIntoConstraints = false
        messagesLeadingConstraint = messagesCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 500)
        messagesLeadingConstraint?.isActive = true

        NSLayoutConstraint.activate([
            messagesCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            messagesCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            messagesCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            // Không cần leading nếu bạn đặt width cố định
        ])
    }
    @objc func textFieldDidChange(_ textField: UITextField) {
        messageInputBar.inputTextView.text = textField.text
        print("Text changed: \(textField.text ?? "")")
    }
    func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {
    }
    
    func loadChatHistory(){
//        showLoading(isShow: true)
        viewModel.getAllChatData { [weak self] result in
            guard let self = self else {
//                self?.showLoading(isShow: false)
                return
            }
//            self.showLoading(isShow: false)
            switch result {
            case .success:
                self.handlerChatHistoryData()
            case .outOfData:
                print("UnknowError")
                self.handlerChatHistoryData()
                //                self.view.makeToast("All chat history loaded",duration: 5.0 ,position: .top)
                print("sd")
            case .failure(let error):
                self.showAlert(title: "error", message: error)
            case .unKnowError:
                print("UnknowError")
                self.showAlert(title: "error", message: "UnknowError")
            }
        }
    }
    func caculateSafeArea() -> CGFloat{
        var safeAreaHeight : CGFloat
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            if let window = windowScene.windows.first {
                safeAreaHeight = window.safeAreaInsets.top// + window.safeAreaInsets.bottom
                print("Chiều cao của safe area: \(safeAreaHeight)")
            } else {
                safeAreaHeight = 60
                print("Không thể lấy được window")
            }
        } else {
            safeAreaHeight = 60
            print("Không thể lấy được window scene")
        }
        let height = 40 + safeAreaHeight
        return height
    }
    func addHeadderBar(){
        let userSubview = UIView()
        view.addSubview(userSubview)
        userSubview.translatesAutoresizingMaskIntoConstraints = false
        let widthConstraint = userSubview.widthAnchor.constraint(equalToConstant: view.bounds.width)
        NSLayoutConstraint.activate([
            userSubview.topAnchor.constraint(equalTo: view.topAnchor),
            userSubview.heightAnchor.constraint(equalToConstant: caculateSafeArea()),
            userSubview.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            widthConstraint
        ])
        
        let childVC = MenuViewController()
        addChild(childVC)
        userSubview.addSubview(childVC.view)
        childVC.menuSize = menuWidth
        childVC.didSelectBtn = { [weak self] isSelected in
            guard let self = self else {return}
            UIView.animate(withDuration: 0.3) {
                self.messagesCollectionView.contentInset.left = isSelected ? self.menuWidth : 0.1
                self.allChatLeadingConstraint.constant = isSelected ? self.menuWidth : 0.1
                self.allChatLeadingConstraint.isActive = true
                self.view.layoutIfNeeded()
            }
        }
        childVC.view.frame = userSubview.bounds
        childVC.didMove(toParent: self)
        view.addSubview(allChatSubview)
        allChatSubviewHandle()
    }
    func allChatSubviewHandle(){
        allChatSubview.translatesAutoresizingMaskIntoConstraints = false
        allChatLeadingConstraint = allChatSubview.trailingAnchor.constraint(equalTo: view.leadingAnchor)
        NSLayoutConstraint.activate([
            allChatSubview.topAnchor.constraint(equalTo: view.topAnchor),
            allChatSubview.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            allChatLeadingConstraint,
            allChatSubview.widthAnchor.constraint(equalToConstant: menuWidth)
        ])
        let childVC = AllChatHistoryViewController()
        childVC.didSelectChatHistory = { [weak self] idChat in
            guard let self = self else {return}
            self.viewModel.idChat = idChat
            self.loadChatHistory()
        }
        addChild(childVC)
        allChatSubview.addSubview(childVC.view)
        childVC.view.frame = allChatSubview.bounds
        childVC.didMove(toParent: self)
    }
    func handlerChatHistoryData() {
        let datas = viewModel.chatHistory
        guard datas.count > 0 else {return}
        for data in datas {
            if let imagePath = data.imagePath {
                let image = viewModel.loadImageFromRealm(imagePath: imagePath)
                let mediaImage = ImageMediaItem(image: image)
                let newMessage = Message(sender: Sender(senderId: data.sender, displayName: data.sender),
                                         messageId: "",
                                         sentDate: Date(),
                                         kind: .photo(mediaImage))
                self.messages.insert(newMessage, at: 0)
            } else {
                let messageText = data.message?.decode() ?? ""
                let newMessage = Message(sender: Sender(senderId: data.sender, displayName: data.sender),
                                         messageId: "",
                                         sentDate: Date(),
                                         kind: .text(messageText))
                self.messages.insert(newMessage, at: 0)
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            self.messagesCollectionView.reloadData()
            self.messagesCollectionView.scrollToLastItem(animated: false)
            self.isLoadingMoreData = false
        })
    }
}

extension MessengerViewController: AvatarConfigurationDelegate {
    func loadMoreData() {
        print("load thêm lịch sử chat")
    }
    
    func endEdit() {
        messageInputBar.inputTextView.resignFirstResponder()
    }
}
extension MessengerViewController: MessageInputButtonViewDelegate, InputBarAccessoryViewDelegate{
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith attachments: [AttachmentManager.Attachment], text: String) {
        handleTextMessage(text: text)
        handleImagePromt(attachments: attachments, prompt: text)
        inputBar.invalidatePlugins()
    }
    func registerDelegte(){
        self.avatarDelegate = self
        messageInputBar = MessageInputButtonView()
        messageInputBar.delegate = self
    }
    
    func getRootVC() -> UIViewController {
        print("getRootVC")
        return self
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith attachments: [AttachmentManager.Attachment]) {
        handleImagePromt(attachments: attachments)
        inputBar.invalidatePlugins()
    }
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else {return}
        handleTextMessage(text: text)
        viewModel.saveChatHistory(sender: Role.user, message: text)
        print("khoong co image")
        Task {
            let response = await viewModel.sendMessage(prompt: trimmedText)
            print("AI response: \(response)")
            self.handleModelTextMessage(text: response)
        }
    }
    func handleImagePromt(attachments: [AttachmentManager.Attachment],prompt: String? = nil ){
        for item in attachments {
            if case .image(let uIImage) = item {
                handleImageMessage(image: uIImage)
                viewModel.saveChatHistory(sender: Role.user, message: prompt, image: uIImage)
                print("user hỏi :\(prompt ?? "") về ảnh")
                guard let imageData = uIImage.jpegData(compressionQuality: 0.5) else {
                    print("Failed to convert image to data")
                    return
                }
                Task {
                    let response = await viewModel.sendMessageWithImage(prompt: prompt ?? "trong ảnh có gì", imageData: imageData)
                    print("AI response: \(response)")
                    self.handleModelTextMessage(text: response)
                }
            } else {
                print("inputBar khoong co image")
            }
        }
    }
    
}





