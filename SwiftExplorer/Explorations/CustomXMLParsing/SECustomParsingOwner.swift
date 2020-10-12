//
//  DRiTunesOwner.swift
//  DailyRadio
//
//  Created by Kenny Leung on 8/23/20.
//

import Foundation

struct SECustomParsingOwner : SECustomParserModel {
    
    var itunesEmail:String?
    var itunesName:String?
    
    public var tag:String {
        return "itunes:owner"
    }
    
    public mutating func setValue(_ value:String, forTag tag:String) {
        switch tag {
            case "itunes:email":
                self.itunesEmail = value
            case "itunes:name":
                self.itunesName = value
            default:
                print("Unsupported tag: \(tag)")
        }
    }
    
    public func setData(_ data:Data, forTag tag:String) {
        switch tag {
            default:
                print("Unsupported tag: \(tag)")
        }
    }

    public func setValue(_ value:String, forTag tag:String?, attribute:String) {
        switch (tag,attribute) {
            default:
                print("Unsupported case: \(tag ?? "")@\(attribute)")
        }
    }
    
    public func makeChildEntity(forTag tag:String) -> SECustomParserModel? {
        return nil
    }
    
    mutating func setChildEntity(_ value:SECustomParserModel, forTag tag:String) {
        print("Unsupported tag: \(tag)")
    }

}
