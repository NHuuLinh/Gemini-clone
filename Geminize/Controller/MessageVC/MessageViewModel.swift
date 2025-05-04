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
    enum fetchDataResult {
        case success
        case failure(String)
        case unKnowError
    }
    enum fetchDataResults {
        case success
        case failure(String)
        case unKnowError
        case outOfData
    }
    //MARK: - Properties
    var userID = UserInfo.shared.getUserID()
    var currentUser = Sender(senderId: UserInfo.shared.getUserID() ?? "", displayName: UserInfo.shared.getUserFullName() ?? "")
    var idChat = ""
    var chatHistory = [UserChatHistory]()
    let apiKey = "AIzaSyAZvvxT5xPNyiFTg4abQXVrXJZo5RIfbRU"
    private var model: GenerativeModel
    private var chat: Chat
    private var stopGenerating = false
    private var chatTask: Task<Void, Never>?
    init() {
        model = GenerativeModel(name: "gemini-2.0-flash", apiKey: "AIzaSyAZvvxT5xPNyiFTg4abQXVrXJZo5RIfbRU")
        chat = model.startChat()
    }

    
    //MARK: - Lấy lịch sử chat
    func getAllChatData(handler: @escaping ((fetchDataResults) -> Void)){
        guard idChat.count > 0 else {
            handler(.outOfData)
            return
        }
        do {
            let realm = try Realm()
            if let result = realm.object(ofType: UserChatHistories.self, forPrimaryKey: idChat) {
                self.chatHistory = Array(result.chatHistories)
                handler(.success)
            } else {
                handler(.outOfData)
            }
        } catch {
            handler(.failure("errror Realm: \(error.localizedDescription)"))
        }
    }
    func saveHistoryPromt(text: String, role: Role.RawValue){
        do {
            let realm = try Realm()
            let userChatHistories = UserChatHistories()
            let chat = UserChatHistory()
            chat.role = role
            chat.text = text
            userChatHistories.chatHistories.insert(chat, at: 0)
            try realm.write {
                realm.add(userChatHistories)
            }
        } catch {
            print("error: \(error.localizedDescription)")
        }
    }
    func sendMessage(prompt: String) async -> String {
        do {
            let response = try await chat.sendMessage(prompt)
            if let text = response.text {
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
