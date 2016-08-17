//
//  ProfileView.swift
//  insta
//
//  Created by Marco on 8/5/16.
//  Copyright © 2016 Marco. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
class ProfileView: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    var refreshControl = UIRefreshControl()
    var entries: [JSON]!
    var name: String!
    var id: Int!
    var photos: [JSON]!
    var userData: JSON!
    var pagination: String!
    var footer: UICollectionReusableView!
    let accessToken = "1125868065.e029fea.4a885fa430d6422098bee4975f0fdc24"
    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.refreshControl.addTarget(self, action: #selector(ProfileView.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        self.collectionView.addSubview(self.refreshControl)
        self.navigationController!.navigationBar.topItem!.title = "Back"
        // set flow stuff in viewdidload, easier
        let width = UIScreen.mainScreen().bounds.size.width
        let fulllength = CGFloat(ceil(Double(entries.count/3)) * Double((width/3 + 3)))
        let frame = collectionView.frame
        collectionView.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, fulllength)
        let flow = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        flow.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)
        flow.itemSize = CGSizeMake(width/3, width/3)
        flow.minimumInteritemSpacing = 0
        flow.minimumLineSpacing = 0
    }
    // collectionview funcs
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let scrollViewHeight = scrollView.frame.size.height
        let scrollContentSizeHeight = scrollView.contentSize.height
        let scrollOffset = scrollView.contentOffset.y
            if (scrollOffset + scrollViewHeight == scrollContentSizeHeight) {
                Alamofire.request(.GET, self.pagination)
                    .validate()
                    .responseJSON {
                        response in
                        if response.result.value != nil {
                            let rawUserData = JSON(response.result.value!)["data"].arrayValue
                            self.entries.appendContentsOf(rawUserData)
                            self.collectionView.reloadData()
                            self.pagination = JSON(response.result.value!)["pagination"]["next_url"].stringValue
                            if self.pagination == "" {
                                self.footer.hidden = true
                                
                            }
                        }
                }
            
        }
    }
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        // set header stuff
        print("\(userData["profile_picture"].stringValue)")
        if kind == "UICollectionElementKindSectionHeader" {
            let view = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "header", forIndexPath: indexPath) as! ProfileInfo
            view.backgroundColor = UIColor.whiteColor()
            name = userData["username"].stringValue
            self.title = "\(name!)'s profile"
            view.postsCountField.text = "\(userData["counts"]["media"].intValue)"
            view.followersCountField.text = "\(userData["counts"]["followed_by"].intValue)"
            view.followingCountField.text = "\(userData["counts"]["follows"].intValue)"
            // bold the name
            let boldAtr = [NSFontAttributeName : UIFont.boldSystemFontOfSize(15)]
            let fulltext = NSMutableAttributedString(string: userData["full_name"].stringValue, attributes: boldAtr)
            let bioText  = NSMutableAttributedString(string:" \(userData["bio"].stringValue)")
            fulltext.appendAttributedString(bioText)
            view.bioField.attributedText = fulltext
            let profUrl = NSURL(string: userData["profile_picture"].stringValue)
            let data = NSData(contentsOfURL: profUrl!)
            view.profileImage.image = UIImage(data: data!)
            view.profileImage.layer.borderWidth = 1
            view.profileImage.layer.masksToBounds = false
            view.profileImage.layer.borderColor = UIColor.clearColor().CGColor
            view.profileImage.layer.cornerRadius = view.profileImage.frame.height/2
            view.profileImage.clipsToBounds = true
            return view
        } else {
            footer = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionFooter, withReuseIdentifier: "footer", forIndexPath: indexPath)
            return footer
        }
    }
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.pagination == "" ? entries.count : entries.count - (entries.count % 3)
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCell", forIndexPath: indexPath) as! PhotoCell
        cell.backgroundColor = UIColor.blackColor()
        // Configure the cell
        let profUrl = NSURL(string: entries[indexPath.row]["images"]["low_resolution"]["url"].stringValue)
        let data = NSData(contentsOfURL: profUrl!)
        // bold the name
        if data == nil {
            
        }
        let rawImage: UIImage! = UIImage(data: data!)
        if rawImage.size.height == rawImage.size.width {
            cell.image.image = rawImage
        } else {
            cell.image.image = formatImage(rawImage)
        }
        cell.image.image = UIImage(data: data!)
        cell.postInfo = entries[indexPath.row]
        return cell
    }
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! PhotoCell
        Alamofire.request(.GET, "https://api.instagram.com/v1/media/\(cell.postInfo["id"].stringValue)/comments", parameters: ["access_token": accessToken])
            .validate()
            .responseJSON {
                response in
                let viewcont = self.storyboard?.instantiateViewControllerWithIdentifier("PhotoView") as? PhotoView
                viewcont!.mediaInfo = cell.postInfo
                viewcont!.commentInfo = JSON(response.result.value!)["data"].arrayValue
                self.navigationController?.pushViewController(viewcont!, animated: true)
                
        }
        print(indexPath.row)
    }
    // other funcs
    // formats to square
    func formatImage(image: UIImage!) -> UIImage {
        let xorigin = image.size.width/2 - image.size.height/2
        let squaredimension = image.size.height
        let yorigin = CGFloat(0)
        let cropSquare = CGRectMake(xorigin, yorigin, squaredimension, squaredimension)
        return UIImage(CGImage: CGImageCreateWithImageInRect(image.CGImage, cropSquare)!)
    }
    func refresh(sender: AnyObject) {
        print("water")
        self.refreshControl.endRefreshing()
    }
}

