//
//  Feeds.swift
//  DailyRadio
//
//  Created by Kenny Leung on 9/13/20.
//

import SwiftUI

public struct Feeds: View {
    static var DATE_FORMATTER:DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, dd MMM yyy HH:mm:ss Z"
        return formatter;
    }
    
    let channels:[DRChannel]
    
    init() {
        Self.fetchFeeds()
        self.channels = Self.readChannels()
    }
    
    public var body: some View {
        List(self.channels, id:\DRChannel.link) { channel in
            NavigationLink(
                destination:Episodes(channel:channel)
                    .navigationBarTitle(channel.title ?? "NO FEED NAME")
            ) {
                HStack {
                    DRAsyncImage(url:channel.itunesImage) {
                        Image("ChannelImageDefault")
                            .resizable()
                    }.frame(width:50, height:50, alignment:.leading)
                    
                    VStack(alignment:.leading, spacing:3.0) {
                        Text(channel.title ?? "NO FEED NAME")
                        Text(channel.latestItem?.pubDate.map{Self.DATE_FORMATTER.string(from:$0)} ?? "No items")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
    }
    
    // MARK: Temporary Data
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
    
    static private func readChannels() -> [DRChannel] {
        var results = [DRChannel]()
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
                let data = try Data(contentsOf:cachedFeed)
                let parser = DRXMLDecoder(data:data, root:DRChannel())
                parser.run()
                if let channel = parser.channel {
                    results.append(channel)
                } else {
                    print("Could not load \(cachedFeed)")
                }
            }
        } catch ( let e ) {
            fatalError("Could not load podcast feeds: \(e)")
        }
        return results
    }

}
