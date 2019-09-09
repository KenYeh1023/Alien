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
        
        cell.groupMemberListLabel.text = groupMemberArray[indexPath.row].groupMember
        
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
            cell.removeMemberButton.isHidden = true
            cell.groupMemberListLabel.textColor = .blue
        }
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ZZZZZZZZZZZZZ\(self.groupAutoID!)")
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
                    memberRef.observe(.value) { (snapshot) in
                        if var groupMemberArray: [String] = snapshot.value as? [String] {
                            print("AAAAAAAAAAAAAAAAAAAAAA\(groupMemberArray)")
                            //若今天有一萬筆？需修改
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
            } else {
             print("Wrong IndexPath Selected")
            }
        } else {
         print("Wrong Cell Selected")
        }
    }
}
