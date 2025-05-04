//
//  IncognitoMessageViewModel.swift
//  Geminize
//
//  Created by Huu Linh Nguyen on 28/07/2024.
//

import Foundation
import Alamofire
import RealmSwift
import GoogleGenerativeAI


final class MessageViewModel {
    //MARK: - Enum
    enum fetchDataResults {
        case success
        case failure(String)
        case unKnowError
        case outOfData
    }
    //MARK: - Properties
    var userID = UserInfo.shared.getUserID()
    var currentUser = Sender(senderId: UserInfo.shared.getUserID() ?? "", displayName: UserInfo.shared.getUserFullName() ?? "")
    //A57E317B-E809-4387-8578-9B47C8480ABF
    var idChat = ""
    var isFirstChat = true
    var chatHistory = [ChatMessage]()
    private var model: GenerativeModel
    private var chat: Chat
    private var chatTask: Task<Void, Never>?
    private let realmManager = RealmManager.shared
    init() {
        model = GenerativeModel(name: "gemini-2.0-flash", apiKey: "AIzaSyAZvvxT5xPNyiFTg4abQXVrXJZo5RIfbRU")
        chat = model.startChat()
    }

    
    //MARK: - Lấy lịch sử chat
    func getAllChatData(handler: @escaping ((fetchDataResults) -> Void)){
        if idChat.count < 1{
            createNewConservation()
            handler(.outOfData)
            return
        } else {
            self.isFirstChat = false
            self.chatHistory = realmManager.loadMessages(of: idChat)
            print("chatHistory:\(chatHistory.count)")
            handler(.success)
        }
    }

    func sendMessage(prompt: String) async -> String {
        do {
            let response = try await chat.sendMessage(prompt)
            if let text = response.text {
                saveChatHistory(sender: Role.model,message: text)
                return text
            } else {
                return "Empty"
            }
        } catch {
            print("Error generating content: \(error)")
            return "Error"
        }
    }
    func sendMessageWithImage(prompt: String, imageData: Data) async -> String {
        let part = ModelContent(parts: [
            .data(mimetype: "image/jpeg", imageData),
            .text(prompt)
        ])

        do {
            let response = try await chat.sendMessage([part])
            if let text = response.text {
                saveChatHistory(sender: Role.model,message: text)
                return text
            } else {
                return "Phản hồi trống."
            }
        } catch {
            print("Lỗi tạo nội dung với hình ảnh: \(error)")
            return "Lỗi: \(error.localizedDescription)"
        }
    }
    func startNewChat() {
        chatTask?.cancel()
        chat = model.startChat()
    }
}

//MARK: - Realm
extension MessageViewModel {
    func createNewConservation(){
            self.idChat = realmManager.createNewChatSession()
    }
    func saveChatHistory(sender:Role, message: String? = nil, image: UIImage? = nil){
        if isFirstChat {
            realmManager.saveHistoryPromt(sender: sender, message: message, image: image, idChat: idChat, isFirstChat: true)
        } else {
            realmManager.saveHistoryPromt(sender: sender, message: message, image: image, idChat: idChat)
        }
    }
    func loadImageFromRealm(imagePath:String) -> UIImage{
        guard let image = realmManager.loadImageFromPath(imagePath) else {
            return UIImage(systemName: "questionmark.circle.dashed")!
        }
        return image
    }
}
