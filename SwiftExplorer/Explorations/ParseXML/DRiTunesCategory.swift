//
//  DRiTunesCategory.swift
//  DailyRadio
//
//  Created by Kenny Leung on 9/13/20.
//

import Foundation

class DRiTunesCategory : DRXMLDecoderModel {
    
    var text:String?
    var itunesCategory:DRiTunesCategory?
    
    public var tag:String {
        return "itunes:category"
    }
    
    public func setValue(_ value:String, forTag tag:String) {
        switch tag {
            case "text":
                self.text = value
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
            case (nil,"text"):
                self.text = value
            default:
                print("Unsupported case: \(tag ?? "")@\(attribute)")
        }
    }
    
    public func makeChildEntity(forTag tag:String) -> DRXMLDecoderModel? {
        switch tag {
            case "itunes:category":
                return DRiTunesCategory()
            default:
                return nil
        }
    }

    public func setChildEntity(_ value:DRXMLDecoderModel, forTag tag:String) {
        switch tag {
            case "itunes:category":
                if let x = value as? DRiTunesCategory {
                    self.itunesCategory = x
                }
            default:
                print("Unsupported tag: \(tag)")
        }
    }

}
