//
//  DRImage.swift
//  DailyRadio
//
//  Created by Kenny Leung on 8/23/20.
//

import Foundation

struct SECustomParsingImage : SECustomParserModel {
    
    var link:URL?
    var title:String?
    var url:URL?
    var width:UInt16?;
    var height:UInt16?;
    
    // MARK: DRXMLDecoderModel
    public let tag = "image"
    
    public mutating func setValue(_ value:String, forTag tag:String) {
        switch tag {
            case "link":
                self.link = self.coerceURL(value)
            case "title":
                self.title = value
            case "url":
                self.url = self.coerceURL(value)
            case "width":
                self.width = UInt16(value)
            case "height":
                self.height = UInt16(value)
            default:
                print("Image: Unsupported tag: \(tag)")
        }
    }
    
    public func setData(_ data:Data, forTag tag:String) {
        switch tag {
            default:
                print("Image: Unsupported tag: \(tag)")
        }
    }

    public func setValue(_ value:String, forTag tag:String?, attribute:String) {
        switch (tag,attribute) {
            default:
                print("Image: Unsupported case: \(tag ?? "")@\(attribute)")
        }
    }

    public func makeChildEntity(forTag tag:String) -> SECustomParserModel? {
        return nil
    }

    mutating func setChildEntity(_ value:SECustomParserModel, forTag tag:String) {
        print("Image: Unsupported tag: \(tag)")
    }
    
}
