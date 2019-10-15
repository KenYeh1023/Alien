//
//  MyGroupViewController.swift
//  Alien
//
//  Created by Ken Yeh on 2019/9/10.
//  Copyright © 2019 Ken Yeh. All rights reserved.
//

import UIKit
import Firebase

class MyGroupViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupArray[int].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyGroupTableViewCell") as! MyGroupTableViewCell
        cell.selectionStyle = .none
        cell.myGroupActivityTime.text = groupArray[int][indexPath.row].groupActivityTime
        cell.myGroupGameName.text = groupArray[int][indexPath.row].gameTitle
        cell.myGroupTitle.text = groupArray[int][indexPath.row].groupTitle
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "showChatRoom", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showChatRoom" {
            if let indexPath = tableView.indexPathForSelectedRow {
             let chatRoom = segue.destination as! ChatRoomViewController
                chatRoom.chatRoomAutoID = groupArray[int][indexPath.row].groupAutoID
                chatRoom.chatRoomTitleText = groupArray[int][indexPath.row].groupTitle
                chatRoom.chatRoomGameText = groupArray[int][indexPath.row].gameTitle
                chatRoom.chatRoomCurrentNumberOfMemberText = groupArray[int][indexPath.row].maxNumberOfMemberInGroup
                chatRoom.chatRoomActivityTimeText = groupArray[int][indexPath.row].groupActivityTime
                chatRoom.chatRoomGroupOwnerText = groupArray[int][indexPath.row].groupOwner
            }
        }
    }
    
    var groupArray: [[Group]] = [[], []]
    
    var int: Int!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let userID: String = Auth.auth().currentUser?.uid {
            int = 0
            
            let nib = UINib(nibName: "MyGroupTableViewCell", bundle: nil)
            tableView.register(nib, forCellReuseIdentifier: "MyGroupTableViewCell")
            
            
            let ref = Database.database().reference(withPath: "groups")
            
            var groupArrayfirst: [Group] = []
            var groupArraySecond: [Group] = []
            
            ref.queryOrdered(byChild: "currentMemberInGroup").observe(.value) { (snapshot) in
                groupArrayfirst = []
                groupArraySecond = []
                for child in snapshot.children {
                    if let childSnapshot: DataSnapshot = child as? DataSnapshot {
                        if let childDict: [String: Any] = childSnapshot.value as? [String: Any] {
                            if var memberArray: [String] = childDict["currentMemberInGroup"] as? [String] {
                                
                                for i in 0..<memberArray.count {
                                    if memberArray[i] == userID {
                                        if let childValue: Group = Group(snapshot: childSnapshot) {
                                            if i == 0 {
                                            groupArrayfirst.append(childValue)
                                            } else {
                                            groupArraySecond.append(childValue)
                                            }
                                        } else {
                                         print("Failed to convert to Group")
                                        }
                                    } else {
                                     print("Not in this group")
                                    }
                                }
                            } else {
                             print("Failed to convert to [String]")
                            }
                        } else {
                            print("Failed to convert to [String: Any]")
                        }
                    } else {
                     print("Failed to convert to DataSnapshot")
                    }
                }
                
                DispatchQueue.main.async {
                    self.groupArray[0] = groupArrayfirst
                    self.groupArray[1] = groupArraySecond
                    self.tableView.reloadData()
                }
            }
        } else {
         print("Invalid User")
        }
    }
    
    @IBAction func switchGroup(_ sender: UISegmentedControl) {
        int = sender.selectedSegmentIndex
        tableView.reloadData()
    }
    
}
