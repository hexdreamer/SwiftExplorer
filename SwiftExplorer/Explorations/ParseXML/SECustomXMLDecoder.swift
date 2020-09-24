//
//  DRFeedParser.swift
//  DailyRadio
//
//  Created by Kenny Leung on 8/22/20.
//

import Foundation

public class SECustomXMLDecoder : HXXMLParserDelegate {
        
    private var level:Int = 0
    private let parser:HXXMLParser
    private var stack = [SECustomXMLDecoderModel]()
    private let root:SECustomXMLDecoderModel
    private var text:String?
    private var cdata:Data?
    
    var channel:SECustomXMLChannel? {
        return self.stack.first as? SECustomXMLChannel
    }

    init(root:SECustomXMLDecoderModel) {
        self.parser = HXXMLParser(mode:.XML)
        self.stack.append(root)
        self.root = root;
        self.parser.delegate = self
    }
    
    public func parse(data:Data) {
        self.parser.parse(data)
    }
        
    // MARK:HXXMLParserDelegate
    public func parser(_ parser: HXXMLParser, didStartElement elementName: String, attributes attributeDict: [String : String]) {
//        for _ in 0..<level {
//            print("    ", terminator:"")
//        }
//        print(elementName)

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

    public func parser(_ parser: HXXMLParser, foundCharacters string: String) {
        if ( isWhiteSpace(string) ) {
            return
        }
        if let text = self.text {
            self.text = text + string
        } else {
            self.text = string
        }
    }
    
    public func parser(_ parser: HXXMLParser, foundCDATA CDATABlock: Data) {
        self.cdata = CDATABlock;
    }

    public func parser(_ parser: HXXMLParser, didEndElement elementName: String) {
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
    
    private func isWhiteSpace(_ string:String) -> Bool {
        for scalar in string.unicodeScalars {
            if !CharacterSet.whitespacesAndNewlines.contains(scalar) {
                return false
            }
        }
        return true
    }

}
