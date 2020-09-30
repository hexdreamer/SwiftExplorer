//
//  HXXMLParser.swift
//  SwiftExplorer
//
//  Created by Kenny Leung on 9/22/20.
//  Copyright © 2020 Kenny Leung. All rights reserved.
//

// TODO: Streaming data version from URL - use dispatchIO

import Foundation
import Dispatch

public protocol HXXMLParserDelegate:class {
    func parser(_ parser:HXXMLParser, didStartElement:String, attributes:[String:String])
    func parser(_ parser:HXXMLParser, foundCharacters:String)
    func parser(_ parser:HXXMLParser, foundCDATA:Data)
    func parser(_ parser:HXXMLParser, didEndElement:String)
    func parserDidEndDocument(_ parser:HXXMLParser)
    func parser(_ parser:HXXMLParser, error:Error)
}

open class HXXMLParser {
    public struct ParserError : Error {
        let message:String;
        init(_ message:String) {
            self.message = message
        }
    }
        
    public enum Mode {
        case XML, HTML
    }
    
    private let serialize = DispatchQueue(label:"HXXMLParser", qos:.background, attributes:[], autoreleaseFrequency:.workItem, target:nil)
    private var operationQueue:OperationQueue?
    private let mode:Mode
    private var fileURL:URL?
    private var netURL:URL?
    private var data:Data?
    private var urlSession:URLSession?
    public weak var delegate:HXXMLParserDelegate?
    private var fileIO:DispatchIO?
    private var xmlContext:xmlParserCtxtPtr?
    private var htmlContext:htmlParserCtxtPtr?
    private var xmlURLSessionDelegate:HXXMLParserURLSessionDelegate?
    private var htmlURLSessionDelegate:HXHTMLParserURLSessionDelegate?
           
    // MARK: Constructors/Destructors
    private init(mode:Mode) throws {
        self.mode = mode
    }
    
    public convenience init(mode:Mode, file:URL) throws {
        try self.init(mode:mode)
        self.fileURL = file
    }
    
    public convenience init(mode:Mode, network:URL) throws {
        try self.init(mode:mode)
        self.netURL = network
    }
    
    public convenience init(mode:Mode, data:Data) throws {
        try self.init(mode:mode)
        self.data = data
    }
    
    deinit {
        if let xmlContext = self.xmlContext {
            xmlFreeParserCtxt(xmlContext)
        }
        if let htmlContext = self.htmlContext {
            htmlFreeParserCtxt(htmlContext)
        }
    }

    // MARK: Parse Methods
    func parse() {
        self.serialize.hxAsync({
            try self._parse();
        }, hxCatch: { (error) in
            print("Unexpected error: \(error)")
        });
    }
    
    private func _parse() throws {
        switch self.mode {
            case .XML:
                if let fileURL = self.fileURL {
                    try self._parseXMLFrom(file:fileURL)
                } else if let netURL = self.netURL {
                    try self._parseXMLFrom(network:netURL)
                } else if let data = self.data {
                    try self._parseXMLFrom(data:data)
                }
            case .HTML:
                break
        }
    }
            
    private func _parseXMLFrom(file:URL) throws {
        self.xmlContext = try self._createXMLContext()
        
        let x:DispatchIO? = try file.withUnsafeFileSystemRepresentation {
            guard let filePath = $0 else {
                throw ParserError("Could not convert url to fileSystemRepresentation: \(file)")
            }
            return DispatchIO(type:.stream, path:filePath, oflag:O_RDONLY, mode:0, queue:self.serialize, cleanupHandler:{err in});
        }
        // Above expression too complex to include in an if-let
        guard let fileIO:DispatchIO = x else {
            throw ParserError("Could not create dispatchIO for file \(file)")
        }
        self.fileIO = fileIO
        
        fileIO.read(offset:0, length:4*1024, queue:self.serialize, ioHandler:self._fileIOCallback);
    }
    
    private func _fileIOCallback(done:Bool, data:DispatchData?, error:Int32) {
        if let data = data,
           data.count > 0 {
            let _ = data.withUnsafeBytes {
                xmlParseChunk(self.xmlContext, $0, Int32(data.count), 0)
            }
            self.fileIO?.read(offset:0, length:4*1024, queue:self.serialize, ioHandler:self._fileIOCallback);
        } else {
            xmlParseChunk(self.xmlContext, "", 0, 1)
        }
    }
    
    private func _parseXMLFrom(network url:URL) throws {
        let xmlContext = try self._createXMLContext()
        let urlSessionDelegate = HXXMLParserURLSessionDelegate(xmlContext:xmlContext)

        self.urlSession = URLSession.init(configuration:.default, delegate:urlSessionDelegate, delegateQueue:self.operationQueue)
        let _ = URLSession.shared.dataTask(with:url)
        
        self.xmlContext = try self._createXMLContext()
        self.xmlURLSessionDelegate = urlSessionDelegate
    }
    
    private func _parseXMLFrom(data:Data) throws {
        self.xmlContext = try self._createXMLContext()
        data.withUnsafeBytes { (ptr:UnsafeRawBufferPointer) in
            let unsafeBufferPointer:UnsafeBufferPointer<Int8> = ptr.bindMemory(to:Int8.self)
            let unsafePointer:UnsafePointer<Int8>? = unsafeBufferPointer.baseAddress
            xmlParseChunk(self.xmlContext, unsafePointer, Int32(data.count), 0)
        }
        xmlParseChunk(self.xmlContext, "", 0, 1)
    }
    
    private func _createXMLContext() throws -> xmlParserCtxtPtr {
        var sax = xmlSAXHandler()
        sax.initialized = XML_SAX2_MAGIC
        sax.startElement = { _me($0)?._startElement(name:$1, atts:$2)      }
        sax.characters   = { _me($0)?._characters  (ch:$1, len:$2)         }
        sax.cdataBlock   = { _me($0)?._cdataBlock  (pointer:$1, length:$2) }
        sax.endElement   = { _me($0)?._endElement  (name:$1)               }
        sax.endDocument  = { _me($0)?._endDocument ()                      }
        guard let xmlParserCtxt = xmlCreatePushParserCtxt(&sax, Unmanaged.passUnretained(self).toOpaque(), "", 0, "") else {
            throw ParserError("Could not create XML parser context")
        }
        return xmlParserCtxt
    }
    
    private func _createHTMLContext() throws -> htmlParserCtxtPtr {
        var sax = htmlSAXHandler()
        sax.initialized = XML_SAX2_MAGIC
        sax.startElement = { _me($0)?._startElement(name:$1, atts:$2)      }
        sax.characters   = { _me($0)?._characters  (ch:$1, len:$2)         }
        sax.cdataBlock   = { _me($0)?._cdataBlock  (pointer:$1, length:$2) }
        sax.endElement   = { _me($0)?._endElement  (name:$1)               }
        sax.endDocument  = { _me($0)?._endDocument ()                      }
        guard let htmlParserCtxt = xmlCreatePushParserCtxt(&sax, Unmanaged.passUnretained(self).toOpaque(), "", 0, "") else {
            throw ParserError("Could not create HTML parser context")
        }
        return htmlParserCtxt
    }
    
    // MARK: libxml2 parser callbacks
    
    private func _startElement(name:UnsafePointer<xmlChar>?, atts:UnsafePointer<UnsafePointer<xmlChar>?>?) {
        // https://github.com/MaddTheSane/chmox/blob/3263ddf09276f6a47961cc4b87762f58b88772d0/CHMTableOfContents.swift#L75
        guard let elementName = _decode(name) else {
            return
        }
        let attributeDict:[String:String]
        if let atts = atts {
            attributeDict = _atts2dict({ _decode(atts[$0]) })
        } else {
            attributeDict = [String:String]()
        }
        self.delegate?.parser(self, didStartElement:elementName, attributes:attributeDict)
    }
    
    private func _characters(ch: UnsafePointer<xmlChar>?, len:CInt) {
        if let ch = ch {
            let d = Data(bytes: ch, count:Int(len)) // clamp
            let s = String(data: d, encoding: .utf8) ?? "<utf8 decoding issue>"
            self.delegate?.parser(self, foundCharacters:s)
        }
    }
    
    private func _cdataBlock(pointer:UnsafePointer<xmlChar>?, length:Int32) {
        guard let pointer = pointer else {
            return
        }
        let data = Data(bytes:pointer, count:Int(length))
        self.delegate?.parser(self, foundCDATA:data)
    }
    
    private func _endElement(name:UnsafePointer<xmlChar>?) {
        // https://github.com/MaddTheSane/chmox/blob/3263ddf09276f6a47961cc4b87762f58b88772d0/CHMTableOfContents.swift#L75
        guard let elementName = _decode(name) else {
            return
        }
        self.delegate?.parser(self, didEndElement:elementName)
    }
    
    private func _endDocument() {
        self.delegate?.parserDidEndDocument(self)
    }
}

// MARK: These functions need to be free-floating because they get accessed from libxml2 C callbacks.

// turn a nil-terminated list of unwrapped name,value pairs into a dictionary.
// expand abbreviated (html5) attribute values.
private func _atts2dict(_ atts: (Int) -> String?) -> [String:String] {
    var ret = [String:String]()
    var idx = 0
    while let name = atts(idx) {
        ret[name] = atts(idx+1) ?? name
        idx += 2
    }
    return ret
}

// https://github.com/apple/swift-corelibs-foundation/blob/master/Foundation/XMLParser.swift#L33
private func _decode(_ bytes:UnsafePointer<xmlChar>?) -> String? {
    if let bytes = bytes {
        if let (str, _) = String.decodeCString(bytes, as:UTF8.self, repairingInvalidCodeUnits:false) {
            return str
        }
    }
    return nil
}

// Look into making this throw at some point
private func _me(_ ptr : UnsafeRawPointer?) -> HXXMLParser? {
    if let ptr = ptr {
        return Unmanaged<HXXMLParser>.fromOpaque(ptr).takeUnretainedValue()
    }
    print("ERROR: context pointer is nil")
    return nil;
}


private class HXXMLParserURLSessionDelegate : NSObject, URLSessionTaskDelegate, URLSessionDataDelegate {
    
    let xmlContext:xmlParserCtxtPtr
    
    init(xmlContext:xmlParserCtxtPtr) {
        self.xmlContext = xmlContext
        super.init()
    }
    
    // URLSessionDataDelegate
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        data.withUnsafeBytes { (ptr:UnsafeRawBufferPointer) in
            let unsafeBufferPointer:UnsafeBufferPointer<Int8> = ptr.bindMemory(to:Int8.self)
            let unsafePointer:UnsafePointer<Int8>? = unsafeBufferPointer.baseAddress
            xmlParseChunk(self.xmlContext, unsafePointer, Int32(data.count), 0)
        }
    }
    
    // URLSesssionTaskDelegate
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        xmlParseChunk(self.xmlContext, "", 0, 1)
    }
}

private class HXHTMLParserURLSessionDelegate : NSObject, URLSessionTaskDelegate, URLSessionDataDelegate {
    
    let htmlContext:htmlParserCtxtPtr
    
    init(htmlContext:htmlParserCtxtPtr) {
        self.htmlContext = htmlContext
        super.init()
    }
    
    // URLSessionDataDelegate
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        data.withUnsafeBytes { (ptr:UnsafeRawBufferPointer) in
            let unsafeBufferPointer:UnsafeBufferPointer<Int8> = ptr.bindMemory(to:Int8.self)
            let unsafePointer:UnsafePointer<Int8>? = unsafeBufferPointer.baseAddress
            htmlParseChunk(self.htmlContext, unsafePointer, Int32(data.count), 0)
        }
    }
    
    // URLSesssionTaskDelegate
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        htmlParseChunk(self.htmlContext, "", 0, 1)
    }
}
