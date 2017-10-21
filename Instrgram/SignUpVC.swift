//
//  SignUpVC.swift
//  Instrgram
//
//  Created by Ian Mao on 7/6/17.
//  Copyright © 2017 Ian Mao. All rights reserved.
//

import UIKit
import AVOSCloud

class SignUpVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var UserImg: UIImageView!
    
    @IBOutlet weak var usernameTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var repeatPasswordTxt: UITextField!
    @IBOutlet weak var emailTxt: UITextField!
    
    @IBOutlet weak var fullnameTxt: UITextField!
    @IBOutlet weak var bioTxt: UITextField!
    @IBOutlet weak var websiteTxt: UITextField!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var scrollViewHeight : CGFloat = 0
    var keyboard : CGRect = CGRect()    // a rectangle
    
    @IBOutlet weak var signUpBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    
    @IBAction func signUpBtn_clicked(_ sender: Any) {
        // hide keyboard
        self.view.endEditing(true)
        
        // if any of the entries is empty
        if usernameTxt.text!.isEmpty || passwordTxt.text!.isEmpty || repeatPasswordTxt.text!.isEmpty || emailTxt.text!.isEmpty || fullnameTxt.text!.isEmpty || bioTxt.text!.isEmpty || websiteTxt.text!.isEmpty {
            
            // an alert modal
            let alert = UIAlertController(title: "Alert", message: "Please complete the form", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(ok)
            
            // presenting the alert view
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        // if the two passwords are not the same
        if passwordTxt.text != repeatPasswordTxt.text {
            let alert = UIAlertController(title: "Alert", message: "The passwords are not the same", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(ok)
            
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        //send data to backend service
        let user = AVUser()
        
        user.username = usernameTxt.text?.lowercased()
        user.email = emailTxt.text?.lowercased()
        user.password = passwordTxt.text
        
        // for the attributes AVUser doesn't have
        user["fullname"] = fullnameTxt.text?.lowercased()
        user["bio"] = bioTxt.text
        user["website"] = websiteTxt.text?.lowercased()
        user["gender"] = ""
        
        //send profile pic to the service
        let avaData = UIImageJPEGRepresentation(UserImg.image!, 0.5)
        let avaFile = AVFile(name: "userImg.jpg", data: avaData!)
        user["Img"] = avaFile
        
        // upload data async
        user.signUpInBackground { (success: Bool, error: Error?) in
            if success {
                print("Succeeded!")
                
                // use user defaults to store data locally
                UserDefaults.standard.set(user.username, forKey: "username")
                UserDefaults.standard.synchronize()
                
                // use login method from appDelegates
                let appDelegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.login()
                
            } else {
                print(error?.localizedDescription)
            }
        }
        
        
    }
    
    @IBAction func cancelBtn_clicked(_ sender: Any) {
        self.view.endEditing(true)
        // if the view is presented modally by the other one
        self.dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        scrollView.contentSize.height = self.view.frame.height
        scrollViewHeight = self.view.frame.height
        
        // notice if the keyboard appears ot disappears
        NotificationCenter.default.addObserver(self, selector: #selector(showKeyboard), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideKeyboard), name: Notification.Name.UIKeyboardWillHide, object: nil)
        
        // hide keyboard after one tap
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboardTap))
        hideTap.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)
        
        // upload profile pic after tap
        let imgTap = UITapGestureRecognizer(target: self, action: #selector(loadImg))
        imgTap.numberOfTapsRequired = 1
        UserImg.isUserInteractionEnabled = true
        UserImg.addGestureRecognizer(imgTap)
        
        // change the shape of use image to round
        UserImg.layer.cornerRadius = UserImg.frame.width / 2
        UserImg.clipsToBounds = true
        
        // Do any additional setup after loading the view.
        
        // constraints
        UserImg.frame = CGRect(x: self.view.frame.width / 2 - 40, y: 80, width: 80, height: 80)
        let viewWidth = self.view.frame.width
        usernameTxt.frame = CGRect(x: 10, y: UserImg.frame.origin.y + 90, width: viewWidth - 20, height: 30)
        passwordTxt.frame = CGRect(x: 10, y: usernameTxt.frame.origin.y + 40, width: viewWidth - 20, height: 30)
        repeatPasswordTxt.frame = CGRect(x: 10, y: passwordTxt.frame.origin.y + 40, width: viewWidth - 20, height: 30)
        emailTxt.frame = CGRect(x: 10, y: repeatPasswordTxt.frame.origin.y + 60, width: viewWidth - 20, height: 30)
        fullnameTxt.frame = CGRect(x: 10, y: emailTxt.frame.origin.y + 40, width: viewWidth - 20, height: 30)
        bioTxt.frame = CGRect(x: 10, y: fullnameTxt.frame.origin.y + 40, width: viewWidth - 20, height: 30)
        websiteTxt.frame = CGRect(x: 10, y: bioTxt.frame.origin.y + 40, width: viewWidth - 20, height: 30)
        
        signUpBtn.frame = CGRect(x: 20, y: websiteTxt.frame.origin.y + 50, width: viewWidth/4, height: 30)
        cancelBtn.frame = CGRect(x: viewWidth - viewWidth/4 - 20, y: signUpBtn.frame.origin.y, width: viewWidth/4, height: 30)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func showKeyboard(notification: Notification) {
        
        // define the size of keyboard
        let rect = notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        keyboard = rect.cgRectValue
        
        // when keyboard pops up, scrollview changes its height
        UIView.animate(withDuration: 0.4) {
            self.scrollView.frame.size.height = self.scrollViewHeight - self.keyboard.size.height
        }
    }
    
    func hideKeyboard(notification: Notification) {
        UIView.animate(withDuration: 0.4) {
            self.scrollView.frame.size.height = self.view.frame.height
        }
    }
    
    func hideKeyboardTap(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    func loadImg(recognizer: UITapGestureRecognizer) {
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)
        
    }
    
    // choose the picture for user image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        UserImg.image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
    }
    
    // when the user cancels choosing a profile pic
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
