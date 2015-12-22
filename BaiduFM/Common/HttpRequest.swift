//
//  HttpRequest.swift
//  BaiduFM
//
//  Created by lumeng on 15/4/12.
//  Copyright (c) 2015年 lumeng. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class HttpRequest {
    
    class func getChannelList(callback:[Channel]?->Void) -> Void{
        
        var channelList:[Channel]? = nil
        
        let url = NSURL(string: http_channel_list_url.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)
        Alamofire.request(.GET, url!).responseJSON{ response in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if let json = response.result.value {
                var data = JSON(json)
                let list = data["channel_list"]
                channelList = []
                for (_, subJson) in list {
                    
                    let id = subJson["channel_id"].stringValue
                    let name = subJson["channel_name"].stringValue
                    let order = subJson["channel_order"].int
                    let cate_id = subJson["cate_id"].stringValue
                    let cate = subJson["cate"].stringValue
                    let cate_order = subJson["cate_order"].int
                    let pv_order = subJson["pv_order"].int
                    
                    let channel = Channel(id: id, name: name, order: order!, cate_id: cate_id, cate: cate, cate_order: cate_order!, pv_order: pv_order!)
                    channelList?.append(channel)
                }
                callback(channelList)
            }else{
                callback(nil)
            }
            })
        }
    }
    
    class func getSongList(ch_name:String, callback:[String]?->Void)->Void{
        
        var songList:[String]? = nil
        let urlStr = http_song_list_url + ch_name
        let url = NSURL(string: urlStr.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)
        Alamofire.request(.GET, url!).responseJSON{ response in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if let json = response.result.value {
                //println(json)
                var data = JSON(json)
                let list = data["list"]
                songList = []
                for (_, subJson) in list {
                    let id = subJson["id"].stringValue
                    songList?.append(id)
                }
                callback(songList)
            }else{
                callback(nil)
            }
            })
        }
    }
    
    class func getSongInfoList(chidArray:[String], callback:[SongInfo]?->Void ){
        
        let chids = chidArray.joinWithSeparator(",")
        
        let params = ["songIds":chids]
        let url = NSURL(string: http_song_info.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)
        Alamofire.request(.POST, url!, parameters: params).responseJSON{ response in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if let json = response.result.value {
                var data = JSON(json)
                
                let lists = data["data"]["songList"]
                
                var ret:[SongInfo] = []
                
                for (_, list) in lists {
                    
                    let id = list["songId"].stringValue
                    let name = list["songName"].stringValue
                    let artistId = list["artistId"].stringValue
                    let artistName = list["artistName"].stringValue
                    let albumId = list["albumId"].int
                    let albumName = list["albumName"].stringValue
                    let songPicSmall = list["songPicSmall"].stringValue
                    let songPicBig = list["songPicBig"].stringValue
                    let songPicRadio = list["songPicRadio"].stringValue
                    let allRate = list["allRate"].stringValue
                    
                    let songInfo = SongInfo(id: id, name: name, artistId: artistId, artistName: artistName, albumId: albumId!, albumName: albumName, songPicSmall: songPicSmall, songPicBig: songPicBig, songPicRadio: songPicRadio, allRate: allRate)
                    ret.append(songInfo)
                }
                callback(ret)
            }else{
                callback(nil)
            }
            })
        }
    }
    
    class func getSongLinkList(chidArray:[String], callback:[SongLink]?->Void ) {
        let chids = chidArray.joinWithSeparator(",")
        let params = ["songIds":chids]
        let url = NSURL(string: http_song_link.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)
        Alamofire.request(.POST, url!, parameters: params).responseJSON{ response in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if let json = response.result.value {
                var data = JSON(json)
                let lists = data["data"]["songList"]
                
                var ret:[SongLink] = []
                
                for (_, list) in lists {
                    
                    let id = list["songId"].stringValue
                    let name = list["songName"].stringValue
                    let lrcLink = list["lrcLink"].stringValue
                    let linkCode = list["linkCode"].int
                    let link = list["songLink"].stringValue
                    let format = list["format"].stringValue
                    let time = list["time"].int
                    let size = list["size"].int
                    let rate = list["rate"].int
                    
                    var t = 0, s = 0, r = 0
                    if time != nil {
                        t = time!
                    }
                    
                    if size != nil {
                        s = size!
                    }
                    
                    if rate != nil {
                        r = rate!
                    }
                    
                    let songLink = SongLink(id: id, name: name, lrcLink: lrcLink, linkCode: linkCode!, songLink: link, format: format, time: t, size: s, rate: r)
                    ret.append(songLink)
                }
                callback(ret)
            }else{
                callback(nil)
            }
            })
        }
    }
    
    class func getSongLink(songid:String, callback:SongLink?->Void ) {
        let params = ["songIds":songid]
        let url = NSURL(string: http_song_link.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)
        Alamofire.request(.POST, url!, parameters: params).responseJSON{ response in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if let json = response.result.value {
                var data = JSON(json)
                let lists = data["data"]["songList"]
                
                var ret:[SongLink] = []
                
                for (_, list) in lists {
                    
                    let id = list["songId"].stringValue
                    let name = list["songName"].stringValue
                    let lrcLink = list["lrcLink"].stringValue
                    let linkCode = list["linkCode"].int
                    let link = list["songLink"].stringValue
                    let format = list["format"].stringValue
                    let time = list["time"].int
                    let size = list["size"].int
                    let rate = list["rate"].int
                    
                    var t = 0, s = 0, r = 0
                    if time != nil {
                        t = time!
                    }
                    
                    if size != nil {
                        s = size!
                    }
                    
                    if rate != nil {
                        r = rate!
                    }
                    
                    let songLink = SongLink(id: id, name: name, lrcLink: lrcLink, linkCode: linkCode!, songLink: link, format: format, time: t, size: s, rate: r)
                    ret.append(songLink)
                }
                if ret.count == 1 {
                    callback(ret[0])
                }else{
                    callback(nil)
                }
            }else{
                callback(nil)
            }
            })
        }
    }
    
    class func getLrc(lrcUrl:String, callback:String?->Void) ->Void{
        let urlStr = http_song_lrc + lrcUrl
        let url = NSURL(string: urlStr.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)
        Alamofire.request(.GET, url!).responseString(encoding: NSUTF8StringEncoding, completionHandler: { (response) -> Void in
            if response.result.error != nil{
                callback(response.result.error?.debugDescription)
            }else{
                callback(response.result.value)
            }
        })
    }
    
    class func downloadFile(songURL:String, musicPath:String, filePath:()->Void){
        let canPlaySongURL = Common.getCanPlaySongUrl(songURL)
        let url = NSURL(string: canPlaySongURL.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)
        Alamofire.download(Method.GET, url!, destination: { (temporaryURL, response) -> NSURL in
            let url = NSURL(fileURLWithPath: musicPath)
            return url
        }).response { (request, response, _, error) -> Void in
            filePath()
        }
    }
}