/*
 MIT License
 
 Copyright (c) 2017-2018 MessageKit
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

import UIKit
import MessageKit
import SwiftyJSON


class BaseChatViewController: MessagesViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    var messageList: [MockMessage] = []
    var otherSenderList: [Sender] = []
    let refreshControl = UIRefreshControl()
    var lastChatDate = ""
    
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "h:mm a"
        formatter.amSymbol = "am"
        formatter.pmSymbol = "pm"
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMessageCollectionView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.removeObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.addObservers()
    }
    
    private func addObservers() {
     //   NotificationCenter.default.addObserver(self, selector: #selector(updateChatView), name: NSNotification.Name(rawValue: Constants.NOTIFICATION_NAME.CONFIRM_COTRAVELLER), object: nil)
    }
    
    private func removeObservers() {
      //  NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constants.NOTIFICATION_NAME.CONFIRM_COTRAVELLER), object: nil)
    }
    
    @objc private func updateChatView(withNotification notif: Notification) {
    //    print("Notification: \(notif.userInfo![Constants.NOTIFICATION_USERINFO.CO_TRAVELLER_INFO])")
//        let coTravellerList = notif.userInfo![Constants.NOTIFICATION_USERINFO.CO_TRAVELLER_INFO] as! [FbSuggestion]
//        if coTravellerList.count == 0 {
//            self.navigationController?.popViewController(animated: true)
//        }
    }
    
    
    func getSenderInfo(withSenderId senderId: String) -> [Sender] {
        return self.otherSenderList.filter { $0.id == senderId }
    }
    
    func getAvatarFor(sender: Sender) -> Avatar {
        let firstName = sender.displayName.components(separatedBy: " ").first
        let lastName = sender.displayName.components(separatedBy: " ").first
        let initials = "\(firstName?.first ?? "A")\(lastName?.first ?? "A")"
        let _: UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        var userimage : UIImage!
        userimage = UIImage(named: "dummy_profile_image")
        return Avatar(image: userimage, initials: initials)
    }
    
    @objc
    func loadMoreMessages() {
        self.refreshControl.endRefreshing()
        /*
         DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 1) {
         SampleData.shared.getMessages(count: 20) { messages in
         DispatchQueue.main.async {
         self.messageList.insert(contentsOf: messages, at: 0)
         self.messagesCollectionView.reloadDataAndKeepOffset()
         self.refreshControl.endRefreshing()
         }
         }
         }
         */
    }
    
    func configureMessageCollectionView() {
        
        messagesCollectionView.messageCellDelegate = self
        scrollsToBottomOnKeyboardBeginsEditing = true // default false
        maintainPositionOnKeyboardFrameChanged = true // default false
        //messagesCollectionView.addSubview(refreshControl)
       // refreshControl.addTarget(self, action: #selector(loadMoreMessages), for: .valueChanged)
    }
    
    // MARK: - Helpers
    
    func insertMessage(_ message: MockMessage) {
        messageList.append(message)
        // Reload last section to update header/footer labels and insert a new one
        messagesCollectionView.performBatchUpdates({
            messagesCollectionView.insertSections([messageList.count - 1])
            if messageList.count >= 2 {
                messagesCollectionView.reloadSections([messageList.count - 2])
            }
        }, completion: { [weak self] _ in
            if self?.isLastSectionVisible() == true {
                self?.messagesCollectionView.scrollToBottom(animated: true)
            }
        })
    }
    
    func isLastSectionVisible() -> Bool {
        guard !messageList.isEmpty else { return false }
        let lastIndexPath = IndexPath(item: 0, section: messageList.count - 1)
        return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
    }
}


// MARK: - MessageCellDelegate
extension BaseChatViewController: MessageCellDelegate {
    
    func didTapAvatar(in cell: MessageCollectionViewCell) {
        print("Avatar tapped")
    }
    
    func didTapMessage(in cell: MessageCollectionViewCell) {
        print("Message tapped")
    }
    
    func didTapCellTopLabel(in cell: MessageCollectionViewCell) {
        print("Top cell label tapped")
    }
    
    func didTapMessageTopLabel(in cell: MessageCollectionViewCell) {
        print("Top message label tapped")
    }
    
    func didTapMessageBottomLabel(in cell: MessageCollectionViewCell) {
        print("Bottom label tapped")
    }
    
    func didTapAccessoryView(in cell: MessageCollectionViewCell) {
        print("Accessory view tapped")
    }
    
}


// MARK: - MessageLabelDelegate
extension BaseChatViewController: MessageLabelDelegate {
    
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
        print("URL Selected: \(url)")
    }
    
    func didSelectTransitInformation(_ transitInformation: [String: String]) {
        print("TransitInformation Selected: \(transitInformation)")
    }
}
