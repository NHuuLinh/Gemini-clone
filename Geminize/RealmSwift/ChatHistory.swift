//
//  ChatHistory.swift
//  Geminize
//  Created by Huu Linh Nguyen on 7/4/25.
//

import Foundation
import RealmSwift

enum Role: String {
    case user = "user"
    case model = "model"
}

//Tin nhắn riêng lẻ
class ChatMessage: Object {
    @Persisted var sender: String
    @Persisted var message: String?
    @Persisted var imagePath: String?
    @Persisted var timestamp: Date = Date()
}

//Một phiên chat (gồm nhiều tin nhắn)
final class UserChatHistories: Object {
    @Persisted(primaryKey: true) var idChat: String = UUID().uuidString
    @Persisted var firstMessage: String
    @Persisted var chatHistories = List<ChatMessage>()
}

