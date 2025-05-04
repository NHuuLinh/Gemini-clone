//  BaseMessageViewController.swift
//  ColorNoteRemake
//
//  Created by LinhMAC on 01/08/2024.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import Kingfisher

protocol AvatarConfigurationDelegate: AnyObject {
    func endEdit()
    func loadMoreData()
}

class BaseMessageViewController: MessagesViewController {
    final var currentUser = Sender(senderId: "user", displayName: "user", avatarUrl: "")
    weak var avatarDelegate: AvatarConfigurationDelegate?
    var messages = [MessageType]()
    var isLoadingMoreData = true
    let defaultAttributes: [NSAttributedString.Key: Any] = {
      [
        NSAttributedString.Key.foregroundColor: UIColor.darkText,
        NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue,
        NSAttributedString.Key.underlineColor: UIColor.darkText,
      ]
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCell()
        if let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
            layout.setMessageOutgoingAvatarSize(.zero)
            //cellBottomLabelAttributedText
            layout.setMessageOutgoingMessageTopLabelAlignment(LabelAlignment(
                textAlignment: .right,
                textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)))
            
            layout.setMessageOutgoingMessageBottomLabelAlignment(LabelAlignment(
                textAlignment: .right,
                textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)))
            layout.setMessageOutgoingCellBottomLabelAlignment(LabelAlignment(
                textAlignment: .right,
                textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)))
            // set the vertical position of the Avatar for incoming messages so that the bottom of the Avatar
            // aligns with the bottom of the Message
            layout.setMessageIncomingAvatarPosition(.init(vertical: .messageTop))
            layout.setMessageIncomingAvatarSize(.zero)
            // set the vertical position of the Avatar for outgoing messages so that the bottom of the Avatar
            // aligns with the `cellBottom`
            layout.setMessageOutgoingAvatarPosition(.init(vertical: .cellTop))
        }
        // Do any additional setup after loading the view.
    }
    @objc func hideKeyBoard(){
        print("hidekeyboar")
        avatarDelegate?.endEdit()
    }
    
    func containsURL(text: String) -> Bool {
        // Tạo một NSDataDetector để phát hiện URL
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        
        // Tìm kiếm các kết quả URL trong văn bản
        let matches = detector?.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))
        
        // Kiểm tra nếu có kết quả nào được tìm thấy
        return matches?.count ?? 0 > 0
    }
    func extractURLs(from text: String) -> [URL] {
        var urls = [URL]()
        
        // Biểu thức chính quy để tìm URL
        let pattern = "(https?://[\\w-]+(\\.[\\w-]+)+(:\\d+)?(/[\\w-./?%&=]*)?)"
        
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
            let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: text.count))
            
            for match in matches {
                if let range = Range(match.range, in: text) {
                    let urlString = String(text[range])
                    if let url = URL(string: urlString) {
                        urls.append(url)
                    }
                }
            }
        } catch {
            print("Error creating regex: \(error)")
        }
        
        return urls
    }

    // Hàm để tạo NSAttributedString với các URL
    func createAttributedString(from text: String) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: text)
        let urls = extractURLs(from: text)
        
        for url in urls {
            let urlRange = (text as NSString).range(of: url.absoluteString)
            attributedString.addAttribute(.foregroundColor, value: UIColor.blue, range: urlRange)
            attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: urlRange)
        }
        
        return attributedString
    }
    
}


// MARK: - Xử lí tin nhắn
extension BaseMessageViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    // convertImageToBase64String
    func convertImageToBase64String (img: UIImage) -> String {
        let string = img.jpegData(compressionQuality: 0.01)?.base64EncodedString() ?? ""
        return string
    }
    // convertImageToBase64String
    func convertBase64StringToImage (imageBase64String:String) -> UIImage? {
        if let imageData = Data(base64Encoded: imageBase64String) {
            let image = UIImage(data: imageData)
            return image
        }
        return nil
    }
    
    
    func handleImageMessage(imageString: String){
        let sentDate = Date()
        guard let image = convertBase64StringToImage(imageBase64String: imageString) else {return}
        let mediaItem = ImageMediaItem(image: image)
        let newMessage = Message(sender: currentUser, messageId: UUID().uuidString, sentDate: sentDate, kind: .photo(mediaItem))
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.messages.append(newMessage)
            self.messagesCollectionView.reloadData()
            self.messagesCollectionView.scrollToLastItem(animated: false)
        }
    }
    func handleImageMessage(image: UIImage){
        let sentDate = Date()
        let mediaItem = ImageMediaItem(image: image)
        let newMessage = Message(sender: currentUser, messageId: UUID().uuidString, sentDate: sentDate, kind: .photo(mediaItem))
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.messages.append(newMessage)
            self.messagesCollectionView.reloadData()
            self.messagesCollectionView.scrollToLastItem(animated: false)
        }
    }

    func handleTextMessage(text: String) {
        let sentDate = Date()
        let newMessage = Message(sender: currentUser, messageId: UUID().uuidString, sentDate: sentDate, kind: .text(text))
        // Thêm tin nhắn mới vào mảng messages và reload dữ liệu hiển thị
        messages.append(newMessage)
        messagesCollectionView.reloadData()
        // Xóa văn bản đã nhập từ thanh nhập liệu
        // Cuộn xuống cuối danh sách tin nhắn để hiển thị tin nhắn mới nhất
        messagesCollectionView.scrollToLastItem(animated: false)
        messageInputBar.inputTextView.text.removeAll()
    }
    func handleModelTextMessage(text: String) {
        let sentDate = Date()
        let newMessage = Message(sender: Sender(senderId: "model", displayName: "model", avatarUrl: ""), messageId: UUID().uuidString, sentDate: sentDate, kind: .text(text))
        // Thêm tin nhắn mới vào mảng messages và reload dữ liệu hiển thị
        messages.append(newMessage)
        messagesCollectionView.reloadData()
        // Xóa văn bản đã nhập từ thanh nhập liệu
        // Cuộn xuống cuối danh sách tin nhắn để hiển thị tin nhắn mới nhất
        messagesCollectionView.scrollToLastItem(animated: false)
        messageInputBar.inputTextView.text.removeAll()
    }
}

// MARK: - Cấu hình UI của MessageViewController
extension BaseMessageViewController:  MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate,MessageCellDelegate  {
    final func registerCell(){
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.showsVerticalScrollIndicator = false
        //        messagesCollectionView.delegate = self
        maintainPositionOnKeyboardFrameChanged = true
        scrollsToLastItemOnKeyboardBeginsEditing = true
        messagesCollectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 500, right: 0)
        messagesCollectionView.scrollIndicatorInsets = messagesCollectionView.contentInset
        messagesCollectionView.bounces = false
    }
//    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        
//        let offsetY = scrollView.contentOffset.y
//        if offsetY < 100 && !isLoadingMoreData {
//            isLoadingMoreData = true
//            avatarDelegate?.loadMoreData()
//        }
//    }
    
    func configureMediaMessageImageView(
        _ imageView: UIImageView,
        for message: MessageType,
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView
    ) {
        //        imageView.contentMode = .scaleAspectFit
        switch message.kind {
        case .photo(let media):
            if let imageURL = media.url {
                let defaultImage = UIImage(named: "screen-image-error")!
                imageView.kf.setImage(with: imageURL, placeholder: defaultImage , options: nil, completionHandler: { result in
                    switch result {
                    case .success(_):
                        // Ảnh đã tải thành công
                        print("downloadImage success")
                        break
                    case .failure(_):
                        // Xảy ra lỗi khi tải ảnh
                        imageView.image = defaultImage
                    }
                })
            }else {
                imageView.kf.cancelDownloadTask()
            }
        default:
            break
        }
    }
    
    func didTapBackground(in cell: MessageCollectionViewCell) {
        avatarDelegate?.endEdit()
    }
    
    final func messagesCollectionView(_ messagesCollectionView: MessagesCollectionView, didSelectItemAt indexPath: IndexPath) {
        let message = messages[indexPath.section]
        // Handle the selection of the message
        print("Selected message: \(message)")
    }
    final func didTapImage(in cell: MessageCollectionViewCell) {
        if let image = (cell as? MediaMessageCell)?.imageView.image {
            imageTapped(image: image)
            print("có ảnh")
            // create and show the new ImageView with this image.
        }
        let indexPath = self.messagesCollectionView.indexPath(for: cell)
        print("click vào image \(indexPath?.row)")
    }
    
    final func didTapMessage(in cell: MessageCollectionViewCell) {
        let indexPath = self.messagesCollectionView.indexPath(for: cell)
        print("Selected message: \(indexPath)")
    }
    func didTapMessages(in cell: MessageCollectionViewCell) {
        print("didTapMessage ")
//        guard let indexPath = messagesCollectionView.indexPath(for: cell) else { return }
//        let message = messages[indexPath.row]
//
//        if case let .attributedText(attributedText) = message.kind {
//            let text = attributedText.string
//            // Tạo một CGRect cho các URL và xác định đâu là URL mà người dùng đã nhấp vào
//            let layoutManager = NSLayoutManager()
//            let textContainer = NSTextContainer(size: CGSize(width: cell.bounds.width, height: .greatestFiniteMagnitude))
//            let textStorage = NSTextStorage(attributedString: attributedText)
//            
//            layoutManager.addTextContainer(textContainer)
//            textStorage.addLayoutManager(layoutManager)
//            
//            let location = cell.bounds.origin // Vị trí người dùng nhấp chuột
//            let characterIndex = layoutManager.characterIndex(for: location, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
//            
//            // Kiểm tra nếu chỉ số ký tự nằm trong các URL đã xác định
//            for url in extractURLs(from: text) {
//                let urlRange = (text as NSString).range(of: url.absoluteString)
//                if NSLocationInRange(characterIndex, urlRange) {
//                    UIApplication.shared.open(url)
//                    return
//                }
//            }
//        }
    }

    
    
    final func imageTapped(image: UIImage) {
        avatarDelegate?.endEdit()
        // tạo UIScrollView
        let scrollView = UIScrollView()
        scrollView.frame = self.view.bounds
        scrollView.bounces = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.maximumZoomScale = 20
        scrollView.minimumZoomScale = 1
        scrollView.backgroundColor = .black
        scrollView.delegate = self
        
        // Create UIImageView
        let newImageView = UIImageView(image: image)
        newImageView.contentMode = .scaleToFill
        newImageView.isUserInteractionEnabled = true
        newImageView.backgroundColor = .clear
        
        // tính toán tỉ lệ ảnh sao cho khi zoom được tối đa ảnh
        let aspectRatio = image.size.width / image.size.height
        var imageViewWidth: CGFloat
        var imageViewHeight: CGFloat
        
        if image.size.width > image.size.height {
            imageViewWidth = scrollView.bounds.width
            imageViewHeight = imageViewWidth / aspectRatio
        } else {
            imageViewWidth = scrollView.bounds.width
            imageViewHeight = imageViewWidth / aspectRatio
        }
        
        newImageView.frame = CGRect(x: 0, y: 0, width: imageViewWidth, height: imageViewHeight)
        scrollView.contentSize = newImageView.bounds.size
        
        // căn ảnh khi zoom sao cho giữa màn hình
        centerImageView(imageView: newImageView, inScrollView: scrollView)
        
        // Add the UIImageView to the UIScrollView
        scrollView.addSubview(newImageView)
        
        // Add tap gesture để ẩn ảnh khi cần
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
        scrollView.addGestureRecognizer(tap)
        
        // Hide message input bar ...
        self.messageInputBar.isHidden = true
        self.view.addSubview(scrollView)
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }
    
    // hàm để khi zoom ảnh sẽ cân đối
    final func centerImageView(imageView: UIImageView, inScrollView scrollView: UIScrollView) {
        let scrollViewSize = scrollView.bounds.size
        let imageViewSize = imageView.frame.size
        
        let verticalPadding = imageViewSize.height < scrollViewSize.height ? (scrollViewSize.height - imageViewSize.height) / 2 : 0
        let horizontalPadding = imageViewSize.width < scrollViewSize.width ? (scrollViewSize.width - imageViewSize.width) / 2 : 0
        scrollView.contentInset = UIEdgeInsets(top: verticalPadding, left: horizontalPadding, bottom: verticalPadding, right: horizontalPadding)
    }
    
    // UIScrollViewDelegate method
    final func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return scrollView.subviews.first
    }
    // hàm để thoát khỏi xem ảnh toàn màn hình
    @objc final func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
        self.messageInputBar.isHidden = false
        sender.view?.removeFromSuperview()
    }
    final func currentSender() -> MessageKit.SenderType {
        return currentUser
    }
    
    final func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> MessageKit.MessageType {
        return messages[indexPath.section]
    }
    
    final func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {
        return messages.count
    }
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return .white
    }
    
    
    final func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        if case .photo(_) = message.kind {
            return .clear
        } else {
            let text = messages[indexPath.row].kind
            return isFromCurrentSender(message: message) ? .darkGray : .darkGray
        }
    }
    
    final func shouldDisplayHeader(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> Bool {
        return false
    }
    
    //
    final func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        return .bubble
    }
}

// MARK: - Cấu hình UI của MessageViewController
extension BaseMessageViewController {
    
    final func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        // Format thời gian gửi của tin nhắn
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"
        
        let date = message.sentDate.timeSinceDate(fromDate: Date())
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10),
            .foregroundColor: UIColor.white
        ]
        return nil //NSAttributedString(string: date, attributes: attributes)
    }
    
    func cellBottomLabelAttributedText(for message: MessageKit.MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if indexPath.section == (messages.count - 1) {
            let attrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 12), .foregroundColor: UIColor.gray]
//            return NSAttributedString(string: isSeen, attributes: attrs)
            return nil

        } else {
            return nil
        }
    }
    func messageTopLabelAttributedText(for message: MessageKit.MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        return nil
//        if message.sender.senderId == Role.user.rawValue {
//            return NSAttributedString(string: "", attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1), .foregroundColor: UIColor.white])
//        } else {
//            let name = message.sender.displayName
//            return NSAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1), .foregroundColor: UIColor.white])
//        }
        
    }
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        return nil
        
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "HH:mm" // Định dạng 24 giờ
//        //        dateFormatter.timeZone = TimeZone.current // Đặt múi giờ của định dạng là GMT
//        
//        let sentDate = dateFormatter.string(from: message.sentDate)
//        // Tạo văn bản được định dạng cho thời gian gửi
//        let attributes: [NSAttributedString.Key: Any] = [
//            .font: UIFont.systemFont(ofSize: 10),
//            .foregroundColor: UIColor.white // Màu xám
//        ]
//        return NSAttributedString(string: sentDate, attributes: attributes)
    }
    
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
            return 10
    }
    
    func cellBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        //        return 10
        if indexPath.section == (messages.count - 1) {
            return 10
        } else {
            return 0
        }
    }
    //
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
            return 10
    }
    //
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 10
    }
    func messageStyle(for message: MessageType) -> MessageStyle {
        // Tùy chỉnh hiển thị cho các tin nhắn chứa URL
        return .bubble
    }
}
extension BaseMessageViewController: MessageLabelDelegate {
    
    func detectorAttributes(for detector: DetectorType, and message: MessageType, at indexPath: IndexPath) -> [NSAttributedString.Key: Any] {
     switch detector {
     case .hashtag, .mention, .url:
         return defaultAttributes
//         return [.foregroundColor: UIColor.blue, .underlineColor : UIColor.blue]
     default: return MessageLabel.defaultAttributes
     }
   }

 func enabledDetectors(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [DetectorType] {
     return [.url, .address, .phoneNumber, .date, .transitInformation, .mention, .hashtag]
 }

    
    func didSelectAddress(_ addressComponents: [String: String]) {
        print("Address Selected: \(addressComponents)")
    }
    
    func didSelectDate(_ date: Date) {
        print("Date Selected: \(date)")
    }
    
    func didSelectPhoneNumber(_ phoneNumber: String) {
        print("Phone Number Selected: \(phoneNumber)")
    }
    
    func didSelectURL(_ url: URL) {
        DispatchQueue.main.async {
            UIApplication.shared.open(url)
        }
        print("URL Selected: \(url)")
    }
    
    func didSelectTransitInformation(_ transitInformation: [String: String]) {
        print("TransitInformation Selected: \(transitInformation)")
    }
    
    func didSelectHashtag(_ hashtag: String) {
        print("Hashtag selected: \(hashtag)")
    }
    
    func didSelectMention(_ mention: String) {
        print("Mention selected: \(mention)")
    }
    
    func didSelectCustom(_ pattern: String, match _: String?) {
        print("Custom data detector patter selected: \(pattern)")
    }
}




