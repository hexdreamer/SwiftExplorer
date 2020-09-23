//
//  DRFeedParser.swift
//  DailyRadio
//
//  Created by Kenny Leung on 8/22/20.
//

import Foundation
import CoreData

@objc
public class SECustomXMLDecoder : NSObject,XMLParserDelegate {
        
    private var level:Int = 0
    private let parser:XMLParser
    private var stack = [SECustomXMLDecoderModel]()
    private let root:SECustomXMLDecoderModel
    private var text:String?
    private var cdata:Data?
    
    var channel:SECustomXMLChannel? {
        return self.stack.first as? SECustomXMLChannel
    }

    init(data:Data, root:SECustomXMLDecoderModel) {
        self.parser = XMLParser(data:data)
        self.stack.append(root)
        self.root = root;
        super.init()
        self.parser.delegate = self
    }
    
    public func run() {
        self.parser.parse()
    }
        
    // MARK:XMLParserDelegate
    
    public func parserDidStartDocument(_ parser: XMLParser) {
        
    }

    
    public func parserDidEndDocument(_ parser: XMLParser) {
        
    }

    
    public func parser(_ parser: XMLParser, foundNotationDeclarationWithName name: String, publicID: String?, systemID: String?) {
        
    }

    
    public func parser(_ parser: XMLParser, foundUnparsedEntityDeclarationWithName name: String, publicID: String?, systemID: String?, notationName: String?) {
        
    }

    
    public func parser(_ parser: XMLParser, foundAttributeDeclarationWithName attributeName: String, forElement elementName: String, type: String?, defaultValue: String?) {
        
    }

    
    public func parser(_ parser: XMLParser, foundElementDeclarationWithName elementName: String, model: String) {
        
    }

    
    public func parser(_ parser: XMLParser, foundInternalEntityDeclarationWithName name: String, value: String?) {
        
    }

    
    public func parser(_ parser: XMLParser, foundExternalEntityDeclarationWithName name: String, publicID: String?, systemID: String?) {
        
    }

    
    public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        for _ in 0..<level {
            print("    ", terminator:"")
        }
        print(elementName)

        self.level += 1

        if self.stack.count == 0 && elementName == root.tag {
            self.stack.append(self.root)
        } else if var currentEntity = self.stack.last {
            if var child = currentEntity.makeChildEntity(forTag:elementName) {
                for (key,value) in attributeDict {
                    child.setValue(value, forTag:nil, attribute:key)
                }
                self.stack.append(child);
            } else {
                for (key,value) in attributeDict {
                    currentEntity.setValue(value, forTag:elementName, attribute:key)
                }
                self.stack.hxSetLast(currentEntity)
            }
        }
    }

    
    public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        self.level -= 1
        
        if self.stack.count > 1,
           let currentEntity = self.stack.last,
           currentEntity.tag == elementName
        {
            let closedEntity = self.stack.removeLast()
            self.stack.hxWithLast{$0.setChildEntity(closedEntity, forTag:elementName)}
            return
        }

        if let text = self.text {
            self.stack.hxWithLast{$0.setValue(text, forTag:elementName)}
            self.text = nil
        }
        
        if let data = self.cdata {
            self.stack.hxWithLast{$0.setData(data, forTag:elementName)}
            self.cdata = nil
        }
    }

    
    public func parser(_ parser: XMLParser, didStartMappingPrefix prefix: String, toURI namespaceURI: String) {
        
    }

    
    public func parser(_ parser: XMLParser, didEndMappingPrefix prefix: String) {
        
    }

    
    public func parser(_ parser: XMLParser, foundCharacters string: String) {
        if ( isWhiteSpace(string) ) {
            return
        }
        if let text = self.text {
            self.text = text + string
        } else {
            self.text = string
        }
    }

    private func isWhiteSpace(_ string:String) -> Bool {
        for scalar in string.unicodeScalars {
            if !CharacterSet.whitespacesAndNewlines.contains(scalar) {
                return false
            }
        }
        return true
    }
    
    public func parser(_ parser: XMLParser, foundIgnorableWhitespace whitespaceString: String) {
        
    }

    
    public func parser(_ parser: XMLParser, foundProcessingInstructionWithTarget target: String, data: String?) {
        
    }

    
    public func parser(_ parser: XMLParser, foundComment comment: String) {
        
    }

    
    public func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data) {
        self.cdata = CDATABlock;
    }

    
    public func parser(_ parser: XMLParser, resolveExternalEntityName name: String, systemID: String?) -> Data? {
        return nil
    }

    
    public func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        
    }

    
    public func parser(_ parser: XMLParser, validationErrorOccurred validationError: Error) {
        
    }
    
}
