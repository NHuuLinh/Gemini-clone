
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

enum TypeMessage: String, Codable {
    case image = "image"
    case text = "text"
    case iconImage = "icon-image"
    case gif = "gif"
    case none = ""
}
