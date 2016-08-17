//
//  ViewController.swift
//  insta
//
//  Created by Marco on 8/5/16.
//  Copyright © 2016 Marco. All rights reserved.
//
/*
SEARCH USER: https://api.instagram.com/v1/users/search?q=[USERNAME]&access_token=1125868065.e029fea.4a885fa430d6422098bee4975f0fdc24
GET PROFILE MEDIA (LAST 20, USE PAGINATION NEXT TO FIND NEXT INFO): https://api.instagram.com/v1/users/[USER_ID]/media/recent/?access_token=1125868065.e029fea.4a885fa430d6422098bee4975f0fdc24
GET PROFILE ID: https://api.instagram.com/v1/users/search?q=[USERNAME]&access_token=1125868065.e029fea.4a885fa430d6422098bee4975f0fdc24
 */



import UIKit
import Alamofire
import SwiftyJSON
class ViewController: UIViewController {
    let accessT = "1125868065.e029fea.4a885fa430d6422098bee4975f0fdc24"
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.s
    }
    
    @IBOutlet weak var nameField: UITextField!
    @IBAction func changeViews(sender: AnyObject) {
        getID(nameField.text, accessToken: self.accessT)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func getID(name: String!, accessToken: String!){
        if name.rangeOfString(" ") != nil {
            let alert = UIAlertController(title: "Alert", message: "You can't have spaces in your search query!", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        var id: Int?
        if (name == "") {
            let alert = UIAlertController(title: "Alert", message: "You can't search for nothing!", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            Alamofire.request(.GET, "https://api.instagram.com/v1/users/search?q=\(name)", parameters: ["access_token": accessToken])
                .validate()
                .responseJSON { response in
                    if (response.result.value == nil || JSON(response.result.value!)["data"].arrayValue.count == 0) {
                        let alert = UIAlertController(title: "Alert", message: "Couldn't find user.", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                    } else {
                        let json = JSON(response.result.value!)
                        print("data: \(json["data"].arrayValue[0]["id"].stringValue)")
                        id = Int(json["data"].arrayValue[0]["id"].stringValue)
                        print("\(id)")
                        self.getUserInfo(id!, accessToken: accessToken)
                    }
            }
        }
    }
    func getUserInfo(id: Int, accessToken: String) {
        Alamofire.request(.GET, "https://api.instagram.com/v1/users/\(id)", parameters: ["access_token": accessToken])
            .responseJSON { response in
                let rawUserData = JSON(response.result.value!)["data"]
                self.getMediaByID(id, accessToken: accessToken, userData: rawUserData)
        }
        
    }
    func getMediaByID(id: Int, accessToken: String, userData: JSON) {
        Alamofire.request(.GET, "https://api.instagram.com/v1/users/\(id)/media/recent/", parameters: ["access_token": accessToken])
            .validate()
            .responseJSON { response in
                if response.result.value != nil {
                    self.gotoProfile(id, media: JSON(response.result.value!)["data"].arrayValue, userData: userData, pagination: JSON(response.result.value!)["pagination"]["next_url"].stringValue)
                } else {
                    let alert = UIAlertController(title: "Alert", message: "User is private or has no posts.", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
    }
    func gotoProfile(id: Int, media: [JSON], userData: JSON, pagination: String!) {
        let viewcont = self.storyboard?.instantiateViewControllerWithIdentifier("ProfileView") as? ProfileView
        viewcont!.entries = media
        viewcont!.name = nameField.text
        viewcont!.id = id
        viewcont!.userData = userData
        viewcont!.pagination = pagination
        self.navigationController?.pushViewController(viewcont!, animated: true)
    }
}

