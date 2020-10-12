//
//  DRFeedParser.swift
//  DailyRadio
//
//  Created by Kenny Leung on 8/22/20.
//

import Foundation
import hexdreamsCocoa

public class SECustomParser : HXSAXParserDelegate {
        
    private var level:Int = 0
    private var stack = [SECustomParserModel]()
    private let root:SECustomParserModel
    private var text:String?
    private var cdata:Data?
    
    private var parser:HXSAXParser?
    private var fileReader:HXDispatchIOFileReader?
    private var urlSessionReader:HXURLSessionReader?
    private var completionHandler:((SECustomParser)->Void)?
    
    var channel:SECustomParsingChannel? {
        return self.stack.first as? SECustomParsingChannel
    }

    init(root:SECustomParserModel) {
        self.stack.append(root)
        self.root = root;
    }
    
    deinit {
    }
    
    public func parse(file:URL, completion:@escaping (SECustomParser)->Void) throws {
        self.completionHandler = completion;
        self.parser = try HXSAXParser(mode:.XML, delegate:self)
        self.fileReader = HXDispatchIOFileReader(
            file:file,
            dataAvailable: { [weak self] (data) in
                do {
                    try self?.parser?.parseChunk(data:data)
                } catch let e{
                    print(e)
                }
            },
            completion: { [weak self] in
                self?.parser?.finishParsing()
            }
        )
    }
    
    public func parse(network:URL, saveTo:URL, completion:@escaping (SECustomParser)->Void) throws {
        self.completionHandler = completion;
        self.parser = try HXSAXParser(mode:.XML, delegate:self)
        
        let dispatchIO:DispatchIO? = saveTo.withUnsafeFileSystemRepresentation {
            guard let filePath = $0 else {
                print("Could not convert file to fileSystemRepresentation")
                return nil
            }
            return DispatchIO(type:.stream, path:filePath,
                              oflag:O_WRONLY|O_CREAT, mode:S_IRUSR|S_IWUSR,
                              queue:DispatchQueue.global(qos:.background),
                              cleanupHandler:{error in
                                if ( error != 0 ) {
                                    print("Error opening cache file \(saveTo) for writing: \(error)")
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
                                                    print("Error writing to file \(saveTo): \(error)")
                                                }
                                          }
                        )
                    }
                } catch let e {
                    print(e)
                }
            },
            completion: { [weak self] in
                self?.parser?.finishParsing()
                dispatchIO?.close(flags:DispatchIO.CloseFlags(rawValue: 0))
            }
        )
    }
    
    // MARK:HXSAXParserDelegate
    public func parser(_ parser: HXSAXParser, didStartElement elementName: String, attributes attributeDict: [String : String]) {
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

    public func parser(_ parser: HXSAXParser, foundCharacters string: String) {
        if ( self._isWhiteSpace(string) ) {
            return
        }
        if let text = self.text {
            self.text = text + string
        } else {
            self.text = string
        }
    }
    
    public func parser(_ parser: HXSAXParser, foundCDATA CDATABlock: Data) {
        self.cdata = CDATABlock;
    }

    public func parser(_ parser: HXSAXParser, didEndElement elementName: String) {
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
    
    public func parserDidEndDocument(_ parser:HXSAXParser) {
        self.completionHandler?(self)
    }
    
    public func parser(_ parser: HXSAXParser, error: Error) {

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
