//
//  LiveValue.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-11-26.
//  Open Source - MIT License
//

import Foundation

public protocol LiveValue {
    
    var name: String? { get }
    
    var type: Any.Type { get }
    
    var uniformIsNew: Bool { get }
    
}
