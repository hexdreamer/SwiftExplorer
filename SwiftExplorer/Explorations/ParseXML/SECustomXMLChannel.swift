//
//  DRChannel.swift
//  DailyRadio
//
//  Created by Kenny Leung on 8/22/20.
//

import Foundation
import CoreData
import hexdreamsCocoa

struct SECustomXMLChannel : SECustomXMLDecoderModel {
    
    var atomLink:URL?
    var copyright:String?
    var description:String?
    var docs:String?
    var generator:String?
    var image:SECustomXMLImage?
    var language:String?
    var lastBuildDate:Date?
    var link:URL?
    var managingEditor:String?
    var pubDate:Date?
    var site:String?
    var title:String?
    var itunesAuthor:String?
    var itunesCategory:SECustomXMLiTunesCategory?
    var itunesCopyright:String?
    var itunesExplicit:Bool?
    var itunesImage:URL?
    var itunesNewFeedURL:URL?
    var itunesOwner:SECustomXMLiTunesOwner?
    var itunesSubtitle:String?
    var itunesSummary:String?
    var itunesType:String?
    var items = [SECustomXMLItem]()
    
    public let tag = "channel"
        
    public var orderedItems:[SECustomXMLItem] {
        var sortable = self.items
        sortable.sort(by: { a,b in
            if let aDate = a.pubDate,
               let bDate = b.pubDate
            {
                return aDate < bDate
            }
            return false
        })
        return sortable
    }
    
    var latestItem:SECustomXMLItem? {
        guard var latest:SECustomXMLItem = self.items.first(where:{$0.pubDate != nil}),
              var latestDate:Date = latest.pubDate
        else {
            return nil
        }
                    
        for item in items {
            guard let itemDate = item.pubDate else {
                HXWarn("Item does not have a pubDate")
                continue
            }
            if itemDate > latestDate {
                latest = item
                latestDate = itemDate
            }
        }
        return latest;
    }
    
    mutating func setValue(_ value:String, forTag tag:String) {
        switch tag {
            case "atom:link":
                self.atomLink = self.coerceURL(value)
            case "copyright":
                self.copyright = value
            case "description":
                self.description = value
            case "docs":
                self.docs = value
            case "generator":
                self.generator = value
            case "language":
                self.language = value
            case "lastBuildDate":
                self.lastBuildDate = self.coerceDate(value)
            case "link":
                self.link = self.coerceURL(value)
            case "managingeditor":
                self.managingEditor = value
            case "pubdate":
                self.pubDate = self.coerceDate(value)
            case "title":
                self.title = value
            case "itunes:author":
                self.itunesAuthor = value
            case "itunes:copyright":
                self.itunesCopyright = value
            case "itunes:explicit":
                self.itunesExplicit = self.coerceBool(value)
            case "itunes:image":
                break
            case "itunes:new-feed-url":
                self.itunesNewFeedURL = self.coerceURL(value)
            case "itunes:subtitle":
                self.itunesSubtitle = value
            case "itunes:summary":
                self.itunesSummary = value
            case "itunes:type":
                self.itunesType = value
            case "site":
                self.site = value
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

    
    public mutating func setValue(_ value:String, forTag tag:String?, attribute:String) {
        switch (tag,attribute) {
            case ("itunes:image","href"):
                self.itunesImage = self.coerceURL(value)
            default:
                print("Unsupported case: \(tag ?? "")@\(attribute)")
        }
    }
        
    public func makeChildEntity(forTag tag:String) -> SECustomXMLDecoderModel? {
        switch tag {
            case "itunes:category":
                return SECustomXMLiTunesCategory()
            case "image":
                return SECustomXMLImage()
            case "itunes:owner":
                return SECustomXMLiTunesOwner()
            case "item":
                return SECustomXMLItem()
            default:
                return nil
        }
    }
    
    mutating func setChildEntity(_ value:SECustomXMLDecoderModel, forTag tag:String) {
        switch tag {
            case "itunes:category":
                if let x = value as? SECustomXMLiTunesCategory {
                    self.itunesCategory = x
                }
            case "image":
                if let x = value as? SECustomXMLImage {
                    self.image = x
                }
            case "itunes:owner":
                if let x = value as? SECustomXMLiTunesOwner {
                    self.itunesOwner = x
                }
            case "item":
                if let x = value as? SECustomXMLItem {
                    self.items.append(x)
                }
            default:
                print("Unsupported tag: \(tag)")
        }
    }

}
