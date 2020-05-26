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
import MapKit
import MessageKit
import XMPPFramework
import NotificationView

final class ChatViewController: MessagesViewController {
    
    var messageList: [MockMessage] = []
    var chatList = [ChatModel]()
    

    var myProfile: Profile!
    var profile: Profile?
    var chatHistory : ChatHistory?
    
    var sender : Sender?
    var receiver : Sender?
    
    let TAG = "ChatVC :"
    var retrySelectedIndex =  -1
    
    var getIsSubscribeuser = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMessageInputBar()
        configureMessageCollectionView()
       
        initChatHistorySenderAndReceiver()
        DatabaseManager.shared.clearUnReadCountInChatHistory(for: chatHistory?.uniqueId ?? self.profile?.uniqueId ?? "")
        setupNavBar()
        loadChatMessage()
    }

    
    func refreshChatViews(chatHistory : ChatHistory)
    {
        
        self.profile = nil
        self.chatList.removeAll()
        self.messageList.removeAll()
        self.sender = nil
        self.receiver = nil
        self.retrySelectedIndex = -1
        
        self.chatHistory = chatHistory
        
        self.initChatHistorySenderAndReceiver()
        DatabaseManager.shared.clearUnReadCountInChatHistory(for: chatHistory.uniqueId ?? "")
        self.setupNavBar()
        
        self.loadChatMessage()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.messagesCollectionView.scrollToBottom()
        }
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sendOpenChatScreenAnalytics(profile: profile, status: ChatManager.share.connectionSatus.rawValue)
        
        // check subscribe validity `
        getIsSubscribeuser = Util.getSubscribeValidityIsAvalibale()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       // print("Register Chat delegate : CVC")
        if ChatManager.share.isReady {
            ChatManager.share.addDelegate(delegate: self)
        }
        // Check and make xmpp connection
        checkAndConnectWithChatServer()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("DeRegister Chat delegate : CVC")
        if ChatManager.share.isReady {
            ChatManager.share.addDelegate(delegate: nil)
        }
    }
    
    func checkAndConnectWithChatServer()
    {
        print("\(TAG) Check and connect with chat server")
        print("\(TAG) Currect connection satus = \(ChatManager.share.connectionSatus)")
        
        switch ChatManager.share.connectionSatus {
        case .ideal:
            APP_DELEGATE.initChatManager(myProfile: nil, chatConfiguration: nil)
        case .failed:
            //Try to connect again
            ChatManager.share.connect()
        case .connecting:
            //Connection is in progress
            break
        default:
            break
        }
    }
    
    func configureMessageCollectionView() {
        
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messageCellDelegate = self
        scrollsToBottomOnKeyboardBeginsEditing = true // default false
        maintainPositionOnKeyboardFrameChanged = true // default false
        messagesCollectionView.backgroundColor = .chatBgColor
        
//        guard let flowLayout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout else { return }
//        flowLayout.attributedTextMessageSizeCalculator.outgoingAvatarSize = .zero
//        flowLayout.attributedTextMessageSizeCalculator.incomingAvatarSize = .zero
    }
    
    func configureMessageInputBar() {
        messageInputBar.delegate = self
        messageInputBar.backgroundView.backgroundColor = UIColor.white
        messageInputBar.inputTextView.placeholder = NSLocalizedString("M_WRITE_YOUR_MESSAGE", comment: "")

        messageInputBar.inputTextView.tintColor = UIColor.darkGray
        messageInputBar.sendButton.tintColor = .appPrimaryColor
        messageInputBar.sendButton.setTitle("", for: .normal)
        messageInputBar.sendButton.setImage(UIImage.init(named: "send-message"), for: .normal)
        messageInputBar.sendButton.setImage(UIImage.init(named: "send-message-disabled"), for: .disabled)
    }
    
    func getAvatarFor(sender: SenderType) -> Avatar {
        let firstName = sender.displayName.components(separatedBy: " ").first
        let lastName = sender.displayName.components(separatedBy: " ").last
        let initials = "\(firstName?.first ?? "A")\(lastName?.first ?? "A")"
        let userimage = UIImage(named: "dummy_profile_image")
        return Avatar(image: userimage, initials: initials)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        messageInputBar.inputTextView.resignFirstResponder()
    }
    
    @objc func backButtonAction()
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func initiateCall()
    {        
        if let chatModel = CallHandler.initiateCall(profile: self.profile, chatHistory: self.chatHistory)
        {
//            let attributedText = NSAttributedString(string: chatModel.message ?? "", attributes: [.font: UIFont.systemFont(ofSize: 15), .foregroundColor: UIColor.white])
//            let messageObj = MockMessage(attributedText: attributedText, sender: self.sender!, messageId: callHistory.lastMessage ?? "Call" , date: Date.init(milliseconds: callHistory.createdDate ))
            
            if let sender = self.sender
            {
                self.insertMessage(chat: chatModel, sender: sender)
            }
        }
    }
    
    fileprivate func initChatHistorySenderAndReceiver()
    {
        if self.profile == nil && self.chatHistory == nil
        {
            print("\(TAG) Comming from invalid source view controller")
            return
        }
        
        if chatHistory == nil
        {
            chatHistory = ChatHistory()
            
            if let profile = self.profile, let uniqueId = self.profile?.uniqueId
            {
                if let chatHistoryObj = DatabaseManager.shared.getChatHistory(for: uniqueId)
                {
                    chatHistory = chatHistoryObj
                }
                chatHistory?.avatarUrl = profile.imageList?.first?.url
                chatHistory?.contactNumber = profile.contactNumber
                chatHistory?.name = profile.name
                chatHistory?.uniqueId = profile.uniqueId
            }
        }

        self.receiver = Sender(id: chatHistory?.uniqueId ?? "", displayName: chatHistory?.name ?? "")

        self.sender = Sender(id: self.myProfile?.jabberId ?? "" , displayName: self.myProfile?.name ?? "")
        
        print("\(TAG) MyProfileId : \(String(describing: self.myProfile.uniqueId)) \nUserProfileId : \(String(describing: self.profile?.uniqueId))")
        print("\(TAG) UserProfileId : \(String(describing: self.profile?.uniqueId))")
        print("\(TAG) Sender : \(self.sender.debugDescription)")
        print("\(TAG) Receiver : \(self.receiver.debugDescription))")
        print("\(TAG) ChatHistory : \(self.chatHistory.debugDescription)")
        
    }
    
    
    func insertMessage(chat: ChatModel, sender : Sender) {
        
        guard let chatId = chat.chatId, let message = chat.message else {
            return
        }
        
        var textColor = UIColor.black
        if sender.id == self.sender?.id
        {
            textColor = UIColor.white
        }
        
        let attributedText = NSAttributedString(string: message, attributes: [.font: UIFont.systemFont(ofSize: 15), .foregroundColor: textColor])
        let messageObj = MockMessage(attributedText: attributedText, sender: sender, messageId: chatId, date: Date.init(milliseconds: chatHistory?.createdDate ?? Date().millisecondsSince1970))
        
        chatList.append(chat)
        messageList.append(messageObj)
        
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
    
    public func loadChatMessage()
    {
        if let chatObjList = DatabaseManager.shared.getChatList(for: (chatHistory?.uniqueId)!) {
            self.chatList = chatObjList
            if chatObjList.count > 0
            {
                for chat in chatList
                {
                    if chat.messageSource == MessageSource.sent.rawValue
                    {
                        let sender = Sender.init(id: myProfile.uniqueId ?? "", displayName: myProfile.name ?? "")
                        
                        let attributedText = NSAttributedString(string: chat.message ?? "", attributes: [.font: UIFont.systemFont(ofSize: 15), .foregroundColor: UIColor.white])
                        let  mockMessage = MockMessage(attributedText: attributedText, sender: sender, messageId:chat.chatId ?? "" , date: Date.init(milliseconds: chat.messageDate ))
                       // self.messageList.insert(mockMessage, at: 0)
                        self.messageList.append(mockMessage)
                    }else{
                        let sender = Sender.init(id: chat.uniqueId ?? "", displayName: chatHistory?.name ?? "")
                        
                        let attributedText = NSAttributedString(string: chat.message ?? "", attributes: [.font: UIFont.systemFont(ofSize: 15), .foregroundColor: UIColor.black])
                        let  mockMessage = MockMessage(attributedText: attributedText, sender: sender, messageId:chat.chatId ?? "" , date: Date.init(milliseconds: chat.messageDate ))
                       // self.messageList.insert(mockMessage, at: 0)
                        self.messageList.append(mockMessage)
                    }
                }
                self.messagesCollectionView.reloadDataAndKeepOffset()
            }
        }
    }
    
    
}


extension ChatViewController
{
    private func setupNavBar()
    {
        guard let chatHistory = chatHistory else {
            return
        }
        
        let titleView = UIView.init()
        titleView.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH - 120 , height: 44)
        titleView.backgroundColor = UIColor.clear
        
        let title = UILabel.init()
        title.frame = titleView.bounds
        title.text = chatHistory.name
        title.textAlignment = .center
        title.textColor = UIColor.appPrimaryBlueColor
        title.font = UIFont.autoScale(weight: .semibold, size: 17)
        titleView.addSubview(title)
        
        if let imageUrl = self.chatHistory?.avatarUrl , let uniqueId =  myProfile.uniqueId
        {
            let thumbImg = UIImageView.init()
            thumbImg.frame = CGRect(x: 0, y: 2, width: 36, height: 36)
            titleView.addSubview(thumbImg)
            title.frame = CGRect(x: 40, y: 0, width: titleView.bounds.size.width - 40, height: 44)
            title.textAlignment = .left
            thumbImg.contentMode = .scaleAspectFill
            thumbImg.layer.cornerRadius = 18
            thumbImg.clipsToBounds = true
            
            thumbImg.setKfImage(url: imageUrl, placeholder: Util.defaultThumImage(), uniqueId: uniqueId)
        }
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(openUserDetail))
        titleView.addGestureRecognizer(tapGesture)
        self.navigationItem.titleView = titleView
    }
    
    @objc fileprivate func openUserDetail()
    {
        let userDetailViewController = UIStoryboard.getViewController(identifier: "UserDetailViewController") as! UserDetailViewController
        userDetailViewController.chatHistory = chatHistory
        userDetailViewController.fromChatPage = true
        self.navigationController?.pushViewController(userDetailViewController, animated: true)
    }
    
}


// MARK: - MessagesDisplayDelegate
extension ChatViewController: MessagesDisplayDelegate {
    
    // MARK: - Text Messages
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .white : .darkText
    }
    
    func detectorAttributes(for detector: DetectorType, and message: MessageType, at indexPath: IndexPath) -> [NSAttributedString.Key: Any] {
        return MessageLabel.defaultAttributes
    }
    
    func enabledDetectors(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [DetectorType] {
        return [.url, .address, .phoneNumber, .date, .transitInformation]
    }
    
    // MARK: - All Messages
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .appPrimaryColor : .chatTextBgColor
    }
    
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let tail: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(tail, .curved)
        //return .bubble
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        let avatar = self.getAvatarFor(sender: message.sender)
        avatarView.set(avatar: avatar)
    }
    
    
//    func avatarSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize {
//        return .zero
//    }
    
    // MARK: - Location Messages
    func annotationViewForLocation(message: MessageType, at indexPath: IndexPath, in messageCollectionView: MessagesCollectionView) -> MKAnnotationView? {
        let annotationView = MKAnnotationView(annotation: nil, reuseIdentifier: nil)
        let pinImage = #imageLiteral(resourceName: "ic_location")
        annotationView.image = pinImage
        annotationView.centerOffset = CGPoint(x: 0, y: -pinImage.size.height / 2)
        return annotationView
    }
    
    func animationBlockForLocation(message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> ((UIImageView) -> Void)? {
        return { view in
            view.layer.transform = CATransform3DMakeScale(2, 2, 2)
            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0, options: [], animations: {
                view.layer.transform = CATransform3DIdentity
            }, completion: nil)
        }
    }
    
    func snapshotOptionsForLocation(message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> LocationMessageSnapshotOptions {
        return LocationMessageSnapshotOptions(showsBuildings: true, showsPointsOfInterest: true, span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10))
    }
}

// MARK: - MessagesLayoutDelegate
extension ChatViewController: MessagesLayoutDelegate {
    
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 18
    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 10
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 16
    }
}

extension ChatViewController: MessagesDataSource {
    func currentSender() -> SenderType {
        return self.sender!
    }
    
    
    // MARK: - MessagesDataSource
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messageList.count
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messageList[indexPath.section]
    }
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        
        var messageDate = MessageKitDateFormatter.shared.string(from: message.sentDate)
        if indexPath.section != 0 {
            // get previous message
            let previousIndexPath = IndexPath(row: 0, section: indexPath.section - 1)
            let previousMessage = messageForItem(at: previousIndexPath, in: messagesCollectionView)
            if message.sentDate.isInSameDayOf(date: previousMessage.sentDate) {
                messageDate = ""
            }
        }
        return NSAttributedString(string: messageDate, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor.darkGray])
    }
    
    
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let dateString = Util.chatDateFormatter.string(from: message.sentDate)
       // return NSAttributedString(string: dateString, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2)])

        let displayDate = NSAttributedString(string: dateString, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2)])
        let finalString = NSMutableAttributedString.init()
        let chatModel = chatList[indexPath.section]
        
        if chatModel.chatId == message.messageId && chatModel.messageSentStatus == MessageSentStatus.failed.rawValue {
            
            let failString = NSAttributedString(string: "  fail", attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2), NSAttributedString.Key.foregroundColor : UIColor.red])
            finalString.append(displayDate)
            finalString.append(failString)
        }else {
            finalString.append(displayDate)
        }
        return finalString

    }
}

// MARK: - MessageInputBarDelegate
extension ChatViewController: MessageInputBarDelegate {
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
    
        if Reachability.isInternetConnected()
        {
                for component in inputBar.inputTextView.components {
                    if let message = component as? String {
                        self.sendMessage(message: message, chatModel: nil)
                    }
                }
                inputBar.inputTextView.text = String()
                messagesCollectionView.scrollToBottom(animated: true)
            
            if ChatManager.share.connectionSatus != .connected || ChatManager.share.connectionSatus != .connecting
            {
                // Connection is not alive
                self.checkAndConnectWithChatServer()
            }
        }
        else {
            self.showNotficationMessage(message: NSLocalizedString("M_INTERNET_CONNECTION", comment: ""))
        }
    }
    
    func showNotficationMessage(message : String)
    {
        let notificationView = NotificationView.default
        notificationView.body = message
        notificationView.show()
    }
    
    fileprivate func sendMessage(message : String, chatModel: ChatModel?)
    {
        if self.profile == nil && self.chatHistory == nil
        {
            return
        }
        
        if !self.getIsSubscribeuser {
            if let uniqueId = chatHistory?.uniqueId {
                if !Util.getChatAllowedForThisUser(userId: uniqueId){
                    let subscriptionPage = SubscriptionAleartVC()
                    subscriptionPage.openSubscriptionPage = {
                        () in
                        self.proceedForOpenSubscription()
                    }
                    subscriptionPage.modalPresentationStyle = .fullScreen
                    self.present(subscriptionPage, animated: true, completion: nil)
                    return
                }
            }
        }
        
        self.chatHistory?.createdDate = Date().millisecondsSince1970
        self.chatHistory?.lastMessage = message
        
        if self.chatHistory?.connectionStatus == ConnectionStatus.new.rawValue
        {
            Util.showLoader()
            
            if let uniqueId = self.chatHistory?.uniqueId
            {
                RequestManager.shared.addConnectionRequest(bParty: uniqueId, onCompletion: { (responseJson) in
                    DispatchQueue.main.async {
                        Util.hideLoader()
                        let response =  Response.init(json: responseJson)
                        if response.status?.uppercased() == ResoponseStatus.SUCCESS.rawValue
                        {
                            self.updateChatDetails(chatModel: chatModel)
                        }else {
                            AlertView().showNotficationMessage(message: NSLocalizedString("M_FAILED_TO_SENT_CHAT", comment: ""))
                        }
                    }
                }) { (error) in
                    DispatchQueue.main.async {
                        Util.hideLoader()
                        AlertView().showNotficationMessage(message: NSLocalizedString("M_FAILED_TO_SENT_CHAT", comment: ""))
                    }
                }
            }else{
                AlertView().showNotficationMessage(message: NSLocalizedString("M_FAILED_TO_SENT_CHAT", comment: ""))
            }
        }else {
            self.updateChatDetails(chatModel: chatModel)
        }
    }
    
    
    func proceedForOpenSubscription() {
        openSubscriptionPage()
    }
    
    
    func openSubscriptionPage(){
        let recentViewController = UIStoryboard.getViewController(identifier: "AppPurchasePacksVC")
        recentViewController.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(recentViewController, animated: true)
    }

    
    fileprivate func updateChatDetails(chatModel: ChatModel?)
    {
        if chatModel == nil {
            retrySelectedIndex = -1
            self.chatHistory?.connectionStatus = ConnectionStatus.connected.rawValue
            DatabaseManager.shared.saveUpdateChatHistory(chatHistory: self.chatHistory!)
            
            let chatId = UUID().uuidString
            var chat = ChatModel.init()
            chat.chatId = chatId
            chat.uniqueId = self.chatHistory?.uniqueId
            chat.messageSource = MessageSource.sent.rawValue
            chat.type = ChatType.chat.rawValue
            chat.messageDate = self.chatHistory?.createdDate ?? 0
            chat.message = self.chatHistory?.lastMessage
            DatabaseManager.shared.saveUpdateChat(chat: chat)
            
            if let sender = self.sender {
                self.insertMessage(chat: chat, sender: sender)
            }
            
            
            ChatManager.share.sendMessage(toJabberId: self.receiver?.id ?? "", message: self.chatHistory?.lastMessage ?? "", name: self.sender?.displayName, dateTime: self.chatHistory?.createdDate)
        }else {
            if let chatModel = chatModel {
                ChatManager.share.sendMessage(toJabberId: self.receiver?.id ?? "", message: chatModel.message ?? "", name: self.sender?.displayName, dateTime: chatModel.messageDate)
            }
            
        }
    }
}


extension ChatViewController : ChatManagerDelegate
{
    func didSendMessage() {
        
    }
    
    func didReceiveMessage(chat : ChatModel, sender : Sender)
    {
        DatabaseManager.shared.clearUnReadCountInChatHistory(for: sender.id)
        if let receiverD = receiver {
            if sender.id == receiverD.id {
                self.insertMessage(chat: chat, sender: sender)
            }
        }
        
    }
    
    
    func didFailedMessage(mxppMessage: String, error: Error) {
        print("message send failed ")
        
        if retrySelectedIndex == -1 {
            retrySelectedIndex = chatList.count - 1
        }
        
        var chatModel = chatList[retrySelectedIndex]
        chatModel.messageSentStatus = 2
        chatList.remove(at: (retrySelectedIndex))
        chatList.insert(chatModel, at: retrySelectedIndex)
        updateChatDb(chatModel: chatModel)

        messagesCollectionView.performBatchUpdates({
            if messageList.count > 0 {
                messagesCollectionView.reloadSections([retrySelectedIndex])
            }
        }, completion: { [weak self] _ in
            if self?.isLastSectionVisible() == true {
                self?.messagesCollectionView.scrollToBottom(animated: true)
            }
        })
        retrySelectedIndex = -1
    }
    
    
    
    
    private func updateChatDb(chatModel: ChatModel){
        print("\(TAG)  update chat on DB -: \(chatModel)")
        DatabaseManager.shared.saveUpdateChat(chat: chatModel)
    }
    
    private func showFailedMessageDialog() {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Retry", comment: ""), style: .default, handler: { (_) in
            print("User click Approve button")
            self.retryMessage()
        }))
        
//        alert.addAction(UIAlertAction(title: "Delete", style: .default, handler: { (_) in
//            print("User click Edit button")
//            self.deleteSelectedMessage()
//        }))
//        
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (_) in
            print("User click Dismiss button")
            self.retrySelectedIndex = -1
        }))
        alert.modalPresentationStyle = .fullScreen
        self.present(alert, animated: true, completion: {
            print("completion block")
        })
        
    }
    
    
    private func isMessageFailed(index: Int){
        retrySelectedIndex = index
        let chatModel = chatList[retrySelectedIndex]
        if chatModel.messageSentStatus == MessageSentStatus.failed.rawValue {
            showFailedMessageDialog()
        }
    }
    
    
    private func deleteSelectedMessage(){
        if retrySelectedIndex != -1 {
            let chatModel = chatList[retrySelectedIndex]
            chatList.remove(at: (retrySelectedIndex))
            messageList.remove(at: retrySelectedIndex)
            
            DatabaseManager.shared.deleteChatFromChatId(chatModel: chatModel)
            messagesCollectionView.reloadDataAndKeepOffset()
        }
    }
    
    private func retryMessage() {
        var chatModel = chatList[retrySelectedIndex]
        if let message = chatModel.message {
            if retrySelectedIndex != -1 {
                chatModel.messageSentStatus = MessageSentStatus.sent.rawValue
                chatList.remove(at: (retrySelectedIndex))
                chatList.insert(chatModel, at: (retrySelectedIndex))
                updateChatDb(chatModel: chatModel)
                
                messagesCollectionView.performBatchUpdates({
                    if messageList.count > 0 {
                        messagesCollectionView.reloadSections([retrySelectedIndex])
                    }
                }, completion: { [weak self] _ in
                    if self?.isLastSectionVisible() == true {
                        self?.messagesCollectionView.scrollToBottom(animated: true)
                    }
                })
            }
            sendMessage(message: message , chatModel: chatModel)

        }
    }
}


// MARK: - MessageCellDelegate
extension ChatViewController: MessageCellDelegate {
    
    func didTapAvatar(in cell: MessageCollectionViewCell) {
        print("\(TAG)  Avatar tapped")
        if let indexPath = messagesCollectionView.indexPath(for: cell)?.section {
            isMessageFailed(index: indexPath)
        }
        

    }
    
    func didTapMessage(in cell: MessageCollectionViewCell) {
                print("\(TAG)  Message tapped ")
        if let indexPath = messagesCollectionView.indexPath(for: cell)?.section {
            isMessageFailed(index: indexPath)
        }
    }
    
    func didTapCellTopLabel(in cell: MessageCollectionViewCell) {
        print("\(TAG)  Top cell label tapped")
        if let indexPath = messagesCollectionView.indexPath(for: cell)?.section {
            isMessageFailed(index: indexPath)
        }

    }
    
    func didTapMessageTopLabel(in cell: MessageCollectionViewCell) {
        print("\(TAG)  Top message label tapped")
        if let indexPath = messagesCollectionView.indexPath(for: cell)?.section {
            isMessageFailed(index: indexPath)
        }
    }
    
    func didTapMessageBottomLabel(in cell: MessageCollectionViewCell) {
        print("\(TAG)  Bottom label tapped")
        if let indexPath = messagesCollectionView.indexPath(for: cell)?.section {
            isMessageFailed(index: indexPath)
        }
    }
    
    func didTapAccessoryView(in cell: MessageCollectionViewCell) {
        print("\(TAG)  Accessory view tapped")
        if let indexPath = messagesCollectionView.indexPath(for: cell)?.section {
            isMessageFailed(index: indexPath)
        }
    }
}

// MARK: - MessageLabelDelegate
extension ChatViewController: MessageLabelDelegate {
    
    func didSelectAddress(_ addressComponents: [String: String]) {
        print("\(TAG)  Address Selected: \(addressComponents)")
    }
    
    func didSelectDate(_ date: Date) {
        print("\(TAG)  Date Selected: \(date)")
    }
    
    func didSelectPhoneNumber(_ phoneNumber: String) {
        print("\(TAG)  Phone Number Selected: \(phoneNumber)")
    }
    
    func didSelectURL(_ url: URL) {
        print("\(TAG)  URL Selected: \(url)")
    }
    
    func didSelectTransitInformation(_ transitInformation: [String: String]) {
        print("\(TAG)  TransitInformation Selected: \(transitInformation)")
    }
}

extension ChatViewController {
    
    private func sendOpenChatScreenAnalytics(profile: Profile?, status: String){
        if let udid = profile?.uniqueId {
            AppAnalytics.log(.chatOpen(uid: udid, xmppStatus: status))
            TPAnalytics.log(.chatOpen(uid: udid, xmppStatus: status))
        }
    }
}



extension ChatViewController: AlertViewDelegate {
    func okButtonAction(tag: Int) {
        if tag == 1 {
//            UIApplication.shared.openURL(URL(string:"prefs:root=WIFI")!)
        }
    }
    
    func cancelButtonAction(tag: Int) {
        if tag == 1 {
            
        }
    }
    
    
}
