//
//  SEXMLDecoderFeed.swift
//  SwiftExplorer
//
//  Created by Kenny Leung on 10/11/20.
//  Copyright © 2020 Kenny Leung. All rights reserved.
//

import Foundation
import Combine

public struct SEXMLDecoderFeed {
    static public let examples:[SEXMLDecoderFeed] = [
        SEXMLDecoderFeed(name:"ThisWeekInTech"             ,title:"This Week In Tech"                ,urlString:"https://feeds.twit.tv/twit.xml"),
        SEXMLDecoderFeed(name:"AccidentalTechPodcast"      ,title:"Accidental Tech Podcast"          ,urlString:"https://atp.fm/rss"),
        SEXMLDecoderFeed(name:"Marketplace"                ,title:"Marketplace"                      ,urlString:"https://marketplace.org/feed/podcast/marketplace"),
        SEXMLDecoderFeed(name:"MakeMeSmartWithKaiAndMolly" ,title:"Make Me Smart With Kai and Molly" ,urlString:"https://marketplace.org/feed/podcast/make-me-smart-with-kai-and-molly"),
      //SEXMLDecoderFeed(name:"BlackOnTheAir"              ,title:"Black on the Air"                 ,urlString:"https://www.theringer.com/rss/larry-wilmore-black-on-air/index.xml"),  - not RSS format
      //SEXMLDecoderFeed(name:"RealTimeWithBillMaher"      ,title"Real Time with Bill Maher"         ,urlString:"http://billmaher.hbo.libsynpro.com/rss"), - not https - won't load
    ]

    let name:String
    let title:String
    let urlString:String
}

class SEXMLDecoderFeedLoader : ObservableObject {
    let feed:SEXMLDecoderFeed
    @Published var channel:SEDecodableChannel?
    var parser:SEXMLParser?
    
    init(feed:SEXMLDecoderFeed) {
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
                    let parser = SEXMLParser()
                    try parser.parse(file:cachedFeed, completion:{ [weak self] in
                        do {
                            guard let _ = self else {
                                return
                            }
                            let decoder = try SEXMLDecoder(elements:[$0.element])
                            let rss = try SEDecodableRSS(from:decoder)
                            DispatchQueue.main.async { [weak self] in
                                self?.channel = rss.channel
                                self?.parser = nil
                                self?.loadFromNetwork(saveTo:cachedFeed)
                            }
                        } catch let e {
                            print(e)
                        }
                    })
                    self.parser = parser
                } else {
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
                let parser = SEXMLParser()
                try parser.parse(network:url, saveTo:saveTo, completion:{ [weak self] in
                    do {
                        guard let _ = self else {
                            return
                        }
                        let decoder = try SEXMLDecoder(elements:[$0.element])
                        let rss = try SEDecodableRSS(from:decoder)
                        DispatchQueue.main.async { [weak self] in
                            self?.channel = rss.channel
                            self?.parser = nil
                        }
                    } catch let e {
                        print(e)
                    }
                })
                self.parser = parser
            } catch ( let e ) {
                print("Unexpected error loading from network: \(e)")
            }
        }
    }

}
