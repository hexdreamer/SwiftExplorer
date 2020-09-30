
import Foundation

public class SEXMLParser : HXXMLParserDelegate {
        
    public class Element {
        let name:String
        let attributes:[String:String]?
        var text:String?
        var cdata:Data?
        var children:[Element]?
        
        init(name:String, attributes:[String:String]) {
            self.name = name
            self.attributes = attributes
        }
        
        func append(_ element:Element) {
            if self.children != nil {
                self.children?.append(element)
            } else {
                self.children = [element]
            }
        }
    }

    private var stack = [Element]()
    
    public var element:Element {
        if let elem = self.stack.last {
            return elem
        } else {
            fatalError("no element available")
        }
    }
            
    public func parse(_ url:URL) throws {
        let parser = try HXXMLParser(mode:.XML, network:url)
        parser.delegate = self
        parser.parse()
    }
    
    // MARK: HXXMLParserDelegate
    public func parser(_ parser: HXXMLParser, didStartElement elementName: String, attributes attributeDict: [String : String]) {
        for _ in 0..<self.stack.count {
            print("    ", terminator:"")
        }
        print(elementName)
        let element = Element(name:elementName, attributes:attributeDict)
        if let openElement = self.stack.last {
            openElement.append(element)
        }
        self.stack.append(element)
    }
    
    public func parser(_ parser: HXXMLParser, foundCharacters string: String) {
        if self._isWhiteSpace(string) {
            return
        }
        if let text = self.stack.last?.text {
            self.stack.last?.text = text + string
        } else {
            self.stack.last?.text = string
        }
    }
    
    public func parser(_ parser: HXXMLParser, foundCDATA: Data) {
        if let element = self.stack.last,
           element.name == "description" {
            self.stack.last?.cdata = foundCDATA
        }
    }
    
    public func parser(_ parser: HXXMLParser, didEndElement: String) {
        if self.stack.count > 1 {
            _ = self.stack.popLast()
        }
    }
    
    public func parserDidEndDocument(_ parser:HXXMLParser) {
        
    }
    
    public func parser(_ parser:HXXMLParser, error:Error) {
        
    }

    // MARK: Private Methods
    private func _isWhiteSpace(_ string:String) -> Bool {
        for scalar in string.unicodeScalars {
            if !CharacterSet.whitespacesAndNewlines.contains(scalar) {
                return false
            }
        }
        return true
    }

}
