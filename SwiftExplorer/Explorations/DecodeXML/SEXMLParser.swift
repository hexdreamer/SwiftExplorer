
import Foundation
import hexdreamsCocoa

public class SEXMLParser : HXSAXParserDelegate {
    
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

    private var parser:HXSAXParser?
    private var fileReader:HXDispatchIOFileReader?
    private var urlSessionReader:HXURLSessionReader?
    private var stack = [Element]()

    public var element:Element {
        if let elem = self.stack.last {
            return elem
        } else {
            fatalError("no element available")
        }
    }
            
    public func parse(file:URL, completion:@escaping (SEXMLParser)->Void) throws {
        self.parser = try HXSAXParser(mode:.XML, delegate:self)
        self.fileReader = HXDispatchIOFileReader(
            file:file,
            dataAvailable: { [weak self] (data) in
                do {
                    try self?.parser?.parseChunk(data:data)
                } catch let e {
                    print(e)
                }
            },
            completion: { [weak self] in
                print("file reader completion")
                guard let self = self else {
                    return;
                }
                self.parser?.finishParsing()
                completion(self)
            }
        )
    }
    
    public func parse(network:URL, saveTo:URL, completion:@escaping (SEXMLParser)->Void) throws {
        self.parser = try HXSAXParser(mode:.XML, delegate:self)
        
        let tempFile = saveTo.appendingPathExtension("temp")
        let dispatchIO:DispatchIO? = tempFile.withUnsafeFileSystemRepresentation {
            guard let filePath = $0 else {
                print("Could not convert file to fileSystemRepresentation")
                return nil
            }
            return DispatchIO(type:.stream, path:filePath,
                              oflag:O_WRONLY|O_CREAT, mode:S_IRUSR|S_IWUSR,
                              queue:DispatchQueue.global(qos:.background),
                              cleanupHandler:{error in
                                if ( error != 0 ) {
                                    print("Error opening cache file \(tempFile) for writing: \(error)")
                                }
                              });
        }
        
        self.urlSessionReader = HXURLSessionReader(
            url:network,
            dataAvailable: { [weak self] (data) in
                do {
                    try self?.parser?.parseChunk(data:data)
                    data.withUnsafeBytes {
                        dispatchIO?.write(offset:0, data:DispatchData(bytes:$0), queue:DispatchQueue.global(qos:.background),
                                          ioHandler:{ (done,data,error) in
                                                if ( error != 0 ) {
                                                    print("Error writing to file \(tempFile): \(error)")
                                                }
                                          }
                        )
                    }
                } catch let e {
                    print(e)
                }
            },
            completion: { [weak self] in
                guard let self = self else {
                    return
                }
                self.parser?.finishParsing()
                dispatchIO?.barrier {
                    dispatchIO?.close(flags:DispatchIO.CloseFlags(rawValue: 0))
                    do {
                        if ( FileManager.default.fileExists(atPath:saveTo.path) ) {
                            try FileManager.default.removeItem(at:saveTo)
                        }
                        try FileManager.default.moveItem(at:tempFile, to:saveTo)
                    } catch let e {
                        print("Error commiting file \(saveTo): \(e)");
                    }
                }
            }
        )
    }

        
    // MARK: HXSAXParserDelegate
    public func parser(_ parser: HXSAXParser, didStartElement elementName: String, attributes attributeDict: [String : String]) {
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
    
    public func parser(_ parser: HXSAXParser, foundCharacters string: String) {
        if self._isWhiteSpace(string) {
            return
        }
        if let text = self.stack.last?.text {
            self.stack.last?.text = text + string
        } else {
            self.stack.last?.text = string
        }
    }
    
    public func parser(_ parser: HXSAXParser, foundCDATA: Data) {
        if let element = self.stack.last,
           element.name == "description" {
            self.stack.last?.cdata = foundCDATA
        }
    }
    
    public func parser(_ parser: HXSAXParser, didEndElement: String) {
        if self.stack.count > 1 {
            _ = self.stack.popLast()
        }
    }
    
    public func parserDidEndDocument(_ parser:HXSAXParser) {
        
    }
    
    public func parser(_ parser:HXSAXParser, error:Error) {
        
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
