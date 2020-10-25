//
//  SEXMLDecoderFeed.swift
//  SwiftExplorer
//
//  Created by Kenny Leung on 10/11/20.
//  Copyright © 2020 Kenny Leung. All rights reserved.
//

import Foundation
import Combine
import hexdreamsCocoa

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
    var fileReader:HXDispatchIOFileReader?
    var urlSessionReader:HXURLSessionReader?
    
    init(feed:SEXMLDecoderFeed) {
        self.feed = feed
        self.loadFromCache()
    }
    
    func loadFromCache() {
        DispatchQueue.global().hxAsync( {
            try self._loadFromCache()
        }, hxCatch: {
            print("Unexpected error loading from cache: \($0)")
        })
    }
    
    private func _loadFromCache() throws {
        let cachedir = try FileManager.default.url(for:FileManager.SearchPathDirectory.cachesDirectory, in:FileManager.SearchPathDomainMask.userDomainMask, appropriateFor:nil, create:true)
        let cachedFeed = cachedir.appendingPathComponent(self.feed.name).appendingPathExtension("xml");
        
        if ( !FileManager.default.fileExists(atPath:cachedFeed.path) ) {
            self.loadFromNetwork(saveTo:cachedFeed)
            return
        }
        
        print("Loading cached feed: \(cachedFeed)")
        let parser = HXDOMParser(mode:.XML)
        self.fileReader = HXDispatchIOFileReader(
            file:cachedFeed,
            dataAvailable: {
                do {
                    try parser.parseChunk(data:$0)
                } catch let e {
                    print(e)
                }
            },
            completion: {
                do {
                    try parser.finishParsing()
                    let decoder = try SEXMLDecoder(elements:[parser.element])
                    let rss = try SEDecodableRSS(from:decoder)
                    DispatchQueue.main.async { [weak self] in
                        self?.channel = rss.channel
                        self?.fileReader = nil;
                        self?.loadFromNetwork(saveTo:cachedFeed)
                    }
                } catch let e {
                    print(e)
                }
            }
        )
    }
    
    func loadFromNetwork(saveTo:URL) {
        DispatchQueue.global().hxAsync( {
            //try self._loadFromNetwork(saveTo:saveTo)
        }, hxCatch: {
            print("Unexpected error loading from network: \($0)")
        })
    }
    
    private func _loadFromNetwork(saveTo:URL) throws {
        print("Loading feed from network: \(self.feed.urlString)")
        guard let url = URL(string:self.feed.urlString) else {
            print("Could not create url from \(self.feed.urlString)")
            return;
        }
        
        let tempFile = saveTo.appendingPathExtension("temp")
        let dispatchIO = try self._openTempFile(tempFile)
        let parser = HXDOMParser(mode:.XML)
        
        self.urlSessionReader = HXURLSessionReader(
            url:url,
            dataAvailable: { [weak self] (data) in
                do {
                    try parser.parseChunk(data:data)
                    self?._writeToTempFile(dispatchIO, data:data)
                } catch let e {
                    print(e)
                }
            },
            completion: { [weak self] () in
                do {
                    try parser.finishParsing()
                    let decoder = try SEXMLDecoder(elements:[parser.element])
                    let rss = try SEDecodableRSS(from:decoder)
                    DispatchQueue.main.async { [weak self] in
                        self?.channel = rss.channel
                        self?.urlSessionReader = nil;
                    }
                    self?._closeTempFile(dispatchIO, tempFile:tempFile, saveTo:saveTo)
                } catch let e {
                    print("Error finishing parsing: \(e)");
                }
            }
        )
    }
    
    private func _openTempFile(_ tempFile:URL) throws -> DispatchIO {
        let dispatchIO:DispatchIO? = try tempFile.withUnsafeFileSystemRepresentation {
            guard let filePath = $0 else {
                throw HXErrors.general("Could not convert file to fileSystemRepresentation")
            }
            return DispatchIO(type:.stream, path:filePath, oflag:O_WRONLY|O_CREAT, mode:S_IRUSR|S_IWUSR, queue:DispatchQueue.global(qos:.background),
                              cleanupHandler:{ error in
                                if ( error != 0 ) {
                                    print("Error opening cache file \(tempFile) for writing: \(error)")
                                }
                              });
        }
        
        if let x = dispatchIO {
            return x;
        } else {
            throw HXErrors.general("Could not create dispatchIO")
        }
    }
    
    private func _writeToTempFile(_ dispatchIO:DispatchIO, data:Data) {
        data.withUnsafeBytes {
            dispatchIO.write(
                offset:0,
                data:DispatchData(bytes:$0),
                queue:DispatchQueue.global(qos:.background),
                ioHandler:{ (done,data,error) in
                    if ( error != 0 ) {
                        print("Error writing to cache temp file: \(error)")
                    }
                }
            )
        }
    }
    
    private func _closeTempFile(_ dispatchIO:DispatchIO, tempFile:URL, saveTo:URL) {
        dispatchIO.barrier {
            dispatchIO.close(flags:DispatchIO.CloseFlags(rawValue: 0))
            do {
                if ( FileManager.default.fileExists(atPath:saveTo.path) ) {
                    try FileManager.default.removeItem(at:saveTo)
                }
                try FileManager.default.moveItem(at:tempFile, to:saveTo)
                print("Committed cache file")
            } catch let e {
                print("Error commiting file \(saveTo): \(e)");
            }
        }
    }
}
