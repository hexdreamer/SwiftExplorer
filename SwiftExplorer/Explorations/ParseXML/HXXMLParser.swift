//
//  HXXMLParser.swift
//  SwiftExplorer
//
//  Created by Kenny Leung on 9/22/20.
//  Copyright © 2020 Kenny Leung. All rights reserved.
//

// TODO: Streaming data version from URL - use dispatchIO

import Foundation

public protocol HXXMLParserDelegate:class {
    func parser(_ parser:HXXMLParser, didStartElement:String, attributes:[String:String])
    func parser(_ parser:HXXMLParser, foundCharacters:String)
    func parser(_ parser:HXXMLParser, foundCDATA:Data)
    func parser(_ parser:HXXMLParser, didEndElement:String)
}

open class HXXMLParser {
        
    public enum Mode {
        case XML, HTML
    }
    
    private let mode:Mode
    public weak var delegate:HXXMLParserDelegate?
    
    init(mode:Mode) {
        self.mode = mode
    }

    func parse(_ data:Data) {
        if self.delegate == nil {
            print("ERROR! No delegate")
            return
        }
        
        var sax = htmlSAXHandler()
        sax.initialized = XML_SAX2_MAGIC
        sax.startElement = { me($0).startElement(name:$1, atts:$2)      }
        sax.characters   = { me($0).characters  (ch:$1, len:$2)         }
        sax.cdataBlock   = { me($0).cdataBlock  (pointer:$1, length:$2) }
        sax.endElement   = { me($0).endElement  (name:$1)               }

        // https://curl.haxx.se/libcurl/c/htmltitle.html
        // http://xmlsoft.org/html/libxml-HTMLparser.html#htmlParseChunk
        // https://stackoverflow.com/questions/41140050/parsing-large-xml-from-server-while-downloading-with-libxml2-in-swift-3
        // https://github.com/apple/swift-corelibs-foundation/blob/master/Foundation/XMLParser.swift#L524
        // http://redqueencoder.com/wrapping-libxml2-for-swift/ bzw. https://github.com/SonoPlot/Swift-libxml

        switch ( self.mode ) {
            case .XML:
                //public func xmlCreatePushParserCtxt(_ sax: xmlSAXHandlerPtr!, _ user_data: UnsafeMutableRawPointer!, _ chunk: UnsafePointer<Int8>!, _ size: Int32, _ filename: UnsafePointer<Int8>!) -> xmlParserCtxtPtr!
                let ctxt = xmlCreatePushParserCtxt(&sax, Unmanaged.passUnretained(self).toOpaque(), "", 0, "")
                defer { xmlFreeParserCtxt(ctxt) }
                let _ = data.withUnsafeBytes { (ptr:UnsafeRawBufferPointer) in
                    let unsafeBufferPointer:UnsafeBufferPointer<Int8> = ptr.bindMemory(to:Int8.self)
                    let unsafePointer:UnsafePointer<Int8>? = unsafeBufferPointer.baseAddress
                    xmlParseChunk(ctxt, unsafePointer, Int32(data.count), 0)
                }
                xmlParseChunk(ctxt, "", 0, 1)
            case .HTML:
                let ctxt = htmlCreatePushParserCtxt(&sax, Unmanaged.passUnretained(self).toOpaque(), "", 0, "", XML_CHAR_ENCODING_UTF8)
                defer { htmlFreeParserCtxt(ctxt) }
                let _ = data.withUnsafeBytes { (ptr:UnsafeRawBufferPointer) in
                    let unsafeBufferPointer:UnsafeBufferPointer<Int8> = ptr.bindMemory(to:Int8.self)
                    let unsafePointer:UnsafePointer<Int8>? = unsafeBufferPointer.baseAddress
                    htmlParseChunk(ctxt, unsafePointer, Int32(data.count), 0)
                }
                htmlParseChunk(ctxt, "", 0, 1)
        }
    }

    private func startElement(name:UnsafePointer<xmlChar>?, atts:UnsafePointer<UnsafePointer<xmlChar>?>?) {
        // https://github.com/MaddTheSane/chmox/blob/3263ddf09276f6a47961cc4b87762f58b88772d0/CHMTableOfContents.swift#L75
        guard let elementName = decode(name) else {
            return
        }
        let attributeDict:[String:String]
        if let atts = atts {
            attributeDict = atts2dict({ decode(atts[$0]) })
        } else {
            attributeDict = [String:String]()
        }
        self.delegate?.parser(self, didStartElement:elementName, attributes:attributeDict)
    }
    
    private func characters(ch: UnsafePointer<xmlChar>?, len:CInt) {
        let d = Data(bytes: ch!, count:Int(len)) // clamp
        let s = String(data: d, encoding: .utf8) ?? "<utf8 decoding issue>"
        self.delegate?.parser(self, foundCharacters:s)
    }
    
    private func cdataBlock(pointer:UnsafePointer<xmlChar>?, length:Int32) {
        guard let pointer = pointer else {
            return
        }
        let data = Data(bytes:pointer, count:Int(length))
        self.delegate?.parser(self, foundCDATA:data)
    }
    
    private func endElement(name:UnsafePointer<xmlChar>?) {
        // https://github.com/MaddTheSane/chmox/blob/3263ddf09276f6a47961cc4b87762f58b88772d0/CHMTableOfContents.swift#L75
        guard let elementName = decode(name) else {
            return
        }
        self.delegate?.parser(self, didEndElement:elementName)
    }
}

// turn a nil-terminated list of unwrapped name,value pairs into a dictionary.
// expand abbreviated (html5) attribute values.
private func atts2dict(_ atts: (Int) -> String?) -> [String:String] {
    var ret = [String:String]()
    var idx = 0
    while let name = atts(idx) {
        ret[name] = atts(idx+1) ?? name
        idx += 2
    }
    return ret
}

// https://github.com/apple/swift-corelibs-foundation/blob/master/Foundation/XMLParser.swift#L33
private func decode(_ bytes:UnsafePointer<xmlChar>?) -> String? {
    guard let bytes = bytes else { return nil }
    guard let (str, _) = String.decodeCString(bytes, as:UTF8.self, repairingInvalidCodeUnits:false) else { return nil }
    return str
}

private func me(_ ptr : UnsafeRawPointer?) -> HXXMLParser {
    if let ptr = ptr {
        return Unmanaged<HXXMLParser>.fromOpaque(ptr).takeUnretainedValue()
    }
    fatalError("pointer is nil")
}
