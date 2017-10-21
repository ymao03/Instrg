//
//  FeedVC.swift
//  Instrgram
//
//  Created by Ian Mao on 8/7/17.
//  Copyright © 2017 Ian Mao. All rights reserved.
//

import UIKit
import AVOSCloud

class FeedVC: UITableViewController {

    @IBOutlet weak var indicator: UIActivityIndicatorView!
    var refresher = UIRefreshControl()
    
    var avaArray = [AVFile]()
    var usernameArray = [String]()
    var postPicArray = [AVFile]()
    var puuidArray = [String]()
    var titleArray = [String]()
    
    // array of users current user follows
    var followerArray = [String]()
    var page: Int = 10
    
    
    @IBAction func usernameBtn_clicked(_ sender: AnyObject) {
        let i = sender.layer.value(forKey: "index") as! IndexPath
        let cell = tableView.cellForRow(at: i) as! PostCell
        
        if cell.usernameBtn.titleLabel?.text == AVUser.current()?.username {
            let home = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
            self.navigationController?.pushViewController(home, animated: true)
        } else {
            let query = AVUser.query()
            query.whereKey("username", equalTo: cell.usernameBtn.titleLabel?.text! as Any)
            query.findObjectsInBackground({ (objects: [Any]?, error: Error?) in
                if let object = objects?.last {
                    let guest = self.storyboard?.instantiateViewController(withIdentifier: "GuestVC") as! GuestVC
                    guest.guestArray.append(object as! AVUser)
                    self.navigationController?.pushViewController(guest, animated: true)
                }
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Feed"
    
//        tableView.rowHeight = UITableViewAutomaticDimension
//        tableView.estimatedRowHeight = 550
        
        refresher.addTarget(self, action: #selector(loadPosts), for: .valueChanged)
        self.view.addSubview(refresher)
        
        indicator.center.x = tableView.center.x
        
        loadPosts()
        
        // receive notification from uploadVC
        NotificationCenter.default.addObserver(self, selector: #selector(uploaded(notification:)), name: NSNotification.Name(rawValue: "uploaded"), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return puuidArray.count
    }

    func loadPosts() {
        AVUser.current()?.getFollowees{ (objects: [Any]?, error: Error?) in
            if error == nil {
                self.followerArray.removeAll(keepingCapacity: false)
                
                for object in objects! {
                    self.followerArray.append((object as AnyObject).username!!)
                }
                
                // add current user to the array
                self.followerArray.append((AVUser.current()?.username)!)
                
                
                let postQuery = AVQuery(className: "Posts")
                postQuery.whereKey("username", containedIn: self.followerArray)
                postQuery.limit = self.page
                postQuery.addDescendingOrder("createdAt")
                postQuery.findObjectsInBackground { (objects: [Any]?, error: Error?) in
                    
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
                    self.refresher.endRefreshing()
                }
            } else {
                print(error?.localizedDescription)
            }
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.frame.height * 2 {
            loadMore()
        }
    }
    
    func loadMore() {
        if self.page <= puuidArray.count {
            indicator.startAnimating()
            page = page + 10
            
            AVUser.current()?.getFollowees{ (objects: [Any]?, error: Error?) in
                if error == nil {
                    self.followerArray.removeAll(keepingCapacity: false)
                    
                    for object in objects! {
                        self.followerArray.append((object as AnyObject).username!!)
                    }
                    
                    // add current user to the array
                    self.followerArray.append((AVUser.current()?.username)!)
                    
                    
                    let postQuery = AVQuery(className: "Posts")
                    postQuery.whereKey("username", containedIn: self.followerArray)
                    postQuery.limit = self.page
                    postQuery.addDescendingOrder("createdAt")
                    postQuery.findObjectsInBackground { (objects: [Any]?, error: Error?) in
                        
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
                        self.indicator.stopAnimating()
                    }
                } else {
                    print(error?.localizedDescription)
                }
            }
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
        
        // set indexpath value to the username button
        cell.usernameBtn.layer.setValue(indexPath, forKey: "index")
        
        return cell
    }
    
    func uploaded(notification: Notification) {
        loadPosts()
    }

}
