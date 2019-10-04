//
//  RegisterViewController.swift
//  Alien
//
//  Created by Ken Yeh on 2019/9/16.
//  Copyright © 2019 Ken Yeh. All rights reserved.
//

import UIKit
import Firebase

class RegisterViewController: UIViewController {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    
    @IBOutlet weak var textFieldRegisterEmail: UITextField!
    @IBOutlet weak var textFieldRegisterPassword: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var returnButton: UIButton!
    @IBOutlet weak var textFieldCreateNickname: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.registerButton.layer.cornerRadius = 10
        self.returnButton.layer.cornerRadius = 10
        self.registerButton.layer.borderColor = UIColor(red: 98.0/255.0, green: 179/255.0, blue: 156/255.0, alpha: 1).cgColor
        self.registerButton.layer.borderWidth = 2
        self.returnButton.layer.borderColor = UIColor(red: 98.0/255.0, green: 179/255.0, blue: 156/255.0, alpha: 1).cgColor
        self.returnButton.layer.borderWidth = 2
        
        
    }
    
    
    @IBAction func registerButtonPressed(_ sender: UIButton) {
        if self.textFieldCreateNickname.text != "" && self.textFieldCreateNickname.text!.count < 20 {
        if let email: String = textFieldRegisterEmail.text, let password: String = textFieldRegisterPassword.text {
            Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
                if let error = error {
                    print(error.localizedDescription)
                    print("Sign up Failed")
                    
                    let alert = UIAlertController(title: "註冊發生錯誤", message: error.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                    let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(alertAction)
                    self.present(alert, animated: true, completion: nil)
                    
                    return
                }
                print("Sign up Successfully")
                
                guard let userID: String = Auth.auth().currentUser?.uid else { return }
                let ref = Database.database().reference()
                let usersRef = ref.child("users").child(userID)
                //檢測使用者是否輸入暱稱
                if self.textFieldCreateNickname.text != "" && self.textFieldCreateNickname.text!.count < 20 {
                    if let nickName: String = self.textFieldCreateNickname.text {
                        //將使用者存進firebase
                        let nameValue:[String:Any] = ["name":nickName, "image": "defaultProfilePicture"]
                        usersRef.setValue(nameValue)
                        let alert = UIAlertController(title: "註冊成功", message: "", preferredStyle: .alert)
                        let alertAction = UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
                            Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                                if error == nil {
                                    
                                    print("Log in Successfully")
                                    guard let userID: String = Auth.auth().currentUser?.uid else { return }
                                    let usersRef = Database.database().reference().child("users").child(userID)
                                    //查看使用者是否已經創建過暱稱
                                    usersRef.observeSingleEvent(of: .value, with: { (snapshot) in
                                        if snapshot.hasChild("name") {
                                            //若以創建過暱稱畫面跳轉至首頁
                                            let appDelegate = UIApplication.shared.delegate as! AppDelegate
                                            let groupListView = self.storyboard?.instantiateViewController(withIdentifier: "GroupListTabBarView")
                                            appDelegate.window?.rootViewController = groupListView
                                            appDelegate.window?.makeKeyAndVisible()
                                            
                                        } else {
                                            //若未創建過暱稱之使用者畫面跳轉至創建暱稱頁面
                                            let appDelegate = UIApplication.shared.delegate as! AppDelegate
                                            let nicknameView = self.storyboard?.instantiateViewController(withIdentifier: "CreateNicknameView")
                                            appDelegate.window?.rootViewController = nicknameView
                                            appDelegate.window?.makeKeyAndVisible()
                                            
                                        }
                                    })
                                }
                            }
                        })
                        alert.addAction(alertAction)
                        self.present(alert, animated: true, completion: nil)
                        
                    }
                } else {
                    let alert = UIAlertController(title: "創建暱稱錯誤", message: "請輸入有效的暱稱 \n暱稱需小於20位數", preferredStyle: UIAlertController.Style.alert)
                    let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(alertAction)
                    self.present(alert, animated: true, completion: nil)
                }
            }
            
            }
        } else {
            let alert = UIAlertController(title: "創建暱稱錯誤", message: "請輸入有效的暱稱 \n暱稱需小於20位數", preferredStyle: UIAlertController.Style.alert)
            let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(alertAction)
            self.present(alert, animated: true, completion: nil)
    }
}
    
    
    
    @IBAction func returnButtonPressed(_ sender: UIButton) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let logInView = self.storyboard?.instantiateViewController(withIdentifier: "LogInView")
        appDelegate.window?.rootViewController = logInView
        appDelegate.window?.makeKeyAndVisible()
        
    }
}
