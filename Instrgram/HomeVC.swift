//
//  HomeVC.swift
//  Instrgram
//
//  Created by Ian Mao on 7/14/17.
//  Copyright © 2017 Ian Mao. All rights reserved.
//

import UIKit
import AVOSCloud

class HomeVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    var refresher : UIRefreshControl!
    
    // number of pages per request
    var page: Int = 12
    
    var puuidArray = [String]()
    var picArray = [AVFile]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set navigation bar title
        self.navigationItem.title = AVUser.current()?.username?.uppercased()
        
        // implement refresher
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
        collectionView?.addSubview(refresher)
        
        self.collectionView?.alwaysBounceVertical = true
        
        // receive notification from EditVC
        NotificationCenter.default.addObserver(self, selector: #selector(reload(notification:)), name: NSNotification.Name(rawValue: "reload"), object: nil)
        
        loadPosts()
    }
    
    @IBAction func logout(_ sender: Any) {
        
        AVUser.logOut()
        
        // remove data from UserDefault
        UserDefaults.standard.removeObject(forKey: "username")
        UserDefaults.standard.synchronize()
        
        // set SignIn view controller as the root view controller
        let signIn = self.storyboard?.instantiateViewController(withIdentifier: "SignInVC")
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = signIn
    }
    
    func refresh() {
        collectionView?.reloadData()
        self.navigationItem.title = AVUser.current()?.username?.uppercased()
        refresher.endRefreshing()
    }
    
    func loadPosts() {
        
        // search in database
        let query = AVQuery(className: "Posts")
        query.whereKey("username", equalTo: AVUser.current()?.username)
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
            } else {
                print(error?.localizedDescription)
            }
            
            for object in objects! {
               // put data into the arrays
                // need to change any type to anyObject to get values using .value for key method
                self.puuidArray.append((object as AnyObject).value(forKey: "puuid") as! String)
                self.picArray.append((object as AnyObject).value(forKey: "pic") as! AVFile)
            }
            
            self.collectionView?.reloadData()
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return picArray.count
    }
    
    // managing the header of the collection view
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        // get the header view
        let header = self.collectionView?.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "Header", for: indexPath) as! HeaderView
        
        // show user info in the header view
        header.nameTxt.text = (AVUser.current()?.object(forKey: "fullname") as! String).uppercased()
        header.webTxt.text = AVUser.current()?.object(forKey: "website") as! String
        header.webTxt.sizeToFit()
        header.bioTxt.text = AVUser.current()?.object(forKey: "bio") as? String
        header.bioTxt.sizeToFit()
        
        // get profile picture
        let Img = AVUser.current()?.object(forKey: "Img") as! AVFile
        Img.getDataInBackground {
            (data: Data?, error: Error?) in
            if data != nil {
                header.userImg.image = UIImage(data: data!)
            }
        }
        
        // update number of posts
        let currentUser : AVUser = AVUser.current()!
        
        let postQuery = AVQuery(className: "Posts")
        postQuery.whereKey("username", equalTo: currentUser.username!)
        postQuery.countObjectsInBackground({ (count: Int, error: Error?) in
            if error == nil {
                header.numOfPost.text = String(count)
            }
        })
        
        // update number of followers
        let followerQuery = AVQuery(className: "_Follower")
        followerQuery.whereKey("user", equalTo: currentUser)
        followerQuery.countObjectsInBackground({ (count: Int, error: Error?) in
            if error == nil {
                header.numOfFollowers.text = String(count)
            }
        })
        
        // update number of people following
        let followingQuery = AVQuery(className: "_Followee")
        followingQuery.whereKey("user", equalTo: currentUser)
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
//
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
    
    func postsTap(_ recognizer: UITapGestureRecognizer) {
        if !picArray.isEmpty {
            let index = IndexPath(item: 0, section: 0)
            self.collectionView?.scrollToItem(at: index, at: .top, animated: true)
        }
    }
    
    func followersTap(_ recognizer: UITapGestureRecognizer) {
        
        // load FollowersVC from storyboard
        let followers = self.storyboard?.instantiateViewController(withIdentifier: "FollowersVC") as! FollowersVC
        followers.user = AVUser.current()!
        followers.show = "FOLLOWERS"
        
        // push FollowersVC to the screen
        self.navigationController?.pushViewController(followers, animated: true)
    }
    
    func followingTap(_ recognizer: UITapGestureRecognizer) {
        // load FollowersVC from storyboard
        let following = self.storyboard?.instantiateViewController(withIdentifier: "FollowersVC") as! FollowersVC
        following.user = AVUser.current()!
        following.show = "FOLLOWING"
        
        // push FollowersVC to the screen
        self.navigationController?.pushViewController(following, animated: true)
    }

    func reload(notification: Notification) {
        collectionView?.reloadData()
        self.navigationItem.title = AVUser.current()?.username?.uppercased()
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
            query.whereKey("username", equalTo: AVUser.current()?.username)
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
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let postVC = self.storyboard?.instantiateViewController(withIdentifier: "PostVC") as! PostVC
        
        // send post uuid to PostVC
        postVC.postuuid.append(puuidArray[indexPath.row])
        self.navigationController?.pushViewController(postVC, animated: true)
    }
    
}
