//
//  SEFeed.swift
//  SwiftExplorer
//
//  Created by Kenny Leung on 9/28/20.
//  Copyright © 2020 Kenny Leung. All rights reserved.
//

import Foundation
import Combine

struct SECustomParsingFeed {
    static public let examples:[SECustomParsingFeed] = [
//        SECustomParsingFeed(name:"ThisWeekInTech"             ,title:"This Week In Tech"                ,urlString:"https://feeds.twit.tv/twit.xml"),
        SECustomParsingFeed(name:"MakeMeSmartWithKaiAndMolly" ,title:"Make Me Smart With Kai and Molly" ,urlString:"https://marketplace.org/feed/podcast/make-me-smart-with-kai-and-molly"),
//        SECustomParsingFeed(name:"AccidentalTechPodcast"      ,title:"Accidental Tech Podcast"          ,urlString:"https://atp.fm/rss"),
//        SECustomParsingFeed(name:"Marketplace"                ,title:"Marketplace"                      ,urlString:"https://marketplace.org/feed/podcast/marketplace"),
      //SEFeed(name:"BlackOnTheAir"              ,title:"Black on the Air"                 ,urlString:"https://www.theringer.com/rss/larry-wilmore-black-on-air/index.xml"),  - not RSS format
      //SEFeed(name:"RealTimeWithBillMaher"      ,title"Real Time with Bill Maher"         ,urlString:"http://billmaher.hbo.libsynpro.com/rss"), - not https - won't load
    ]

    let name:String
    let title:String
    let urlString:String
}

class SEFeedLoader : ObservableObject {
    let feed:SECustomParsingFeed
    @Published var channel:SECustomParsingChannel?
    var parser:SECustomParser?
    
    init(feed:SECustomParsingFeed) {
        self.feed = feed
        self.loadFromCache()
    }
    
    func loadFromCache() {
        DispatchQueue.global().async {
            do {
                let cachedir = try FileManager.default.url(for:FileManager.SearchPathDirectory.cachesDirectory, in:FileManager.SearchPathDomainMask.userDomainMask, appropriateFor:nil, create:true)
                let cachedFeed = cachedir.appendingPathComponent(self.feed.name).appendingPathExtension("xml");
                if ( FileManager.default.fileExists(atPath:cachedFeed.path) ) {
                    print("Loading cached feed: \(cachedFeed)")
                    let parser = SECustomParser(root:SECustomParsingChannel())
                    try parser.parse(file:cachedFeed, completion:{ [weak self] in
                        guard let _ = self else {
                            return
                        }
                        let channel = $0.channel
                        DispatchQueue.main.async { [weak self] in
                            self?.channel = channel
                            self?.parser = nil
                            self?.loadFromNetwork(saveTo:cachedFeed)
                        }
                    })
                    self.parser = parser
                } else {
                    print("No cached feed: \(cachedFeed)")
                    self.loadFromNetwork(saveTo:cachedFeed)
                }
            } catch ( let e ) {
                print("Unexpected error loading from cache: \(e)")
            }
        }
    }
    
    func loadFromNetwork(saveTo:URL) {
        DispatchQueue.global().async {
            do {
                print("Loading feed from network: \(self.feed.urlString)")
                guard let url = URL(string:self.feed.urlString) else {
                    print("Could not create url from \(self.feed.urlString)")
                    return;
                }
                let parser = SECustomParser(root:SECustomParsingChannel())
                try parser.parse(network:url, saveTo:saveTo, completion:{ [weak self] in
                    guard let _ = self else {
                        return
                    }
                    let channel = $0.channel
                    DispatchQueue.main.async { [weak self] in
                        self?.channel = channel
                        self?.parser = nil
                    }
                })
                self.parser = parser
            } catch ( let e ) {
                print("Unexpected error loading from network: \(e)")
            }
        }
    }
    
}
