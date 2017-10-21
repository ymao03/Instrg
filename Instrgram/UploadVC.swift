//
//  UploadVC.swift
//  Instrgram
//
//  Created by Ian Mao on 7/28/17.
//  Copyright © 2017 Ian Mao. All rights reserved.
//

import UIKit
import AVOSCloud

class UploadVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var text: UITextView!
    
    @IBOutlet weak var barPostBtn: UIBarButtonItem!
    @IBOutlet weak var barCancelBtn: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        alignment()
       
        barPostBtn.isEnabled = false
        barCancelBtn.isEnabled = false
        
        // tap the default image to upload pictures
        let imgTap = UITapGestureRecognizer(target: self, action: #selector(selecting))
        imgTap.numberOfTapsRequired = 1
        self.img.isUserInteractionEnabled = true
        self.img.addGestureRecognizer(imgTap)
        
        // reset uploadVC
        img.image = UIImage(named: "picture.png")
        text.text = ""
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func barPostBtn_clicked(_ sender: Any) {
        self.view.endEditing(true)
        
        let object = AVObject(className: "Posts")
        object["username"] = AVUser.current()?.username
        object["Img"] = AVUser.current()?.value(forKey: "Img") as! AVFile
        object["puuid"] = "\(AVUser.current()?.username) \(NSUUID().uuidString)"
        
        if text.text.isEmpty {
            object["title"] = ""
        } else {
            object["title"] = text.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
        
        let imgData = UIImageJPEGRepresentation(img.image!, 0.5)
        let imgFile = AVFile(name: "post.jpg", data: imgData!)
        object["pic"] = imgFile
        
        object.saveInBackground({ (success: Bool, error: Error?) in
            if error == nil {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "uploaded"), object: nil)
                self.tabBarController?.selectedIndex = 0
            }
            
        })
        
        self.viewDidLoad()
    }
    
    @IBAction func cancelBtn_clicked(_ sender: Any) {
        self.viewDidLoad()
        
        self.view.backgroundColor = .white
        self.text.alpha = 1
    }
    
    func selecting() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        img.image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
        
        // enable post button
        barPostBtn.isEnabled = true
        barCancelBtn.isEnabled = true
        
        // tap image to zoom in
        let zoomTap = UITapGestureRecognizer(target: self, action: #selector(zoomIn))
        zoomTap.numberOfTapsRequired = 1
        img.isUserInteractionEnabled = true
        img.addGestureRecognizer(zoomTap)
        
    }
    
    func alignment() {
        let width = self.view.frame.width
        
        img.frame = CGRect(x: 15, y: self.navigationController!.navigationBar.frame.height + 35, width: width / 4.5, height: width / 4.5)
        text.frame = CGRect(x: img.frame.width + 25, y: img.frame.origin.y, width: width - text.frame.origin.x - 10, height: img.frame.height)
    }
    
    func zoomIn() {
        
        let zoomedImg = CGRect(x: 0, y: self.view.center.y - self.view.center.x, width: self.view.frame.width, height: self.view.frame.width)
        let originalImg = CGRect(x: 15, y: self.navigationController!.navigationBar.frame.height + 35, width: self.view.frame.width / 4.5, height: self.view.frame.width / 4.5)
        
        if img.frame == originalImg {
            UIView.animate(withDuration: 0.3, animations: {
                self.img.frame = zoomedImg
                self.view.backgroundColor = .black
                
                // make text and post button disappear
                self.barPostBtn.isEnabled = false
//                self.barCancelBtn.isEnabled = false
                self.text.alpha = 0
            })
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                self.img.frame = originalImg
                self.view.backgroundColor = .white
                
                self.barPostBtn.isEnabled = true
//                self.barCancelBtn.isEnabled = true
                self.text.alpha = 1
            })
        }
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
