//
//  ConvertPIX.swift
//  Pixels
//
//  Created by Anton Heestand on 2019-04-25.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import CoreGraphics

public class ConvertPIX: PIXSingleEffect {
    
    override open var shader: String { return "effectSingleConvertPIX" }
    
    // MARK: - Public Properties
    
    public enum ConvertMode: String, CaseIterable {
        case domeToEquirectangular
        case equirectangularToDome
        case squareToCircle
        case circleToSquare
        var index: Int {
            switch self {
            case .domeToEquirectangular: return 0
            case .equirectangularToDome: return 1
            case .squareToCircle: return 2
            case .circleToSquare: return 3
            }
        }
    }
    public var mode: ConvertMode = .domeToEquirectangular
    
    // MARK: - Property Helpers
    
    public override var uniforms: [CGFloat] {
        return [CGFloat(mode.index)]
    }
    
}
