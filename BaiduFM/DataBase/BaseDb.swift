//
//  BaseDb.swift
//  BaiduFM
//
//  Created by lumeng on 15/4/18.
//  Copyright (c) 2015年 lumeng. All rights reserved.
//

import Foundation

class BaseDb {
    
    var dbPath: String
    var db:FMDatabase
    
    init(){
        
        print("basedb init")
        let dbDirectory = Utils.documentPath().stringByAppendingString("database")
        
        if !NSFileManager.defaultManager().fileExistsAtPath(dbDirectory){
               try! NSFileManager.defaultManager().createDirectoryAtPath(dbDirectory, withIntermediateDirectories: false, attributes: nil)
        }
        
        self.dbPath = dbDirectory.stringByAppendingString("baidufm.sqlite")
        
        self.db = FMDatabase(path: self.dbPath)
        //println(dbPath)
        
        //db文件不存在则创建
        if !NSFileManager.defaultManager().fileExistsAtPath(self.dbPath){
            if self.open() {
                let sql = "CREATE TABLE tbl_song_list (id INTEGER PRIMARY KEY AUTOINCREMENT,sid TEXT UNIQUE,name TEXT,artist TEXT,album TEXT,song_url  TEXT,pic_url   TEXT,lrc_url TEXT,time INTEGER,is_dl INTEGER DEFAULT 0,dl_file TEXT,is_like INTEGER DEFAULT 0,is_recent INTEGER DEFAULT 1,format TEXT)"
                if !self.db.executeUpdate(sql, withArgumentsInArray: nil){
                    print("db创建失败")
                }else{
                    print("db创建成功")
                }
            }else{
                print("open error")
            }
        }
    }
    
    deinit{
        self.close()
    }
    
    func open()->Bool{
        return self.db.open()
    }
    
    func close()->Bool{
        return self.db.close()
    }
}