//
//  EditVC.swift
//  Instrgram
//
//  Created by Ian Mao on 7/24/17.
//  Copyright © 2017 Ian Mao. All rights reserved.
//

import UIKit
import AVOSCloud

class EditVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var Img: UIImageView!
    @IBOutlet weak var nametxt: UITextField!
    @IBOutlet weak var usernametxt: UITextField!
    @IBOutlet weak var websiteTxt: UITextField!
    @IBOutlet weak var bioTxt: UITextView!
    
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var genderTxt: UITextField!
    @IBOutlet weak var phoneTxt: UITextField!
    
    // it has to be force-unwrapped
    var genderPicker : UIPickerView!
    
    let genders = ["Male", "Female"]
    
    var keyboard = CGRect()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        alignment()
        
        // assinging the picker view
        genderPicker = UIPickerView()
        genderPicker.dataSource = self
        genderPicker.delegate = self
        genderPicker.showsSelectionIndicator = true
        genderTxt.inputView = genderPicker
        
        // to detect if a keyboard is showing
        NotificationCenter.default.addObserver(self, selector: #selector(showKeyboard), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideKeyboard), name: Notification.Name.UIKeyboardWillHide, object: nil)

        // hide keyboard by one tap
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboardTap))
        hideTap.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)
        
        // update profile pic
        let imgTap = UITapGestureRecognizer(target: self, action: #selector(loadImg))
        imgTap.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(imgTap)
        
        // getting information back from database
        information()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelBtn_clicked(_ sender: Any) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func saveBtn_clicked(_ sender: Any) {
        
        if !validateEmail(email: emailTxt.text!) {
            alert(error: "Wrong Email Address", message: "Please enter the right address")
            return
        }
        
        if !validateWebsite(website: websiteTxt.text!) {
            alert(error: "Wrong website link", message: "Please enter the right website link")
            return
        }
        
        let user = AVUser.current()
        
        user?.username = usernametxt.text?.lowercased()
        user?.email = emailTxt.text?.lowercased()
        user?["fullname"] = nametxt.text?.lowercased()
        user?["website"] = websiteTxt.text?.lowercased()
        user?["bio"] = bioTxt.text
        
        let avaData = UIImageJPEGRepresentation(Img.image!, 0.5)
        let avaFile = AVFile(name: "userImg.jpg", data: avaData!)
        user?["Img"] = avaFile
        
        
        if !phoneTxt.text!.isEmpty {
            user?.mobilePhoneNumber = phoneTxt.text
        } else {
            user?.mobilePhoneNumber = nil
        }

        if genderTxt.text!.isEmpty {
            user?["gender"] = nil
        } else {
            user?["gender"] = genderTxt.text
        }
        
        user?.saveInBackground({ (success: Bool, error: Error?) in
            if success {
                self.view.endEditing(true)
                self.dismiss(animated: true, completion: nil)
            } else {
                print(error?.localizedDescription)
            }
        })
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reload"), object: nil)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return genders.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return genders[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        genderTxt.text = genders[row]
        self.view.endEditing(true)
    }
    
    func hideKeyboardTap(recognizer: UIGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    func showKeyboard(notification: Notification) {
        // define the size of the keyboard
        let rect = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue
        keyboard = rect.cgRectValue
        
        UIView.animate(withDuration: 0.4) {
            self.scrollView.contentSize.height = self.view.frame.height + self.keyboard.height / 2
        }
    }
    
    func hideKeyboard(notification: Notification) {
        UIView.animate(withDuration: 0.4) {
            self.scrollView.contentSize.height = 0
        }
    }
    
    func loadImg(recognizer: UITapGestureRecognizer) {
        
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        Img.image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func information() {
        
        let profilePic = AVUser.current()?.object(forKey: "Img") as! AVFile
        profilePic.getDataInBackground { (data: Data?, error: Error?) in
            if data != nil {
                self.Img.image = UIImage(data: data!)
            }
        }
        
        usernametxt.text = AVUser.current()?.username
        nametxt.text = AVUser.current()?.object(forKey: "fullname") as? String
        bioTxt.text = AVUser.current()?.object(forKey: "bio") as? String
        websiteTxt.text = AVUser.current()?.object(forKey: "website") as? String
        emailTxt.text = AVUser.current()?.email
        phoneTxt.text = AVUser.current()?.mobilePhoneNumber
        genderTxt.text = AVUser.current()?.object(forKey: "gender") as? String
        
    }
    
    func validateEmail(email: String) -> Bool {
        
        let regex = "\\w[-\\w.+]*@([A-Za-z0-9][-A-Za-z0-9]+\\.)+[A-Za-z]{2,14}"
        let range = email.range(of: regex, options: .regularExpression)
        let result = range != nil ? true : false
        
        return result
    }
    
    func validateWebsite(website: String) -> Bool {
        
        let regex = "www\\.[A-Za-z0-9._%+-]+\\.[A-Za-z]{2,14}"
        let range = website.range(of: regex, options: .regularExpression)
        let result = range != nil ? true : false
        
        return result
    }
    
    func alert(error: String, message: String) {
        let alert = UIAlertController(title: error, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    
    func alignment() {
        let width = self.view.frame.width
        let height = self.view.frame.height
        
        scrollView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        
        // round profile picture
        Img.frame = CGRect(x: width - 68 - 10, y: 15, width: 68, height: 68)
        Img.layer.cornerRadius = Img.frame.width / 2
        Img.clipsToBounds = true
     
        nametxt.frame = CGRect(x: 10, y: Img.frame.origin.y, width: width - Img.frame.width - 30, height: 30)
        usernametxt.frame = CGRect(x: 10, y: nametxt.frame.origin.y + 45, width: width - Img.frame.width - 30, height: 30)
        websiteTxt.frame = CGRect(x: 10, y: usernametxt.frame.origin.y + 45, width: width - 20, height: 30)
        bioTxt.frame = CGRect(x: 10, y: websiteTxt.frame.origin.y + 45, width: width - 20, height: 100)
        bioTxt.layer.cornerRadius = bioTxt.frame.width / 50
        bioTxt.clipsToBounds = true
        
        infoLabel.frame = CGRect(x: 10, y: bioTxt.frame.origin.y + 140, width: width - 20, height: 30)
        emailTxt.frame = CGRect(x: 10, y: infoLabel.frame.origin.y + 45, width: width - 20, height: 30)
        phoneTxt.frame = CGRect(x: 10, y: emailTxt.frame.origin.y + 45, width: width - 20, height: 30)
        genderTxt.frame = CGRect(x: 10, y: phoneTxt.frame.origin.y + 45, width: width - 20, height: 30)
        
        
    }

}
