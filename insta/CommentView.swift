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
    var heights: [CGFloat] = []
    let sWidth = UIScreen.mainScreen().bounds.width
    var heightsLoaded = false
    @IBOutlet weak var tableView: UITableView!
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
        cell.commentLabel.preferredMaxLayoutWidth = sWidth - 85
        cell.commentLabel.numberOfLines = 0
        cell.commentLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        print("frame: \(cell.commentLabel.frame.size.height)")
        print("bounds: \(cell.commentLabel.bounds.height)")
        heights.append(cell.commentLabel.frame.size.height + 10.0)
        return cell
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.estimatedRowHeight = 100.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.contentInset = UIEdgeInsets(top: 35, left: 0, bottom: 0, right: 0)
        self.navigationController!.navigationBar.topItem!.title = "Back"
        self.tableView.tableFooterView = UIView()
        
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
            let viewcont = self.storyboard?.instantiateViewControllerWithIdentifier("ProfileView") as? ProfileView
            self.navigationController!.pushViewController(viewcont!, animated: true)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
