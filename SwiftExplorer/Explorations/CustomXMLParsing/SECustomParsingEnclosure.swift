//
//  DREnclosure.swift
//  DailyRadio
//
//  Created by Kenny Leung on 9/13/20.
//

import Foundation

struct SECustomParsingEnclosure : SECustomParserModel {
    
    var length:Int32?
    var type:String?
    var url:URL?
    
    public let tag = "enclosure";
    
    public mutating func setValue(_ value:String, forTag tag:String) {
        switch tag {
            case "length":
                self.length = self.coerceInt32(value)
            case "type":
                self.type = value
            case "url":
                self.url = self.coerceURL(value)
            default:
                print("Enclosure: Unsupported tag: \(tag)")
        }
    }
    
    public mutating func setValue(_ value:String, forTag tag:String?, attribute:String) {
        switch (tag,attribute) {
            case (nil,"length"):
                self.length = self.coerceInt32(value)
            case (nil,"type"):
                self.type = value
            case (nil,"url"):
                self.url = self.coerceURL(value)
            default:
                print("Enclosure: Unsupported case: \(tag ?? "")@\(attribute)")
        }
    }
    
    public func setData(_ data:Data, forTag tag:String) {
        switch tag {
            default:
                print("Enclosure: Unsupported tag: \(tag)")
        }
    }

    public func makeChildEntity(forTag tag:String) -> SECustomParserModel? {
        return nil
    }
    
    mutating func setChildEntity(_ value:SECustomParserModel, forTag tag:String) {
        print("Enclosure: Unsupported tag: \(tag)")
    }

}
