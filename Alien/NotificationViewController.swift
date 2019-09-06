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

struct Notification {
    var notificationGroupOwner: String
    var notificationGameName: String
    var notificationGroupAutoID: String
    var notificationstatus: String
    var notificationRequestBy: String
    var notificationID: String
    var notificationText1: String = "申請加入了您的揪團"
    
    init(notificationGroupOwner: String, notificationGameName: String, notificationGroupAutoID: String, notificationstatus: String, notificationRequestBy: String, notificationID: String) {
     self.notificationGameName = notificationGameName
     self.notificationGroupOwner = notificationGroupOwner
     self.notificationGroupAutoID = notificationGroupAutoID
        self.notificationstatus = notificationstatus
        self.notificationRequestBy = notificationRequestBy
        self.notificationID = notificationID
    }
    
//    init?(snapshot: DataSnapshot) {
//        if let notificationValue: [String: Any] = snapshot.value as? [String: Any],
//            let gameNameValue: String = notificationValue["groupGame"] as? String,
//            let groupAutoIDValue: String = notificationValue["groupAutoID"] as? String {
//            self.notificationGameName = gameNameValue
//            self.notificationGroupAutoID = groupAutoIDValue
//            self.notificationGroupOwner = snapshot.key
//            self.notificationstatus = "0"
//        } else {
//         return nil
//        }
//    }
    init?(snapshot2: DataSnapshot) {
        if let notificationDict: [String: Any] = snapshot2.value as? [String: Any],
            let gameName: String = notificationDict["groupGame"] as? String,
            let groupID: String = notificationDict["groupID"] as? String,
            let groupOwner: String = notificationDict["groupOwner"] as? String,
            let requestBy: String = notificationDict["requestBy"] as? String,
            let status: String = notificationDict["status"] as? String {
            self.notificationID = snapshot2.key
            self.notificationGameName = gameName
            self.notificationGroupAutoID = groupID
            self.notificationGroupOwner = groupOwner
            self.notificationRequestBy = requestBy
            self.notificationstatus = status
            
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
            "status": notificationstatus
        ]
    }
}

class NotificationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var notificationArray: [Notification] = []
    var notificationArraySection2: [Notification] = [Notification(notificationGroupOwner: "ZZZZZ", notificationGameName: "CCCCC", notificationGroupAutoID: "DDDDDDD", notificationstatus: "0", notificationRequestBy: "AAAA", notificationID: "JDIU")]
    
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! NotificationTableViewCell
        if indexPath.section == 0 {
        cell.notificationText.text = notificationArray[indexPath.row].notificationText1
        cell.userNameText.setTitle(notificationArray[indexPath.row].notificationGroupOwner, for: .normal)
        cell.gameNameText.setTitle(notificationArray[indexPath.row].notificationGameName, for: .normal)
        cell.agreeButtonOutlet.isHidden = false
        cell.rejectButtonOutlet.isHidden = false
        } else {
            notificationArraySection2[indexPath.row].notificationText1 = "婉拒了您的加入請求"
            cell.notificationText.text = notificationArraySection2[indexPath.row].notificationText1
            cell.userNameText.setTitle(notificationArraySection2[indexPath.row].notificationGroupOwner, for: .normal)
            cell.gameNameText.setTitle(notificationArraySection2[indexPath.row].notificationGameName, for: .normal)
            cell.agreeButtonOutlet.isHidden = true
            cell.rejectButtonOutlet.isHidden = true
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.NotificationTableView.reloadData()
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
                                    if let notificationValue: Notification = Notification(snapshot2: childDataSnapshot) {
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
        } else {
         print("Invalid User")
        }
      }
    
    @IBAction func notificationAgreeButtonPressed(_ sender: UIButton) {
        if let cell = sender.superview?.superview as? NotificationTableViewCell {
            if let indexPath = NotificationTableView.indexPath(for: cell) {
            let groupRef = Database.database().reference(withPath: "groups")
            let currentMemberRef = groupRef.child(notificationArray[indexPath.row].notificationGroupAutoID).child("currentMemberInGroup")
                currentMemberRef.observeSingleEvent(of: .value) { (snapshot) in
                    if var currentMemberArray: [String] = snapshot.value as? [String] {
                            currentMemberArray.append(self.notificationArray[indexPath.row].notificationRequestBy)
                            currentMemberRef.setValue(currentMemberArray)
                        print(currentMemberArray)

                        let ref = Database.database().reference(withPath: "notifications")
                        let notificationRef = ref.child(self.notificationArray[indexPath.row].notificationID)
                        self.notificationArray[indexPath.row].notificationstatus = "1"
                        notificationRef.setValue(self.notificationArray[indexPath.row].toAnyObject())
                        
                        DispatchQueue.main.async {
                            self.NotificationTableView.reloadData()
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
}

