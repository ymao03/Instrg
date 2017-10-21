//
//  GuestVC.swift
//  Instrgram
//
//  Created by Ian Mao on 7/20/17.
//  Copyright © 2017 Ian Mao. All rights reserved.
//

import UIKit
import AVOSCloud

class GuestVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    var guestArray = [AVUser]()
    
    // get data from LeanCloud
    var puuidArray = [String]()
    var picArray = [AVFile]()
    
    var refresher : UIRefreshControl!
    var page : Int = 12
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView?.alwaysBounceVertical = true
        self.navigationItem.title = guestArray.last?.username
        
        // hide the original back button
        self.navigationItem.hidesBackButton = true
        
        // create our own back button
        let backBtn = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(back(_:)))
        self.navigationItem.leftBarButtonItem = backBtn
        
        // return when right swipe
        let backSwipe = UISwipeGestureRecognizer(target: self, action: #selector(back(_:)))
        backSwipe.direction = .right
        self.view.addGestureRecognizer(backSwipe)
        
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(refresh), for: .valueChanged)
        self.collectionView?.addSubview(refresher)
        
        loadPosts()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func back(_: UIBarButtonItem) {
        // return to last viewController
        _ = self.navigationController?.popViewController(animated: true)
        
        // remove the last AVUser from guestArray
        if !guestArray.isEmpty {
            guestArray.removeLast()
        }
    }
    
    func refresh() {
        self.collectionView?.reloadData()
        self.refresher.endRefreshing()
    }
    
    func loadPosts() {
        
        // search in database
        let query = AVQuery(className: "Posts")
        query.whereKey("username", equalTo: guestArray.last!.username!)
        query.limit = page
        
        // objects array exists if success
        // objects array has all contents of "username"
        query.findObjectsInBackground({
            (objects: [Any]?, error: Error?) in
            // if success
            if error == nil {
                
                // clear both arrays
                self.puuidArray.removeAll(keepingCapacity: false)
                self.picArray.removeAll(keepingCapacity: false)
                
                for object in objects! {
                    // put data into the arrays
                    // need to change any type to anyObject to get values using .value for key method
                    self.puuidArray.append((object as AnyObject).value(forKey: "puuid") as! String)
                    self.picArray.append((object as AnyObject).value(forKey: "pic") as! AVFile)
                }
                
                self.collectionView?.reloadData()
                
            } else {
                print(error?.localizedDescription)
            }
        })
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return picArray.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PictureCell
        
        picArray[indexPath.row].getDataInBackground {
            (data: Data?, error: Error?) in
            if error == nil {
                cell.picImg.image = UIImage(data: data!)
            } else {
                print(error?.localizedDescription)
            }
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        // get the header view
        let header = self.collectionView?.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "Header", for: indexPath) as! HeaderView
        
        header.user = guestArray.last
        
        // find the user in database
        let infoQuery = AVQuery(className: "_User")
        infoQuery.whereKey("username", equalTo: guestArray.last!.username!)
        
        // find user into and update the header
        infoQuery.findObjectsInBackground { (objects: [Any]?, error: Error?) in
            if error == nil {
                // check if there's any user
                // use guard let objects = objects to unwrap objects so we don't need ! anymore
                guard let objects = objects, objects.count > 0 else {
                    return
                }
                
                // find user info
                for object in objects {
                    header.nameTxt.text = ((object as AnyObject).object(forKey: "fullname") as! String).uppercased()
                    header.webTxt.text = (object as AnyObject).object(forKey: "website") as! String
                    header.webTxt.sizeToFit()
                    header.bioTxt.text = (object as AnyObject).object(forKey: "bio") as? String
                    header.bioTxt.sizeToFit()
                    
                    // get profile picture
                    let Img = (object as AnyObject).object(forKey: "Img") as! AVFile
                    Img.getDataInBackground {
                        (data: Data?, error: Error?) in
                        header.userImg.image = UIImage(data: data!)
                    }
                }
            } else {
                print(error?.localizedDescription)
            }
        }
        
        // find the relationship between the user and the visitor
        // the followee's followees
        let query = AVQuery(className: "_Followee")
        
        // if any of his followee is the current user
        query.whereKey("followee", equalTo: guestArray.last!)
        query.whereKey("user", equalTo: AVUser.current()!)
        
        query.countObjectsInBackground({(count: Int, error: Error?) in
            if error == nil {
                if count == 0 {
                    header.editProfile.setTitle("FOLLOW", for: .normal)
                } else {
                    header.editProfile.setTitle("UNFOLLOW", for: .normal)
                }
            }
        })

        // update number of posts
        
        let postQuery = AVQuery(className: "Posts")
        postQuery.whereKey("username", equalTo: guestArray.last!.username!)
        postQuery.countObjectsInBackground({ (count: Int, error: Error?) in
            if error == nil {
                header.numOfPost.text = String(count)
            }
        })
        
        // update number of followers
        let followerQuery = AVQuery(className: "_Follower")
        followerQuery.whereKey("user", equalTo: guestArray.last!)
        followerQuery.countObjectsInBackground({ (count: Int, error: Error?) in
            if error == nil {
                header.numOfFollowers.text = String(count)
            }
        })
        
        // update number of people following
        let followingQuery = AVQuery(className: "_Followee")
        followingQuery.whereKey("user", equalTo: guestArray.last!)
        followingQuery.countObjectsInBackground({ (count: Int, error: Error?) in
            if error == nil {
                header.numOfFollowing.text = String(count)
            }
        })
        
        // tap number of posts
        let postsTap = UITapGestureRecognizer(target: self, action: #selector(postsTap(_:)))
        postsTap.numberOfTapsRequired = 1
        header.numOfPost.isUserInteractionEnabled = true
        header.numOfPost.addGestureRecognizer(postsTap)
        
        // tap number of followers
        let followersTap = UITapGestureRecognizer(target: self, action: #selector(followersTap(_:)))
        followersTap.numberOfTapsRequired = 1
        header.numOfFollowers.isUserInteractionEnabled = true
        header.numOfFollowers.addGestureRecognizer(followersTap)
        
        // tap number of following
        let followingTap = UITapGestureRecognizer(target: self, action: #selector(followingTap(_:)))
        followingTap.numberOfTapsRequired = 1
        header.numOfFollowing.isUserInteractionEnabled = true
        header.numOfFollowing.addGestureRecognizer(followingTap)
        
        return header
    }
    
    func postsTap(_ recognizer: UITapGestureRecognizer) {
        if !picArray.isEmpty {
            let index = IndexPath(item: 0, section: 0)
            self.collectionView?.scrollToItem(at: index, at: .top, animated: true)
        }
    }
    
    func followersTap(_ recognizer: UITapGestureRecognizer) {
        
        // load FollowersVC from storyboard
        let followers = self.storyboard?.instantiateViewController(withIdentifier: "FollowersVC") as! FollowersVC
        followers.user = guestArray.last!
        followers.show = "FOLLOWERS"
        
        // push FollowersVC to the screen
        self.navigationController?.pushViewController(followers, animated: true)
    }
    
    func followingTap(_ recognizer: UITapGestureRecognizer) {
        // load FollowersVC from storyboard
        let following = self.storyboard?.instantiateViewController(withIdentifier: "FollowersVC") as! FollowersVC
        following.user = guestArray.last!
        following.show = "FOLLOWING"
        
        // push FollowersVC to the screen
        self.navigationController?.pushViewController(following, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = CGSize(width: self.view.frame.width / 3, height: self.view.frame.width / 3)
        
        return size
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        // content is already scrolled to the end
        if scrollView.contentOffset.y >= scrollView.contentSize.height - self.view.frame.height {
            self.loadMore()
        }
    }
    
    func loadMore() {
        if page <= picArray.count {
            page = page + 12
            
            let query = AVQuery(className: "Posts")
            query.whereKey("username", equalTo: guestArray.last?.username)
            query.limit = page
            query.findObjectsInBackground({ (objects: [Any]?, error: Error?) in
                
                if error == nil {
                    
                    // empty two arrays
                    self.puuidArray.removeAll(keepingCapacity: false)
                    self.picArray.removeAll(keepingCapacity: false)
                    
                    for object in objects! {
                        self.puuidArray.append((object as AnyObject).value(forKey: "puuid") as! String)
                        self.picArray.append((object as AnyObject).value(forKey: "pic") as! AVFile)
                    }
                    
                    print("loaded + \(self.page)")
                    self.collectionView?.reloadData()
                } else {
                    print(error?.localizedDescription)
                }
            })
        }
    }


}
