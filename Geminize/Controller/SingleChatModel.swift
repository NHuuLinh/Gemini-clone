//
//  SingleChatModel.swift
//  ColorNoteRemake
//
//  Created by LinhMAC on 03/07/2024.
//

import Foundation

struct SingleChatModel: Codable {
    let data: [ChatModelData]?
    let status: Int?

    enum CodingKeys: String, CodingKey {
        case data = "data"
        case status = "status"
    }
}

// MARK: - Datum
struct ChatModelData: Codable {
    let messages: [SingleChat]?
    let room: String?

    enum CodingKeys: String, CodingKey {
        case messages = "messages"
        case room = "room"
    }
}

// MARK: - Message
struct SingleChat: Codable {
//    let id: Int?
//    let idReceive: Int?
//    let idSend: Int?
//    let image: String?
//    let sendAt: String?
//    let state: MessageState?
//    let text: String?
//    let type: TypeMessage?
//    let gif: String?
    
    let gif: String?
    let id: Int?
    let idReceive: Int?
    let idSend: Int?
    let image: String?
    let sendAt: String?
    let state: MessageState?
    let text: String?
    let type: TypeMessage?


    enum CodingKeys: String, CodingKey {
        case gif = "gif"
        case id = "id"
        case idReceive = "idReceive"
        case idSend = "idSend"
        case image = "image"
        case sendAt = "sendAt"
        case state = "state"
        case text = "text"
        case type = "type"
    }
}

enum MessageState: String, Codable {
    case notSeen = "not seen"
    case seen = "seen"
}

// Other structs and functions remain unchanged


import Foundation
import MessageKit


struct Sender: SenderType {
    var senderId: String
    var displayName: String
    var avatarUrl : String? = nil
}

struct Message: MessageType {
    var sender: MessageKit.SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKit.MessageKind

}

struct GIFMessage: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
    
    init(sender: SenderType, messageId: String, sentDate: Date, gifURL: URL) {
        self.sender = sender
        self.messageId = messageId
        self.sentDate = sentDate
        self.kind = .custom(gifURL)
    }
}

public struct ImageMediaItem: MediaItem {
    public var url: URL?
    public var image: UIImage?
    public var placeholderImage: UIImage
    public var size: CGSize

    public init(image: UIImage) {
        self.image = image
        self.size = CGSize(width: 240, height: 240)
        self.placeholderImage = UIImage()
    }
    init(imageURL: URL) {
        url = imageURL
        size = CGSize(width: 240, height: 240)
        if let placeholder = UIImage(named: "screen-image-error") {
            placeholderImage = placeholder
        } else {
            // Đặt giá trị mặc định nếu hình ảnh không tồn tại
            placeholderImage = UIImage()
            print("Warning: Placeholder image 'screen-image-error' not found.")
        }
    }
}

public struct LikeImageMediaItem: MediaItem {
    public var url: URL?
    public var image: UIImage?
    public var placeholderImage: UIImage
    public var size: CGSize

    public init(image: UIImage) {
        self.image = image
        self.size = CGSize(width: 50, height: 50)
        self.placeholderImage = UIImage()
    }
}
public struct UrlLinkItem: LinkItem {
    public var text: String?
    public var attributedText: NSAttributedString?
    public var url: URL
    public var title: String?
    public var teaser: String
    public var thumbnailImage: UIImage
}

struct MessageUserData {
    var otherUserAvatar: UIImage
    var otherUserFullName: String
    var otherUserId: String
    var otherUserIsCurrentOnline : Bool
    var otherLastActivityTime: String
}
//
//  ChatUnknowModel.swift
//  ColorNoteRemake
//
//  Created by LinhMAC on 24/07/2024.
//

import Foundation
struct UnknowChat: Codable {
    let chatUnknowData: [ChatUnknowData]?
    let status: Int?

    enum CodingKeys: String, CodingKey {
        case chatUnknowData = "data"
        case status = "status"
    }
}

// MARK: - Datum
struct ChatUnknowData: Codable {
    let content: String?
    let id: Int?
    let idReceive: Int?
    let idSend: Int?
    let sendAt: String?
    let gif: String?
    let img: String?
    let type: TypeMessage?


    enum CodingKeys: String, CodingKey {
        case content = "content"
        case id = "id"
        case idReceive = "idReceive"
        case idSend = "idSend"
        case sendAt = "sendAt"
        case gif = "gif"
        case img = "img"
        case type = "type"
        
    }
}
enum TypeMessage: String, Codable {
    case image = "image"
    case text = "text"
    case iconImage = "icon-image"
    case gif = "gif"
    case none = ""


}







