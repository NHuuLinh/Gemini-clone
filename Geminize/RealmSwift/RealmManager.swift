//
//  RealmManager.swift
//  Geminize
//
//  Created by Huu Linh Nguyen on 11/4/25.
// 

import Foundation
import RealmSwift
class RealmManager {
    static let shared = RealmManager()
    private init (){
        if let realmURL = Realm.Configuration.defaultConfiguration.fileURL {
            print("📦 Realm file is located at: \(realmURL)")
        }
    }
    func exportRealmFile(from viewController: UIViewController) {
        if let realmURL = Realm.Configuration.defaultConfiguration.fileURL {
            let activityVC = UIActivityViewController(activityItems: [realmURL], applicationActivities: nil)
            
            // Chỉ định sourceView cho popover
            if let popoverController = activityVC.popoverPresentationController {
                popoverController.sourceView = viewController.view // hoặc nút bạn muốn dùng
                popoverController.sourceRect = CGRect(x: viewController.view.bounds.midX, y: viewController.view.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = [] // nếu không muốn có mũi tên
            }
            
            viewController.present(activityVC, animated: true)
        }
    }

    
    //Tao lich su chat moi
    func createNewChatSession() -> String {
        let realm = try! Realm()
        let session = UserChatHistories()

        try! realm.write {
            realm.add(session)
        }
        print("session.idChat:\(session.idChat)")
        return session.idChat
    }

    func saveHistoryPromt(sender: Role, message: String? = nil, image: UIImage? = nil,idChat:String,isFirstChat: Bool = false){
            let realm = try! Realm()
            guard let chatSession = realm.object(ofType: UserChatHistories.self, forPrimaryKey: idChat) else {
                print("error khong thay chat Session)")
                return
            }
        print(" Tìm thấy chat với ID: \(chatSession.idChat)")
            let chatMessage = ChatMessage()
            chatMessage.message = message
            chatMessage.sender = sender.rawValue
            chatMessage.timestamp = Date()
            
            if let image = image, let imageData = image.jpegData(compressionQuality: 0.1) {
                let fileName = UUID().uuidString + ".jpg"
                let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                    .appendingPathComponent(fileName)
                
                do {
                    try imageData.write(to: fileURL)
                    chatMessage.imagePath = fileName
                } catch {
                    print("error save file: \(error.localizedDescription)")
                }
            }
            try! realm.write {
                chatSession.chatHistories.insert(chatMessage, at: 0)
                if isFirstChat {
                    chatSession.firstMessage = message ?? "Nội dung ảnh"
                } else {
                    print("đã chat")
                }
            }
    }
    func test(chatSession:UserChatHistories){
        for (index, msg) in chatSession.chatHistories.enumerated() {
            print("🔹 \(index + 1). [\(msg.sender)]")
            if let text = msg.message {
                print("    ✉️ Text: \(text)")
            }
            if let path = msg.imagePath {
                print("    🖼 Image path: \(path)")
            }
            print("    ⏰ Time: \(msg.timestamp)")
        }
    }
    func loadMessages(of chatId: String) -> [ChatMessage] {
        let realm = try! Realm()

        guard let session = realm.object(ofType: UserChatHistories.self, forPrimaryKey: chatId) else {
            print("ChatMessage nil")
            return []
        }
        print("loadMessages :\(session)")

        return Array(session.chatHistories)
//        return Array(session.chatHistories.sorted(by: { $0.timestamp < $1.timestamp }))
    }
    func loadAllChat() -> [UserChatHistories] {
        let realm = try! Realm()
        let allChat = realm.objects(UserChatHistories.self)
        let messageArray = Array(allChat)
        return messageArray
    }
    func loadImageFromPath(_ fileName: String) -> UIImage? {
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(fileName)
        return UIImage(contentsOfFile: fileURL.path)
    }
    

}
