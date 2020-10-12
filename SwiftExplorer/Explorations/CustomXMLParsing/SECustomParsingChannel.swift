//
//  DRChannel.swift
//  DailyRadio
//
//  Created by Kenny Leung on 8/22/20.
//

import Foundation
import CoreData
import hexdreamsCocoa

struct SECustomParsingChannel : SECustomParserModel {
    
    var atomLink:URL?
    var copyright:String?
    var description:String?
    var docs:String?
    var generator:String?
    var image:SECustomParsingImage?
    var language:String?
    var lastBuildDate:Date?
    var link:URL?
    var managingEditor:String?
    var pubDate:Date?
    var site:String?
    var title:String?
    var itunesAuthor:String?
    var itunesCategory:SECustomParsingCategory?
    var itunesCopyright:String?
    var itunesExplicit:Bool?
    var itunesImage:URL?
    var itunesNewFeedURL:URL?
    var itunesOwner:SECustomParsingOwner?
    var itunesSubtitle:String?
    var itunesSummary:String?
    var itunesType:String?
    var items = [SECustomParsingItem]()
    
    public let tag = "channel"
        
    public var orderedItems:[SECustomParsingItem] {
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
    
    var latestItem:SECustomParsingItem? {
        guard var latest:SECustomParsingItem = self.items.first(where:{$0.pubDate != nil}),
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
            case "pubDate":
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
        
    public func makeChildEntity(forTag tag:String) -> SECustomParserModel? {
        switch tag {
            case "itunes:category":
                return SECustomParsingCategory()
            case "image":
                return SECustomParsingImage()
            case "itunes:owner":
                return SECustomParsingOwner()
            case "item":
                return SECustomParsingItem()
            default:
                return nil
        }
    }
    
    mutating func setChildEntity(_ value:SECustomParserModel, forTag tag:String) {
        switch tag {
            case "itunes:category":
                if let x = value as? SECustomParsingCategory {
                    self.itunesCategory = x
                }
            case "image":
                if let x = value as? SECustomParsingImage {
                    self.image = x
                }
            case "itunes:owner":
                if let x = value as? SECustomParsingOwner {
                    self.itunesOwner = x
                }
            case "item":
                if let x = value as? SECustomParsingItem {
                    self.items.append(x)
                }
            default:
                print("Unsupported tag: \(tag)")
        }
    }

}
