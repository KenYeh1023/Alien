//
//  NotificationViewController.swift
//  Alien
//
//  Created by Ken Yeh on 2019/9/3.
//  Copyright © 2019 Ken Yeh. All rights reserved.
//

import Foundation
import UIKit
import Firebase

struct showDetail {
    var requestName: String
    var imageView: String
    
    init(requestName: String, imageView: String) {
        self.imageView = imageView
        self.requestName = requestName
    }
}

struct Notification {
    var notificationTimeStamp: String
    var notificationGroupOwner: String
    var notificationGameName: String
    var notificationGroupAutoID: String
    var notificationstatus: String
    var notificationRequestBy: String
    var notificationID: String
    var notificationText1: String = "申請加入了您的揪團"
    var imageView: String = ""
    var notificationStatus: String = ""
    
    init(notificationTimeStamp: String, notificationGroupOwner: String, notificationGameName: String, notificationGroupAutoID: String, notificationstatus: String, notificationRequestBy: String, notificationID: String) {
     self.notificationGameName = notificationGameName
     self.notificationGroupOwner = notificationGroupOwner
     self.notificationGroupAutoID = notificationGroupAutoID
        self.notificationstatus = notificationstatus
        self.notificationRequestBy = notificationRequestBy
        self.notificationID = notificationID
        self.notificationTimeStamp = notificationTimeStamp
    }
    
    init?(snapshot: DataSnapshot) {
        if let notificationDict: [String: Any] = snapshot.value as? [String: Any],
            let gameName: String = notificationDict["groupGame"] as? String,
            let groupID: String = notificationDict["groupID"] as? String,
            let groupOwner: String = notificationDict["groupOwner"] as? String,
            let requestBy: String = notificationDict["requestBy"] as? String,
            let status: String = notificationDict["status"] as? String,
            let timeStamp: String = notificationDict["timeStamp"] as? String {
            self.notificationID = snapshot.key
            self.notificationGameName = gameName
            self.notificationGroupAutoID = groupID
            self.notificationGroupOwner = groupOwner
            self.notificationRequestBy = requestBy
            self.notificationstatus = status
            self.notificationTimeStamp = timeStamp
            
        } else {
         return nil
        }
    }
    
    func toAnyObject() -> Any {
        return [
            "groupGame": notificationGameName,
            "groupID": notificationGroupAutoID,
            "groupOwner": notificationGroupOwner,
            "requestBy": notificationRequestBy,
            "status": notificationstatus,
            "timeStamp": notificationTimeStamp
        ]
    }
}

class NotificationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var notificationArray: [Notification] = []
    var notificationArraySection2: [Notification] = []
    
    @IBOutlet weak var NotificationTableView: UITableView!
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
        return notificationArray.count
        } else {
         return notificationArraySection2.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print(indexPath.section)
        if indexPath.section == 0 {
            //////
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! NotificationTableViewCell
            let dateFormatter: DateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YYYY/MM/dd HH:mm:ss"
            if let timeAgo = dateFormatter.date(from: notificationArray[indexPath.row].notificationTimeStamp) {
            cell.timeStamp.text = timeAgo.timeAgoDisplay()
            } else {
             print("Fail to get time stamp")
            }
            cell.notificationContentView.layer.cornerRadius = 10
            cell.notificationContentView.layer.borderColor = UIColor(red: 98.0/255.0, green: 179/255.0, blue: 156/255.0, alpha: 1).cgColor
            cell.notificationContentView.layer.borderWidth = 2
            cell.userNameText.setTitleColor(UIColor.white, for: .normal)
            cell.userNameText.titleLabel?.font = .systemFont(ofSize: 11)
            cell.notificationText.textColor = UIColor(red: 98.0/255.0, green: 179/255.0, blue: 156/255.0, alpha: 1)
            let ref = Database.database().reference(withPath: "users")
            let userRef = ref.child(self.notificationArray[indexPath.row].notificationRequestBy)
            userRef.observe(.value) { (snapshot) in
                if let ValueDict: [String: Any] = snapshot.value as? [String: Any] {
                    if let nameValue: String = ValueDict["name"] as? String, let imageValue: String = ValueDict["image"] as? String {
                            cell.userNameText.setTitle(nameValue, for: .normal)
                            self.notificationArray[indexPath.row].imageView = imageValue
                            let url = URL(string: imageValue)
                            let task = URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
                            if error != nil {
                                DispatchQueue.main.async {
                                cell.userProfilePicture.image = UIImage(named: "defaultProfilePicture")
                                }
                                print("error")
                                return
                            }
                            DispatchQueue.main.async {
                                cell.userProfilePicture.image = UIImage(data: data!)
                            }
                        })
                        task.resume()
                    }
                }
            }
                    cell.notificationText.text = self.notificationArray[indexPath.row].notificationText1
                    cell.agreeButtonOutlet.isHidden = false
                    cell.rejectButtonOutlet.isHidden = false
            //////
            cell.gameNameText.setTitle(notificationArray[indexPath.row].notificationGameName, for: .normal)
            return cell
            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! NotificationTableViewCell
            let dateFormatter: DateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YYYY/MM/dd HH:mm:ss"
            if let timeAgo = dateFormatter.date(from: notificationArraySection2[indexPath.row].notificationTimeStamp) {
                cell.timeStamp.text = timeAgo.timeAgoDisplay()
            } else {
             print("Fail to get time stamp")
            }
            cell.userNameText.setTitleColor(UIColor.white, for: .normal)
            cell.userNameText.titleLabel?.font = .systemFont(ofSize: 11)
            if notificationArraySection2[indexPath.row].notificationStatus == "reject" {
                notificationArraySection2[indexPath.row].notificationText1 = "婉拒了您的加入請求"
            } else if notificationArraySection2[indexPath.row].notificationStatus == "kick" {
                notificationArraySection2[indexPath.row].notificationText1 = "將您踢出了揪團"
            }
            cell.notificationText.textColor = UIColor(red: 98.0/255.0, green: 179/255.0, blue: 156/255.0, alpha: 1)
            cell.notificationText.text = notificationArraySection2[indexPath.row].notificationText1
            cell.gameNameText.setTitle(notificationArraySection2[indexPath.row].notificationGameName, for: .normal)
            
            let ref = Database.database().reference(withPath: "users")
            let userRef = ref.child(notificationArraySection2[indexPath.row].notificationGroupOwner)
            userRef.observe(.value) { (snapshot) in
                if let ValueDict: [String: Any] = snapshot.value as? [String: Any] {
                    if let nameValue: String = ValueDict["name"] as? String, let imageValue: String = ValueDict["image"] as? String {
                     cell.userNameText.setTitle(nameValue, for: .normal)
                        let url = URL(string: imageValue)
                        let task = URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
                            if error != nil {
                                print("error")
                                return
                            }
                            DispatchQueue.main.async {
                                cell.userProfilePicture.image = UIImage(data: data!)
                            }
                        })
                        task.resume()
                    }
                }
            }
            cell.agreeButtonOutlet.isHidden = true
            cell.rejectButtonOutlet.isHidden = true
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "要求加入揪團通知"
        } else {
            return "最新消息"
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationTableView.rowHeight = UITableView.automaticDimension
        NotificationTableView.estimatedRowHeight = 70
        
        if let userID: String = Auth.auth().currentUser?.uid {
            
            let ref = Database.database().reference(withPath: "notifications")
            ref.queryOrdered(byChild: "groupOwner").queryEqual(toValue: userID).observe(.value) { (snapshot) in
                var newNotificationArray: [Notification] = []
                for child in snapshot.children {
                    if let childDataSnapshot: DataSnapshot = child as? DataSnapshot {
                        if let notificationDict: [String: Any] = childDataSnapshot.value as? [String: Any] {
                            if let statusValue: String = notificationDict["status"] as? String {
                                if statusValue == "0" {
                                    if let notificationValue: Notification = Notification(snapshot: childDataSnapshot) {
                                        newNotificationArray.append(notificationValue)
                                        print(newNotificationArray)
                                    } else {
                                     print("Get nil when Notification")
                                    }
                                }
                            } else {
                             print("Can not convert status to String")
                            }
                        } else {
                            print("Cant not convert notificationDict to [String: Any]")
                        }
                    } else {
                     print("Can not conver child to DataSnapshot")
                    }
                }
                self.notificationArray = newNotificationArray
                self.NotificationTableView.reloadData()
            }
            
            ref.queryOrdered(byChild: "requestBy").queryEqual(toValue: userID).observe(.value) { (snapshot) in
                var rejectNotificationArray: [Notification] = []
                for child in snapshot.children {
                    if let childDataSnapshot: DataSnapshot = child as? DataSnapshot {
                        if let notificationDict: [String :Any] = childDataSnapshot.value as? [String: Any] {
                            if let statusValue: String = notificationDict["status"] as? String {
                                if statusValue == "2" {
                                    if var rejectNotificationValue: Notification = Notification(snapshot: childDataSnapshot) {
                                     rejectNotificationValue.notificationStatus = "reject"
                                     rejectNotificationArray.append(rejectNotificationValue)
                                    }
                                } else if statusValue == "3" {
                                    if var kickNotificationValue: Notification = Notification(snapshot: childDataSnapshot) {
                                        kickNotificationValue.notificationStatus = "kick"
                                        rejectNotificationArray.append(kickNotificationValue)
                                    }
                                }
                            }
                        }
                    }
                }
                self.notificationArraySection2 = rejectNotificationArray
                self.NotificationTableView.reloadData()
            }
        } else {
         print("Invalid User")
        }
     }
    
    ///////////////如果房間人數超過上限便無法同意進入
    @IBAction func notificationAgreeButtonPressed(_ sender: UIButton) {
        if let cell = sender.superview?.superview?.superview as? NotificationTableViewCell {
            if let indexPath = NotificationTableView.indexPath(for: cell) {
            let groupRef = Database.database().reference(withPath: "groups")
            let currentMemberRef = groupRef.child(notificationArray[indexPath.row].notificationGroupAutoID)
                currentMemberRef.observeSingleEvent(of: .value) { (snapshot) in
                    if var ValueDict: [String: Any] = snapshot.value as? [String: Any], var currentMemberArray: [String] = ValueDict["currentMemberInGroup"] as? [String], let maxNumberValue: String = ValueDict["maxNumberOfMemberInGroup"] as? String, let maxNumberIntValue: Int = Int(maxNumberValue) {
                        if maxNumberIntValue > currentMemberArray.count {
                            currentMemberArray.append(self.notificationArray[indexPath.row].notificationRequestBy)
                            ValueDict["currentMemberInGroup"] = currentMemberArray
                            currentMemberRef.setValue(ValueDict)
                        print(currentMemberArray)

                        let ref = Database.database().reference(withPath: "notifications")
                        let notificationRef = ref.child(self.notificationArray[indexPath.row].notificationID)
                        self.notificationArray[indexPath.row].notificationstatus = "1"
                        notificationRef.setValue(self.notificationArray[indexPath.row].toAnyObject())
                        } else {
                            let Alert = UIAlertController(title: "批准加入失敗", message: "此揪團人數已達上限", preferredStyle: .alert)
                            Alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(Alert, animated: true, completion: nil)
                        }
                    } else {
                     print("Can not conver to [String]")
                    }
                }
            } else {
                print("Wrong IndexPath Selected")
            }
        } else {
         print("Wromg TableViewCell Selected")
        }
    }
    
    
    @IBAction func rejectButtonPressed(_ sender: UIButton) {
        
        print("Rejected Request")
        if let cell = sender.superview?.superview?.superview as? NotificationTableViewCell {
            if let indexPath = NotificationTableView.indexPath(for: cell) {
                        
                        let ref = Database.database().reference(withPath: "notifications")
                        let notificationRef = ref.child(self.notificationArray[indexPath.row].notificationID)
                        self.notificationArray[indexPath.row].notificationstatus = "2"
                        notificationRef.setValue(self.notificationArray[indexPath.row].toAnyObject())
                
            } else {
                print("Wrong IndexPath Selected")
            }
        } else {
            print("Wromg TableViewCell Selected")
        }
    }
    
    
    @IBAction func userNameButtonPressed(_ sender: UIButton) {
        if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "OtherUserPage") as? OtherUserViewController {
            if let cell = sender.superview?.superview?.superview as? NotificationTableViewCell {
                if let indexPath = NotificationTableView.indexPath(for: cell) {
                    if indexPath.section == 0 {
                        
                    viewController.userID = notificationArray[indexPath.row].notificationRequestBy
                    present(viewController, animated: true, completion: nil)
                        
                    } else {
                        
                     viewController.userID = notificationArraySection2[indexPath.row].notificationGroupOwner
                        present(viewController, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    
    @IBAction func gameNameButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "showGroupDetailFromNotification", sender: sender)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showGroupDetailFromNotification" {
            if let senderButton: UIButton = sender as? UIButton {
            if let cell = senderButton.superview?.superview?.superview as? NotificationTableViewCell {
                if let indexPath = NotificationTableView.indexPath(for: cell) {
                    if indexPath.section == 0 {
                    if let viewController = segue.destination as? GroupDetailViewController {
                        let ref = Database.database().reference(withPath: "groups")
                        let groupRef = ref.child(self.notificationArray[indexPath.row].notificationGroupAutoID)
                        groupRef.observeSingleEvent(of: .value) { (snapshot) in
                            if let groupValue: Group = Group(snapshot: snapshot) {
                                viewController.groupDetailActivityTimeText = groupValue.groupActivityTime
                                viewController.groupDetailAutoIDText = groupValue.groupAutoID
                                viewController.groupDetailCurrentNumberOfMemberText = groupValue.maxNumberOfMemberInGroup
                                viewController.groupDetailGameText = groupValue.gameTitle
                                viewController.groupDetailGroupOwnerText = groupValue.groupOwner
                                viewController.groupDetailTitleText = groupValue.groupTitle
                                    }
                                }
                            }
                        } else if indexPath.section == 1 {
                        if let viewController = segue.destination as? GroupDetailViewController {
                            let ref = Database.database().reference(withPath: "groups")
                            let groupRef = ref.child(self.notificationArraySection2[indexPath.row].notificationGroupAutoID)
                            groupRef.observeSingleEvent(of: .value) { (snapshot) in
                                if let groupValue: Group = Group(snapshot: snapshot) {
                                    viewController.groupDetailActivityTimeText = groupValue.groupActivityTime
                                    viewController.groupDetailAutoIDText = groupValue.groupAutoID
                                    viewController.groupDetailCurrentNumberOfMemberText = groupValue.maxNumberOfMemberInGroup
                                    viewController.groupDetailGameText = groupValue.gameTitle
                                    viewController.groupDetailGroupOwnerText = groupValue.groupOwner
                                    viewController.groupDetailTitleText = groupValue.groupTitle
                                }
                            }
                        }
                        
                    }
                }
            } else {
             print("Wrong Cell SuperView")
            }
        } else {
         print("Sender is not UIButton")
        }
    }
  }
    
    
}

extension Date {
    func timeAgoDisplay() -> String {
        let secondsAgo = Int(Date().timeIntervalSince(self))
        
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        let week = 7 * day
        
        if secondsAgo < minute {
         return "\(secondsAgo) seconds ago"
        } else if secondsAgo < hour {
         return "\(secondsAgo / minute) minutes ago"
        } else if secondsAgo < day {
         return "\(secondsAgo / hour) hours ago"
        } else if secondsAgo < week {
         return "\(secondsAgo / day) days ago"
        } else {
        return "\(secondsAgo / week) weeks ago"
        }
    }
}
