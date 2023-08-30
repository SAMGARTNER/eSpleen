//
//  PGPDataExtension.swift
//  SwiftPGP
//
//  Created by Marcin Krzyzanowski on 05/07/14.
//  Copyright (c) 2014 Marcin Krzyzanowski. All rights reserved.
//

import Foundation

extension NSMutableData {
    
    /** Convenient way to append bytes */
    internal func appendBytes(_ aByteArray: [UInt8]) {
        self.append(aByteArray, length: aByteArray.count)
    }
    
}

extension Data {
    
    public func md5() -> Data? {
        return Hash.md5(self).calculate()
    }
}

extension Data {

    
    func toHexString() -> String {
        let count = self.count / MemoryLayout<UInt8>.size
        var bytesArray = [UInt8](repeating: 0, count: count)
        (self as NSData).getBytes(&bytesArray, length:count * MemoryLayout<UInt8>.size)
        
        var s:String = "";
        for byte in bytesArray {
            s = s + (NSString(format:"%02X", byte) as String)
        }
        return s;
    }
    

    
}
