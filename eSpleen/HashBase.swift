//
//  Hash.swift
//  CryptoSwift
//
//  Created by Marcin Krzyzanowski on 17/08/14.
//  Copyright (c) 2014 Marcin Krzyzanowski. All rights reserved.
//

import Foundation

class HashBase {
    
    var message: Data
    
    init(_ message: Data) {
        self.message = message
    }
    
    /** Common part for hash calculation. Prepare header data. */
    func prepare(_ len:Int = 64) -> NSMutableData {
        let tmpMessage: NSMutableData = (NSMutableData(data: self.message as Data) as NSMutableData)
        
        // Step 1. Append Padding Bits
        tmpMessage.appendBytes([0x80]) // append one bit (UInt8 with one bit) to message
        
        // append "0" bit until message length in bits ≡ 448 (mod 512)
        var msgLength = tmpMessage.length;
        var counter = 0;
        while msgLength % len != (len - 8) {
            counter += 1
            msgLength += 1
        }
        //var bufZeros = UnsafeMutablePointer<UInt8>(calloc(UInt(counter), UInt(sizeof(UInt8))))
        let bufZeros = UnsafeMutableRawPointer(calloc(counter, Int(MemoryLayout<UInt8>.size)))
        tmpMessage.append(bufZeros!, length: counter)
        
        return tmpMessage
    }
}
