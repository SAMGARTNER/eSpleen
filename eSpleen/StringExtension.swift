//
//  StringExtension.swift
//  CryptoSwift
//
//  Created by Marcin Krzyzanowski on 15/08/14.
//  Copyright (c) 2014 Marcin Krzyzanowski. All rights reserved.
//

import Foundation

/** String extension */
extension String {
    
    /** Calculate MD5 hash */
    public func md5() -> String? {
        return self.data(using: String.Encoding.utf8, allowLossyConversion: false)?.md5()?.toHexString()
    }

}
