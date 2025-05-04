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
    private let allChatSubview = UIView()
    private let headderBar = UIView()
    private var messagesLeadingConstraint: NSLayoutConstraint!
    private let menuPercent: CGFloat = 4
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.startNewChat()
        setupCustomConstraints()
        addHeadderBar()
    }
    
    override func viewIsAppearing(_ animated: Bool) {

    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = true
        registerDelegte()
        loadChatHistory()
    }
    
    private func setupCustomConstraints() {
        messagesCollectionView.translatesAutoresizingMaskIntoConstraints = false
        messagesLeadingConstraint = messagesCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0)
        NSLayoutConstraint.activate([
            messagesCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            messagesCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            messagesCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            messagesLeadingConstraint
        ])
        print("setupCustomConstraints")
    }
    @objc func textFieldDidChange(_ textField: UITextField) {
        messageInputBar.inputTextView.text = textField.text
        print("Text changed: \(textField.text ?? "")")
    }
    func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {
    }
    
    func loadChatHistory(){
        viewModel.getAllChatData { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case .success:
                self.handlerChatHistoryData()
            case .outOfData:
                print("UnknowError")
                self.handlerChatHistoryData()
                print("sd")
            case .failure(let error):
                self.showAlert(title: "error", message: error)
            case .unKnowError:
                print("UnknowError")
                self.showAlert(title: "error", message: "UnknowError")
            }
        }
    }
    func addHeadderBar(){
        view.addSubview(headderBar)
        headderBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            headderBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headderBar.bottomAnchor.constraint(equalTo: messagesCollectionView.topAnchor, constant: 0),
            headderBar.trailingAnchor.constraint(equalTo: messagesCollectionView.trailingAnchor),
            headderBar.leadingAnchor.constraint(equalTo: messagesCollectionView.leadingAnchor)
        ])
        
        let childVC = MenuViewController()
        addChild(childVC)
        headderBar.addSubview(childVC.view)
        childVC.didSelectBtn = { [weak self] isSelected in
            guard let self = self else {return}
            UIView.animate(withDuration: 0.3) {
                self.messagesLeadingConstraint.constant = isSelected ? (self.view.bounds.width / self.menuPercent) : 0.1
                self.messagesLeadingConstraint.isActive = true
                self.view.layoutIfNeeded()
            }
        }
//        childVC.view.frame = userSubview.bounds
        childVC.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            childVC.view.topAnchor.constraint(equalTo: headderBar.topAnchor),
            childVC.view.bottomAnchor.constraint(equalTo: headderBar.bottomAnchor),
            childVC.view.leadingAnchor.constraint(equalTo: headderBar.leadingAnchor),
            childVC.view.trailingAnchor.constraint(equalTo: headderBar.trailingAnchor)
        ])

        childVC.didMove(toParent: self)
        view.addSubview(allChatSubview)
        allChatSubviewHandle()
        print("addHeadderBar")

    }
    func allChatSubviewHandle(){
        allChatSubview.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            allChatSubview.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            allChatSubview.bottomAnchor.constraint(equalTo: messagesCollectionView.bottomAnchor),
            allChatSubview.trailingAnchor.constraint(equalTo: messagesCollectionView.leadingAnchor),
            allChatSubview.widthAnchor.constraint(equalToConstant: view.bounds.width/menuPercent)
        ])
        let childVC = AllChatHistoryViewController()
        childVC.didSelectChatHistory = { [weak self] idChat in
            guard let self = self else {return}
            self.viewModel.idChat = idChat
            self.loadChatHistory()
        }
        addChild(childVC)
        allChatSubview.addSubview(childVC.view)
        childVC.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            childVC.view.topAnchor.constraint(equalTo: allChatSubview.topAnchor),
            childVC.view.bottomAnchor.constraint(equalTo: allChatSubview.bottomAnchor),
            childVC.view.leadingAnchor.constraint(equalTo: allChatSubview.leadingAnchor),
            childVC.view.trailingAnchor.constraint(equalTo: allChatSubview.trailingAnchor)
        ])
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





