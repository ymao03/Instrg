//
//  ResetPasswordVC.swift
//  Instrgram
//
//  Created by Ian Mao on 7/6/17.
//  Copyright © 2017 Ian Mao. All rights reserved.
//

import UIKit
import AVOSCloud

class ResetPasswordVC: UIViewController {

    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var resetBtn: UIButton!
    
    @IBAction func cancelBtn_clicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func resetBtn_clicked(_ sender: Any) {
        // hide keyboard
        self.view.endEditing(true)
        
        // check if the user didn't enter email address
        if emailTxt.text!.isEmpty {
            let alert = UIAlertController(title: "ALert", message: "Please enter your email address", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        // use LeanCLoud method to reset password
        AVUser.requestPasswordResetForEmail(inBackground: emailTxt.text!) {
            (success: Bool, error: Error?) in
            if success {
                let alert = UIAlertController(title: "ALert", message: "The link has been sent to your email", preferredStyle: .alert)
                
                // close this view after clicking ok button
                let ok = UIAlertAction(title: "OK", style: .default, handler: { (_) in
                    self.dismiss(animated: true, completion: nil)
                })
                
                alert.addAction(ok)
                self.present(alert, animated: true, completion: nil)
            } else {
                print(error?.localizedDescription)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
