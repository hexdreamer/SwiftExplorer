
import Foundation

public class XMLDecoder : NSObject,Decoder,XMLParserDelegate {
    
    private var level:Int = 0
    private var stack = [Decodable]()
    private var text:String?
    
    init(codingPath:[CodingKey]) {
        self.codingPath = codingPath;
        self.userInfo = [CodingUserInfoKey : Any]()
        super.init()
    }
    
    // MARK: Decoder
    
    public var codingPath: [CodingKey]
    public var userInfo: [CodingUserInfoKey : Any]
    
    public func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        fatalError()
    }
    
    public func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        fatalError()
    }
    
    public func singleValueContainer() throws -> SingleValueDecodingContainer {
        fatalError()
    }
    
    // MARK: XMLParserDelegate
    public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
    }
    
    public func parser(_ parser: XMLParser, foundCharacters string: String) {
        
    }

    public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
    }

}

public struct XMLKeyedContainer<T:CodingKey> : KeyedDecodingContainerProtocol {
    public typealias Key = T

    public var codingPath = [CodingKey]()
    public var allKeys = [T]()

    public func contains(_ key: Self.Key) -> Bool                                               {fatalError()}
    public func decodeNil(forKey key: Self.Key) throws -> Bool                                  {fatalError()}
    public func decode(_ type: Bool.Type, forKey key: Self.Key) throws -> Bool                  {fatalError()}
    public func decode(_ type: String.Type, forKey key: Self.Key) throws -> String              {fatalError()}
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
    public func decode<T>(_ type: T.Type, forKey key: Self.Key) throws -> T where T : Decodable {fatalError()}
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
    public func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Self.Key) throws
        -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey                        {fatalError()}
    public func nestedUnkeyedContainer(forKey key: Self.Key) throws -> UnkeyedDecodingContainer {fatalError()}
    public func superDecoder() throws -> Decoder                                                {fatalError()}
    public func superDecoder(forKey key: Self.Key) throws -> Decoder                            {fatalError()}
}

public struct XMLUnkeyedContainer : UnkeyedDecodingContainer {
    public var codingPath: [CodingKey]
    public var count: Int?
    public var isAtEnd: Bool
    public var currentIndex: Int
        
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
    public mutating func decode<T>(_ type: T.Type) throws
        -> T where T : Decodable                                         {fatalError()}
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

