//
//  PostVC.swift
//  Instrgram
//
//  Created by Ian Mao on 8/1/17.
//  Copyright © 2017 Ian Mao. All rights reserved.
//

import UIKit
import AVOSCloud

class PostVC: UITableViewController {
    
    var postuuid = [String]()
    var avaArray = [AVFile]()
    var usernameArray = [String]()
    var postPicArray = [AVFile]()
    var puuidArray = [String]()
    var titleArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // define back button
        self.navigationItem.hidesBackButton = true
        let backBtn = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(back(_sender:)))
        self.navigationItem.leftBarButtonItem = backBtn
        
        // right swipe to return to the previous view controller
        let backSwipe = UISwipeGestureRecognizer(target: self, action: #selector(back(_sender:)))
        backSwipe.direction = .right
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(backSwipe)
        
        // set table row height
//        tableView.rowHeight = UITableViewAutomaticDimension
//        tableView.estimatedRowHeight = 550
        
        // load post information
        let postQuery = AVQuery(className: "Posts")
        postQuery.whereKey("puuid", equalTo: postuuid.last!)
        postQuery.findObjectsInBackground({(objects: [Any]?, error: Error?) in
            
            // clear data
            self.avaArray.removeAll(keepingCapacity: false)
            self.usernameArray.removeAll(keepingCapacity: false)
            self.postPicArray.removeAll(keepingCapacity: false)
            self.puuidArray.removeAll(keepingCapacity: false)
            self.titleArray.removeAll(keepingCapacity: false)
            
            for object in objects! {
                self.avaArray.append((object as AnyObject).value(forKey: "Img") as! AVFile)
                self.usernameArray.append((object as AnyObject).value(forKey: "username") as! String)
                self.postPicArray.append((object as AnyObject).value(forKey: "pic") as! AVFile)
                self.puuidArray.append((object as AnyObject).value(forKey: "puuid") as! String)
                self.titleArray.append((object as AnyObject).value(forKey: "title") as! String)
            }
            
            self.tableView.reloadData()
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return usernameArray.count
    }

    func back(_sender: UIBarButtonItem) {
        _ = self.navigationController?.popViewController(animated: true)
        
        if !postuuid.isEmpty {
            postuuid.removeLast()
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PostCell
        
        cell.usernameBtn.setTitle(usernameArray[indexPath.row], for: .normal)
        cell.puuidLabel.text = puuidArray[indexPath.row]
        cell.titleLabel.text = titleArray[indexPath.row]
        
        cell.titleLabel.sizeToFit()
        cell.usernameBtn.sizeToFit()
        
        avaArray[indexPath.row].getDataInBackground { (data: Data?, error: Error?) in
            cell.userImg.image = UIImage(data: data!)
        }
        
        postPicArray[indexPath.row].getDataInBackground { (data: Data?, error: Error?) in
            cell.postImg.image = UIImage(data: data!)
        }
        
        return cell
    }
}
