
import Foundation
import SwiftUI

struct SEDecodeXML : View {
    
    static private let feeds :[(String,String)] = [
        ("AccidentalTechPodcast"             , "https://atp.fm/rss"),
        ("Marketplace"                       , "https://marketplace.org/feed/podcast/marketplace"),
        ("Make Me Smart sith Kain and Molly" , "https://marketplace.org/feed/podcast/make-me-smart-with-kai-and-molly")
        //("BlackOnTheAir"          , "https://www.theringer.com/rss/larry-wilmore-black-on-air/index.xml") - not RSS format
        //("RealTimeWithBillMaher" , "http://billmaher.hbo.libsynpro.com/rss") - not https - won't load
    ]
        
    private let channels:[SEDecodableChannel]

    init() {
        Self.fetchFeeds()
        self.channels = Self.readChannels()
    }
            
    var body: some View {
        List(self.channels, id:\SEDecodableChannel.link) { item in
            Text(item.title)
        }
    }
    
    static private func fetchFeeds() {
        do {
            let cachedir = try FileManager.default.url(for:FileManager.SearchPathDirectory.cachesDirectory,
                                                       in:FileManager.SearchPathDomainMask.userDomainMask,
                                                       appropriateFor:nil,
                                                       create:true)
            for (name,feed) in self.feeds {
                let cachedFeed = cachedir.appendingPathComponent(name).appendingPathExtension("xml");
                if ( !FileManager.default.fileExists(atPath:cachedFeed.path) ) {
                    print("Cache does not exist: \(cachedFeed)")
                    if let feedURL = URL(string:feed) {
                        let data = try Data(contentsOf:feedURL)
                        try data.write(to:cachedFeed)
                    }
                }
            }
        } catch ( let e ) {
            fatalError("Could not download podcast feeds: \(e)")
        }
    }
    
    static private func readChannels() -> [SEDecodableChannel] {
        var results = [SEDecodableChannel]()
        do {
            let cachedir = try FileManager.default.url(for:FileManager.SearchPathDirectory.cachesDirectory,
                                                       in:FileManager.SearchPathDomainMask.userDomainMask,
                                                       appropriateFor:nil,
                                                       create:true)
            for (name,_) in self.feeds {
                let cachedFeed = cachedir.appendingPathComponent(name).appendingPathExtension("xml");
                if ( !FileManager.default.fileExists(atPath:cachedFeed.path) ) {
                    print("Cache does not exist: \(cachedFeed)")
                    continue;
                }
                print("Loading cached feed: \(cachedFeed)")
                let decoder = SEXMLDecoder(url:cachedFeed)
                let rss = try SEDecodableRSS(from:decoder)
                results.append(rss.channel)
            }
        } catch ( let e ) {
            fatalError("Could not load podcast feeds: \(e)")
        }
        return results
    }
    
}
