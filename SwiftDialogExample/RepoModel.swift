//
//  RepoModel.swift
//  SwiftDialog
//
//  Created by apsp on 15/7/5.
//  Copyright (c) 2015年 Shoal Software LLC. All rights reserved.
//

import Foundation
import JSONJoy
struct Owner : JSONJoy {
    var login:String?
    var id: Int?
    var avatar_url: String?
    var gravatar_id: String?
    var url: String?
    var html_url: String?
    var followers_url: String?
    var following_url: String?
    var gists_url: String?
    var starred_url: String?
    var subscriptions_url: String?
    var organizations_url: String?
    var repos_url: String?
    var events_url: String?
    var received_events_url: String?
    var type: String?
    init() {
        
    }
    init(_ decoder: JSONDecoder) {
        id = decoder["id"].integer
        login = decoder["login"].string
        avatar_url = decoder["avatar_url"].string
        gravatar_id = decoder["gravatar_id"].string
        url = decoder["url"].string
        html_url = decoder["html_url"].string
        followers_url = decoder["followers_url"].string
        gists_url = decoder["gists_url"].string
        starred_url = decoder["starred_url"].string
        subscriptions_url = decoder["subscriptions_url"].string
        organizations_url = decoder["organizations_url"].string
        repos_url = decoder["repos_url"].string
        events_url = decoder["events_url"].string
        received_events_url = decoder["received_events_url"].string
        type = decoder["type"].string
     }
}

struct Repo : JSONJoy {
    var id: Int?
    var name: String?
    var full_name: String?
    var owner: Owner?
    var url:String?
    init() {
    }
    init(_ decoder: JSONDecoder) {
        id = decoder["id"].integer
        name = decoder["name"].string
        full_name = decoder["full_name"].string
        url = decoder["url"].string
        owner = Owner(decoder["owner"])
    }
}
struct RepoList : JSONJoy {
    var addresses: Array<Repo>?
    init() {
    }
    init(_ decoder: JSONDecoder) {
        //we check if the array is valid then alloc our array and loop through it, creating the new address objects.
        addresses = Array<Repo>()
        if let addrs = decoder.array {
            for addrDecoder in addrs {
                addresses?.append(Repo(addrDecoder))
                 //addrDecoder.print()
            }
        }
        
    }
}