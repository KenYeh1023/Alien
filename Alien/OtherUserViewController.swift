//
//  PersonalViewController.swift
//  Alien
//
//  Created by Ken Yeh on 2019/9/9.
//  Copyright © 2019 Ken Yeh. All rights reserved.
//

//SMTP Server

import UIKit
import Firebase

class OtherUserViewController: UIViewController {
    
    var userID: String?
    
    @IBOutlet weak var otherUserProfilePicture: UIImageView!
    
    @IBOutlet weak var otherUserNickname: UILabel!
    
    @IBOutlet weak var otherUserID: UILabel!
    
    @IBOutlet weak var blockUserButton: UIButton!
    
    @IBOutlet weak var reportUserButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.reportUserButton.layer.borderWidth = 2
        self.blockUserButton.layer.borderWidth = 2
        self.reportUserButton.layer.borderColor = UIColor.orange.cgColor
        self.blockUserButton.layer.borderColor = UIColor.red.cgColor
        let ref = Database.database().reference(withPath: "users")
        if let userIDString: String = userID {
        let userRef = ref.child(userIDString)
        userRef.observeSingleEvent(of: .value) { (snapshot) in
            if let valueDict: [String: Any] = snapshot.value as? [String: Any],
                let nameValue: String = valueDict["name"] as? String,
                let imageValue: String = valueDict["image"] as? String {
                ////////////
                self.otherUserNickname.text = nameValue
                self.otherUserID.text = snapshot.key
                let url = URL(string: imageValue)
                let task = URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
                    if error != nil {
                        print("error")
                        return
                    }
                    DispatchQueue.main.async {
                        self.otherUserProfilePicture.image = UIImage(data: data!)
                    }
                })
                task.resume()
                }
            }
        } else {
         print("Found nil when unwrapped optional")
        }
        
        let blockRef = Database.database().reference(withPath: "blocked")
        if let userIDString: String = userID {
            if let currentUserID: String = Auth.auth().currentUser?.uid {
            let blockUserRef = blockRef.child(userIDString)
            blockUserRef.observeSingleEvent(of: .value) { (snapshot) in
                if let blockArray: [String] = snapshot.value as? [String] {
                    if blockArray.contains(currentUserID) {
                        self.blockUserButton.setTitle("解除封鎖使用者", for: .normal)
                    } else {
                        self.blockUserButton.setTitle("封鎖使用者", for: .normal)
                    }
                }
            }
        }
    } else {
         print("Found error when unwrapped optional")
    }
}
    
    
    
    @IBAction func blockUserButtonPressed(_ sender: UIButton) {
        
        if sender.titleLabel?.text == "封鎖使用者" {
        guard let currentUserID: String = Auth.auth().currentUser?.uid else { return }
        let ref = Database.database().reference(withPath: "blocked")
        if let userIDString: String = userID {
            let blockRef = ref.child(userIDString)
            blockRef.observeSingleEvent(of: .value) { (snapshot) in
                if var blockArray: [String] = snapshot.value as? [String] {
                    blockArray.append(currentUserID)
                    blockRef.setValue(blockArray)
                    sender.setTitle("解除封鎖使用者", for: .normal)
                } else {
                 print("Can't convert snapshot.value to [String]")
                    let blockArray: [String] = [currentUserID]
                    blockRef.setValue(blockArray)
                    sender.setTitle("解除封鎖使用者", for: .normal)
                }
            }
        } else {
            print("Found nil when unwrapped optional")
        }
        } else if sender.titleLabel?.text == "解除封鎖使用者" {
            guard let currentUserID: String = Auth.auth().currentUser?.uid else { return }
            let ref = Database.database().reference(withPath: "blocked")
            if let userIDString: String = userID {
                let blockRef = ref.child(userIDString)
                blockRef.observeSingleEvent(of: .value) { (snapshot) in
                    if var blockArray: [String] = snapshot.value as? [String] {
                        for i in 0..<blockArray.count {
                            if blockArray[i] == currentUserID {
                             blockArray.remove(at: i)
                            }
                        }
                        blockRef.setValue(blockArray)
                        sender.setTitle("封鎖使用者", for: .normal)
                    }
                }
            }
        }
    }
    
    @IBAction func reportButtonPressed(_ sender: UIButton) {
        if let _: String = Auth.auth().currentUser?.uid {
        let alert = UIAlertController(title: "檢舉", message: "", preferredStyle: .actionSheet)
        let reportOptions = ["不雅名稱", "騷擾訊息", "其他"]
        for option in reportOptions {
            
            let action = UIAlertAction(title: option, style: .default, handler: {(action) in
                let ref = Database.database().reference(withPath: "reports")
                guard let currentUserID: String = Auth.auth().currentUser?.uid else { return }
                let userRef = ref.child(self.userID!).childByAutoId()
                let currentTime: Date = Date()
                let dateFormate: DateFormatter = DateFormatter()
                dateFormate.dateFormat = "YYYY/MM/dd HH:mm:ss"
                let dateString: String = dateFormate.string(from: currentTime)
                let valueDict: [String: Any] = ["reporter": currentUserID, "reason": option, "timeStamp": dateString]
                userRef.setValue(valueDict)
                let alert = UIAlertController(title: "檢舉成功", message: "檢舉信息已傳送給開發者", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            })
            
            alert.addAction(action)
        }
        
        let alertAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alert.addAction(alertAction)
        present(alert, animated: true, completion: nil)
            
        } else {
         let alert = UIAlertController(title: "請先登入", message: "請先登入使用者以使用檢舉功能", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    
    @IBAction func goBackButtonPressed(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
}

