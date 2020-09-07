//
//  SEXMLDecoder.swift
//  SwiftExplorer
//
//  Created by Kenny Leung on 9/7/20.
//  Copyright © 2020 Kenny Leung. All rights reserved.
//

import Foundation

public protocol SEXMLCodingKey {
    var attribute:String? {get}
}

public class SEXMLDecoder : Decoder {
    let element:XMLElement
    
    init(element:XMLElement) {
        self.element = element
    }
    
    // MARK: Decoder
    public var codingPath = [CodingKey]()
    public var userInfo = [CodingUserInfoKey:Any]()
    
    public func container<K>(keyedBy type:K.Type) throws -> KeyedDecodingContainer<K> where K : CodingKey {
        return KeyedDecodingContainer(XMLKeyedDecodingContainer<K>(decoder:self))
    }
    
    public func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        guard let key = self.codingPath.last else {
            fatalError("No current key")
        }
        return XMLUnkeyedContainer(codingPath:self.codingPath, values:self.element.childModelsForKey(key))
    }
    
    public func singleValueContainer() throws -> SingleValueDecodingContainer {
        fatalError()
    }
    
    // MARK: New Methods
    func pushKey(_ key:CodingKey) -> Void {
        self.codingPath.append(key)
    }
    
    func popKey() -> CodingKey? {
        return self.codingPath.popLast()
    }
    
    func decode<T>(_ key:CodingKey,
                   _ create: (String) throws -> T?
    ) rethrows -> T
    {
        guard let child = self.element.childForKey(key) else {
            fatalError("Does not contain child \(key)")
        }
        
        var stringValue:String? = nil
        
        if let xmlkey:SEXMLCodingKey = key as? SEXMLCodingKey,
            let attribute:String = xmlkey.attribute,
            let value:String = child.attributes[attribute]
        {
            stringValue = value
        }
        
        if ( stringValue == nil ) {
            stringValue = child.text
        }
        
        if let value = stringValue {
            let trimmed = value.trimmingCharacters(in:.whitespacesAndNewlines)
            if ( !trimmed.isEmpty ) {
                if let decoded = try create(trimmed) {
                    return decoded
                }
            }
        }
        
        fatalError("Could not decode \(key)")
    }
}

public struct XMLKeyedDecodingContainer<K:CodingKey> : KeyedDecodingContainerProtocol {
    static var DATE_FORMATTER:DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, dd MMM yyy HH:mm:ss Z"
        return formatter;
    }
    
    var decoder:SEXMLDecoder
    var element:XMLElement {decoder.element}

    // MARK: KeyedDecodingContainerProtocol
    
    public typealias Key = K

    public var codingPath = [CodingKey]()
    public var allKeys = [K]()
    
    init(decoder:Decoder) {
        guard let decoder = decoder as? SEXMLDecoder else {
            fatalError("Can only be used with an XMLDecoder")
        }
        self.decoder = decoder
        self.allKeys = self.element.children.compactMap { Key(stringValue:$0.name) }
    }

    public func contains(_ key: Self.Key) -> Bool                                               {return self.allKeys.contains {$0.stringValue == key.stringValue}}
    public func decodeNil(forKey key: Self.Key) throws -> Bool                                  {return true}
    public func decode(_ type: Bool.Type, forKey key: Self.Key) throws -> Bool                  {return self.decoder.decode(key) {self.parseBool($0)}}
    public func decode(_ type: String.Type, forKey key: Self.Key) throws -> String              {return self.decoder.decode(key) {$0}}
    public func decode(_ type: Double.Type, forKey key: Self.Key) throws -> Double              {fatalError()}
    public func decode(_ type: Float.Type, forKey key: Self.Key) throws -> Float                {fatalError()}
    public func decode(_ type: Int.Type, forKey key: Self.Key) throws -> Int                    {fatalError()}
    public func decode(_ type: Int8.Type, forKey key: Self.Key) throws -> Int8                  {fatalError()}
    public func decode(_ type: Int16.Type, forKey key: Self.Key) throws -> Int16                {fatalError()}
    public func decode(_ type: Int32.Type, forKey key: Self.Key) throws -> Int32                {fatalError()}
    public func decode(_ type: Int64.Type, forKey key: Self.Key) throws -> Int64                {fatalError()}
    public func decode(_ type: UInt.Type, forKey key: Self.Key) throws -> UInt                  {fatalError()}
    public func decode(_ type: UInt8.Type, forKey key: Self.Key) throws -> UInt8                {fatalError()}
    public func decode(_ type: UInt16.Type, forKey key: Self.Key) throws -> UInt16              {fatalError()}
    public func decode(_ type: UInt32.Type, forKey key: Self.Key) throws -> UInt32              {fatalError()}
    public func decode(_ type: UInt64.Type, forKey key: Self.Key) throws -> UInt64              {fatalError()}
    public func decode<T:Decodable>(_ type: T.Type, forKey key: Self.Key) throws -> T {
        if type == URL.self {
            return self.decoder.decode(key) {URL(string:$0) as? T}
        } else if type == Date.self {
            return self.decoder.decode(key) {Self.DATE_FORMATTER.date(from:$0) as? T}
        } else {
            // If type is an array, it will ask the decoder for an unkeyedContainer. We need to set up the state for the decoder so it knows what to give as the unkeyedContainer.
            self.decoder.pushKey(key); defer {let _ = self.decoder.popKey()}
            return try type.init(from:self.decoder);
        }
    }
    /*
    public func decodeIfPresent(_ type: Bool.Type, forKey key: Self.Key) throws -> Bool?        {fatalError()}
    public func decodeIfPresent(_ type: String.Type, forKey key: Self.Key) throws -> String?    {fatalError()}
    public func decodeIfPresent(_ type: Double.Type, forKey key: Self.Key) throws -> Double?    {fatalError()}
    public func decodeIfPresent(_ type: Float.Type, forKey key: Self.Key) throws -> Float?      {fatalError()}
    public func decodeIfPresent(_ type: Int.Type, forKey key: Self.Key) throws -> Int?          {fatalError()}
    public func decodeIfPresent(_ type: Int8.Type, forKey key: Self.Key) throws -> Int8?        {fatalError()}
    public func decodeIfPresent(_ type: Int16.Type, forKey key: Self.Key) throws -> Int16?      {fatalError()}
    public func decodeIfPresent(_ type: Int32.Type, forKey key: Self.Key) throws -> Int32?      {fatalError()}
    public func decodeIfPresent(_ type: Int64.Type, forKey key: Self.Key) throws -> Int64?      {fatalError()}
    public func decodeIfPresent(_ type: UInt.Type, forKey key: Self.Key) throws -> UInt?        {fatalError()}
    public func decodeIfPresent(_ type: UInt8.Type, forKey key: Self.Key) throws -> UInt8?      {fatalError()}
    public func decodeIfPresent(_ type: UInt16.Type, forKey key: Self.Key) throws -> UInt16?    {fatalError()}
    public func decodeIfPresent(_ type: UInt32.Type, forKey key: Self.Key) throws -> UInt32?    {fatalError()}
    public func decodeIfPresent(_ type: UInt64.Type, forKey key: Self.Key) throws -> UInt64?    {fatalError()}
    public func decodeIfPresent<T>(_ type: T.Type, forKey key: Self.Key) throws
        -> T? where T : Decodable                                                               {fatalError()}
     */
    public func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Self.Key) throws
        -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey                        {fatalError()}
    public func nestedUnkeyedContainer(forKey key: Self.Key) throws -> UnkeyedDecodingContainer {fatalError()}
    public func superDecoder() throws -> Decoder                                                {fatalError()}
    public func superDecoder(forKey key: Self.Key) throws -> Decoder                            {fatalError()}
    
    private func parseBool(_ val:String) -> Bool? {
        if  val.hasPrefix("T") || val.hasPrefix("t") ||
            val.hasPrefix("Y") || val.hasPrefix("y")
        {
            return true
        }
        return false
    }
    
}

public struct XMLUnkeyedContainer : UnkeyedDecodingContainer {
    
    private let values: [Decodable]?
    
    init(codingPath:[CodingKey], values:[Decodable]?) {
        self.codingPath = codingPath;
        self.values = values
        if values == nil {
            self.isAtEnd = true
        }
    }
    
    // MARK: UnkeyedDecodingContainer Protocol
    public var codingPath: [CodingKey]
    public var count:Int? {values?.count}
    public var isAtEnd: Bool = false
    public var currentIndex: Int = 0
        
    public mutating func decodeNil() throws -> Bool                      {fatalError()}
    public mutating func decode(_ type: Bool.Type) throws -> Bool        {fatalError()}
    public mutating func decode(_ type: String.Type) throws -> String    {fatalError()}
    public mutating func decode(_ type: Double.Type) throws -> Double    {fatalError()}
    public mutating func decode(_ type: Float.Type) throws -> Float      {fatalError()}
    public mutating func decode(_ type: Int.Type) throws -> Int          {fatalError()}
    public mutating func decode(_ type: Int8.Type) throws -> Int8        {fatalError()}
    public mutating func decode(_ type: Int16.Type) throws -> Int16      {fatalError()}
    public mutating func decode(_ type: Int32.Type) throws -> Int32      {fatalError()}
    public mutating func decode(_ type: Int64.Type) throws -> Int64      {fatalError()}
    public mutating func decode(_ type: UInt.Type) throws -> UInt        {fatalError()}
    public mutating func decode(_ type: UInt8.Type) throws -> UInt8      {fatalError()}
    public mutating func decode(_ type: UInt16.Type) throws -> UInt16    {fatalError()}
    public mutating func decode(_ type: UInt32.Type) throws -> UInt32    {fatalError()}
    public mutating func decode(_ type: UInt64.Type) throws -> UInt64    {fatalError()}
    public mutating func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        if  let values = self.values,
            let value = values[self.currentIndex] as? T
        {
            self.currentIndex += 1
            if self.currentIndex >= values.count {
                self.isAtEnd = true
            }
            return value
        } else {
            fatalError("Could not decode:\(type) at:\(self.currentIndex)");
        }
    }
    public mutating func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws
        -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {fatalError()}
    public mutating func nestedUnkeyedContainer() throws
        -> UnkeyedDecodingContainer                                      {fatalError()}
    public mutating func superDecoder() throws -> Decoder                {fatalError()}
}

public struct XMLSingleValueContainer : SingleValueDecodingContainer {
    public var codingPath: [CodingKey]
    
    public func decodeNil() -> Bool                                       {fatalError()}
    public func decode(_ type: Bool.Type) throws -> Bool                  {fatalError()}
    public func decode(_ type: String.Type) throws -> String              {fatalError()}
    public func decode(_ type: Double.Type) throws -> Double              {fatalError()}
    public func decode(_ type: Float.Type) throws -> Float                {fatalError()}
    public func decode(_ type: Int.Type) throws -> Int                    {fatalError()}
    public func decode(_ type: Int8.Type) throws -> Int8                  {fatalError()}
    public func decode(_ type: Int16.Type) throws -> Int16                {fatalError()}
    public func decode(_ type: Int32.Type) throws -> Int32                {fatalError()}
    public func decode(_ type: Int64.Type) throws -> Int64                {fatalError()}
    public func decode(_ type: UInt.Type) throws -> UInt                  {fatalError()}
    public func decode(_ type: UInt8.Type) throws -> UInt8                {fatalError()}
    public func decode(_ type: UInt16.Type) throws -> UInt16              {fatalError()}
    public func decode(_ type: UInt32.Type) throws -> UInt32              {fatalError()}
    public func decode(_ type: UInt64.Type) throws -> UInt64              {fatalError()}
    public func decode<T>(_ type: T.Type) throws -> T where T : Decodable {fatalError()}
}
