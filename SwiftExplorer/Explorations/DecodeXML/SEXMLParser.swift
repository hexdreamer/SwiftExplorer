
import Foundation

public class SEXMLParser : NSObject,XMLParserDelegate {
        
    public class Element {
        let name:String
        let attributes:[String:String]?
        var text:String?
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
            
    public func parse(_ url:URL) {
        if let parser = XMLParser(contentsOf:url) {
            parser.delegate = self
            parser.parse()
        } else {
            fatalError("Could not initialize parser with \(url)")
        }
    }
    
    // MARK: XMLParserDelegate
    @objc
    public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
//        for _ in 0..<self.stack.count {
//            print("    ", terminator:"")
//        }
//        print(elementName)
        let element = Element(name:elementName, attributes:attributeDict)
        if let openElement = self.stack.last {
            openElement.append(element)
        }
        self.stack.append(element)
    }
    
    @objc
    public func parser(_ parser: XMLParser, foundCharacters string: String) {
        if let text = self.stack.last?.text {
            self.stack.last?.text = text + string
        } else {
            self.stack.last?.text = string
        }
    }
    
    @objc
    public func parser(_ parser: XMLParser, foundIgnorableWhitespace whitespaceString: String) {
        // do nothing
    }

    @objc
    public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if self.stack.count > 1 {
            _ = self.stack.popLast()
        }
    }

}
