//
//  PhotoView.swift
//  insta
//
//  Created by Marco on 8/7/16.
//  Copyright © 2016 Marco. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
class PhotoView: UIViewController {
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var outerView: UIStackView!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var commentsButton: UIButton!
    @IBOutlet weak var profileView: UIImageView!
    @IBAction func toComments(sender: AnyObject) {
        let viewcont = self.storyboard?.instantiateViewControllerWithIdentifier("CommentView") as? CommentView
        viewcont!.commentInfo = commentInfo
        if mediaInfo["caption"]["from"] != nil {
            viewcont!.captionInfo = mediaInfo["caption"]
        }
        self.navigationController?.pushViewController(viewcont!, animated: true)
    }
    @IBOutlet weak var secondComment: UILabel!
    @IBOutlet weak var mainImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var firstComment: UILabel!
    var mediaInfo: JSON!
    var commentInfo: [JSON]!
    let sWidth = UIScreen.mainScreen().bounds.width
    let accessT = "ACCESS_TOKEN"
    override func viewDidLoad() {
        super.viewDidLoad()
        captionLabel.frame = CGRectMake(captionLabel.frame.origin.x, captionLabel.frame.origin.y, sWidth, captionLabel.frame.height)
        likesLabel.text = "\(mediaInfo["likes"]["count"].stringValue) likes"
        commentsButton.setTitle("View all \(commentInfo.count) comments", forState: UIControlState.Normal)
        nameLabel.text = mediaInfo["user"]["username"].stringValue
        let mainUrl = NSURL(string: mediaInfo["images"]["standard_resolution"]["url"].stringValue)
        print("url: \(mediaInfo["images"]["standard_resolution"]["url"].stringValue)")
        let mainData = NSData(contentsOfURL: mainUrl!)
        // bold the name
        mainImage.image = ResizeImage(UIImage(data: mainData!)!, targetSize: CGSize(width: sWidth, height: 400))
        let profUrl = NSURL(string: mediaInfo["user"]["profile_picture"].stringValue)
        let data = NSData(contentsOfURL: profUrl!)
        // format image
        profileView.image = UIImage(data: data!)
        profileView.layer.borderWidth = 1
        profileView.layer.masksToBounds = false
        profileView.layer.borderColor = UIColor.blackColor().CGColor
        profileView.layer.cornerRadius = profileView.frame.height/2
        profileView.clipsToBounds = true
        //caption stuff
        let boldAtr = [NSFontAttributeName: UIFont.boldSystemFontOfSize(17)]
        if mediaInfo["caption"]["from"] != nil {
            let captionName = NSMutableAttributedString(string: "\(mediaInfo["caption"]["from"]["username"].stringValue) ", attributes: boldAtr)
            let captionBody  = NSMutableAttributedString(string: mediaInfo["caption"]["text"].stringValue)
            captionName.appendAttributedString(captionBody)
            captionLabel.attributedText = captionName
        } else {
            captionLabel.hidden = true
        }
        // set comment stuff
        switch commentInfo.count {
        case 0:
            secondComment.hidden = true
            firstComment.hidden = true
            commentsButton.hidden = true
        case 1:
            secondComment.hidden = true
            commentsButton.hidden = true
            let firstCommentName = NSMutableAttributedString(string: "\(commentInfo[0]["from"]["username"].stringValue) ", attributes: boldAtr)
            let firstCommentBody  = NSMutableAttributedString(string: commentInfo[0]["text"].stringValue)
            firstCommentName.appendAttributedString(firstCommentBody)
            firstComment.attributedText = firstCommentName
        case 2:
            commentsButton.hidden = true
            let boldAtr = [NSFontAttributeName: UIFont.boldSystemFontOfSize(17)]
            let firstCommentName = NSMutableAttributedString(string: "\(commentInfo[0]["from"]["username"].stringValue) ", attributes: boldAtr)
            let firstCommentBody  = NSMutableAttributedString(string: commentInfo[0]["text"].stringValue)
            firstCommentName.appendAttributedString(firstCommentBody)
            firstComment.attributedText = firstCommentName
            let secondCommentName = NSMutableAttributedString(string: "\(commentInfo[1]["from"]["username"].stringValue) ", attributes: boldAtr)
            let secondCommentBody  = NSMutableAttributedString(string: commentInfo[1]["text"].stringValue)
            secondCommentName.appendAttributedString(secondCommentBody)
            secondComment.attributedText = secondCommentName
        default:
            let boldAtr = [NSFontAttributeName: UIFont.boldSystemFontOfSize(17)]
            let firstCommentName = NSMutableAttributedString(string: "\(commentInfo[commentInfo.count-2]["from"]["username"].stringValue) ", attributes: boldAtr)
            let firstCommentBody  = NSMutableAttributedString(string: commentInfo[commentInfo.count-2]["text"].stringValue)
            firstCommentName.appendAttributedString(firstCommentBody)
            firstComment.attributedText = firstCommentName
            let secondCommentName = NSMutableAttributedString(string: "\(commentInfo[commentInfo.count-1]["from"]["username"].stringValue) ", attributes: boldAtr)
            let secondCommentBody  = NSMutableAttributedString(string: commentInfo[commentInfo.count-1]["text"].stringValue)
            secondCommentName.appendAttributedString(secondCommentBody)
            secondComment.attributedText = secondCommentName
        }
        
    }
    func ResizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        let widthRatio  = targetSize.width  / image.size.width
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        newSize = CGSizeMake(targetSize.width, size.height * widthRatio)
         print("width: \(targetSize.width)")
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRectMake(0, 0, newSize.width, newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.drawInRect(rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
