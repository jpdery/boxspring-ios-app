//
//  BGContextBinding.h
//  BoxSpringApp
//
//  Created by Jean-Philippe Déry on 2013-03-20.
//  Copyright (c) 2013 Jean-Philippe Déry. All rights reserved.
//

#import <JavaScriptCore/JavaScriptCore.h>
#import "NSString+JavaScriptCore.h"
#import "NSData+JavaScriptCore.h"

#import "BSBinding.h"

@interface BSContextBinding : BSBinding

@property (nonatomic) CGContextRef context;

/*
 * Colors, Styles, and Shadows
 */

- (void)setFillStyle:(JSContextRef)jsContext value:(JSValueRef)jsValue;
- (JSValueRef)getFillStyle:(JSContextRef)jsContext;
- (void)setStrokeStyle:(JSContextRef)jsContext value:(JSValueRef)jsValue;
- (JSValueRef)getStrokeStyle:(JSContextRef)jsContext;
- (void)setShadowColor:(JSContextRef)jsContext value:(JSValueRef)jsValue;
- (JSValueRef)getShadowColor:(JSContextRef)jsContext;
- (void)setShadowBlur:(JSContextRef)jsContext value:(JSValueRef)jsValue;
- (JSValueRef)getShadowBlur:(JSContextRef)jsContext;
- (void)setShadowOffsetX:(JSContextRef)jsContext value:(JSValueRef)jsValue;
- (JSValueRef)getShadowOffsetX:(JSContextRef)jsContext;
- (void)setShadowOffsetY:(JSContextRef)jsContext value:(JSValueRef)jsValue;
- (JSValueRef)getShadowOffsetY:(JSContextRef)jsContext;

/*
 * Line Styles
 */

- (void)setLineCap:(JSContextRef)jsContext value:(JSValueRef)jsValue;
- (JSValueRef)getLineCap:(JSContextRef)jsContext;
- (void)setLineJoin:(JSContextRef)jsContext value:(JSValueRef)jsValue;
- (JSValueRef)getLineJoin:(JSContextRef)jsContext;
- (void)setLineWidth:(JSContextRef)jsContext value:(JSValueRef)jsValue;
- (JSValueRef)getLineWidth:(JSContextRef)jsContext;
- (void)setMiterLimit:(JSContextRef)jsContext value:(JSValueRef)jsValue;
- (JSValueRef)getMiterLimit:(JSContextRef)jsContext;

/*
 * Gradients
 */

- (JSValueRef)createLinearGradient:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv;
- (JSValueRef)createPattern:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv;
- (JSValueRef)createRadialGradient:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv;
- (JSValueRef)addColorStop:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv;

/*
 * Rectangles
 */

- (JSValueRef)rect:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv;
- (JSValueRef)fillRect:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv;
- (JSValueRef)strokeRect:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv;
- (JSValueRef)clearRect:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv;
/*
 * Paths
 */

- (JSValueRef)fill:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv;
- (JSValueRef)stroke:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv;
- (JSValueRef)beginPath:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv;
- (JSValueRef)moveTo:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv;
- (JSValueRef)closePath:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv;
- (JSValueRef)lineTo:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv;
- (JSValueRef)clip:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv;
- (JSValueRef)quadraticCurveTo:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv;
- (JSValueRef)bezierCurveTo:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv;
- (JSValueRef)arc:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv;
- (JSValueRef)arcTo:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv;
- (JSValueRef)isPointInPath:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv;

/*
 * Transformations
 */

- (JSValueRef)scale:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv;
- (JSValueRef)rotate:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv;
- (JSValueRef)translate:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv;
- (JSValueRef)transform:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv;
- (JSValueRef)setTransform:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv;

/*
 * Text
 */

- (void)setFont:(JSContextRef)jsContext value:(JSValueRef)jsValue;
- (JSValueRef)getFont:(JSContextRef)jsContext;
- (void)setTextAlign:(JSContextRef)jsContext value:(JSValueRef)jsValue;
- (JSValueRef)getTextAlign:(JSContextRef)jsContext;
- (void)setTextBaseline:(JSContextRef)jsContext value:(JSValueRef)jsValue;
- (JSValueRef)getTextBaseline:(JSContextRef)jsContext;

- (JSValueRef)fillText:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv;
- (JSValueRef)strokeText:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv;
- (JSValueRef)measureText:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv;

/*
 * Image Drawing
 */

- (JSValueRef)drawImage:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv;

/*
 * Pixel Manipulation
 */

- (JSValueRef)createImageData:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv;
- (JSValueRef)getImageData:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv;
- (JSValueRef)putImageData:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv;

/*
 * Compositing
 */

- (void)setGlobalAlpha:(JSContextRef)jsContext value:(JSValueRef)jsValue;
- (JSValueRef)getGlobalAplha:(JSContextRef)jsContext;
- (void)setGlobalCompositeOperation:(JSContextRef)jsContext value:(JSValueRef)jsValue;
- (JSValueRef)getGlobalCompositeOperation:(JSContextRef)jsContext;

/*
 * Other
 */

- (JSValueRef)save:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv;
- (JSValueRef)restore:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv;

@end
