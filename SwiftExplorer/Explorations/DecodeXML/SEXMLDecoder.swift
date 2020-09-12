//
//  SEXMLDecoder.swift
//  SwiftExplorer
//
//  Created by Kenny Leung on 9/7/20.
//  Copyright © 2020 Kenny Leung. All rights reserved.
//

// Key - "tag"            - text contents of child element
//     - "tag@attribute"  - attribute of child element
//     - "@attribute"     - my own attribute

import Foundation

public class SEXMLDecoder : Decoder {
    
    public struct DecodingError : Error {
        let message:String
    }
    
    let elements:[SEXMLParser.Element]
        
    init(elements:[SEXMLParser.Element]) throws {
        if elements.count == 0 {
            throw DecodingError(message:"Decoder initialized with no XML elements ")
        }
        self.elements = elements
    }

    init(url:URL) {
        let parser = SEXMLParser()
        parser.parse(url)
        self.elements = [parser.element]
    }
        
    func element() throws -> SEXMLParser.Element {
        switch self.elements.count {
            case 0:
                throw DecodingError(message:"Decoder does not have any elements")
            case 1:
                return self.elements[0]
            default:
                throw DecodingError(message:"Assumed singular child when there are multiples")
        }
    }
    
    // MARK: Decoder
    public var codingPath = [CodingKey]()
    public var userInfo = [CodingUserInfoKey:Any]()
    
    public func container<K>(keyedBy type:K.Type) throws -> KeyedDecodingContainer<K> where K : CodingKey {
        return KeyedDecodingContainer(try XMLKeyedDecodingContainer<K>(decoder:self))
    }
    
    public func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        return XMLUnkeyedContainer(decoder:self)
    }
    
    public func singleValueContainer() throws -> SingleValueDecodingContainer {
        fatalError()
    }
    
    // MARK: New Methods
    func getValueIfPresent(_ key:CodingKey) throws -> String? {
        let keyString = key.stringValue
                
        if let index = keyString.firstIndex(of:"@") {
            if index == keyString.startIndex {
                // "@attribute" - using the attribute from the top element
                let substart = keyString.index(after:index)
                let attributeName = String(keyString[substart...])
                return try self.element().attributes?[attributeName]
            } else {
                // "tag@attribute" - using the attribute from named child
                let tag = keyString[..<index]
                let substart = keyString.index(after:index)
                let attributeName = String(keyString[substart...])
                if let elements = try self.element().children?.filter({$0.name == tag}) {
                    switch elements.count {
                        case 0:
                            return nil
                        case 1:
                            return elements[0].attributes?[attributeName]
                        default:
                            throw DecodingError(message:"More than one child for tag \(tag)")
                    }
                }
            }
        } else {
            // "tag"
            if let elements = try self.element().children?.filter({$0.name == keyString}) {
                switch elements.count {
                    case 0:
                        return nil
                    case 1:
                        return elements[0].text
                    default:
                        throw DecodingError(message:"More than one child for tag \(keyString)")
                }
            }
        }
        
        return nil
    }
    
    func decodeIfPresent <T> (
        _ key:CodingKey,
        _ create: (String) throws -> T?
    ) throws -> T?
    {
        if let value = try self.getValueIfPresent(key) {
            return try create(value)
        }
        return nil
    }
    
    func decode <T> (
        _ key:CodingKey,
        _ create: (String) throws -> T?
    ) throws -> T
    {
        if let value = try self.decodeIfPresent(key, create) {
            return value
        } else {
            throw DecodingError(message:"no value decoded for \(key)")
        }
    }
}



public struct XMLKeyedDecodingContainer<K:CodingKey> : KeyedDecodingContainerProtocol {
    static var DATE_FORMATTER:DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, dd MMM yyy HH:mm:ss Z"
        return formatter;
    }
    
    let decoder:SEXMLDecoder

    init(decoder:Decoder) throws {
        guard let decoder = decoder as? SEXMLDecoder else {
            fatalError("Can only be used with an XMLDecoder")
        }
        self.decoder = decoder
        self.allKeys = try self.decoder.element().children?.compactMap { Key(stringValue:$0.name) } ?? []
    }

    // MARK: KeyedDecodingContainerProtocol
    public typealias Key = K
    
    public var codingPath:[CodingKey] {self.decoder.codingPath}
    public var allKeys = [K]()
    
    public func contains(_ key: Self.Key) -> Bool {return self.allKeys.contains(where:{$0.stringValue == key.stringValue})}
    public func decodeNil(forKey key: Self.Key) throws -> Bool {
        if !self.contains(key) {
            return true
        }
        return try self.decoder.decodeIfPresent(key, {$0}) != nil
    }
    public func decode(_ type: Bool.Type,           forKey key: Self.Key)  throws -> Bool       {return try self.decoder.decode(key, {self.parseBool($0)})}
    public func decode(_ type: String.Type,         forKey key: Self.Key)  throws -> String     {return try self.decoder.decode(key, {$0})}
    public func decode(_ type: Double.Type,         forKey key: Self.Key)  throws -> Double     {return try self.decoder.decode(key, {Double($0)})}
    public func decode(_ type: Float.Type,          forKey key: Self.Key)  throws -> Float      {return try self.decoder.decode(key, {Float($0)})}
    public func decode(_ type: Int.Type,            forKey key: Self.Key)  throws -> Int        {return try self.decoder.decode(key, {Int($0)})}
    public func decode(_ type: Int8.Type,           forKey key: Self.Key)  throws -> Int8       {return try self.decoder.decode(key, {Int8($0)})}
    public func decode(_ type: Int16.Type,          forKey key: Self.Key)  throws -> Int16      {return try self.decoder.decode(key, {Int16($0)})}
    public func decode(_ type: Int32.Type,          forKey key: Self.Key)  throws -> Int32      {return try self.decoder.decode(key, {Int32($0)})}
    public func decode(_ type: Int64.Type,          forKey key: Self.Key)  throws -> Int64      {return try self.decoder.decode(key, {Int64($0)})}
    public func decode(_ type: UInt.Type,           forKey key: Self.Key)  throws -> UInt       {return try self.decoder.decode(key, {UInt($0)})}
    public func decode(_ type: UInt8.Type,          forKey key: Self.Key)  throws -> UInt8      {return try self.decoder.decode(key, {UInt8($0)})}
    public func decode(_ type: UInt16.Type,         forKey key: Self.Key)  throws -> UInt16     {return try self.decoder.decode(key, {UInt16($0)})}
    public func decode(_ type: UInt32.Type,         forKey key: Self.Key)  throws -> UInt32     {return try self.decoder.decode(key, {UInt32($0)})}
    public func decode(_ type: UInt64.Type,         forKey key: Self.Key)  throws -> UInt64     {return try self.decoder.decode(key, {UInt64($0)})}
    public func decode<T:Decodable>(_ type: T.Type, forKey key: Self.Key)  throws -> T {
        if type == URL.self {
            return try self.decoder.decode(key) {URL(string:$0) as? T}
        } else if type == Date.self {
            return try self.decoder.decode(key) {Self.DATE_FORMATTER.date(from:$0) as? T}
        } else {
            let elements = try self.decoder.element().children?.filter({$0.name == key.stringValue})
            return try type.init(from:SEXMLDecoder(elements:elements ?? []));
        }
    }
    
    public func decodeIfPresent(_ type: Bool.Type,   forKey key: Self.Key) throws -> Bool?      {return try self.decoder.decodeIfPresent(key, {self.parseBool($0)})}
    public func decodeIfPresent(_ type: String.Type, forKey key: Self.Key) throws -> String?    {return try self.decoder.getValueIfPresent(key)}
    public func decodeIfPresent(_ type: Double.Type, forKey key: Self.Key) throws -> Double?    {return try self.decoder.decodeIfPresent(key, {Double($0)})}
    public func decodeIfPresent(_ type: Float.Type,  forKey key: Self.Key) throws -> Float?     {return try self.decoder.decodeIfPresent(key, {Float($0)})}
    public func decodeIfPresent(_ type: Int.Type,    forKey key: Self.Key) throws -> Int?       {return try self.decoder.decodeIfPresent(key, {Int($0)})}
    public func decodeIfPresent(_ type: Int8.Type,   forKey key: Self.Key) throws -> Int8?      {return try self.decoder.decodeIfPresent(key, {Int8($0)})}
    public func decodeIfPresent(_ type: Int16.Type,  forKey key: Self.Key) throws -> Int16?     {return try self.decoder.decodeIfPresent(key, {Int16($0)})}
    public func decodeIfPresent(_ type: Int32.Type,  forKey key: Self.Key) throws -> Int32?     {return try self.decoder.decodeIfPresent(key, {Int32($0)})}
    public func decodeIfPresent(_ type: Int64.Type,  forKey key: Self.Key) throws -> Int64?     {return try self.decoder.decodeIfPresent(key, {Int64($0)})}
    public func decodeIfPresent(_ type: UInt.Type,   forKey key: Self.Key) throws -> UInt?      {return try self.decoder.decodeIfPresent(key, {UInt($0)})}
    public func decodeIfPresent(_ type: UInt8.Type,  forKey key: Self.Key) throws -> UInt8?     {return try self.decoder.decodeIfPresent(key, {UInt8($0)})}
    public func decodeIfPresent(_ type: UInt16.Type, forKey key: Self.Key) throws -> UInt16?    {return try self.decoder.decodeIfPresent(key, {UInt16($0)})}
    public func decodeIfPresent(_ type: UInt32.Type, forKey key: Self.Key) throws -> UInt32?    {return try self.decoder.decodeIfPresent(key, {UInt32($0)})}
    public func decodeIfPresent(_ type: UInt64.Type, forKey key: Self.Key) throws -> UInt64?    {return try self.decoder.decodeIfPresent(key, {UInt64($0)})}
    public func decodeIfPresent<T:Decodable>(_ type: T.Type, forKey key: Self.Key) throws -> T? {
        if type == URL.self {
            return try self.decoder.decodeIfPresent(key) {URL(string:$0) as? T}
        } else if type == Date.self {
            return try self.decoder.decodeIfPresent(key) {Self.DATE_FORMATTER.date(from:$0) as? T}
        } else if let elements = try self.decoder.element().children?.filter({$0.name == key.stringValue}) {
            return try type.init(from:SEXMLDecoder(elements:elements));
        }
        return nil
    }
    
    public func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Self.Key) throws
        -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey                        {fatalError()}
    public func nestedUnkeyedContainer(forKey key:Self.Key) throws -> UnkeyedDecodingContainer  {fatalError()}
    public func superDecoder() throws -> Decoder                                                {fatalError()}
    public func superDecoder(forKey key:Self.Key) throws -> Decoder                             {fatalError()}
    
    private func parseBool(_ value:String?) -> Bool? {
        if let val = value {
            if  val.hasPrefix("T") || val.hasPrefix("t") ||
                val.hasPrefix("Y") || val.hasPrefix("y")
            {
                return true
            }
        }
        return false
    }
    
}

public struct XMLUnkeyedContainer : UnkeyedDecodingContainer {
    
    private let decoder:SEXMLDecoder
    
    init(decoder:SEXMLDecoder) {
        self.decoder = decoder
        if decoder.elements.count == 0 {
            self.isAtEnd = true
        }
    }
    
    // MARK: UnkeyedDecodingContainer Protocol
    public var codingPath:[CodingKey] {self.decoder.codingPath}
    public var count:Int? {self.decoder.elements.count}
    public var isAtEnd: Bool = false
    public var currentIndex: Int = 0
        
    public mutating func decodeNil()                        throws -> Bool   {fatalError()}
    public mutating func decode(_ type: Bool.Type)          throws -> Bool   {fatalError()}
    public mutating func decode(_ type: String.Type)        throws -> String {fatalError()}
    public mutating func decode(_ type: Double.Type)        throws -> Double {fatalError()}
    public mutating func decode(_ type: Float.Type)         throws -> Float  {fatalError()}
    public mutating func decode(_ type: Int.Type)           throws -> Int    {fatalError()}
    public mutating func decode(_ type: Int8.Type)          throws -> Int8   {fatalError()}
    public mutating func decode(_ type: Int16.Type)         throws -> Int16  {fatalError()}
    public mutating func decode(_ type: Int32.Type)         throws -> Int32  {fatalError()}
    public mutating func decode(_ type: Int64.Type)         throws -> Int64  {fatalError()}
    public mutating func decode(_ type: UInt.Type)          throws -> UInt   {fatalError()}
    public mutating func decode(_ type: UInt8.Type)         throws -> UInt8  {fatalError()}
    public mutating func decode(_ type: UInt16.Type)        throws -> UInt16 {fatalError()}
    public mutating func decode(_ type: UInt32.Type)        throws -> UInt32 {fatalError()}
    public mutating func decode(_ type: UInt64.Type)        throws -> UInt64 {fatalError()}
    public mutating func decode<T:Decodable>(_ type:T.Type) throws -> T {
        let value:T = try type.init(from:SEXMLDecoder(elements:[self.decoder.elements[self.currentIndex]]))
        self.currentIndex += 1
        if self.currentIndex >= self.decoder.elements.count {
            self.isAtEnd = true
        }
        return value
    }
    public mutating func nestedContainer<NestedKey:CodingKey>(keyedBy type: NestedKey.Type) throws
        -> KeyedDecodingContainer<NestedKey>                                 {fatalError()}
    public mutating func nestedUnkeyedContainer() throws
        -> UnkeyedDecodingContainer                                          {fatalError()}
    public mutating func superDecoder() throws -> Decoder                    {fatalError()}
}

// Not used. When is this actually used?
public struct XMLSingleValueContainer : SingleValueDecodingContainer {
    public var codingPath: [CodingKey]
    
    public func decodeNil()                               -> Bool   {fatalError()}
    public func decode(_ type: Bool.Type)          throws -> Bool   {fatalError()}
    public func decode(_ type: String.Type)        throws -> String {fatalError()}
    public func decode(_ type: Double.Type)        throws -> Double {fatalError()}
    public func decode(_ type: Float.Type)         throws -> Float  {fatalError()}
    public func decode(_ type: Int.Type)           throws -> Int    {fatalError()}
    public func decode(_ type: Int8.Type)          throws -> Int8   {fatalError()}
    public func decode(_ type: Int16.Type)         throws -> Int16  {fatalError()}
    public func decode(_ type: Int32.Type)         throws -> Int32  {fatalError()}
    public func decode(_ type: Int64.Type)         throws -> Int64  {fatalError()}
    public func decode(_ type: UInt.Type)          throws -> UInt   {fatalError()}
    public func decode(_ type: UInt8.Type)         throws -> UInt8  {fatalError()}
    public func decode(_ type: UInt16.Type)        throws -> UInt16 {fatalError()}
    public func decode(_ type: UInt32.Type)        throws -> UInt32 {fatalError()}
    public func decode(_ type: UInt64.Type)        throws -> UInt64 {fatalError()}
    public func decode<T:Decodable>(_ type:T.Type) throws -> T      {fatalError()}
}
