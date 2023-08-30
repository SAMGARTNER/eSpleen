//
//  CryptoHash.swift
//  CryptoSwift
//
//  Created by Marcin Krzyzanowski on 07/08/14.
//  Copyright (c) 2014 Marcin Krzyzanowski. All rights reserved.
//

import Foundation

public enum Hash {
    case md5(Data)
    
    public func calculate() -> Data? {
        switch self {
        case .md5(let data):
            return MD5(data).calculate()
        }
    }
}
