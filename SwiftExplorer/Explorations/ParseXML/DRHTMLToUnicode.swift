//
//  DRHTMLToUnicode.swift
//  DailyRadio
//
//  Created by Kenny Leung on 9/16/20.
//
// https://blog.mro.name/2019/07/swift-libxml2-html/
// https://www.rapidtables.com/code/text/unicode-characters.html
// https://unicode-search.net/unicode-namesearch.pl?term=MATHEMATICAL - search by name
// https://yaytext.com/underline/
// https://unicodelookup.com
// http://unicode.scarfboy.com - lookup by code
// https://www.i18nqa.com/debug/utf8-debug.html - some good encoding debugging problems

import Foundation

//
//  HtmlFormParser.swift
//  http://mro.name/ShaarliOS
//
//  Created by Marcus Rohrmoser on 09.06.19.
//  Copyright © 2019 Marcus Rohrmoser mobile Software. All rights reserved.
//

import Foundation

// turn a nil-terminated list of unwrapped name,value pairs into a dictionary.
// expand abbreviated (html5) attribute values.
internal func atts2dict(_ atts: (Int) -> String?) -> [String:String] {
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

private func me(_ ptr : UnsafeRawPointer?) -> DRHTMLToUnicode {
    if let ptr = ptr {
        return Unmanaged<DRHTMLToUnicode>.fromOpaque(ptr).takeUnretainedValue()
    }
    fatalError("pointer is nil")
}

public class DRHTMLToUnicode {
    
    private class Element {
        let name:String
        let attributes:[String:String]?
        var text:String?
        
        init(name:String, attributes:[String:String]) {
            self.name = name
            self.attributes = attributes
        }
                
        func appendText(_ string:String) {
            if let text = self.text {
                self.text = text + string
            } else {
                self.text = string
            }
        }
    }
    
    private var stack = [Element(name:"ROOT", attributes:[:])]

    func parse(_ data:Data?) -> String {
        guard let data = data else { return "" }
        var sax = htmlSAXHandler()
        sax.initialized = XML_SAX2_MAGIC
        sax.startElement = { me($0).startElement(name:$1, atts:$2) }
        sax.endElement = { me($0).endElement(name:$1) }
        sax.characters = { me($0).charactersFound(ch:$1, len:$2) }
        // handler.error = errorEncounteredSAX

        // https://curl.haxx.se/libcurl/c/htmltitle.html
        // http://xmlsoft.org/html/libxml-HTMLparser.html#htmlParseChunk
        // https://stackoverflow.com/questions/41140050/parsing-large-xml-from-server-while-downloading-with-libxml2-in-swift-3
        // https://github.com/apple/swift-corelibs-foundation/blob/master/Foundation/XMLParser.swift#L524
        // http://redqueencoder.com/wrapping-libxml2-for-swift/ bzw. https://github.com/SonoPlot/Swift-libxml
        let ctxt = htmlCreatePushParserCtxt(&sax, Unmanaged.passUnretained(self).toOpaque(), "", 0, "", XML_CHAR_ENCODING_UTF8)
        defer { htmlFreeParserCtxt(ctxt) }
        //let _ = data.withUnsafeBytes { htmlParseChunk(ctxt, $0, Int32(data.count), 0) }
        let _ = data.withUnsafeBytes { (ptr:UnsafeRawBufferPointer) in
            let unsafeBufferPointer:UnsafeBufferPointer<Int8> = ptr.bindMemory(to:Int8.self)
            let unsafePointer:UnsafePointer<Int8>? = unsafeBufferPointer.baseAddress
            htmlParseChunk(ctxt, unsafePointer, Int32(data.count), 0)
        }
        htmlParseChunk(ctxt, "", 0, 1)

        guard let root = self.stack.popLast() else {
            print("Error - root element popped off stack")
            return "ERROR PARSING HTML"
        }
        guard let text = root.text else {
            print("Error - no root text")
            return "NO TEXT"
        }
        
        var trimmed = text.trimmingCharacters(in:.whitespacesAndNewlines)
        if trimmed.starts(with:"•") {
            trimmed = " " + trimmed
        }
        
        //print("\(trimmed)")
        
        return trimmed
    }

    private func startElement(name: UnsafePointer<xmlChar>? , atts:UnsafePointer<UnsafePointer<xmlChar>?>?) {
        // https://github.com/MaddTheSane/chmox/blob/3263ddf09276f6a47961cc4b87762f58b88772d0/CHMTableOfContents.swift#L75
        guard let elementName = decode(name) else { return }
        let attributeDict:[String:String]
        if let atts = atts {
            attributeDict = atts2dict({ decode(atts[$0]) })
        } else {
            attributeDict = [String:String]()
        }

//        for _ in 0..<self.stack.count {
//            print("    ", terminator:"")
//        }
//        print(elementName)
        let element = Element(name:elementName, attributes:attributeDict)
        self.stack.append(element)
    }

    private func endElement(name:UnsafePointer<xmlChar>?) {
        // https://github.com/MaddTheSane/chmox/blob/3263ddf09276f6a47961cc4b87762f58b88772d0/CHMTableOfContents.swift#L75
        
        guard let closedElement = self.stack.popLast() else {
            print("Error - no element onstack")
            return
        }
        
        let parentElement = self.stack.last
        let elementName = decode(name)
        if elementName != closedElement.name {
            print("Error! Closing the wrong element!")
        }
        
        if let text = closedElement.text {
            switch closedElement.name {
                case "body":
                    parentElement?.appendText(text)
                case "html":
                    parentElement?.appendText(text)
                case "a":
                    if let href = closedElement.attributes?["href"] {
                        parentElement?.appendText("\(self.underline(text)) <\(href)>")
                    }
                case "b":
                    parentElement?.appendText(self.bold(text))
                case "em":
                    parentElement?.appendText(self.italic(text))
                case "i":
                    parentElement?.appendText(self.italic(text))
                case "li":
                    parentElement?.appendText("\n • \(text)")
                case "p":
                    if let parentText = parentElement?.text,
                       !parentText.hasSuffix("\n") {
                        parentElement?.appendText("\n")
                    }
                    parentElement?.appendText("\n\(text)")
                case "span":
                    parentElement?.appendText(text)
                case "strong":
                    parentElement?.appendText(self.bold(text))
                case "ul":
                    parentElement?.appendText(text)
                default:
                    parentElement?.appendText(text)
                    print("Unsuported tag: \(closedElement.name)")
            }
        } else {
            switch closedElement.name {
                case "b":
                    break
                case "li":
                    break
                case "p":
                    break
                case "ul":
                    break
                default:
                    print("Unsuported tag: \(closedElement.name)")
            }
        }
    }
    
    private func charactersFound(ch: UnsafePointer<xmlChar>?, len: CInt) {
        let d = Data(bytes: ch!, count:Int(len)) // clamp
        let s = String(data: d, encoding: .utf8) ?? "<utf8 decoding issue>"
        
        if ( self.isWhiteSpace(s) ) {
            return
        }
        self.stack.last?.appendText(s)
    }
    
    private func isWhiteSpace(_ string:String) -> Bool {
        for scalar in string.unicodeScalars {
            if !CharacterSet.whitespacesAndNewlines.contains(scalar) {
                return false
            }
        }
        return true
    }
    
    static private func _mapCharacters(original orig:String, modified modi:String) -> [Character:Character] {
        var results = [Character:Character]()
        var origIndex = orig.startIndex;
        let endIndex = orig.endIndex;
        var modiIndex = modi.startIndex;
        while ( origIndex != endIndex ) {
            results[orig[origIndex]] = modi[modiIndex]
            origIndex = orig.index(after:origIndex)
            modiIndex = modi.index(after:modiIndex)
        }
        return results
    }
    
    // This is the full set of characters
    static let ascii        = "!\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~"
    static let bold         = "!\"#$%&'()*+,-./𝟬𝟭𝟮𝟯𝟰𝟱𝟲𝟳𝟴𝟵:;<=>?@𝗔𝗕𝗖𝗗𝗘𝗙𝗚𝗛𝗜𝗝𝗞𝗟𝗠𝗡𝗢𝗣𝗤𝗥𝗦𝗧𝗨𝗩𝗪𝗫𝗬𝗭[\\]^_`𝗮𝗯𝗰𝗱𝗲𝗳𝗴𝗵𝗶𝗷𝗸𝗹𝗺𝗻𝗼𝗽𝗾𝗿𝘀𝘁𝘂𝘃𝘄𝘅𝘆𝘇{|}~"
    static let italic       = "!\"#$%&'()*+,-./0123456789:;<=>?@𝘈𝘉𝘊𝘋𝘌𝘍𝘎𝘏𝘐𝘑𝘒𝘓𝘔𝘕𝘖𝘗𝘘𝘙𝘚𝘛𝘜𝘝𝘞𝘟𝘠𝘡[\\]^_`𝘢𝘣𝘤𝘥𝘦𝘧𝘨𝘩𝘪𝘫𝘬𝘭𝘮𝘯𝘰𝘱𝘲𝘳𝘴𝘵𝘶𝘷𝘸𝘹𝘺𝘻{|}~"
    static let bolditalic   = "!\"#$%&'()*+,-./𝟬𝟭𝟮𝟯𝟰𝟱𝟲𝟳𝟴𝟵:;<=>?@𝘼𝘽𝘾𝘿𝙀𝙁𝙂𝙃𝙄𝙅𝙆𝙇𝙈𝙉𝙊𝙋𝙌𝙍𝙎𝙏𝙐𝙑𝙒𝙓𝙔𝙕[\\]^_`𝙖𝙗𝙘𝙙𝙚𝙛𝙜𝙝𝙞𝙟𝙠𝙡𝙢𝙣𝙤𝙥𝙦𝙧𝙨𝙩𝙪𝙫𝙬𝙭𝙮𝙯{|}~"
    static let ascii_u      = underline(ascii)
    static let bold_u       = underline(bold)
    static let italic_u     = underline(italic)
    static let bolditalic_u = underline(bolditalic)

    static let italicLUT = _mapCharacters(
        original:ascii  + ascii_u  + bold       + bold_u ,
        modified:italic + italic_u + bolditalic + bolditalic_u
    )
    private func italic(_ orig:String) -> String {
        var buffer = [Character]()
        for char in orig {
            if let bold = DRHTMLToUnicode.italicLUT[char] {
                buffer.append(bold)
            } else {
                buffer.append(char)
            }
        }
        return String(buffer)
    }

    static let boldLUT = _mapCharacters(
        original:ascii + ascii_u + italic     + italic_u ,
        modified:bold  + bold_u  + bolditalic + bolditalic_u
    )
    private func bold(_ orig:String) -> String {
        var buffer = [Character]()
        for char in orig {
            if let bold = DRHTMLToUnicode.boldLUT[char] {
                buffer.append(bold)
            } else {
                buffer.append(char)
            }
        }
        return String(buffer)
    }
    
    static let badu_ascii             = " \"$'()*,-/;<=@Q[\\]^_`gjpqy{|}~"
    static let badu_bold_serif        = " \"$'()*,-/;<=@𝐐[\\]^_`𝐠𝐣𝐩𝐪𝐲{|}~"
    static let badu_bold_sans         = " \"$'()*,-/;<=@𝗤[\\]^_`𝗴𝗷𝗽𝗾𝘆{|}~"
    static let badu_italic_serif      = " \"$'()*,-/;<=@𝑄[\\]^_`𝑔𝑗𝑝𝑞𝑦{|}~"
    static let badu_italic_sans       = " \"$'()*,-/;<=@𝘘[\\]^_`𝘨𝘫𝘱𝘲𝘺{|}~"
    static let badu_bold_italic_serif = " \"$'()*,-/;<=@𝑸[\\]^_`𝒈𝒋𝒑𝒒𝒚{|}~"
    static let badu_bold_italic_sans  = " \"$'()*,-/;<=@𝙌[\\]^_`𝙜𝙟𝙥𝙦𝙮{|}~"
    static let badu_quotation_marks   = "«»‘’‚‛“”„‟‹›❛❜❝❞❮❯〝〞〟＂"
    static let badunderlines = badu_ascii + badu_bold_serif + badu_bold_sans + badu_italic_serif + badu_italic_sans + badu_bold_italic_serif + badu_bold_italic_sans + badu_quotation_marks
    static private func underline(_ orig:String) -> String {
        var buffer = [UInt8]()
        for char in orig {
            buffer.append(contentsOf:char.utf8)
            if DRHTMLToUnicode.badunderlines.contains(char) {
                continue
            }
            buffer.append(0xcd)
            buffer.append(0x9f)
        }
        let result = String(bytes:buffer, encoding:.utf8)
        return result ?? orig
    }
    private func underline(_ orig:String) -> String {
        return DRHTMLToUnicode.underline(orig)
    }

}
