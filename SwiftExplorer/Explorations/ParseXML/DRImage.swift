//
//  DRImage.swift
//  DailyRadio
//
//  Created by Kenny Leung on 8/23/20.
//

import Foundation

struct DRImage : DRXMLDecoderModel {
    
    var link:URL?
    var title:String?
    var url:URL?
    
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

    public func makeChildEntity(forTag tag:String) -> DRXMLDecoderModel? {
        return nil
    }

    mutating func setChildEntity(_ value:DRXMLDecoderModel, forTag tag:String) {
        print("Unsupported tag: \(tag)")
    }
    
}
