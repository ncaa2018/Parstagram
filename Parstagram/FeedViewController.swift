//
//  FeedViewController.swift
//  Parstagram
//
//  Created by loan on 10/27/20.
//  Copyright © 2020 naomia2022@hotmail.com. All rights reserved.
//

import UIKit
import Parse
import Alamofire
import MessageInputBar

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MessageInputBarDelegate {
    
    var posts = [PFObject]()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let post = posts[section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        return comments.count + 2 //post + comments + 1 for creating a comment
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.section]
        let comments = (post["comments"] as? [PFObject]) ?? []
               
        
        if indexPath.row == 0 { //post cell is always the 0th row
        
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
           
            let user = post["author"] as! PFUser
            cell.usernameLabel.text = user.username
            
            cell.captionLabel.text = post["caption"] as! String
            
            let imageFile = post["photo"] as! PFFileObject
            let urlString = imageFile.url!
            let url = URL(string: urlString)!
            
            cell.photoView.af_setImage(withURL: url)
            
            return cell
        }
        else if indexPath.row <= comments.count{ //index 0 is post, 1 is comments, 2 is addComment so if indexPath is 1, then within the domain of comments
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
            
            let comment = comments[indexPath.row - 1] //first comment is at index 1, at index 0 is the first post
            cell.commentLabel.text = comment["text"] as? String
            
            let user = comment["author"] as? PFUser
            cell.nameLabel.text = user?.username
            return cell
        } else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "addCommentCell")!
            
            return cell
        }
    
    }
    

    @IBOutlet weak var tableView: UITableView!
    let commentBar = MessageInputBar()
    var showsCommentBar = false
    var selectedPost: PFObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commentBar.inputTextView.placeholder = "add a comment..."
        commentBar.sendButton.title = "post"
        commentBar.delegate = self //who controls it? when did they click send?
        
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
        tableView.keyboardDismissMode = .interactive
        
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWillBeHidden(note:)), name: UIResponder.keyboardWillHideNotification, object: nil) //when event happens
    }
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        
        //create the comment
        let comment = PFObject(className: "comments")
        comment["text"] = text
        comment["post"] = selectedPost //foreign key?
        comment["author"] = PFUser.current()!

        selectedPost.add(comment, forKey: "comments") //every post should have an array called comments. Add this comment to that

        selectedPost.saveInBackground { (success,error) in

            if success{
                print("comment saved")
            }
            else{
                print("comment did not save")
            }
        }
        tableView.reloadData()
        
        
        //clear and dismiss the input bar
        commentBar.inputTextView.text = nil
        showsCommentBar = false
        becomeFirstResponder()
        commentBar.inputTextView.resignFirstResponder()
    }
    
    
    
    //take out messageInputBar from bottom
    @objc func keyboardWillBeHidden(note: Notification){
        commentBar.inputTextView.text = nil
        showsCommentBar = false
        becomeFirstResponder()
    }
    
    override var inputAccessoryView: UIView? {
        return commentBar

    }
    override var canBecomeFirstResponder: Bool {
        return showsCommentBar //to control whether it shows or not
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated) //refresh
        let query = PFQuery(className:"Posts")
        query.includeKeys(["author","comments","comments.author"]) //fetch object from the pointer in the table
        query.limit = 20
        
        query.findObjectsInBackground { (posts,error) in
            if posts != nil {
                self.posts = posts! //get the query
                self.tableView.reloadData() //show data
            }
            
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let post = posts[indexPath.section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        if indexPath.row == comments.count + 1 { //on the last row
            showsCommentBar = true
            becomeFirstResponder() //call
            
            commentBar.inputTextView.becomeFirstResponder() //bring the keyboard up
            
            selectedPost = post //on that is selected by user
        }
        

    }

    @IBAction func onLogoutButton(_ sender: Any) {
        
        PFUser.logOut() //clear parse tuple
        let main = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = main.instantiateViewController(identifier: "LoginViewController")
        
        //access window
        let delegate = self.view.window?.windowScene?.delegate as! SceneDelegate // UIApplication.shared.delegate as! SceneDelegate
        delegate.window?.rootViewController = loginViewController
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
