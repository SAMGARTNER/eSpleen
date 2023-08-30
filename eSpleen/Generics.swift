//
//  Generics.swift
//  CryptoSwift
//
//  Created by Marcin Krzyzanowski on 02/09/14.
//  Copyright (c) 2014 Marcin Krzyzanowski. All rights reserved.
//

import Foundation


/** array of bytes, little-endian representation */
func arrayOfBytes<T>(_ value:T, length:Int? = nil) -> [UInt8] {
    let totalBytes = length ?? (MemoryLayout.size(ofValue: value) * 8)
    //var v = value
    
    let valuePointer = UnsafeMutablePointer<T>.allocate(capacity: 1)
    valuePointer.pointee = value
    
    let bytesPointer = UnsafeMutablePointer<UInt8>(OpaquePointer(valuePointer)) //era byte, swift 1.3 lo cambio
    var bytes = [UInt8](repeating: 0, count: totalBytes)
    for j in 0..<min(MemoryLayout<T>.size,totalBytes) {
        bytes[totalBytes - 1 - j] = (bytesPointer + j).pointee
    }
    
    valuePointer.deinitialize(count:1)
    valuePointer.deallocate()
    
    return bytes
}

