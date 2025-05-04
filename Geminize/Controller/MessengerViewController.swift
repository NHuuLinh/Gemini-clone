//
//  MainViewController.swift
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
    let downloadImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 400, height: 400))

    override func viewDidLoad() {
        super.viewDidLoad()
        loadChatHistory()
        registerDelegte()
        subviewHandle()
        viewModel.startNewChat()

    }
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }
    @objc func textFieldDidChange(_ textField: UITextField) {
        messageInputBar.inputTextView.text = textField.text
        print("Text changed: \(textField.text ?? "")")
    }
    func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {
    }
    
    func loadChatHistory(){
        showLoading(isShow: true)
        viewModel.getAllChatData { [weak self] result in
            guard let self = self else {
                self?.showLoading(isShow: false)
                return
            }
            self.showLoading(isShow: false)
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
    func handlerChatHistoryData() {
        let datas = viewModel.chatHistory
        guard datas.count > 0 else {return}
        for data in datas {
            let messageText = data.text.decode()
            if data.type == TypeMessage.image.rawValue {
                print("xử lí image")
            } else {
                let newMessage = Message(sender: Sender(senderId: data.role, displayName: data.role),
                                             messageId: "",
                                         sentDate: Date(),
                                             kind: .text(messageText))
                    self.messages.insert(newMessage, at: 0)
//                }

            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                self.messagesCollectionView.reloadData()
                self.messagesCollectionView.scrollToLastItem(animated: false)
                self.isLoadingMoreData = false
        })
    }

    func downloadImage(imageUrl: String?, hander: @escaping ((UIImage) -> ())){
        let imageUrl = URL(string: imageUrl ?? "")
        let defaultImage = UIImage(named: "screen-image-error")!
        downloadImage.kf.setImage(with: imageUrl, placeholder: defaultImage , options: nil, completionHandler: { result in
            switch result {
            case .success(_):
                // Ảnh đã tải thành công
                print("downloadImage success")
                hander(self.downloadImage.image ?? defaultImage)
                break
            case .failure(_):
                // Xảy ra lỗi khi tải ảnh
                self.downloadImage.image = defaultImage
                hander(defaultImage)
            }
        })
    }
    func subviewHandle(){
//        var safeAreaHeight : CGFloat
//        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
//            if let window = windowScene.windows.first {
//                safeAreaHeight = window.safeAreaInsets.top// + window.safeAreaInsets.bottom
//                print("Chiều cao của safe area: \(safeAreaHeight)")
//            } else {
//                safeAreaHeight = 60
//                print("Không thể lấy được window")
//            }
//        } else {
//            safeAreaHeight = 60
//            print("Không thể lấy được window scene")
//        }
//        let height = 50 + safeAreaHeight
//        let userSubview = UIView()
//        view.addSubview(userSubview)
//        userSubview.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: height)
//        messagesCollectionView.contentInset.top = userSubview.frame.height
//
//        let childVC = IncognitoMessageHeaderViewController()
//        addChild(childVC)
//        childVC.bindData(userID: viewModel.otherUserId)
//        childVC.didSelectBtn = { [weak self] in
//            guard let self = self else {return}
//            self.routoInfoVC()
////            self.showAlert(title: "Notice", message: "This feature will be added later.")
//        }
//        userSubview.addSubview(childVC.view)
//        childVC.view.frame = userSubview.bounds
//        childVC.didMove(toParent: self)
    }
    
    func routoInfoVC(){
//        let vc = IncognitoInfoViewController()
//        vc.idRoom = viewModel.idRoom
//        vc.otherUserId = viewModel.otherUserId
//        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension MessengerViewController: AvatarConfigurationDelegate {

    func loadMoreData() {
//        if !viewModel.isFirstFetchData {
//            guard !viewModel.isMaxData else {
//                print("đã hết data để Refesh")
//                messagesCollectionView.bounces = false
//                return}
//            DispatchQueue.main.async {
//                self.loadChatHistory()
//            }
//        }
    }
    
    func endEdit() {
        messageInputBar.inputTextView.resignFirstResponder()
    }
}
extension MessengerViewController: MessageInputButtonViewDelegate, InputBarAccessoryViewDelegate{

    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith attachments: [AttachmentManager.Attachment], text: String) {
        for item in attachments {
            if case .image(let uIImage) = item {
                handleImageMessage(image: uIImage)
                handleTextMessage(text: text)
                print("có image")
                guard let imageData = uIImage.jpegData(compressionQuality: 0.5) else {
                    print("Failed to convert image to data")
                    return
                }
                Task {
                    let response = await viewModel.sendMessageWithImage(prompt: text, imageData: imageData)
                    print("AI response: \(response)")
                    self.handleModelTextMessage(text: response)
//                    self.handleImageMessage(imageString: response)
                }
            } else {
                print("inputBar khoong co image")
            }
        }
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
        for item in attachments {
            if case .image(let uIImage) = item {
                handleImageMessage(image: uIImage)

                print("có image")
                guard let imageData = uIImage.jpegData(compressionQuality: 0.5) else {
                    print("Failed to convert image to data")
                    return
                }
                Task {
                    let response = await viewModel.sendMessageWithImage(prompt: "trong ảnh có gì", imageData: imageData)
                    print("AI response: \(response)")
                    self.handleModelTextMessage(text: response)
//                    self.handleImageMessage(imageString: response)
                }
            } else {
                print("inputBar khoong co image")
            }
        }
        inputBar.invalidatePlugins()
    }
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else {return}
        handleTextMessage(text: text)
        print("khoong co image")
        Task {
            let response = await viewModel.sendMessage(prompt: trimmedText)
            print("AI response: \(response)")
            // ví dụ: thêm vào giao diện chat
            self.handleModelTextMessage(text: response)

        }
    }

}





