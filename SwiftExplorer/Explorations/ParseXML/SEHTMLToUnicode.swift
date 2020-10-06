//
//  DRHTMLToUnicode.swift
//  DailyRadio
//
//  Created by Kenny Leung on 9/16/20.
//

import Foundation

public class SEHTMLToUnicode : HXXMLParserDelegate {
                
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
    private var indentLevel:UInt = 0;
    
    init() {}
    
    func convert(_ data:Data) throws -> String? {
        let parser = try HXXMLParser(mode:.HTML, delegate:self)
        try parser.parseChunk(data:data)
        
        if var unicode = self.stack.last?.text {
            unicode = unicode.trimmingCharacters(in:CharacterSet.whitespacesAndNewlines)
            if ( unicode.starts(with:"•")) {
                unicode = " " + unicode
            }
            return unicode
        }
        return nil
    }

    public func parser(_ parser: HXXMLParser, didStartElement elementName: String, attributes attributeDict: [String : String]) {
//        for _ in 0..<self.stack.count {
//            print("    ", terminator:"")
//        }
//        print(elementName)
        let element = Element(name:elementName, attributes:attributeDict)
        self.stack.append(element)
        if elementName == "ul" {
            self.indentLevel += 1
        }
    }
    
    public func parser(_ parser: HXXMLParser, foundCharacters s: String) {
        if ( self.isWhiteSpace(s) ) {
            return
        }
        
        let stripped = s.replacingOccurrences(of:"\n", with:"")
        self.stack.last?.appendText(stripped)
    }
    
    public func parser(_ parser: HXXMLParser, foundCDATA: Data) {
    }
    
    public func parser(_ parser: HXXMLParser, didEndElement elementName: String) {
        guard let closedElement = self.stack.popLast() else {
            print("Error - no element on stack")
            return
        }
        
        let parentElement = self.stack.last
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
                    parentElement?.appendText(self.translate(text, Self.boldLUT))
                case "code":
                    parentElement?.appendText(self.translate(text, Self.monospaceLUT))
                case "em":
                    parentElement?.appendText(self.translate(text, Self.italicLUT))
                case "i":
                    parentElement?.appendText(self.translate(text, Self.italicLUT))
                case "li":
                    var indent = ""
                    if ( indentLevel > 1 ) {
                        for _ in 0..<self.indentLevel - 1 {
                            indent = indent + "   "
                        }
                    }
                    parentElement?.appendText("\n " + indent + "• \(text)")
                case "p":
                    if let parentText = parentElement?.text,
                       !parentText.hasSuffix("\n") {
                        parentElement?.appendText("\n")
                    }
                    parentElement?.appendText("\n\(text)")
                case "span":
                    parentElement?.appendText(text)
                case "strong":
                    parentElement?.appendText(self.translate(text, Self.boldLUT))
                case "ul":
                    parentElement?.appendText(text)
                    self.indentLevel -= 1
                default:
                    parentElement?.appendText(text)
                    print("Unsuported tag: \(closedElement.name)")
            }
        } else {
            switch closedElement.name {
                case "b":
                    break
                case "br":
                    parentElement?.appendText("\n")
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
    
    public func parserDidEndDocument(_ parser:HXXMLParser) {}
    
    public func parser(_ parser:HXXMLParser, error:Error) {}
    
    // MARK: Private Methods
    
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
    static let monospace    = "!\"#$%&'()*+,-./0𝟷𝟸𝟹𝟺𝟻𝟼𝟽𝟾𝟿:;<=>?@𝙰𝙱𝙲𝙳𝙴𝙵𝙶𝙷𝙸𝙹𝙺𝙻𝙼𝙽𝙾𝙿𝚀𝚁𝚂𝚃𝚄𝚅𝚆𝚇𝚈𝚉[\\]^_`𝚊𝚋𝚌𝚍𝚎𝚏𝚐𝚑𝚒𝚓𝚔𝚕𝚖𝚗𝚘𝚙𝚚𝚛𝚜𝚝𝚞𝚟𝚠𝚡𝚢𝚣{|}~"
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
    static let boldLUT = _mapCharacters(
        original:ascii + ascii_u + italic     + italic_u ,
        modified:bold  + bold_u  + bolditalic + bolditalic_u
    )
    static let monospaceLUT = _mapCharacters(original:ascii, modified:monospace)
    
    private func translate(_ orig:String, _ lut:[Character:Character]) -> String {
        var buffer = [Character]()
        for char in orig {
            if let tran = lut[char] {
                buffer.append(tran)
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
            if SEHTMLToUnicode.badunderlines.contains(char) {
                continue
            }
            buffer.append(0xcd)
            buffer.append(0x9f)
        }
        let result = String(bytes:buffer, encoding:.utf8)
        return result ?? orig
    }
    private func underline(_ orig:String) -> String {
        return SEHTMLToUnicode.underline(orig)
    }

}
