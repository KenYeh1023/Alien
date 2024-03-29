//
//  GroupListViewController.swift
//  Alien
//
//  Created by Ken Yeh on 2019/8/26.
//  Copyright © 2019 Ken Yeh. All rights reserved.
//

import Foundation
import Firebase

//揪團所有資訊
struct Group {
    
    let groupAutoID: String
    let gameTitle: String
    let groupOwner: String
    let groupTitle: String
    let groupActivityTime: String
    let maxNumberOfMemberInGroup: String
    
    init(groupAutoID: String,gameTitle: String, groupOwner: String, groupTitle: String, groupActivityTime: String, maxNumberOfMemberInGroup: String) {
        self.groupAutoID = groupAutoID
        self.gameTitle = gameTitle
        self.groupOwner = groupOwner
        self.groupTitle = groupTitle
        self.groupActivityTime = groupActivityTime
        self.maxNumberOfMemberInGroup = maxNumberOfMemberInGroup
    }
    
    init?(snapshot: DataSnapshot) {
        guard let snapshotValue: [String:Any] = snapshot.value as? [String:Any],
              let groupTitle: String = snapshotValue["groupTitle"] as? String,
              let gameTitle: String = snapshotValue["gameTitle"] as? String,
              let groupOwner: String = snapshotValue["groupOwner"] as? String,
              let groupActivityTime: String = snapshotValue["groupActivityTime"] as? String,
              let maxNumberOfMemberInGroup: String = snapshotValue["maxNumberOfMemberInGroup"] as? String
              else { return nil }
        self.groupAutoID = snapshot.key
        self.gameTitle = gameTitle
        self.groupOwner = groupOwner
        self.groupTitle = groupTitle
        self.groupActivityTime = groupActivityTime
        self.maxNumberOfMemberInGroup = maxNumberOfMemberInGroup
        
    }
}

class GroupListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var groupListTableView: UITableView!
    
    var refreshControl: UIRefreshControl!
    var groupArray: [Group] = []
    var blockArray: [String] = []
    let cellSpacing: CGFloat = 5
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = UIRefreshControl()
        groupListTableView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(reloadData), for: UIControl.Event.valueChanged)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(rightBarButtonPressed))
        navigationItem.rightBarButtonItem?.image = UIImage(named: "add")
        
        if let userID: String = Auth.auth().currentUser?.uid {
            let ref = Database.database().reference(withPath: "blocked")
            let blockRef = ref.child(userID)
            blockRef.observe(.value) { (snapshot) in
                if let ValueArray: [String] = snapshot.value as? [String] {
                    self.blockArray = ValueArray
                }
            }
        }
        
        let groupRef = Database.database().reference(withPath: "groups")
        groupRef.observe(.value) { (snapshot) in
            var newGroupArray: [Group] = []
            for child in snapshot.children.reversed() {
                if let groupChild: DataSnapshot = child as? DataSnapshot {
                    if let groupInfo: Group = Group(snapshot: groupChild) {
                        if self.blockArray.contains(groupInfo.groupOwner) == false {
                        newGroupArray.append(groupInfo)
                        } else {
                         print("Being blocked by the group owner")
                        }
                    } else {
                        print("Data not exists")
              }
            }
        }
            self.groupArray = newGroupArray
            self.groupListTableView.reloadData()
    }
}
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = groupListTableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! GroupListTableViewCell
        cell.groupListTitle.text = groupArray[indexPath.row].groupTitle
        cell.groupListActivityTime.text = "活動時間:\(groupArray[indexPath.row].groupActivityTime)"
        cell.groupGameTitle.text = groupArray[indexPath.row].gameTitle
        return cell
        }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showGroupDetail", sender: self)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return cellSpacing
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showGroupDetail" {
            if let indexPath = groupListTableView.indexPathForSelectedRow {
                let groupDetail = segue.destination as! GroupDetailViewController
                groupDetail.groupDetailTitleText = groupArray[indexPath.row].groupTitle
                groupDetail.groupDetailGameText = groupArray[indexPath.row].gameTitle
                groupDetail.groupDetailCurrentNumberOfMemberText = groupArray[indexPath.row].maxNumberOfMemberInGroup
                groupDetail.groupDetailActivityTimeText = groupArray[indexPath.row].groupActivityTime
                groupDetail.groupDetailAutoIDText = groupArray[indexPath.row].groupAutoID
                groupDetail.groupDetailGroupOwnerText = groupArray[indexPath.row].groupOwner
            }
        }
    }
    
    @objc func rightBarButtonPressed(sender: UIBarButtonItem) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let createGroupView = storyboard.instantiateViewController(withIdentifier: "CreateGroupView")
        self.present(createGroupView, animated: true)
        
    }
    
    @objc func reloadData() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            self.refreshControl.endRefreshing()
            self.groupListTableView.reloadData()
        }
    }
}
