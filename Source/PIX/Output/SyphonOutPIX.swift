//
//  SyphonOutPIX.swift
//  Pixels
//
//  Created by Hexagons on 2019-04-28.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import AppKit
import Metal

public class SyphonOutPIX: PIXOutput {

    var context: NSOpenGLContext!
    var surface: IOSurfaceRef!
    var server: SyphonServer!
    
    // MARK: - Life Cycle
    
    override public init() {
        super.init()
        setup()
    }
    
    func setup() {
        let glPFAttributes: [NSOpenGLPixelFormatAttribute] = [
            UInt32(NSOpenGLPFAAccelerated),
            UInt32(NSOpenGLPFADoubleBuffer),
            UInt32(NSOpenGLPFAColorSize), UInt32(24),
            UInt32(NSOpenGLPFAAlphaSize), UInt32(8),
            UInt32(NSOpenGLPFAMultisample),
            UInt32(NSOpenGLPFASampleBuffers), UInt32(1),
            UInt32(NSOpenGLPFASamples), UInt32(4),
            UInt32(NSOpenGLPFAMinimumPolicy),
            UInt32(0)
        ]
        let format = NSOpenGLPixelFormat(attributes: glPFAttributes)!
        context = NSOpenGLContext(format: format, share: nil)
        server = SyphonServer(name: "Pixels", context: context.cglContextObj, options: nil)!
    }
    
    public override func didRender(texture: MTLTexture, force: Bool = false) {
        super.didRender(texture: texture, force: force)
        stream(texture: texture)
    }
    
    func stream(texture: MTLTexture) {
        if let newSurface = texture.iosurface {
            if surface != nil { IOSurfaceDecrementUseCount(surface!) }
            
            surface = newSurface
            IOSurfaceIncrementUseCount(surface)
            
            let size = NSSize(width: IOSurfaceGetWidth(surface), height: IOSurfaceGetHeight(surface))
            print("Texture with \(size)")
            
            context.makeCurrentContext()
            
            glEnable(GLenum(GL_TEXTURE_RECTANGLE))
            
            var glTexture = GLuint()
            glGenTextures(1, &glTexture)
            
            glBindTexture(GLenum(GL_TEXTURE_RECTANGLE), glTexture)
            let clErr = CGLTexImageIOSurface2D(context.cglContextObj!, GLenum(GL_TEXTURE_RECTANGLE), GLenum(GL_RGBA), GLsizei(size.width), GLsizei(size.height), GLenum(GL_BGRA), GLenum(GL_UNSIGNED_INT_8_8_8_8_REV), surface!, 0)
            guard Int(clErr.rawValue) == 0 else {
                print("clErr:", clErr)
                return
            }
            server.publishFrameTexture(glTexture,
                                       textureTarget: GLenum(GL_TEXTURE_RECTANGLE),
                                       imageRegion: NSRect(origin: CGPoint(x: 0, y: 0), size: size),
                                       textureDimensions: size,
                                       flipped: false)
            
            context.flushBuffer()
        }
    }
    
    public override func destroy() {
        super.destroy()
        server.stop()
    }
    
}
