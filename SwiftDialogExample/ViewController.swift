//
//  ViewController.swift
//  OAuthSwift
//
//  Created by Dongri Jin on 6/21/14.
//  Copyright (c) 2014 Dongri Jin. All rights reserved.
//

import UIKit
import OAuthSwift
import SwiftHTTP
import SwiftDialog
import JSONJoy
class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var services = ["Github"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "OAuth"
        let tableView: UITableView = UITableView(frame: self.view.bounds, style: .Plain)
        tableView.delegate = self
        tableView.dataSource = self
        self.view.addSubview(tableView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func doOAuthTwitter(){
        let oauthswift = OAuth1Swift(
            consumerKey:    Twitter["consumerKey"]!,
            consumerSecret: Twitter["consumerSecret"]!,
            requestTokenUrl: "https://api.twitter.com/oauth/request_token",
            authorizeUrl:    "https://api.twitter.com/oauth/authorize",
            accessTokenUrl:  "https://api.twitter.com/oauth/access_token"
        )
        
        //oauthswift.authorize_url_handler = WebViewController()
        oauthswift.authorizeWithCallbackURL( NSURL(string: "oauth-swift://oauth-callback/twitter")!, success: {
            credential, response in
            self.showAlertView("Twitter", message: "auth_token:\(credential.oauth_token)\n\noauth_toke_secret:\(credential.oauth_token_secret)")
            var parameters =  Dictionary<String, AnyObject>()
            oauthswift.client.get("https://api.twitter.com/1.1/statuses/mentions_timeline.json", parameters: parameters,
                success: {
                    data, response in
                    let jsonDict: AnyObject! = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil)
                    println(jsonDict)
                }, failure: {(error:NSError!) -> Void in
                    println(error)
                })
            
            }, failure: {(error:NSError!) -> Void in
                println(error.localizedDescription)
            }
        )
    }

    func doOAuthFlickr(){
        let oauthswift = OAuth1Swift(
            consumerKey:    Flickr["consumerKey"]!,
            consumerSecret: Flickr["consumerSecret"]!,
            requestTokenUrl: "https://www.flickr.com/services/oauth/request_token",
            authorizeUrl:    "https://www.flickr.com/services/oauth/authorize",
            accessTokenUrl:  "https://www.flickr.com/services/oauth/access_token"
        )
        oauthswift.authorizeWithCallbackURL( NSURL(string: "oauth-swift://oauth-callback/flickr")!, success: {
            credential, response in
            self.showAlertView("Flickr", message: "oauth_token:\(credential.oauth_token)\n\noauth_toke_secret:\(credential.oauth_token_secret)")
            let url :String = "https://api.flickr.com/services/rest/"
            let parameters :Dictionary = [
                "method"         : "flickr.photos.search",
                "api_key"        : Flickr["consumerKey"]!,
                "user_id"        : "128483205@N08",
                "format"         : "json",
                "nojsoncallback" : "1",
                "extras"         : "url_q,url_z"
            ]
            oauthswift.client.get(url, parameters: parameters,
                success: {
                    data, response in
                    let jsonDict: AnyObject! = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil)
                    println(jsonDict)
                }, failure: {(error:NSError!) -> Void in
                    println(error)
            })


        }, failure: {(error:NSError!) -> Void in
            println(error.localizedDescription)
        })
        
    }

    func doOAuthGithub(){
        let oauthswift = OAuth2Swift(
            consumerKey:    Github["consumerKey"]!,
            consumerSecret: Github["consumerSecret"]!,
            authorizeUrl:   "https://github.com/login/oauth/authorize",
            accessTokenUrl: "https://github.com/login/oauth/access_token",
            responseType:   "code"
        )
        let state: String = generateStateWithLength(20) as String
        oauthswift.authorizeWithCallbackURL( NSURL(string: "oauth-swift://oauth-callback/github")!, scope: "user,repo", state: state, success: {
            credential, response, parameters in
            //self.showAlertView("Github", message: "oauth_token:\(credential.oauth_token)")
            self.popgitrepo(credential.oauth_token)
            }, failure: {(error:NSError!) -> Void in
                println(error.localizedDescription)
            })
        
    }

    func snapshot() -> NSData {
        UIGraphicsBeginImageContext(self.view.frame.size)
        self.view.layer.renderInContext(UIGraphicsGetCurrentContext())
        let fullScreenshot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        UIImageWriteToSavedPhotosAlbum(fullScreenshot, nil, nil, nil)
        return  UIImageJPEGRepresentation(fullScreenshot, 0.5)
    }

    func popgitrepo(token:String){
        var request = HTTPTask()
        request.requestSerializer = HTTPRequestSerializer()
        request.requestSerializer.headers["Authorization"] = "token "+token
        request.GET("https://api.github.com/user/repos", parameters: nil, completionHandler: {(response: HTTPResponse) in
            if let err = response.error {
                println("error: \(err.localizedDescription)")
                return //also notify app of failure as needed
            }
            if let data = response.responseObject as? NSData {
                //let str = NSString(data: data, encoding: NSUTF8StringEncoding)
                var repolist = RepoList(JSONDecoder(data))
                
                 let dv = DialogViewController(root: self.getRootElement(repolist))
                
                self.navigationController?.presentViewController(dv, animated: true, completion: nil)

            }
            
        })
    }
    func getRootElement(repolist: RepoList) -> RootElement {
        let customHeaderLabel = UILabel(frame: CGRect.zeroRect)
        customHeaderLabel.autoresizingMask = .FlexibleWidth
        customHeaderLabel.text = "Root Elements (+ custom header)"
        customHeaderLabel.font = UIFont(name: "AmericanTypewriter-Bold", size: UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline).pointSize)
        customHeaderLabel.sizeToFit()
        customHeaderLabel.textAlignment = .Center
        
        let root = RootElement(
            title: "SwiftDialog",
            sections: [
                SectionElement(header: "列表")
            ],
            groups: [
                "apts": 0
            ]
        )
        for item in repolist.addresses! {
            let se = StringElement(item.name!, onSelect: { element in self.clickMeTapped(item.url!) })
            root.sections[0].elements.append(se)
        }
        return root
    }
    func clickMeTapped(url:String) {
        UIApplication.sharedApplication().openURL(NSURL(string: url)!)

    } 
    func showAlertView(title: String, message: String) {
        var alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int  {
        return services.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath:NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "Cell")
        cell.textLabel?.text = services[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath:NSIndexPath) {
        var service: String = services[indexPath.row]
        switch service {
            case "Twitter":
                doOAuthTwitter()
            case "Flickr":
                doOAuthFlickr()
            case "Github":
                doOAuthGithub()
            default:
                println("default (check ViewController tableView)")
        }
        tableView.deselectRowAtIndexPath(indexPath, animated:true)
    }
    
    
}

