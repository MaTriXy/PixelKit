//
//  Uniform.swift
//  PixelKit
//
//  Created by Hexagons on 2019-10-01.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import LiveValues

public class MetalUniform {
    public var name: String
    public var value: LiveFloat
    public init(name: String, value: LiveFloat = 0.0) {
        self.name = name
        self.value = value
    }
}
