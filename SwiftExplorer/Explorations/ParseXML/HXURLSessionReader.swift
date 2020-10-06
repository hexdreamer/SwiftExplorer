//
//  HXURLSessionReader.swift
//  SwiftExplorer
//
//  Created by Kenny Leung on 10/1/20.
//  Copyright © 2020 Kenny Leung. All rights reserved.
//

import Foundation

public class HXURLSessionReader : NSObject, URLSessionTaskDelegate, URLSessionDataDelegate {
    private let dataAvailable:(Data)->Void
    private let completion:()->Void
    private let queue:OperationQueue
    private var urlSession:URLSession?
    private var dataTask:URLSessionDataTask?
    
    init(url:URL,
          dataAvailable:@escaping (Data)->Void,
          completion:@escaping ()->Void
    ) {
        self.dataAvailable = dataAvailable
        self.completion = completion
        
        let queue = OperationQueue()
        queue.underlyingQueue = DispatchQueue.global(qos:.background)
        self.queue = queue
        self.urlSession = nil
        self.dataTask = nil
        super.init()

        let urlSession = URLSession.init(configuration:.default, delegate:self, delegateQueue:queue)
        let dataTask = urlSession.dataTask(with:url)

        self.urlSession = urlSession
        self.dataTask = dataTask
        dataTask.resume()
    }
    
    deinit {
        print("HXURLSessionReader.deinit()")
    }
        
    // URLSessionDataDelegate
    @objc
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data:Data) {
        self.dataAvailable(data)
    }
    
    // URLSesssionTaskDelegate
    @objc
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        self.completion()
        self.urlSession?.invalidateAndCancel() // Must do this because urlSession has a strong reference to self
    }

}
