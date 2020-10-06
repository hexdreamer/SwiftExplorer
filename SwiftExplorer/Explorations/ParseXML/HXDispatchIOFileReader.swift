//
//  HXDispatchIOFileReader.swift
//  SwiftExplorer
//
//  Created by Kenny Leung on 10/1/20.
//  Copyright © 2020 Kenny Leung. All rights reserved.
//

import Foundation

public struct HXDispatchIOFileReader {
    private let dispatchIO:DispatchIO
    private let dataAvailable:(Data)->Void
    private let completion:()->Void

    init?(file:URL,
          dataAvailable:@escaping (Data)->Void,
          completion:@escaping ()->Void
    ) {
        self.dataAvailable = dataAvailable
        self.completion = completion
        
        let x:DispatchIO? = file.withUnsafeFileSystemRepresentation {
            guard let filePath = $0 else {
                print("Could not convert file to fileSystemRepresentation")
                return nil
            }
            return DispatchIO(type:.stream, path:filePath, oflag:O_RDONLY, mode:0, queue:DispatchQueue.global(qos:.background), cleanupHandler:{err in});
        }
        // Above expression too complex to include in an if-let
        guard let fileIO:DispatchIO = x else {
            print("Could not create dispatchIO for file \(file)")
            return nil;
        }
        
        self.dispatchIO = fileIO
        // APFS block size is 4K
        dispatchIO.read(offset:0, length:4*1024, queue:DispatchQueue.global(qos:.background), ioHandler:self._fileIOCallback);
    }
    
    private func _fileIOCallback(done:Bool, data:DispatchData?, error:Int32) {
        if let data = data, data.count > 0 {
            self.dataAvailable(data as Any as! NSData as Data)
            self.dispatchIO.read(offset:0, length:4*1024, queue:DispatchQueue.global(qos:.background), ioHandler:self._fileIOCallback);
        } else {
            self.completion()
        }
    }
    
}
