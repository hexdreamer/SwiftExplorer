//
//  DRFeedParser.swift
//  DailyRadio
//
//  Created by Kenny Leung on 8/22/20.
//

import Foundation
import CoreData

public protocol DRXMLDecoderModel {
    var tag:String {get}
    mutating func setValue(_ value:String, forTag tag:String)
    mutating func setData(_ data:Data, forTag tag:String)
    mutating func setValue(_ value:String, forTag tag:String?, attribute:String)
    func makeChildEntity(forTag tag:String) -> DRXMLDecoderModel?
    mutating func setChildEntity(_ value:DRXMLDecoderModel, forTag tag:String);
}


@objc
public class DRXMLDecoder : NSObject,XMLParserDelegate {
        
    private var level:Int = 0
    private let parser:XMLParser
    private var stack = [DRXMLDecoderModel]()
    private let root:DRXMLDecoderModel
    private var text:String?
    private var cdata:Data?
    
    var channel:DRChannel? {
        return self.stack.first as? DRChannel
    }

    init(data:Data, root:DRXMLDecoderModel) {
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
        } else if let currentEntity = self.stack.last {
            if var child = currentEntity.makeChildEntity(forTag:elementName) {
                for (key,value) in attributeDict {
                    child.setValue(value, forTag:nil, attribute:key)
                }
                self.stack.append(child);
            } else {
                if let _ = self.stack.last {
                    for (key,value) in attributeDict {
                        var index = self.stack.endIndex;
                        index = self.stack.index(before:index)
                        self.stack[index].setValue(value, forTag:elementName, attribute:key)
                    }
                }
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
            if let _ = self.stack.last {
                var index = self.stack.endIndex;
                index = self.stack.index(before:index)
                self.stack[index].setChildEntity(closedEntity, forTag:elementName)
            }
            return
        }

        if let text = self.text {
            if let _ = self.stack.last {
                var index = self.stack.endIndex;
                index = self.stack.index(before:index)
                self.stack[index].setValue(text, forTag:elementName)
            }
            self.text = nil
        }
        
        if let data = self.cdata {
            if let _ = self.stack.last {
                var index = self.stack.endIndex;
                index = self.stack.index(before:index)
                self.stack[index].setData(data, forTag:elementName)
            }
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
