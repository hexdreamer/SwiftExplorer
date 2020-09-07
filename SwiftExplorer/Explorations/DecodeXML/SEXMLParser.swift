
import Foundation

public class SEXMLParser : NSObject,XMLParserDelegate {
    
    private var level:Int = 0
    private var stack = [XMLElement]()
    private var openElement = XMLElement(name:"__ROOT__", attributes:[:])
    private var lastModel:Any?
    private var text:String?
    
    private let models:[String:Decodable.Type]
    
    init(models:[String:Decodable.Type]) {
        self.models = models
        super.init()
    }
    
    public func parse(_ data:Data) -> Any? {
        let parser = XMLParser(data:data)
        parser.delegate = self
        parser.parse()
        return self.lastModel;
    }
    
    // MARK: XMLParserDelegate
    @objc
    public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        // for _ in 0..<level {
        //     print("    ", terminator:"")
        // }
        // print(elementName)
        self.stack.append(self.openElement)
        self.openElement = XMLElement(name:elementName, attributes:attributeDict)
        self.level += 1
    }
    
    @objc
    public func parser(_ parser: XMLParser, foundCharacters string: String) {
        if let text = self.text {
            self.text = text + string
        } else {
            self.text = string
        }
    }

    @objc
    public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if ( self.openElement.name != elementName ) {
            fatalError("Expecting close of element \(self.openElement.name), but got \(elementName) instead")
        }
        
        self.level -= 1
        var closedElement = self.openElement
        self.openElement = self.stack.removeLast()
        closedElement.text = self.text
        self.text = nil
        if closedElement.text == nil,
            let attributeText = closedElement.attributes["text"] {
            closedElement.text = attributeText
        }
        
        do {
            if let modelClass = self.models[closedElement.name] {
                let model = try modelClass.init(from:SEXMLDecoder(element:closedElement))
                self.openElement.append(childModel:model, forTag:closedElement.name)
                self.lastModel = model
            } else {
                self.openElement.children.append(closedElement)
            }
        } catch (let error){
            print("Error: \(error)")
        }
    }

}

struct XMLElement {
    let name:String
    let attributes:[String:String]
    var text:String?
    var model:Any?
    var children = [XMLElement]()
    var childModels = [String:[Decodable]]()
    
    // Cannot put this inline into a let-else for some reason. Puzzle for another day
    func childForKey(_ key:CodingKey) -> XMLElement? {
        return self.children.first {$0.name == key.stringValue};
    }
    
    func childModelsForKey(_ key:CodingKey) -> [Decodable]? {
        return self.childModels[key.stringValue]
    }
    
    mutating func append(childModel:Decodable, forTag tag:String) {
        if self.childModels[tag] != nil {
            self.childModels[tag]?.append(childModel)
        } else {
            self.childModels[tag] = [childModel]
        }
    }
}
