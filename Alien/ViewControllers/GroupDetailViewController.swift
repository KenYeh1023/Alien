//
//  GroupDetailViewController.swift
//  Alien
//
//  Created by Ken Yeh on 2019/8/29.
//  Copyright © 2019 Ken Yeh. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class GroupDetailViewController: UIViewController {
    
    var groupDetailTitleText: String?
    var groupDetailActivityTimeText: String?
    var groupDetailCurrentNumberOfMemberText: String?
    var groupDetailGameText: String?
    var groupDetailAutoIDText: String?
    var groupDetailGroupOwnerText: String?
    
    
    @IBOutlet weak var groupDetailAutoID: UILabel!
    @IBOutlet weak var groupDetailTitle: UILabel!
    @IBOutlet weak var groupDetailActivityTime: UILabel!
    @IBOutlet weak var groupDetailCurrentNumberOfMember: UIButton!
    @IBOutlet weak var groupDetailGame: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.groupRequestButton.layer.cornerRadius = 10
        self.groupRequestButton.layer.borderWidth = 2
        self.groupRequestButton.layer.borderColor = UIColor(red: 98.0/255.0, green: 179/255.0, blue: 156/255.0, alpha: 1).cgColor
        self.groupRequestButton.setTitleColor(UIColor(red: 98.0/255.0, green: 179/255.0, blue: 156/255.0, alpha: 1), for: .normal)
        
        groupDetailTitle.text = groupDetailTitleText!
        groupDetailActivityTime.text = groupDetailActivityTimeText!
        groupDetailCurrentNumberOfMember.setTitle(groupDetailCurrentNumberOfMemberText!, for: .normal)
        groupDetailGame.text = groupDetailGameText!
        groupDetailAutoID.text = groupDetailAutoIDText!
        
        let groupRef = Database.database().reference(withPath: "groups")
        groupRef.child(groupDetailAutoIDText!).observe(.value) { (snapshot) in
            if let ValueDict: [String: Any] = snapshot.value as? [String: Any] {
                if let ValueArray: [String] = ValueDict["currentMemberInGroup"] as? [String] {
                if let currentCountOfGroup: Int = Int(self.groupDetailCurrentNumberOfMemberText!) {
                    //房間已滿
                    if currentCountOfGroup <= ValueArray.count {
                        self.groupRequestButton.layer.borderColor = UIColor.red.cgColor
                        self.groupRequestButton.layer.borderWidth = 2
                        self.groupRequestButton.titleLabel?.textColor = .red
                        self.groupRequestButton.setTitle("房間已滿", for: .normal)
                        self.groupDetailCurrentNumberOfMember.setTitle("\(ValueArray.count) / \(self.groupDetailCurrentNumberOfMemberText!)", for: .normal)
                        self.groupDetailCurrentNumberOfMember.setTitleColor(UIColor.red, for: .normal)
                        self.groupDetailCurrentNumberOfMember.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
                        //房間未滿
                    } else {
                        self.groupDetailCurrentNumberOfMember.setTitle("\(ValueArray.count) / \(self.groupDetailCurrentNumberOfMemberText!)", for: .normal)
                    }
                } else {
                    print("Can not convert String to Int")
                }
                } else {
                 print("Can't find currentMemberInGroup")
                }
            } else {
                print("Can not convert to [String: Any]")
            }
        }
        
        let ref = Database.database().reference(withPath: "notifications")
        if let userID: String = Auth.auth().currentUser?.uid {
            if userID != self.groupDetailGroupOwnerText {
                if self.groupRequestButton.titleLabel?.text != "房間已滿" {
        ref.queryOrdered(byChild: "groupID").queryEqual(toValue: self.groupDetailAutoIDText).observe(.value) { (snapshot) in
            for child in snapshot.children {
                if let childDataSnapshot: DataSnapshot = child as? DataSnapshot {
                    if let notificationDict: [String: Any] = childDataSnapshot.value as? [String: Any] {
                        if let statusValue: String = notificationDict["status"] as? String {
                            if let requestByValue: String = notificationDict["requestBy"] as? String {
                                if requestByValue == userID && statusValue == "0" {
                                    print("============================等待批准中===============================")
                                    self.groupRequestButton.layer.borderColor = UIColor.gray.cgColor
                                    self.groupRequestButton.layer.borderWidth = 2
                                    self.groupRequestButton.setTitleColor(UIColor.gray, for: .normal)
                                    self.groupRequestButton.setTitle("等待批准中", for: .normal)
                                } else if requestByValue == userID && statusValue == "1" {
                                    print("============================已加入揪團===============================")
                                    self.groupRequestButton.layer.borderColor = UIColor.red.cgColor
                                    self.groupRequestButton.layer.borderWidth = 2
                                    self.groupRequestButton.setTitleColor(UIColor.red, for: .normal)
                                    self.groupRequestButton.setTitle("退出揪團", for: .normal)
                                }
                            } else {
                             print("Can't convert groupID to String")
                            }
                        } else {
                         print("Can't convert statusID to String")
                        }
                    }
                    else {
                        print("Can't convert to Dict[String:Any]")
                    }
                } else {
                    print("Can't convert to DataSnapshot")
                }
            }
            
        }
                } else {
                 print("房間已滿")
                }
            } else {
             self.groupRequestButton.isHidden = true
            }
    } else {
        print("Invalid User")
    }
}
    
    @IBAction func groupDetailMemberButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "showGroupMember", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showGroupMember" {
            
            let groupMemberView = segue.destination as! GroupMemberViewController
            groupMemberView.groupAutoID = self.groupDetailAutoIDText
            
        }
    }
    
    @IBOutlet weak var groupRequestButton: UIButton!
    
    
    @IBAction func groupRequestButtonPressed(_ sender: UIButton) {
        if let userID: String = Auth.auth().currentUser?.uid {
            if userID != self.groupDetailGroupOwnerText{
                if sender.titleLabel?.text != "房間已滿" {
                    if sender.titleLabel?.text != "等待批准中" {
                        if sender.titleLabel?.text != "退出揪團" {
        let notificationRef = Database.database().reference(withPath: "notifications")
        let requestRef = notificationRef.childByAutoId()
        if let groupOwnerValue: String = self.groupDetailGroupOwnerText {
            if let groupGameValue: String = self.groupDetailGameText {
                if let groupAutoIDValue: String = self.groupDetailAutoIDText {
                    let requestByValue: String = userID
                    //現在時間
                    let now: Date = Date()
                    let dateFormatter: DateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "YYYY/MM/dd HH:mm:ss"
                    let dateString: String = dateFormatter.string(from: now)
                    
                    let groupValueDict: [String: Any] = ["groupOwner": groupOwnerValue, "groupGame": groupGameValue, "groupID": groupAutoIDValue, "requestBy": requestByValue, "status": "0", "timeStamp": dateString] as [String: Any]
                requestRef.setValue(groupValueDict)
                self.groupRequestButton.layer.borderWidth = 2
                self.groupRequestButton.layer.borderColor = UIColor.gray.cgColor
                self.groupRequestButton.setTitleColor(UIColor.gray, for: .normal)
                self.groupRequestButton.setTitle("等待批准中", for: .normal)
            } else {
                print("Group Auto ID not exists")
            }
            } else {
                print("Group Game not exists")
                }
        } else {
           print("Group Owner not exists")
        }
                        } else {
                         print("退出揪團")
                            guard let currentUser: String = Auth.auth().currentUser?.uid else { return }
                            let alert = UIAlertController(title: "退出揪團", message: "請確認是否要退出此揪團", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "取消", style: .default, handler: nil))
                            alert.addAction(UIAlertAction(title: "是的", style: .default, handler: { (alertAction) in
                                print("確認退出揪團")
                                let groupRef = Database.database().reference(withPath: "groups")
                                let notificationRef = Database.database().reference(withPath: "notifications")
                                groupRef.child(self.groupDetailAutoIDText!).observeSingleEvent(of: .value, with: { (snapshot) in
                                    if let valueDict: [String: Any] = snapshot.value as? [String: Any], var currentMemberArray: [String] = valueDict["currentMemberInGroup"] as? [String] {
                                        for i in 0..<currentMemberArray.count {
                                            if currentMemberArray[i] == currentUser {
                                             currentMemberArray.remove(at: i)
                                            }
                                        }
                                        groupRef.child(self.groupDetailAutoIDText!).child("currentMemberInGroup").setValue(currentMemberArray)
                                    }
                                })
                                
                                notificationRef.queryOrdered(byChild: "requestBy").queryEqual(toValue: currentUser).observeSingleEvent(of: .value, with: { (snapshot) in
                                    for child in snapshot.children {
                                        if let childSnapshot: DataSnapshot = child as? DataSnapshot {
                                            if var valueDict: [String: Any] = childSnapshot.value as? [String: Any], let groupAutoID: String = valueDict["groupID"] as? String, let status: String = valueDict["status"] as? String {
                                                if groupAutoID == self.groupDetailAutoIDText! && status == "1" {
                                                    valueDict["status"] = "4"
                                                    notificationRef.child(childSnapshot.key).setValue(valueDict)
                                                }
                                            }
                                        }
                                    }
                                })
                                self.groupRequestButton.setTitle("申請加入", for: .normal)
                                self.groupRequestButton.layer.cornerRadius = 10
                                self.groupRequestButton.layer.borderWidth = 2
                                self.groupRequestButton.layer.borderColor = UIColor(red: 98.0/255.0, green: 179/255.0, blue: 156/255.0, alpha: 1).cgColor
                                self.groupRequestButton.setTitleColor(UIColor(red: 98.0/255.0, green: 179/255.0, blue: 156/255.0, alpha: 1), for: .normal)
                            }))
                            present(alert, animated: true, completion: nil)
                        }
                    } else {
                     let alert = UIAlertController(title: "等待房主批准中", message: "\n", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        present(alert ,animated: true, completion: nil)
                    }
                } else {
                 let alert = UIAlertController(title: "房間人數已達上限", message: "\n", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    present(alert, animated: true, completion: nil)
                }
            } else {
             sender.isHidden = true
            }
    } else {
        let alert = UIAlertController(title: "尚未登入", message: "請先登入使用者", preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(alertAction)
        self.present(alert, animated: true, completion: nil)
        }
    }
}
