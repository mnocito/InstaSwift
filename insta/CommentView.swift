//
//  CommentView.swift
//  insta
//
//  Created by Marco on 8/11/16.
//  Copyright © 2016 Marco. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class CommentView: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var commentInfo: [JSON]!
    var captionInfo: JSON?
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if captionInfo != nil {
            return commentInfo.count + 1
        }
        return commentInfo.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("CommentCell", forIndexPath: indexPath) as! CommentCell
        if captionInfo != nil {
            if indexPath.row == 0 {
                let mainUrl = NSURL(string: captionInfo!["from"]["profile_picture"].stringValue)
                let mainData = NSData(contentsOfURL: mainUrl!)
                // bold the name
                cell.profileImage.image = UIImage(data: mainData!)
                cell.nameLabel.text = captionInfo!["from"]["username"].stringValue
                cell.commentLabel.text = captionInfo!["text"].stringValue
            } else {
                let index = indexPath.row - 1
                let mainUrl = NSURL(string: commentInfo![index]["from"]["profile_picture"].stringValue)
                let mainData = NSData(contentsOfURL: mainUrl!)
                // bold the name
                cell.profileImage.image = UIImage(data: mainData!)
                cell.nameLabel.text = commentInfo![index]["from"]["username"].stringValue
                cell.commentLabel.text = commentInfo![index]["text"].stringValue
            }
        } else {
            let index = indexPath.row
            let mainUrl = NSURL(string: commentInfo![index]["from"]["profile_picture"].stringValue)
            let mainData = NSData(contentsOfURL: mainUrl!)
            // bold the name
            cell.profileImage.image = UIImage(data: mainData!)
            cell.nameLabel.text = commentInfo![index]["from"]["username"].stringValue
            cell.commentLabel.text = commentInfo![index]["text"].stringValue
        }
        return cell
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let bottomOffset = CGPoint(x: 0, y: tableView.contentSize.height - tableView
            .bounds.size.height)
        tableView.setContentOffset(bottomOffset, animated: false)
        self.navigationController!.navigationBar.topItem!.title = "Back"
        self.tableView.tableFooterView = UIView()
        
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
            let viewcont = self.storyboard?.instantiateViewControllerWithIdentifier("ProfileView") as? ProfileView
            self.navigationController!.pushViewController(viewcont!, animated: true)
        
    }
    @IBOutlet weak var tableView: UITableView!

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    



}
