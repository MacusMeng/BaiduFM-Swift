//
//  InterfaceController.swift
//  BaiduFM WatchKit Extension
//
//  Created by lumeng on 15/4/26.
//  Copyright (c) 2015年 lumeng. All rights reserved.
//

import WatchKit
import Foundation

class InterfaceController: WKInterfaceController {
    
    @IBOutlet weak var songImage: WKInterfaceImage!
    @IBOutlet weak var songNameLabel: WKInterfaceLabel!
    @IBOutlet weak var playButton: WKInterfaceButton!
    @IBOutlet weak var prevButton: WKInterfaceButton!
    @IBOutlet weak var nextButton: WKInterfaceButton!
    var curPlaySongId:String? = nil
    
    @IBOutlet weak var progressLabel: WKInterfaceLabel!
    @IBOutlet weak var songTimeLabel: WKInterfaceLabel!
    @IBOutlet weak var lrcLabel: WKInterfaceLabel!
    
    @IBOutlet weak var nextLrcLabel: WKInterfaceLabel!
    var timer:NSTimer? = nil
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        if let chid = NSUserDefaults.standardUserDefaults().stringForKey("LAST_PLAY_CHANNEL_ID"){
            DataManager.shareDataManager.chid = chid
        }
    
        if DataManager.shareDataManager.songInfoList.count == 0 {
            DataManager.getTop20SongInfoList({ () -> Void in
                if let song = DataManager.shareDataManager.curSongInfo{
                    self.playSong(song)
                }
            })
        }else{
            if let song = DataManager.shareDataManager.curSongInfo{
                self.playSong(song)
            }
        }
        
        self.timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("progresstimer:"), userInfo: nil, repeats: true)
        
        // Configure interface objects here.
    }
    
    func playSong(info:SongInfo){
        
        self.curPlaySongId = info.id
        
        //UI
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.progressLabel.setText("00:00")
            self.songTimeLabel.setText("00:00")
            self.lrcLabel.setText("")
            self.nextLrcLabel.setText("")
            
            self.songImage.setImageData(NSData(contentsOfURL: NSURL(string: info.songPicRadio)!)!)
            self.songNameLabel.setText(info.name + "-" + info.artistName)
            
            if DataManager.shareDataManager.curIndex == 0 {
                self.prevButton.setEnabled(false)
            }else{
                self.prevButton.setEnabled(true)
            }
            
            if DataManager.shareDataManager.curIndex >= DataManager.shareDataManager.songInfoList.count-1{
                self.nextButton.setEnabled(false)
            }else{
                self.nextButton.setEnabled(true)
            }
        }
        
        print("curIndex:\(DataManager.shareDataManager.curIndex),all:\(DataManager.shareDataManager.songInfoList.count)")
        print(Double(DataManager.shareDataManager.curIndex) / Double(DataManager.shareDataManager.songInfoList.count))
        if Double(DataManager.shareDataManager.curIndex) / Double(DataManager.shareDataManager.songInfoList.count) >= 0.75{
            self.loadMoreData()
        }
        
        //请求歌曲地址信息
        HttpRequest.getSongLink(info.id, callback: {(link:SongLink?) -> Void in
            if let songLink = link {
                DataManager.shareDataManager.curSongLink = songLink
                //播放歌曲
                DataManager.shareDataManager.mp.stop()
                let songUrl = Common.getCanPlaySongUrl(songLink.songLink)
                DataManager.shareDataManager.mp.contentURL = NSURL(string: songUrl)
                DataManager.shareDataManager.mp.prepareToPlay()
                DataManager.shareDataManager.mp.play()
                DataManager.shareDataManager.curPlayStatus = 1
                
                //显示歌曲时间
                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                    self.songTimeLabel.setText(Common.getMinuteDisplay(songLink.time))
                }
                
                HttpRequest.getLrc(songLink.lrcLink, callback: { lrc -> Void in
                    if let songLrc = lrc {
                        DataManager.shareDataManager.curLrcInfo = Common.praseSongLrc(songLrc)
                        //println(songLrc)
                    }
                })
            }
        })
    }
    
    @IBAction func playButtonAction() {
        
        if DataManager.shareDataManager.curPlayStatus == 1 {
            DataManager.shareDataManager.mp.pause()
            DataManager.shareDataManager.curPlayStatus = 2
            self.playButton.setBackgroundImage(UIImage(named: "btn_play"))
        }else{
            DataManager.shareDataManager.mp.play()
            DataManager.shareDataManager.curPlayStatus = 1
            self.playButton.setBackgroundImage(UIImage(named: "btn_pause"))
        }
    }
    
    @IBAction func prevButtonAction() {
        
        self.prev()
    }
    
    @IBAction func nextButtonAction() {
        
        self.next()
    }
    
    
    func prev(){
        
        DataManager.shareDataManager.curIndex--
        if let song = DataManager.shareDataManager.curSongInfo{
            self.playSong(song)
        }
    }
    
    func next(){
        
        DataManager.shareDataManager.curIndex++
        if let song = DataManager.shareDataManager.curSongInfo{
            self.playSong(song)
        }
    }
    
    @IBAction func songListAction() {
        
        self.pushControllerWithName("SongListInterfaceController", context: nil)
    }
    
    @IBAction func channelListAction() {
        self.pushControllerWithName("ChannelListInterfaceController", context: nil)
    }
    
    func loadMoreData(){
        
        if DataManager.shareDataManager.songInfoList.count >= DataManager.shareDataManager.allSongIdList.count{
            print("no more data:\(DataManager.shareDataManager.songInfoList.count),\(DataManager.shareDataManager.allSongIdList.count)")
            return
        }
        
        let curMaxCount = (Int(DataManager.shareDataManager.curIndex / 20) + 2) * 20
        print("curMaxCount:\(curMaxCount)")
        if DataManager.shareDataManager.songInfoList.count >= curMaxCount {
            return
        }
        
        let startIndex = DataManager.shareDataManager.songInfoList.count
        var endIndex = startIndex + 20
        
        if endIndex > DataManager.shareDataManager.allSongIdList.count-1 {
            endIndex = DataManager.shareDataManager.allSongIdList.count-1
        }
        
        let ids = [] + DataManager.shareDataManager.allSongIdList[startIndex..<endIndex]
        
        print("start load more data:\(startIndex),\(endIndex)")
        HttpRequest.getSongInfoList(ids, callback:{ (infolist:[SongInfo]?) -> Void in
            if let sInfoList = infolist {
                DataManager.shareDataManager.songInfoList += sInfoList
                print("load more data success,count=\(DataManager.shareDataManager.songInfoList.count)")
            }
        })

    }
    
    func progresstimer(time:NSTimer){
    
        if let link = DataManager.shareDataManager.curSongLink {
            let currentPlaybackTime = DataManager.shareDataManager.mp.currentPlaybackTime
            if currentPlaybackTime.isNaN {return}
            
            let curTime = Int(currentPlaybackTime)
            self.progressLabel.setText(Common.getMinuteDisplay(curTime))
            
            if link.time == curTime{
                self.next()
            }
            
            let (curLrc,nextLrc) = Common.currentLrcByTime(curTime, lrcArray: DataManager.shareDataManager.curLrcInfo)
            self.lrcLabel.setText(curLrc)
            self.nextLrcLabel.setText(nextLrc)
        }
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        if let cur = curPlaySongId {
            if let song = DataManager.shareDataManager.curSongInfo{
                if cur != song.id {
                    self.playSong(song)
                }
            }
        }
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
