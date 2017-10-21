//
//  FollowersVC.swift
//  Instrgram
//
//  Created by Ian Mao on 7/18/17.
//  Copyright © 2017 Ian Mao. All rights reserved.
//

import UIKit
import AVOSCloud

class FollowersVC: UITableViewController {

    var show = String()
    var user = AVUser()
    
    var followersArray = [AVUser]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = show
        
        if show == "FOLLOWERS" {
            loadFollowers()
        } else {
            loadFollowees()
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return followersArray.count
    }
    
    func loadFollowers() {
        
        user.getFollowers {(followers: [Any]?, error: Error?) in
            if error == nil && followers != nil {
                self.followersArray = followers as! [AVUser]
                
                // refresh the table view
                self.tableView.reloadData()
                
            } else {
                print(error?.localizedDescription)
            }
        
        }
    }

    
    func loadFollowees() {
        user.getFollowees {(followees: [Any]?, error: Error?) in
            if error == nil && followees != nil {
                self.followersArray = followees as! [AVUser]
                
                // refresh the table view
                self.tableView.reloadData()
            } else {
                print(error?.localizedDescription)
            }
            
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // Configure the cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! FollowersCell
        cell.usernameLabel.text = followersArray[indexPath.row].username
        cell.user = followersArray[indexPath.row]
        
        let img = followersArray[indexPath.row].object(forKey: "Img") as! AVFile
        img.getDataInBackground({
            (data: Data?, error: Error?) in
            if error == nil {
                cell.Img.image = UIImage(data: data!)
            } else {
                print(error?.localizedDescription)
            }
        
        })
        
        // check if the user follows any followee
        
        // the followee's followees
        let query = AVQuery(className: "_Followee")
        
        // if any of his followee is the current user
        query.whereKey("followee", equalTo: followersArray[indexPath.row])
        query.whereKey("user", equalTo: user)
        
        query.countObjectsInBackground({(count: Int, error: Error?) in
            if error == nil {
                
                if count == 0 { // if current user doesn't follow the followee
                    cell.followBtn.setTitle("FOLLOW", for: .normal)
                    cell.followBtn.backgroundColor = .lightGray
                } else {
                    cell.followBtn.setTitle("UNFOLLOW", for: .normal)
                    cell.followBtn.backgroundColor = .lightGray
                }
                
                // if a user clicks into someone's profile, we hide the followBtn to avoid following the user himself
                if cell.usernameLabel.text == AVUser.current()?.username {
                    cell.followBtn.isHidden = true
                }
            }
        })
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! FollowersCell
        
        if cell.usernameLabel.text == AVUser.current()?.username {
            // if clicking the user himself, going to homeVC
            let home = storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
            self.navigationController?.pushViewController(home, animated: true)
        } else {
            let guest = storyboard?.instantiateViewController(withIdentifier: "GuestVC") as! GuestVC
            guest.guestArray.append(followersArray[indexPath.row])
            self.navigationController?.pushViewController(guest, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return self.view.frame.width / 5
    
    }
    
    

}
