//
//  PersonalPageViewController.swift
//  Alien
//
//  Created by Ken Yeh on 2019/9/4.
//  Copyright © 2019 Ken Yeh. All rights reserved.
//

import Foundation
import Firebase
import UIKit

class PersonalPageViewController: UIViewController {
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var profileNickname: UILabel!
    
    @IBOutlet weak var profileUserID: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.profileUserID.numberOfLines = 1
        self.profileUserID.sizeToFit()
        
        print("Welcome to Personal Page")
        
        if let userID:String = Auth.auth().currentUser?.uid {
                let ref = Database.database().reference(withPath: "users")
                let userRef = ref.child(userID)
            userRef.observe(.value) { (snapshot) in
                if let valueDict: [String: Any] = snapshot.value as? [String: Any],
                    let nicknameValue: String = valueDict["name"] as? String,
                    let imageValue: String = valueDict["image"] as? String {
                    self.profileNickname.text = nicknameValue
                    self.profileUserID.text = snapshot.key
                    self.profilePicture.image = UIImage(named: imageValue)
                    
                } else {
                    print("Can not convert to [String:Any]")
                }
            }
        }
    }
    
    @IBAction func logOutButtonPressed(_ sender: UIButton) {
        if Auth.auth().currentUser?.uid != nil {
            do {
                
                try Auth.auth().signOut()
                
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let loginView = self.storyboard?.instantiateViewController(withIdentifier: "LogInView")
                appDelegate.window?.rootViewController = loginView
                appDelegate.window?.makeKeyAndVisible()
                
            } catch let error as NSError {
                
                print(error.localizedDescription)
                
            }
        }
    }
    
    
}
