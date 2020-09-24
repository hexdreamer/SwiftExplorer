
import Foundation
import SwiftUI

struct SEDecodeXML : View {
    static var DATE_FORMATTER:DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, dd MMM yyy HH:mm:ss Z"
        return formatter;
    }
            
    private let channels:[SEDecodableChannel]

    init() {
        Self.fetchFeeds()
        self.channels = Self.readChannels()
    }
            
    var body: some View {
        List(self.channels, id:\SEDecodableChannel.link) { channel in
            NavigationLink(
                destination:SEPodcastEpisodes(channel:channel)
                    .navigationBarTitle(channel.title)
            ){
                HStack {
                    SEAsyncImage(url:channel.itunesImage) {
                        Image("ChannelImageDefault")
                            .resizable()
                    }.frame(width:50, height:50, alignment:.center)
                    
                    VStack(alignment:.leading, spacing:3.0) {
                        Text(channel.title)
                        Text(self.dateToString(channel.latestItem?.pubDate) ?? "No items")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
    }
    
    static private let feeds :[(String,String)] = [
        ("AccidentalTechPodcast"      , "https://atp.fm/rss"),
        ("Marketplace"                , "https://marketplace.org/feed/podcast/marketplace"),
        ("MakeMeSmartWithKaiAndMolly" , "https://marketplace.org/feed/podcast/make-me-smart-with-kai-and-molly")
        //("BlackOnTheAir"          , "https://www.theringer.com/rss/larry-wilmore-black-on-air/index.xml") - not RSS format
        //("RealTimeWithBillMaher" , "http://billmaher.hbo.libsynpro.com/rss") - not https - won't load
    ]

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
                let decoder = try SEXMLDecoder(url:cachedFeed)
                let rss = try SEDecodableRSS(from:decoder)
                results.append(rss.channel)
            }
        } catch ( let e ) {
            fatalError("Could not load podcast feeds: \(e)")
        }
        return results
    }
    
    // MARK: Utility Methods
    private func dateToString(_ date:Date?) -> String? {
        guard let date = date else {
            return nil
        }
        return Self.DATE_FORMATTER.string(from:date)
    }
    
}
