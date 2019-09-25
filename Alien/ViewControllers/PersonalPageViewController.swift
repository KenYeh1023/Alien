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
import Crashlytics
import Fabric

class PersonalPageViewController: UIViewController {
    
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var profileNickname: UILabel!
    @IBOutlet weak var profileUserID: UILabel!
    
    @IBOutlet weak var saveButtonOutlet: UIButton!
    
    
    @IBAction func saveButton(_ sender: UIButton) {
        //儲存圖片按鈕
        guard let userID: String = Auth.auth().currentUser?.uid else { return }
        guard let data = self.profilePicture.image?.jpegData(compressionQuality: 0.7) else { return }
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        let storageRef = Storage.storage().reference()
        storageRef.child("users").child(userID).putData(data, metadata: metaData) { (metadata, error) in
            if error != nil {
                print("\(String(describing: error))")
            }
            storageRef.child("users").child(userID).downloadURL(completion: { (url, error) in
                if error != nil {
                    print("\(String(describing: error))")
                } else {
                    if url?.absoluteString != nil {
                        let ref = Database.database().reference(withPath: "users")
                        let userRef = ref.child(userID)
                        let ValueDict: [String: Any] = ["name": self.profileNickname.text!, "image": url?.absoluteString as Any]
                        userRef.setValue(ValueDict)
                    }
                }
            })
        }
        let alert = UIAlertController(title: "變更照片成功", message: "您的大頭貼已更新", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
        self.saveButtonOutlet.isHidden = true
    }
    
    var imagePicker: UIImagePickerController!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.saveButtonOutlet.isHidden = true
        self.saveButtonOutlet.layer.borderWidth = 2
        self.saveButtonOutlet.layer.cornerRadius = 10
        self.saveButtonOutlet.layer.borderColor = UIColor(red: 189/255, green: 106/255, blue: 101/255, alpha: 1).cgColor
        self.logOutButton.layer.borderWidth = 2
        self.logOutButton.layer.borderColor = UIColor.red.cgColor
        self.profileUserID.numberOfLines = 1
        self.profileUserID.sizeToFit()
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(openImagePicker))
        profilePicture.isUserInteractionEnabled = true
        profilePicture.addGestureRecognizer(imageTap)
        
        if let userID:String = Auth.auth().currentUser?.uid {
                let ref = Database.database().reference(withPath: "users")
                let userRef = ref.child(userID)
            userRef.observe(.value) { (snapshot) in
                if let valueDict: [String: Any] = snapshot.value as? [String: Any],
                    let nicknameValue: String = valueDict["name"] as? String,
                    let imageValue: String = valueDict["image"] as? String {
                    self.profileNickname.text = nicknameValue
                    self.profileUserID.text = snapshot.key
                    let url = URL(string: imageValue)
                    let task = URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
                        if error != nil {
                            print("error")
                            DispatchQueue.main.async {
                            self.profilePicture.image = UIImage(named: "defaultProfilePicture")
                            }
                            return
                        }
                        DispatchQueue.main.async {
                            self.profilePicture.image = UIImage(data: data!)
                        }
                    })
                        task.resume()
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
    
    @objc func openImagePicker (_ sender: Any) {
        self.present(imagePicker, animated: true, completion: nil)
        self.saveButtonOutlet.isHidden = false
    }
}

extension PersonalPageViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.profilePicture.image = pickedImage
            
        }
        
        picker.dismiss(animated: true, completion: nil)
        
    }
}
