//
//  ChatRoomViewController.swift
//  Alien
//
//  Created by Ken Yeh on 2019/10/14.
//  Copyright © 2019 Ken Yeh. All rights reserved.
//

struct Message {
    var userID: String
    var timeStamp: String
    var message: String
    var messageAutoID: String
    
    init(userID: String, timeStamp: String, message: String, messageAutoID: String){
        self.userID = userID
        self.timeStamp = timeStamp
        self.message = message
        self.messageAutoID = messageAutoID
    }
}

import UIKit
import Firebase

class ChatRoomViewController: UIViewController {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    var chatRoomAutoID: String?
    var chatRoomTitleText: String?
    var chatRoomActivityTimeText: String?
    var chatRoomCurrentNumberOfMemberText: String?
    var chatRoomGameText: String?
    var chatRoomGroupOwnerText: String?
    
    @IBOutlet weak var chatRoomTableView: UITableView!
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var textFieldView: UIView!
    
    var messageArray: [Message] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let button = UIButton.init(type: .custom)
        button.setImage(UIImage.init(named: "info"), for: UIControl.State.normal)
        button.addTarget(self, action:#selector(rightBarButtonPressed), for:.touchUpInside)
        button.frame = CGRect.init(x: 0, y: 0, width: 30, height: 30)
        let barButton = UIBarButtonItem.init(customView: button)
        self.navigationItem.rightBarButtonItem = barButton
        
        let userXib = UINib(nibName: "UserMessageTableViewCell", bundle: nil)
        let otherUserXib = UINib(nibName: "OtherUserMessageTableViewCell", bundle: nil)
        chatRoomTableView.register(userXib, forCellReuseIdentifier: "UserMessageTableViewCell")
        chatRoomTableView.register(otherUserXib, forCellReuseIdentifier: "OtherUserMessageTableViewCell")
        self.fetchMessage()
    }
    
    
    @IBAction func messageSendButtonPressed(_ sender: Any) {
        if self.inputTextField.text != "" {
            if let message = self.inputTextField.text {
                let currentDate = Date()
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale(identifier: "zh_Hant_TW")
                dateFormatter.dateFormat = "HH:mm\nyyyy/MM/dd"
                let dateString = dateFormatter.string(from: currentDate)
                let ref = Database.database().reference()
                let messageRef = ref.child("messages")
                let chatRoomRef = messageRef.child(chatRoomAutoID!)
                let valueDict: [String: Any] = ["userID": Auth.auth().currentUser!.uid, "timeStamp": dateString, "message": message]
                chatRoomRef.childByAutoId().setValue(valueDict)
                self.inputTextField.text = ""
                
            } else {
             print("Invalid Input Text")
            }
        } else {
         print("Space")
        }
    }
    
    func fetchMessage() {
        let ref = Database.database().reference()
        let chatRoomRef = ref.child("messages").child(chatRoomAutoID!)
        chatRoomRef.observe(.value) { (dataSnapshot) in
            var newMessageArray: [Message] = []
            if dataSnapshot.childrenCount > 0 {
                for child in dataSnapshot.children {
                    if let snapshot = child as? DataSnapshot {
                        let messageAutoID: String = snapshot.key
                        guard
                            let valueDict: [String: Any] = snapshot.value as? [String: Any],
                            let userID: String = valueDict["userID"] as? String,
                            let timeStamp: String = valueDict["timeStamp"] as? String,
                            let message: String = valueDict["message"] as? String
                            else { return }
                        newMessageArray.append(Message(userID: userID, timeStamp: timeStamp, message: message, messageAutoID: messageAutoID))
                    }
                }
                self.messageArray = newMessageArray
                self.chatRoomTableView.reloadData()
                self.chatRoomTableView.scrollToRow(at: IndexPath(row: self.messageArray.count-1, section: 0), at: UITableView.ScrollPosition.bottom, animated: false)
            }
        }
    }
    
    @objc func rightBarButtonPressed() {
        
     performSegue(withIdentifier: "showGroupDetailFromChatRoom", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showGroupDetailFromChatRoom" {
                let groupDetail = segue.destination as! GroupDetailViewController
                groupDetail.groupDetailTitleText = self.chatRoomActivityTimeText!
                groupDetail.groupDetailGameText = self.chatRoomGameText!
                groupDetail.groupDetailCurrentNumberOfMemberText = self.chatRoomCurrentNumberOfMemberText!
                groupDetail.groupDetailActivityTimeText = self.chatRoomActivityTimeText!
                groupDetail.groupDetailAutoIDText = self.chatRoomAutoID!
                groupDetail.groupDetailGroupOwnerText = self.chatRoomGroupOwnerText!
        }
    }
}

extension ChatRoomViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let userID = Auth.auth().currentUser!.uid
            if messageArray[indexPath.row].userID == userID {
                let cell = tableView.dequeueReusableCell(withIdentifier: "UserMessageTableViewCell") as! UserMessageTableViewCell
                cell.userMessageLabel.text = messageArray[indexPath.row].message
                cell.userTimeStampLabel.text = messageArray[indexPath.row].timeStamp
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "OtherUserMessageTableViewCell") as! OtherUserMessageTableViewCell
                cell.otherUserMessageLabel.text = messageArray[indexPath.row].message
                cell.otherUserNameLabel.text = messageArray[indexPath.row].userID
                cell.timeStampLabel.text = messageArray[indexPath.row].timeStamp
                
                let ref = Database.database().reference()
                let userRef = ref.child("users").child(messageArray[indexPath.row].userID)
                userRef.observeSingleEvent(of: .value) { (snapshot) in
                    if let ValueDict: [String: Any] = snapshot.value as?[String: Any] {
                        if let nameValue: String = ValueDict["name"] as? String,
                            let imageValue: String = ValueDict["image"] as? String {
                            cell.otherUserNameLabel.text = nameValue
                            let url = URL(string: imageValue)
                            let task = URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
                                if error != nil {
                                    print("error")
                                    DispatchQueue.main.async {
                                        cell.otherUserImageView.image = UIImage(named: "defaultProfilePicture")
                                    }
                                    return
                                }
                                DispatchQueue.main.async {
                                    cell.otherUserImageView.image = UIImage(data: data!)
                                }
                            })
                            task.resume()
                        }
                    }
                }
                return cell
            }
    }
}

