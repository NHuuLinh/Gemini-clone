//
//  MessageInputButtonView.swift
//  ColorNoteRemake
//
//  Created by LinhMAC on 03/08/2024.
//

import Foundation
import UIKit
import InputBarAccessoryView

enum SourceType {
    case camera
    case photoLibrary
}

protocol MessageInputButtonViewDelegate: InputBarAccessoryViewDelegate{
    func getRootVC() -> UIViewController
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith attachments: [AttachmentManager.Attachment])
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith attachments: [AttachmentManager.Attachment], text: String)

}


class MessageInputButtonView: InputBarAccessoryView {
    private let itemWidth: CGFloat = 50
    private var itemHeight: CGFloat {
        return itemWidth - 15
    }

    private let itemSpacing: CGFloat = 0 // Khoảng cách giữa các mục

    private var sourceType : SourceType = .camera

    lazy var attachmentManager: AttachmentManager = { [unowned self] in
      let manager = AttachmentManager()
      manager.delegate = self
      return manager
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSendBtn()
        addInputButton()
        setupInputTextView()
        inputTextViewDidChange()
    }
    @objc func textFieldDidChange(_ textField: UITextField) {
        inputTextView.text = textField.text
//        print("Text changed: \(textField.text ?? "")")
    }
    required init?(coder _: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }

    func setupInputTextView(){
        inputTextView.placeholder = "Aa"
        inputTextView.contentInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: itemWidth)
        inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: itemWidth)
        inputTextView.backgroundColor = .white
        inputTextView.textColor = .black
        inputTextView.layer.cornerRadius = 20
        inputTextView.clipsToBounds = true
        inputTextView.layer.masksToBounds = true
        if inputTextView.bounds.height > 0 {
            inputTextView.layer.cornerRadius = inputTextView.bounds.height / 2
        }
        print("inputTextV.bounds.height:\(inputTextView.bounds.height)")
    }
    
    final func setupSendBtn(){
        sendButton.setSize(CGSize(width: itemWidth, height: itemHeight), animated: false)
        sendButton.image = UIImage(systemName: "paperplane.fill")
        sendButton.title = nil
        sendButton.tintColor = UIColor(hex: "#5BE260")
        sendButton.backgroundColor = .clear
        sendButton.isEnabled = true
    }
    final func addInputButton() {
        let leftItems = [
            makeButton(named: "camera.fill").onSelected({ _ in
                self.openCamera()
            }),
            makeButton(named: "photo").onSelected({ _ in
                self.openPhotoLibrary()
            })
            ]
        leftStackView.alignment = .center
        if let view = middleContentView {
            view.backgroundColor = .clear
            print("leftStackView")
        } else {
            print("no middleContentView")
        }

        let totalItemSize = itemWidth * CGFloat(leftItems.count)
        backgroundView.backgroundColor = UIColor(hex: "#4A4B51")
        
        setLeftStackViewWidthConstant(to: CGFloat(totalItemSize), animated: false)
        setStackViewItems(leftItems, forStack: .left, animated: false)
        
//        setRightStackViewWidthConstant(to: 100, animated: false)
//        middleContentViewPadding.right = -itemWidth
        inputPlugins = [attachmentManager]
    }
    private func makeButton(named : String) -> InputBarButtonItem {
        InputBarButtonItem().configure { button in
            button.image = UIImage(systemName: named)
            button.tintColor = UIColor(hex: "#5BE260")
            button.setSize(CGSize(width: itemWidth, height: itemHeight), animated: false)
            button.backgroundColor = .clear
//            button.spacing = .fixed(10)
        }.onSelected { _ in
            print("Item onSelected")
        }.onDeselected {_ in
            print("Item onDeselected")
//            $0.tintColor = UIColor.lightGray
          }.onTouchUpInside { _ in
            print("Item onTouchUpInside")
          }
    }
    private func makeButtons(named : String) -> InputBarButtonItem {
        InputBarButtonItem().configure { button in
//            button.spacing = .fixed(itemSpacing)
            let color = UIColor(hex: "#5BE260") ?? UIColor.green
            let image = UIImage(named: named)?.withTintColor(color, renderingMode: .alwaysTemplate)
            button.image = image
            button.tintColor = color
            button.setSize(CGSize(width: itemWidth, height: itemHeight), animated: false)
            button.backgroundColor = .clear
//            button.spacing = .fixed(10)
        }.onSelected { _ in
            print("Item onSelected")
        }.onDeselected {_ in
            print("Item onDeselected")
//            $0.tintColor = UIColor.lightGray
          }.onTouchUpInside { _ in
            print("Item onTouchUpInside")
          }
    }

    override func didSelectSendButton() {
        let hasAttachments = (attachmentManager.attachments.count > 0)
        if hasAttachments  {
            if inputTextView.text.isEmpty {
                (delegate as? MessageInputButtonViewDelegate)?.inputBar(self, didPressSendButtonWith: attachmentManager.attachments)

            } else {
                (delegate as? MessageInputButtonViewDelegate)?.inputBar(self, didPressSendButtonWith: attachmentManager.attachments, text: inputTextView.text)
            }
            } else {
                delegate?.inputBar(self, didPressSendButtonWith: inputTextView.text)
            }
    }

}
// MARK: - Xử lí khi chọn ảnh và tệp

extension MessageInputButtonView: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    private func openPhotoLibrary() {
        let picker = UIImagePickerController()
        sourceType = .photoLibrary
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        (delegate as? MessageInputButtonViewDelegate)?.getRootVC().present(picker, animated: true)
    }
    
    @objc fileprivate func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            /// Cho phép edit ảnh hay là không
            imagePicker.allowsEditing = true
            sourceType = .camera
            (delegate as? MessageInputButtonViewDelegate)?.getRootVC().present(imagePicker, animated: true, completion: nil)
        } else {
            let errorText = NSLocalizedString("Error", comment: "")
            let errorMessage = NSLocalizedString("Divice not have camera", comment: "")
            
            let alertWarning = UIAlertController(title: errorText,
                                                 message: errorMessage,
                                                 preferredStyle: .alert)
            let cancelText = NSLocalizedString("Cancel", comment: "")
            let cancel = UIAlertAction(title: cancelText,
                                       style: .cancel) { (_) in
                print("Cancel")
            }
            alertWarning.addAction(cancel)
            (delegate as? MessageInputButtonViewDelegate)?.getRootVC().present(alertWarning, animated: true, completion: nil)
        }
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true) {
                if let image = info[.originalImage] as? UIImage {
                    self.inputPlugins.forEach({_ = $0.handleInput(of: image)})
            }
        }
    }

}

extension MessageInputButtonView: AttachmentManagerDelegate {
    // MARK: - AttachmentManagerDelegate
    
    func attachmentManager(_: AttachmentManager, shouldBecomeVisible: Bool) {
        setAttachmentManager(active: shouldBecomeVisible)
    }
    
    func attachmentManager(_ manager: AttachmentManager, didReloadTo _: [AttachmentManager.Attachment]) {
        sendButton.isEnabled = manager.attachments.count > 0
    }
    
    func attachmentManager(_ manager: AttachmentManager, didInsert _: AttachmentManager.Attachment, at _: Int) {
        sendButton.isEnabled = manager.attachments.count > 0
    }
    
    func attachmentManager(_ manager: AttachmentManager, didRemove _: AttachmentManager.Attachment, at _: Int) {
        sendButton.isEnabled = manager.attachments.count > 0
    }
    
    func attachmentManager(_: AttachmentManager, didSelectAddAttachmentAt index : Int) {
        if sourceType == .camera {
            openCamera()
        }else {
            openPhotoLibrary()
        }
        print("didSelectAddAttachmentAt: \(index)")
    }
    func setAttachmentManager(active: Bool) {
      let topStackView = topStackView
      if active, !topStackView.arrangedSubviews.contains(attachmentManager.attachmentView) {
        topStackView.insertArrangedSubview(attachmentManager.attachmentView, at: topStackView.arrangedSubviews.count)
        topStackView.layoutIfNeeded()
      } else if !active, topStackView.arrangedSubviews.contains(attachmentManager.attachmentView) {
        topStackView.removeArrangedSubview(attachmentManager.attachmentView)
        topStackView.layoutIfNeeded()
      }
    }
}


