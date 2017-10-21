//
//  SignInVC.swift
//  Instrgram
//
//  Created by Ian Mao on 7/6/17.
//  Copyright © 2017 Ian Mao. All rights reserved.
//

import UIKit
import AVOSCloud

class SignInVC: UIViewController {

    @IBOutlet weak var SignInBtn: UIButton!
    @IBOutlet weak var SignUpBtn: UIButton!
    @IBOutlet weak var ForgetBtn: UIButton!
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var UsernameTxt: UITextField!
    @IBOutlet weak var PasswordTxt: UITextField!
    
    @IBAction func SignInBtn_clicked(_ sender: UIButton) {
        print("sign in button clicked")
        
        // hide keyboard
        self.view.endEditing(true)
        
        // check completion
        if UsernameTxt.text!.isEmpty || PasswordTxt.text!.isEmpty {
            let alert = UIAlertController(title: "Alert", message: "Please complete username and password", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        }
        
        // log in useing username and password
        AVUser.logInWithUsername(inBackground: UsernameTxt.text!, password: PasswordTxt.text!) {
            (user: AVUser?, error: Error?) in
            if error == nil {
                // remember username
                UserDefaults.standard.set(user?.username, forKey: "username")
                UserDefaults.standard.synchronize()
                
                // use login method from appDelegate
                let appDelegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.login()
            }
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // hide keyboard after one tap
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        hideTap.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)
        
        // Do any additional setup after loading the view.
        
        // constraits
//        label.frame = CGRect(x: 10, y: 80, width: self.view.frame.width - 20, height: 50)
//        UsernameTxt.frame = CGRect(x: 10, y: label.frame.origin.y + 70, width: self.view.frame.width - 20, height: 30)
//        PasswordTxt.frame = CGRect(x: 10, y: UsernameTxt.frame.origin.y + 40, width: self.view.frame.width - 20, height: 30)
//        ForgetBtn.frame = CGRect(x: 10, y: PasswordTxt.frame.origin.y + 30, width: self.view.frame.width - 20, height: 30)
//        SignInBtn.frame = CGRect(x: 20, y: ForgetBtn.frame.origin.y + 40, width: self.view.frame.width / 4, height: 30)
//        SignUpBtn.frame = CGRect(x: self.view.frame.width - SignInBtn.frame.width - 20, y: SignInBtn.frame.origin.y, width: SignInBtn.frame.width, height: 30)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func hideKeyboard(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
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
