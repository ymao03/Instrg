//
//  SearchUsersVC.swift
//  Instrgram
//
//  Created by Ian Mao on 8/13/17.
//  Copyright © 2017 Ian Mao. All rights reserved.
//

import UIKit
import AVOSCloud

class SearchUsersVC: UITableViewController, UISearchBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var searchBar = UISearchBar()
    
    var usernameArray = [String]()
    var avaArray = [AVFile]()
    
    var collectionView : UICollectionView!
    
    var picArray = [AVFile]()
    var puuidArray = [String]()
    var page : Int = 24
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // implement search bar
        searchBar.delegate = self
        searchBar.showsCancelButton = true
        searchBar.sizeToFit()
        searchBar.tintColor = UIColor.groupTableViewBackground
        searchBar.frame.size.width = self.view.frame.width - 30
        
        let searchItem = UIBarButtonItem(customView: searchBar)
        self.navigationItem.leftBarButtonItem = searchItem
        
        loadUsers()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return usernameArray.count
    }
    
    func loadUsers() {
        let usersQuery = AVUser.query()
        usersQuery.addDescendingOrder("createdAt")
        usersQuery.limit = 20
        usersQuery.findObjectsInBackground({ (objects: [Any]?, error: Error?) in
            if error == nil {
                // clear the arrays
                self.usernameArray.removeAll(keepingCapacity: false)
                self.avaArray.removeAll(keepingCapacity: false)
                
                for object in objects! {
                    self.usernameArray.append((object as AnyObject).username as! String)
                    self.avaArray.append((object as AnyObject).value(forKey: "Img") as! AVFile)
                    
                }
                
                self.tableView.reloadData()
            } else {
                print(error?.localizedDescription)
            }
        })
    }
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let userQuery = AVUser.query()
        userQuery.whereKey("username", matchesRegex: "(?!)" + searchBar.text!)
        userQuery.findObjectsInBackground({ (objects: [Any]?, error: Error?) in
            if error == nil {
                
                // if can't find any users in username query, then search via fullname query
                if objects!.isEmpty {
                    let fullnameQuery = AVUser.query()
                    fullnameQuery.whereKey("fullname", matchesRegex: "(?!)" + searchBar.text!)
                    fullnameQuery.findObjectsInBackground({ (objects: [Any]?, error: Error?) in
                        if error == nil {
                            // clear arrays
                            self.usernameArray.removeAll(keepingCapacity: false)
                            self.avaArray.removeAll(keepingCapacity: false)
                            
                            for object in objects! {
                                self.usernameArray.append((object as AnyObject).username as! String)
                                self.avaArray.append((object as AnyObject).value(forKey: "Img") as! AVFile)
                            }
                            
                            self.tableView.reloadData()
                        }
                    
                    })
                } else {
                    // clear arrays
                    self.usernameArray.removeAll(keepingCapacity: false)
                    self.avaArray.removeAll(keepingCapacity: false)
                    
                    for object in objects! {
                        self.usernameArray.append((object as AnyObject).username as! String)
                        self.avaArray.append((object as AnyObject).value(forKey: "Img") as! AVFile)
                    }
                    
                    self.tableView.reloadData()
                }
            } else {
                
            }
        })
        
        return true
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton = false
        searchBar.text = ""
        
        loadUsers()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.view.frame.width / 4
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! FollowersCell
        
        cell.followBtn.isHidden = true
        
        cell.usernameLabel.text = usernameArray[indexPath.row]
        
        avaArray[indexPath.row].getDataInBackground({ (data: Data?, error: Error?) in
            if error == nil {
                cell.Img.image = UIImage(data: data!)
            }
        })
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! FollowersCell
        
        if cell.usernameLabel.text == AVUser.current()?.username {
            let home = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
            self.navigationController?.pushViewController(home, animated: true)
        } else {
            let query = AVUser.query()
            query.whereKey("username", equalTo: cell.usernameLabel.text as Any)
            query.findObjectsInBackground({ (objects: [Any]?, error: Error?) in
                if let object = objects?.last {
                    let guest = self.storyboard?.instantiateViewController(withIdentifier: "GuestVC") as! GuestVC
                    guest.guestArray.append(object as! AVUser)
                    self.navigationController?.pushViewController(guest, animated: true)
                }
            })
        }
    }
    
    // launch the collection view by default
    func collectionViewLaunch() {
        
        let layout = UICollectionViewFlowLayout()
        
        layout.itemSize = CGSize(width: self.view.frame.width / 3, height: self.view.frame.width / 3)
        layout.scrollDirection = .vertical
        
        let frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height - self.tabBarController!.tabBar.frame.height - self.navigationController!.navigationBar.frame.height - 20)
        
        collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = .white
        self.view.addSubview(collectionView)
        
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
    }
    
    // the space between rows
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    // the space between items
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return picArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        let picImg = UIImageView(frame: CGRect(x: 0, y: 0, width: cell.frame.width, height: cell.frame.height))
        cell.addSubview(picImg)
        
        picArray[indexPath.row].getDataInBackground({ (data: Data?, error: Error?) in
            if error == nil {
                picImg.image = UIImage(data: data!)
            } else {
                print(error?.localizedDescription)
            }
        })
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let post = self.storyboard?.instantiateViewController(withIdentifier: "PostVC") as! PostVC
        post.puuidArray.append(puuidArray[indexPath.row])
        
        self.navigationController?.pushViewController(post, animated: true)
    }
    
    func loadPosts() {
        let query = AVQuery(className: "Posts")
        query.limit = page
        query.findObjectsInBackground({ (objects: [Any]?, error: Error?) in
            
            if error == nil {
                // clear all the data
                self.picArray.removeAll(keepingCapacity: false)
                self.puuidArray.removeAll(keepingCapacity: false)
                
                // retrieve data
                for object in objects! {
                    self.puuidArray.append((object as AnyObject).value(forKey: "puuid") as! String)
                    self.picArray.append((object as AnyObject).value(forKey: "pic") as! AVFile)
                }
                
                self.collectionView.reloadData()
            } else {
                print(error?.localizedDescription)
            }
        
        })
    }
    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        if scrollView.contentOffset.y >= scrollView.contentSize.height / 6 {
//            self.loadMore()
//        }
//    }
    
    

}
