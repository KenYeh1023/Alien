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
        groupDetailTitle.text = groupDetailTitleText!
        groupDetailActivityTime.text = groupDetailActivityTimeText!
        groupDetailCurrentNumberOfMember.setTitle(groupDetailCurrentNumberOfMemberText!, for: .normal)
        groupDetailGame.text = groupDetailGameText!
        groupDetailAutoID.text = groupDetailAutoIDText!
        
//        if let userID: String = Auth.auth().currentUser?.uid {
//        let userRef = Database.database().reference(withPath: "users")
//        let requestRef = userRef.child(userID).child("request")
//            requestRef.observeSingleEvent(of: .value) { (snapshot) in
//                if snapshot.hasChild(self.groupDetailAutoIDText!) {
//                    self.groupRequestButton.backgroundColor = .gray
//                    self.groupRequestButton.titleLabel?.textColor = .white
//                    self.groupRequestButton.setTitle("等待批准中", for: .normal)
//                } else {
//                    self.groupRequestButton.setTitle("申請加入", for: .normal)
//                }
//            }
//        } else {
//         print("Invalid User")
//        }
        
        let ref = Database.database().reference(withPath: "notifications")
        if let userID: String = Auth.auth().currentUser?.uid {
        ref.queryOrdered(byChild: "requestBy").queryEqual(toValue: userID).observe(.value) { (snapshot) in
            print("AAAAAAAAAA GO IN Success")
            for child in snapshot.children {
                if let childDataSnapshot: DataSnapshot = child as? DataSnapshot {
                    if let notificationDict: [String: Any] = childDataSnapshot.value as? [String: Any] {
                        if let statusValue: String = notificationDict["status"] as? String {
                            if let groupIDValue: String = notificationDict["groupID"] as? String {
                                if groupIDValue == self.groupDetailAutoIDText && statusValue == "0" {
                                    self.groupRequestButton.backgroundColor = .gray
                                    self.groupRequestButton.titleLabel?.textColor = .white
                                    self.groupRequestButton.setTitle("等待批准中", for: .normal)
                                } else {
                                    self.groupRequestButton.setTitle("申請加入", for: .normal)
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
        print("Invalid User")
    }
        
    print("Group Detail Created")
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
        let notificationRef = Database.database().reference(withPath: "notifications")
        let requestRef = notificationRef.childByAutoId()
        if let groupOwnerValue: String = self.groupDetailGroupOwnerText {
            if let groupGameValue: String = self.groupDetailGameText {
                if let groupAutoIDValue: String = self.groupDetailAutoIDText {
                    let requestByValue: String = userID
                    let groupValueDict: [String: Any] = ["groupOwner": groupOwnerValue, "groupGame": groupGameValue, "groupID": groupAutoIDValue, "requestBy": requestByValue, "status": "0"] as [String: Any]
                requestRef.setValue(groupValueDict)
                self.groupRequestButton.backgroundColor = .gray
                self.groupRequestButton.titleLabel?.textColor = .white
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
        let alert = UIAlertController(title: "尚未登入", message: "請先登入使用者", preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(alertAction)
        self.present(alert, animated: true, completion: nil)
        }
    }
}
