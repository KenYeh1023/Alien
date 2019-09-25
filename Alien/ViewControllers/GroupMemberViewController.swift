//
//  GroupMemberViewController.swift
//  Alien
//
//  Created by Ken Yeh on 2019/9/2.
//  Copyright © 2019 Ken Yeh. All rights reserved.
//


import Foundation
import UIKit
import Firebase

struct GroupMember {
    
    var groupMember: String
    
    init(groupMember: String) {
        self.groupMember = groupMember
    }
    
    init?(snapshot: DataSnapshot) {
        guard let snapshotValue: String = snapshot.value as? String
            else { return nil }
        self.groupMember = snapshotValue
    }
}

class GroupMemberViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var groupAutoID: String?
    
    var groupMemberArray: [GroupMember] = []
    
    @IBOutlet weak var groupMemberTableView: UITableView!
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupMemberArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! GroupMemberTableViewCell
        
        let ref = Database.database().reference(withPath: "users")
        let userRef = ref.child(groupMemberArray[indexPath.row].groupMember)
        userRef.observeSingleEvent(of: .value) { (snapshot) in
            if let ValueDict: [String: Any] = snapshot.value as?[String: Any] {
                if let nameValue: String = ValueDict["name"] as? String,
                    let imageValue: String = ValueDict["image"] as? String {
                    cell.groupMemberListLabel.text = nameValue
                    let url = URL(string: imageValue)
                    let task = URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
                        if error != nil {
                            print("error")
                            DispatchQueue.main.async {
                            cell.groupMemberImage.image = UIImage(named: "defaultProfilePicture")
                            }
                            return
                        }
                        DispatchQueue.main.async {
                            cell.groupMemberImage.image = UIImage(data: data!)
                        }
                    })
                    task.resume()
                }
            }
        }
        
        if let currentUserID: String = Auth.auth().currentUser?.uid {
            if currentUserID == groupMemberArray[0].groupMember {
                cell.removeMemberButton.isHidden = false
                cell.removeMemberButton.layer.cornerRadius = 5
                cell.removeMemberButton.layer.masksToBounds = true
                print("Owner of the Group")
            } else {
                cell.removeMemberButton.isHidden = true
                print("not the Owner of the group")
            }
        } else {
         print("Invalid User ID")
        }
        if indexPath.row == 0 {
            cell.crownImage.isHidden = false
            cell.removeMemberButton.isHidden = true
            cell.groupMemberListLabel.textColor = .blue
        } else {
         cell.crownImage.isHidden = true
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let currentUser = Auth.auth().currentUser?.uid else { return }
        if currentUser != groupMemberArray[indexPath.row].groupMember {
        if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "OtherUserPage") as? OtherUserViewController {
            viewController.userID = groupMemberArray[indexPath.row].groupMember
            present(viewController, animated: true, completion: nil)
            }
        } else {
         print("Can not Enter")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
         if let groupAutoIDString = self.groupAutoID {
            let groupRef = Database.database().reference(withPath: "groups")
            let groupAutoID = groupRef.child(groupAutoIDString)
            let groupMemberRef = groupAutoID.child("currentMemberInGroup")
            groupMemberRef.observe(.value) { (snapshot) in
                var groupMember: [GroupMember] = []
                for child in snapshot.children {
                    if let memberChild: DataSnapshot = child as? DataSnapshot {
                        if let memberValue: GroupMember = GroupMember(snapshot: memberChild) {
                            groupMember.append(memberValue)
                            print(groupMember)
                        } else {
                         print("Can't find Group Member")
                        }
                    } else {
                     print("Group Member not exists")
                    }
                }
                print(groupMember)
                self.groupMemberArray = groupMember
                self.groupMemberTableView.reloadData()
            }
        }
    }
    
    
    @IBAction func removeMemberButtonPressed(_ sender: UIButton) {
        
        if let cell = sender.superview?.superview as? GroupMemberTableViewCell {
            if let indexPath = groupMemberTableView.indexPath(for: cell) {
                print(indexPath.item)
                    let groupMemberAutoID: String = groupMemberArray[indexPath.row].groupMember
                    print(groupMemberAutoID)
                    let groupRef = Database.database().reference(withPath: "groups")
                    let memberRef = groupRef.child(self.groupAutoID!).child("currentMemberInGroup")
                memberRef.observeSingleEvent(of: .value) { (snapshot) in
                        if var groupMemberArray: [String] = snapshot.value as? [String] {
                            for i in 0..<groupMemberArray.count {
                                if groupMemberArray[i] == groupMemberAutoID {
                                    groupMemberArray.remove(at: i)
                                    memberRef.setValue(groupMemberArray)
                                } else {
                                    print("Can't find the member")
                                }
                            }
                            self.groupMemberTableView.reloadData()
                        } else {
                         print("Wrong Command")
                        }
                    }
                
            if let cell = sender.superview?.superview as? GroupMemberTableViewCell {
                if let indexPath = groupMemberTableView.indexPath(for: cell) {
                    let groupMemberAutoID: String = groupMemberArray[indexPath.row].groupMember
                        let notificationRef = Database.database().reference(withPath: "notifications")
                    notificationRef.queryOrdered(byChild: "groupID").queryEqual(toValue: self.groupAutoID).observeSingleEvent(of: .value) { (snapshot) in
                                for child in snapshot.children {
                                        if let childDataSnapshot: DataSnapshot = child as? DataSnapshot {
                                                if var valueDict: [String: Any] = childDataSnapshot.value as? [String: Any] {
                                                        if let requestBy: String = valueDict["requestBy"] as? String, let status: String = valueDict["status"] as? String {
                                                                if requestBy == groupMemberAutoID && status == "1" {
                                                                        let key = childDataSnapshot.key
                                                                            valueDict["status"] = "3"
                                                                        let NotificationRef = notificationRef.child(key)
                                                                            NotificationRef.setValue(valueDict)
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                } else {
                                    print("Wrong IndexPath Selected")
                            }
                } else {
            print("Wrong Cell Selected")
            }
        }
    }
