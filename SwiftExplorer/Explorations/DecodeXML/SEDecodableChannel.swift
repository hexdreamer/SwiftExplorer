
import Foundation
import UIKit

public struct SEDecodableChannel : Decodable {

    let atomLink:URL?
    let copyright:String
    let description:String
    let docs:String?
    let generator:String?
    let language:String
    let lastBuildDate:Date?
    let link:URL
    let managingEditor:String?
    let pubDate:Date?
    let title:String
    let itunesAuthor:String
    let itunesCategory:[SEDecodableCategory]
    let itunesExplicit:Bool
    let itunesImage:URL
    let itunesNewFeedURL:URL?
    let itunesOwner:SEDecodableOwner
    let itunesSubtitle:String?
    let itunesSummary:String?
    let itunesType:String?
    let items:[SEDecodableItem]
        
    var latestItem:SEDecodableItem? {
        if self.items.count == 0 {
            return nil
        }
        var latest = self.items[0]
        for item in self.items {
            if item.pubDate > latest.pubDate {
                latest = item
            }
        }
        return latest
    }
    
    enum CodingKeys: String, CodingKey {
        case atomLink         = "atom:link"
        case copyright
        case description
        case docs
        case generator
        case language
        case lastBuildDate
        case link
        case managingEditor
        case pubDate
        case title
        case itunesAuthor     = "itunes:author"
        case itunesCategory   = "itunes:category"
        case itunesExplicit   = "itunes:explicit"
        case itunesImage      = "itunes:image@href"
        case itunesNewFeedURL = "itunes:new-feed-url"
        case itunesOwner      = "itunes:owner"
        case itunesSubtitle   = "itunes:subtitle"
        case itunesSummary    = "itunes:summary"
        case itunesType       = "itunes:type"
        case items            = "item"
    }
    
}
