//
//  DRitem.swift
//  DailyRadio
//
//  Created by Kenny Leung on 8/23/20.
//

import Foundation

struct SECustomParsingItem : SECustomParserModel {
    
    var contentEncoded:String?
    var description:Data?
    var enclosure:SECustomParsingEnclosure?
    var guid:String?
    var guidIsPermalink:Bool?
    var link:URL?
    var postID:String?
    var pubDate:Date?
    var title:String?
    var itunesAuthor:String?
    var itunesDuration:String?
    var itunesEpisode:String?
    var itunesEpisodeType:String?
    var itunesExplicit:Bool?
    var itunesImage:URL?
    var itunesKeywords:String?
    var itunesSubtitle:String?
    var itunesSummary:Data?
    var itunesTitle:String?
        
    // MARK: DRXMLDecoderModel
    public let tag = "item"
            
    public mutating func setValue(_ value:String, forTag tag:String) {
        switch tag {
            case "content:encoded":
                self.contentEncoded = value
            case "guid":
                self.guid = value
            case "itunes:author":
                self.itunesAuthor = value
            case "itunes:duration":
                self.itunesDuration = value
            case "itunes:episode":
                self.itunesEpisode = value
            case "itunes:episodeType":
                self.itunesEpisodeType = value
            case "itunes:explicit":
                self.itunesExplicit = self.coerceBool(value)
            case "itunes:image":
                break
            case "itunes:keywords":
                self.itunesKeywords = value
            case "itunes:subtitle":
                self.itunesSubtitle = value
            case "itunes:title":
                self.itunesTitle = value
            case "link":
                self.link = self.coerceURL(value)
            case "post-id":
                self.postID = value
            case "pubDate":
                self.pubDate = self.coerceDate(value)
            case "title":
                self.title = value
            case "category",
                 "comments",
                 "media:title",
                 "media:description",
                 "media:keywords",
                 "media:rating",
                 "media:category",
                 "media:credit"
            :
                break;
            default:
                print("Item: Unsupported tag: \(tag)")
        }
    }
    
    public mutating func setData(_ data:Data, forTag tag:String) {
        switch tag {
            case "description":
                self.description = data
            case "itunes:summary":
                self.itunesSummary = data
            case "content:encoded":  // in TWIT feed
                break
            default:
                print("Item: Unsupported tag: \(tag)")
        }
    }
        
    public mutating func setValue(_ value:String, forTag tag:String?, attribute:String) {
        switch (tag,attribute) {
            case ("itunes:image","href"):
                self.itunesImage = self.coerceURL(value)
            case ("guid","isPermaLink"):
                self.guidIsPermalink = self.coerceBool(value)
            case("post-id","xmlns"):
                break
            case
                ("media:content", "fileSize"),
                ("media:content", "medium"),
                ("media:content", "type"),
                ("media:content", "url"),
                ("media:credit", "role"),
                ("media:category", "label"),
                ("media:category", "scheme"),
                ("media:description", "type"),
                ("media:rating", "scheme"),
                ("media:thumbnail", "height"),
                ("media:thumbnail", "url"),
                ("media:thumbnail", "width"),
                ("media:title", "type")
            :
                break
            default:
                print("Item: Unsupported case: \(tag ?? "")@\(attribute)")
        }
    }
    
    public func makeChildEntity(forTag tag:String) -> SECustomParserModel? {
        switch tag {
            case "enclosure":
                return SECustomParsingEnclosure()
            default:
                return nil
        }
    }
        
    mutating func setChildEntity(_ value:SECustomParserModel, forTag tag:String) {
        switch tag {
            case "enclosure":
                if let x = value as? SECustomParsingEnclosure {
                    self.enclosure = x
                }
            default:
                print("Unsupported tag: \(tag)")
        }
    }
    
}

