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
    private let mode:Mode
    public weak var delegate:HXXMLParserDelegate?
    private var xmlContext:xmlParserCtxtPtr?
    private var htmlContext:htmlParserCtxtPtr?
           
    // MARK: Constructors/Destructors
    public init(mode:Mode) throws {
        self.mode = mode
        switch self.mode {
            case .XML:
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
                self.xmlContext = xmlParserCtxt
            case .HTML:
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
                self.htmlContext = htmlParserCtxt
        }
    }
        
    public convenience init(mode:Mode, delegate:HXXMLParserDelegate) throws {
        try self.init(mode:mode)
        self.delegate = delegate
    }
    
    deinit {
        if let xmlContext = self.xmlContext {
            xmlFreeParserCtxt(xmlContext)
        }
        if let htmlContext = self.htmlContext {
            htmlFreeParserCtxt(htmlContext)
        }
    }
                            
    public func parseChunk(data:Data) throws {
        data.withUnsafeBytes { (ptr:UnsafeRawBufferPointer) in
            let unsafeBufferPointer:UnsafeBufferPointer<Int8> = ptr.bindMemory(to:Int8.self)
            let unsafePointer:UnsafePointer<Int8>? = unsafeBufferPointer.baseAddress
            switch self.mode {
                case .XML:
                    xmlParseChunk(self.xmlContext, unsafePointer, Int32(data.count), 0)
                case .HTML:
                    htmlParseChunk(self.htmlContext, unsafePointer, Int32(data.count), 0)

            }
        }
    }
    
    public func finishParsing() {
        switch self.mode {
            case .XML:
                xmlParseChunk(self.xmlContext, "", 0, 1)
            case .HTML:
                htmlParseChunk(self.htmlContext, "", 0, 1)
        }
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
