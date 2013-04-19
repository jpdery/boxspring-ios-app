//
//  BGContextBinding.m
//  BoxSpringApp
//
//  Created by Jean-Philippe Déry on 2013-03-20.
//  Copyright (c) 2013 Jean-Philippe Déry. All rights reserved.
//

#import "BSCoreImageBinding.h"
#import "BSContextBinding.h"

@implementation BSContextBinding

@synthesize context;

/*
 * Deallocation
 */

- (void)dealloc
{
    if (context) CGContextRelease(context);
    [super dealloc];
}

/*
 * Colors, Styles, and Shadows
 */

BS_DEFINE_BOUND_SETTER(fillStyle, setFillStyle)
BS_DEFINE_BOUND_GETTER(fillStyle, getFillStyle)
BS_DEFINE_BOUND_SETTER(strokeStyle, setStrokeStyle)
BS_DEFINE_BOUND_GETTER(strokeStyle, getStrokeStyle)
BS_DEFINE_BOUND_SETTER(shadowColor, setShadowColor)
BS_DEFINE_BOUND_GETTER(shadowColor, getShadowColor)
BS_DEFINE_BOUND_SETTER(shadowBlur, setShadowBlur)
BS_DEFINE_BOUND_GETTER(shadowBlur, getShadowBlur)
BS_DEFINE_BOUND_SETTER(shadowOffsetX, setShadowOffsetX)
BS_DEFINE_BOUND_GETTER(shadowOffsetX, getShadowOffsetX)
BS_DEFINE_BOUND_SETTER(shadowOffsetY, setShadowOffsetY)
BS_DEFINE_BOUND_GETTER(shadowOffsetY, getShadowOffsetY)

/**
 * Bound Method
 *
 * The fillStyle property sets or returns the color, gradient, or pattern used 
 * to fill the drawing.
 *
 * @type color    A CSS color value that indicates the fill color of the drawing. Default value is #000000
 *       gradient A gradient object (linear or radial) used to fill the drawing
 *       pattern  A pattern object to use to fill the drawing
 *
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1
 */
- (void)setFillStyle:(JSContextRef)jsContext value:(JSValueRef)jsValue
{
    jsFillStyle = jsValue;
    CGContextSetFillColorWithColor(self.context, JSValueToCGColor(jsContext, jsFillStyle));
}

/**
 * Bound Method
 *
 * DESCRIPTION
 *
 * ARGUMENTS
 *
 * RETURN
 *
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1
 */
- (JSValueRef)getFillStyle:(JSContextRef)jsContext
{
    return jsFillStyle;
}

/**
 * Bound Method
 *
 * DESCRIPTION
 *
 * ARGUMENTS
 *
 * RETURN
 *
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1
 */
- (void)setStrokeStyle:(JSContextRef)jsContext value:(JSValueRef)jsValue
{
    jsStrokeStyle = jsValue;
    CGContextSetStrokeColorWithColor(self.context, JSValueToCGColor(jsContext, jsStrokeStyle));
}

/**
 * Bound Method
 *
 * DESCRIPTION
 *
 * ARGUMENTS
 *
 * RETURN
 *
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1
 */
- (JSValueRef)getStrokeStyle:(JSContextRef)jsContext
{
    return jsStrokeStyle;
}

/**
 * Bound Method
 *
 * DESCRIPTION
 *
 * ARGUMENTS
 *
 * RETURN
 *
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1
 */
- (void)setShadowColor:(JSContextRef)jsContext value:(JSValueRef)jsValue
{
    jsShadowColor = jsValue;
    shadowColor = JSValueToCGColor(jsContext, jsShadowColor);
    [self applyShadow];  
}

/**
 * Bound Method
 *
 * DESCRIPTION
 *
 * ARGUMENTS
 *
 * RETURN
 *
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1
 */
- (JSValueRef)getShadowColor:(JSContextRef)jsContext
{
    return jsShadowColor;
}

/**
 * Bound Method
 *
 * DESCRIPTION
 *
 * ARGUMENTS
 *
 * RETURN
 *
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1
 */
- (void)setShadowBlur:(JSContextRef)jsContext value:(JSValueRef)jsValue
{
    jsShadowBlur = jsValue;
    shadowBlur = JSValueToNumber(jsContext, jsShadowBlur, NULL);
    [self applyShadow];
}

/**
 * Bound Method
 *
 * DESCRIPTION
 *
 * ARGUMENTS
 *
 * RETURN
 *
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1
 */
- (JSValueRef)getShadowBlur:(JSContextRef)jsContext
{
    return jsShadowBlur;
}

/**
 * Bound Method
 *
 * DESCRIPTION
 *
 * ARGUMENTS
 *
 * RETURN
 *
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1
 */
- (void)setShadowOffsetX:(JSContextRef)jsContext value:(JSValueRef)jsValue
{
    jsShadowOffsetX = jsValue;
    shadowOffsetX = JSValueToNumber(jsContext, jsShadowOffsetX, NULL);
    [self applyShadow];
}

/**
 * Bound Method
 *
 * DESCRIPTION
 *
 * ARGUMENTS
 *
 * RETURN
 *
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1
 */
- (JSValueRef)getShadowOffsetX:(JSContextRef)jsContext
{
    return jsShadowOffsetX;
}

/**
 * Bound Method
 *
 * DESCRIPTION
 *
 * ARGUMENTS
 *
 * RETURN
 *
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1
 */
- (void)setShadowOffsetY:(JSContextRef)jsContext value:(JSValueRef)jsValue
{
    jsShadowOffsetY = jsValue;
    shadowOffsetY = JSValueToNumber(jsContext, jsShadowOffsetY, NULL);
    [self applyShadow];
}

/**
 * Bound Method
 *
 * DESCRIPTION
 *
 * ARGUMENTS
 *
 * RETURN
 *
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1
 */
- (JSValueRef)getShadowOffsetY:(JSContextRef)jsContext
{
    return NULL;
}

- (void)applyShadow
{
    CGContextSetShadowWithColor(self.context, CGSizeMake(shadowOffsetX, shadowOffsetY), shadowBlur, shadowColor);
}

/*
 * Line Styles
 */

BS_DEFINE_BOUND_SETTER(lineCap, setLineCap)
BS_DEFINE_BOUND_GETTER(lineCap, getLineCap)
BS_DEFINE_BOUND_SETTER(lineJoin, setLineJoin)
BS_DEFINE_BOUND_GETTER(lineJoin, getLineJoin)
BS_DEFINE_BOUND_SETTER(lineWidth, setLineWidth)
BS_DEFINE_BOUND_GETTER(lineWidth, getLineWidth)
BS_DEFINE_BOUND_SETTER(miterLimit, setMiterLimit)
BS_DEFINE_BOUND_GETTER(miterLimit, getMiterLimit)

/**
 * Bound Method
 *
 * DESCRIPTION
 *
 * ARGUMENTS
 *
 * RETURN
 *
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1
 */
- (void)setLineCap:(JSContextRef)jsContext value:(JSValueRef)jsValue
{
    jsLineCap = jsValue;
    
    NSString* lineCap = [JSValueToNSString(jsContext, jsLineCap) lowercaseString];
    if ([lineCap isEqualToString:@"butt"]) {
        CGContextSetLineCap(self.context, kCGLineCapButt);
    } else if ([lineCap isEqualToString:@"round"]) {
        CGContextSetLineCap(self.context, kCGLineCapRound);
    } else if ([lineCap isEqualToString:@"square"]) {
        CGContextSetLineCap(self.context, kCGLineCapSquare);
    }
}

/**
 * Bound Method
 *
 * DESCRIPTION
 *
 * ARGUMENTS
 *
 * RETURN
 *
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1
 */
- (JSValueRef)getLineCap:(JSContextRef)jsContext
{
    return jsLineCap;
}

/**
 * Bound Method
 *
 * DESCRIPTION
 *
 * ARGUMENTS
 *
 * RETURN
 *
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1
 */
- (void)setLineJoin:(JSContextRef)jsContext value:(JSValueRef)jsValue
{
    jsLineJoin = jsValue;
    NSString* lineJoin = [JSValueToNSString(jsContext, jsLineJoin) lowercaseString];
    if ([lineJoin isEqualToString:@"miter"]) {
        CGContextSetLineJoin(self.context, kCGLineJoinMiter);
    } else if ([lineJoin isEqualToString:@"round"]) {
        CGContextSetLineJoin(self.context, kCGLineJoinRound);
    } else if ([lineJoin isEqualToString:@"bevel"]) {
        CGContextSetLineJoin(self.context, kCGLineJoinBevel);
    }    
}

/**
 * Bound Method
 *
 * DESCRIPTION
 *
 * ARGUMENTS
 *
 * RETURN
 *
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1
 */
- (JSValueRef)getLineJoin:(JSContextRef)jsContext
{
    return jsLineJoin;
}

/**
 * Bound Method
 *
 * DESCRIPTION
 *
 * ARGUMENTS
 *
 * RETURN
 *
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1
 */
- (void)setLineWidth:(JSContextRef)jsContext value:(JSValueRef)jsValue
{
    jsLineWidth = jsValue;
    CGContextSetLineWidth(self.context, JSValueToNumber(jsContext, jsLineWidth, NULL));
}

/**
 * Bound Method
 *
 * DESCRIPTION
 *
 * ARGUMENTS
 *
 * RETURN
 *
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1
 */
- (JSValueRef)getLineWidth:(JSContextRef)jsContext
{
    return jsLineWidth;
}

/**
 * Bound Method
 *
 * DESCRIPTION
 *
 * ARGUMENTS
 *
 * RETURN
 *
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1
 */
- (void)setMiterLimit:(JSContextRef)jsContext value:(JSValueRef)jsValue
{
    jsMiterLimit = jsValue;
    CGContextSetMiterLimit(self.context, JSValueToNumber(jsContext, jsMiterLimit, NULL));
}

/**
 * Bound Method
 *
 * DESCRIPTION
 *
 * ARGUMENTS
 *
 * RETURN
 *
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1
 */
- (JSValueRef)getMiterLimit:(JSContextRef)jsContext
{
    return jsMiterLimit;
}

/*
 * Gradients
 */

BS_DEFINE_BOUND_FUNCTION(createLinearGradient, createLinearGradient)
BS_DEFINE_BOUND_FUNCTION(createPattern, createPattern)
BS_DEFINE_BOUND_FUNCTION(createRadialGradient, createRadialGradient)
BS_DEFINE_BOUND_FUNCTION(addColorStop, addColorStop)

/**
 * Bound Method
 *
 * DESCRIPTION
 *
 * ARGUMENTS
 *
 * RETURN
 *
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1
 */
- (JSValueRef)createLinearGradient:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv
{
    NSLog(@"Method '' has not yet been implemented");
    return NULL;
}

/**
 * Bound Method
 *
 * DESCRIPTION
 *
 * ARGUMENTS
 *
 * RETURN
 *
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1
 */
- (JSValueRef)createPattern:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv
{
    NSLog(@"Method '' has not yet been implemented");
    return NULL;
}

/**
 * Bound Method
 *
 * DESCRIPTION
 *
 * ARGUMENTS
 *
 * RETURN
 *
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1
 */
- (JSValueRef)createRadialGradient:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv
{
    NSLog(@"Method '' has not yet been implemented");
    return NULL;
}

/**
 * Bound Method
 *
 * DESCRIPTION
 *
 * ARGUMENTS
 *
 * RETURN
 *
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1
 */
- (JSValueRef)addColorStop:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv
{
    NSLog(@"Method '' has not yet been implemented");
    return NULL;
}

/*
 * Rectangles
 */

BS_DEFINE_BOUND_FUNCTION(rect, rect)
BS_DEFINE_BOUND_FUNCTION(fillRect, fillRect)
BS_DEFINE_BOUND_FUNCTION(strokeRect, strokeRect)
BS_DEFINE_BOUND_FUNCTION(clearRect, clearRect)

/**
 * Bound Method
 *
 * DESCRIPTION
 *
 * ARGUMENTS
 *
 * RETURN
 *
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1
 */
- (JSValueRef)rect:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv
{
    double x = JSValueToNumber(jsContext, argv[0], NULL);
    double y = JSValueToNumber(jsContext, argv[1], NULL);
    double w = JSValueToNumber(jsContext, argv[2], NULL);
    double h = JSValueToNumber(jsContext, argv[3], NULL);
    CGContextAddRect(self.context, CGRectMake(x, y, w, h));
    return NULL;
}

/**
 * Bound Method
 *
 * DESCRIPTION
 *
 * ARGUMENTS
 *
 * RETURN
 *
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1
 */
- (JSValueRef)fillRect:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv
{
    double x = JSValueToNumber(jsContext, argv[0], NULL);
    double y = JSValueToNumber(jsContext, argv[1], NULL);
    double w = JSValueToNumber(jsContext, argv[2], NULL);
    double h = JSValueToNumber(jsContext, argv[3], NULL);
    CGContextFillRect(self.context, CGRectMake(x, y, w, h));
    return NULL;
}

/**
 * Bound Method
 *
 * DESCRIPTION
 *
 * ARGUMENTS
 *
 * RETURN
 *
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1
 */
- (JSValueRef)strokeRect:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv
{
    double x = JSValueToNumber(jsContext, argv[0], NULL);
    double y = JSValueToNumber(jsContext, argv[1], NULL);
    double w = JSValueToNumber(jsContext, argv[2], NULL);
    double h = JSValueToNumber(jsContext, argv[3], NULL);
    CGContextAddRect(self.context, CGRectMake(x, y, w, h));
    CGContextStrokePath(self.context);
    return NULL;
}

/**
 * Bound Method
 *
 * DESCRIPTION
 *
 * ARGUMENTS
 *
 * RETURN
 *
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1
 */
- (JSValueRef)clearRect:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv
{
    double x = JSValueToNumber(jsContext, argv[0], NULL);
    double y = JSValueToNumber(jsContext, argv[1], NULL);
    double w = JSValueToNumber(jsContext, argv[2], NULL);
    double h = JSValueToNumber(jsContext, argv[3], NULL);
    CGContextClearRect(self.context, CGRectMake(x, y, w, h));
    return NULL;
}

/*
 * Paths
 */

BS_DEFINE_BOUND_FUNCTION(fill, fill)
BS_DEFINE_BOUND_FUNCTION(stroke, stroke)
BS_DEFINE_BOUND_FUNCTION(beginPath, beginPath)
BS_DEFINE_BOUND_FUNCTION(moveTo, moveTo)
BS_DEFINE_BOUND_FUNCTION(closePath, closePath)
BS_DEFINE_BOUND_FUNCTION(lineTo, lineTo)
BS_DEFINE_BOUND_FUNCTION(clip, clip)
BS_DEFINE_BOUND_FUNCTION(quadraticCurveTo, quadraticCurveTo)
BS_DEFINE_BOUND_FUNCTION(bezierCurveTo, bezierCurveTo)
BS_DEFINE_BOUND_FUNCTION(arc, arc)
BS_DEFINE_BOUND_FUNCTION(arcTo, arcTo)
BS_DEFINE_BOUND_FUNCTION(isPointInPath, isPointInPath)

/**
 * Bound Method
 *
 * DESCRIPTION
 *
 * ARGUMENTS
 *
 * RETURN
 *
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1
 */
- (JSValueRef)fill:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv
{
    CGContextFillPath(self.context);
    return NULL;
}

/**
 * Bound Method
 *
 * DESCRIPTION
 *
 * ARGUMENTS
 *
 * RETURN
 *
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1
 */
- (JSValueRef)stroke:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv
{
    CGContextStrokePath(self.context);
    return NULL;
}

/**
 * Bound Method
 *
 * DESCRIPTION
 *
 * ARGUMENTS
 *
 * RETURN
 *
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1
 */
- (JSValueRef)beginPath:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv
{
    CGContextBeginPath(self.context);
    return NULL;
}

/**
 * Bound Method
 *
 * DESCRIPTION
 *
 * ARGUMENTS
 *
 * RETURN
 *
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1
 */
- (JSValueRef)moveTo:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv
{
    double x = JSValueToNumber(jsContext, argv[0], NULL);
    double y = JSValueToNumber(jsContext, argv[1], NULL);
    CGContextMoveToPoint(self.context, x, y);
    return NULL;
}

/**
 * Bound Method
 *
 * DESCRIPTION
 *
 * ARGUMENTS
 *
 * RETURN
 *
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1
 */
- (JSValueRef)closePath:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv
{
    CGContextClosePath(self.context);
    return NULL;
}

/**
 * Bound Method
 *
 * DESCRIPTION
 *
 * ARGUMENTS
 *
 * RETURN
 *
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1
 */
- (JSValueRef)lineTo:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv
{
    double x = JSValueToNumber(jsContext, argv[0], NULL);
    double y = JSValueToNumber(jsContext, argv[1], NULL);
    CGContextAddLineToPoint(self.context, x, y);
    return NULL;
}

/**
 * Bound Method
 *
 * DESCRIPTION
 *
 * ARGUMENTS
 *
 * RETURN
 *
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1
 */
- (JSValueRef)clip:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv
{
    double x = JSValueToNumber(jsContext, argv[0], NULL);
    double y = JSValueToNumber(jsContext, argv[1], NULL);
    double w = JSValueToNumber(jsContext, argv[2], NULL);
    double h = JSValueToNumber(jsContext, argv[3], NULL);
    CGContextClipToRect(self.context, CGRectMake(x, y, w, h));
    return NULL;
}

/**
 * Bound Method
 *
 * DESCRIPTION
 *
 * ARGUMENTS
 *
 * RETURN
 *
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1
 */
- (JSValueRef)quadraticCurveTo:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv
{
    double cpx = JSValueToNumber(jsContext, argv[0], NULL);
    double cpy = JSValueToNumber(jsContext, argv[1], NULL);
    double x = JSValueToNumber(jsContext, argv[2], NULL);
    double y = JSValueToNumber(jsContext, argv[3], NULL);
    CGContextAddQuadCurveToPoint(self.context, cpx, cpy, x, y);
    return NULL;
}

/**
 * Bound Method
 *
 * DESCRIPTION
 *
 * ARGUMENTS
 *
 * RETURN
 *
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1
 */
- (JSValueRef)bezierCurveTo:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv
{
    double cp1x = JSValueToNumber(jsContext, argv[0], NULL);
    double cp1y = JSValueToNumber(jsContext, argv[1], NULL);
    double cp2x = JSValueToNumber(jsContext, argv[2], NULL);
    double cp2y = JSValueToNumber(jsContext, argv[3], NULL);
    double x = JSValueToNumber(jsContext, argv[4], NULL);
    double y = JSValueToNumber(jsContext, argv[5], NULL);
    CGContextAddCurveToPoint(self.context, cp1x, cp1y, cp2x, cp2y, x, y);
    return NULL;
}

/**
 * Bound Method
 *
 * DESCRIPTION
 *
 * ARGUMENTS
 *
 * RETURN
 *
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1
 */
- (JSValueRef)arc:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv
{
    double x = JSValueToNumber(jsContext, argv[0], NULL);
    double y = JSValueToNumber(jsContext, argv[1], NULL);
    double r = JSValueToNumber(jsContext, argv[2], NULL);
    double sa = JSValueToNumber(jsContext, argv[3], NULL);
    double ea = JSValueToNumber(jsContext, argv[4], NULL);
    int acw = JSValueToNumber(jsContext, argv[5], NULL);
    CGContextAddArc(self.context, x, y, r, sa, ea, acw);
    return NULL;
}

/**
 * Bound Method
 *
 * DESCRIPTION
 *
 * ARGUMENTS
 *
 * RETURN
 *
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1
 */
- (JSValueRef)arcTo:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv
{
    double x1 = JSValueToNumber(jsContext, argv[0], NULL);
    double y1 = JSValueToNumber(jsContext, argv[1], NULL);
    double x2 = JSValueToNumber(jsContext, argv[2], NULL);
    double y2 = JSValueToNumber(jsContext, argv[3], NULL);
    double r = JSValueToNumber(jsContext, argv[4], NULL);
    CGContextAddArcToPoint(self.context, x1, y1, x2, y2, r);
    return NULL;
}

/**
 * Bound Method
 *
 * DESCRIPTION
 *
 * ARGUMENTS
 *
 * RETURN
 *
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1
 */
- (JSValueRef)isPointInPath:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv
{
    double x = JSValueToNumber(jsContext, argv[0], NULL);
    double y = JSValueToNumber(jsContext, argv[1], NULL);
    return JSValueMakeBoolean(jsContext, CGContextPathContainsPoint(self.context, CGPointMake(x, y), kCGPathFill));
}

/*
 * Transformations
 */

BS_DEFINE_BOUND_FUNCTION(scale, scale)
BS_DEFINE_BOUND_FUNCTION(rotate, rotate)
BS_DEFINE_BOUND_FUNCTION(translate, translate)
BS_DEFINE_BOUND_FUNCTION(transform, transform)
BS_DEFINE_BOUND_FUNCTION(setTransform, setTransform)

/**
 * Bound Method
 *
 * DESCRIPTION
 *
 * ARGUMENTS
 *
 * RETURN
 *
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1
 */
- (JSValueRef)scale:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv
{
    double x = JSValueToNumber(jsContext, argv[0], NULL);
    double y = JSValueToNumber(jsContext, argv[1], NULL);
    CGContextScaleCTM(self.context, x, y);
    return NULL;
}

/**
 * Bound Method
 *
 * DESCRIPTION
 *
 * ARGUMENTS
 *
 * RETURN
 *
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1
 */
- (JSValueRef)rotate:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv
{
    double a = JSValueToNumber(jsContext, argv[0], NULL);
    CGContextRotateCTM(self.context, a);
    return NULL;
}

/**
 * Bound Method
 *
 * DESCRIPTION
 *
 * ARGUMENTS
 *
 * RETURN
 *
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1
 */
- (JSValueRef)translate:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv
{
    double x = JSValueToNumber(jsContext, argv[0], NULL);
    double y = JSValueToNumber(jsContext, argv[1], NULL);
    CGContextTranslateCTM(self.context, x, y);
    return NULL;
}

/**
 * Bound Method
 *
 * DESCRIPTION
 *
 * ARGUMENTS
 *
 * RETURN
 *
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1
 */
- (JSValueRef)transform:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv
{
    CGAffineTransform transform;
    transform.a = JSValueToNumber(jsContext, argv[0], NULL);
    transform.b = JSValueToNumber(jsContext, argv[1], NULL);
    transform.c = JSValueToNumber(jsContext, argv[2], NULL);
    transform.d = JSValueToNumber(jsContext, argv[3], NULL);
    transform.tx = JSValueToNumber(jsContext, argv[4], NULL);
    transform.ty = JSValueToNumber(jsContext, argv[5], NULL);
    CGContextConcatCTM(self.context, transform);
    return NULL;
}

/**
 * Bound Method
 *
 * DESCRIPTION
 *
 * ARGUMENTS
 *
 * RETURN
 *
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1
 */
- (JSValueRef)setTransform:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv
{
    CGAffineTransform transform;
    transform.a = JSValueToNumber(jsContext, argv[0], NULL);
    transform.b = JSValueToNumber(jsContext, argv[1], NULL);
    transform.c = JSValueToNumber(jsContext, argv[2], NULL);
    transform.d = JSValueToNumber(jsContext, argv[3], NULL);
    transform.tx = JSValueToNumber(jsContext, argv[4], NULL);
    transform.ty = JSValueToNumber(jsContext, argv[5], NULL);
    CGAffineTransform current = CGContextGetCTM(self.context);
    CGAffineTransform invert = CGAffineTransformInvert(current);
    CGContextConcatCTM(self.context, invert);
    CGContextConcatCTM(self.context, transform);
    return NULL;
}

/*
 * Text
 */

BS_DEFINE_BOUND_SETTER(font, setFont)
BS_DEFINE_BOUND_GETTER(font, getFont)
BS_DEFINE_BOUND_SETTER(textAlign, setTextAlign)
BS_DEFINE_BOUND_GETTER(textAlign, getTextAlign)
BS_DEFINE_BOUND_SETTER(textBaseline, setTextBaseline)
BS_DEFINE_BOUND_GETTER(textBaseline, getTextBaseline)

BS_DEFINE_BOUND_FUNCTION(fillText, fillText)
BS_DEFINE_BOUND_FUNCTION(strokeText, strokeText)
BS_DEFINE_BOUND_FUNCTION(measureText, measureText)

/**
 * Bound Method
 *
 * DESCRIPTION
 *
 * ARGUMENTS
 *
 * RETURN
 *
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1
 */
- (void)setFont:(JSContextRef)jsContext value:(JSValueRef)jsValue
{
    NSLog(@"Property 'font' has not yet been implemented");
}

/**
 * Bound Method
 *
 * DESCRIPTION
 *
 * ARGUMENTS
 *
 * RETURN
 *
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1
 */
- (JSValueRef)getFont:(JSContextRef)jsContext
{
    NSLog(@"Property 'font' has not yet been implemented");
    return NULL;
}

/**
 * Bound Method
 *
 * DESCRIPTION
 *
 * ARGUMENTS
 *
 * RETURN
 *
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1
 */
- (void)setTextAlign:(JSContextRef)jsContext value:(JSValueRef)jsValue
{
    NSLog(@"Property 'textAlign' has not yet been implemented");
}

/**
 * Bound Method
 *
 * DESCRIPTION
 *
 * ARGUMENTS
 *
 * RETURN
 *
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1
 */
- (JSValueRef)getTextAlign:(JSContextRef)jsContext
{
    NSLog(@"Property 'textAlign' has not yet been implemented");
    return NULL;
}

/**
 * Bound Method
 *
 * DESCRIPTION
 *
 * ARGUMENTS
 *
 * RETURN
 *
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1
 */
- (void)setTextBaseline:(JSContextRef)jsContext value:(JSValueRef)jsValue
{
    NSLog(@"Property 'textBaseline' has not yet been implemented");
}

/**
 * Bound Method
 *
 * DESCRIPTION
 *
 * ARGUMENTS
 *
 * RETURN
 *
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1
 */
- (JSValueRef)getTextBaseline:(JSContextRef)jsContext
{
    NSLog(@"Property 'textBaseline' has not yet been implemented");
    return NULL;
}

/**
 * Bound Method
 *
 * DESCRIPTION
 *
 * ARGUMENTS
 *
 * RETURN
 *
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1
 */
- (JSValueRef)fillText:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv
{
    NSLog(@"Method 'fillText' has not yet been implemented");
    return NULL;
}

/**
 * Bound Method
 *
 * DESCRIPTION
 *
 * ARGUMENTS
 *
 * RETURN
 *
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1
 */
- (JSValueRef)strokeText:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv
{
    NSLog(@"Method 'strokeText' has not yet been implemented");
    return NULL;
}

/**
 * Bound Method
 *
 * DESCRIPTION
 *
 * ARGUMENTS
 *
 * RETURN
 *
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1
 */
- (JSValueRef)measureText:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv
{
    NSLog(@"Method 'measureText' has not yet been implemented");
    return NULL;
}

/*
 * Image Drawing
 */

BS_DEFINE_BOUND_FUNCTION(drawImage, drawImage)

/**
 * Bound Method
 *
 * DESCRIPTION
 *
 * ARGUMENTS
 *
 * RETURN
 *
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1
 */
- (JSValueRef)drawImage:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv
{
//    double sx, sy, sw, sh;
    double dx, dy, dw, dh;
    
    JSValueRef jsImage = argv[0];
    
    BSCoreImageBinding* binding = (BSCoreImageBinding*) JSObjectGetBoundObject(jsContext, (JSObjectRef) jsImage);
 
    if (binding.loaded == NO) {
        return NULL;
    }
 
    UIImage* image = binding.image;
    
	if (argc == 3) {
		// drawImage(image, dx, dy)
        dx = JSValueToNumber(jsContext, argv[1], NULL);
        dy = JSValueToNumber(jsContext, argv[2], NULL);

        CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
        CGContextSaveGState(self.context);
        CGContextTranslateCTM(self.context, dx, image.size.height + dy);
        CGContextScaleCTM(self.context, 1.0, -1.0);
        CGContextDrawImage(self.context, rect, image.CGImage);
        CGContextRestoreGState(self.context);
	} else if (argc == 5) {
		// drawImage(image, dx, dy, dw, dh)
        dx = JSValueToNumber(jsContext, argv[1], NULL);
        dy = JSValueToNumber(jsContext, argv[2], NULL);
        dw = JSValueToNumber(jsContext, argv[3], NULL);
        dh = JSValueToNumber(jsContext, argv[3], NULL);
	} else if (argc >= 9) {
		// drawImage(image, sx, sy, sw, sh, dx, dy, dw, dh)
        dx = JSValueToNumber(jsContext, argv[1], NULL);
        dy = JSValueToNumber(jsContext, argv[2], NULL);
        dw = JSValueToNumber(jsContext, argv[3], NULL);
        dh = JSValueToNumber(jsContext, argv[3], NULL);        
	} else {
		return NULL;
	}
	/*
	scriptView.currentRenderingContext = renderingContext;
	[renderingContext drawImage:image sx:sx sy:sy sw:sw sh:sh dx:dx dy:dy dw:dw dh:dh];*/
    return NULL;
}

/*
 * Pixel Manipulation
 */

BS_DEFINE_BOUND_FUNCTION(createImageData, createImageData)
BS_DEFINE_BOUND_FUNCTION(getImageData, getImageData)
BS_DEFINE_BOUND_FUNCTION(putImageData, putImageData)

/**
 * Bound Method
 *
 * DESCRIPTION
 *
 * ARGUMENTS
 *
 * RETURN
 *
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1
 */
- (JSValueRef)createImageData:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv
{
    return NULL;
}

/**
 * Bound Method
 *
 * DESCRIPTION
 *
 * ARGUMENTS
 *
 * RETURN
 *
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1
 */
- (JSValueRef)getImageData:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv
{
    return NULL;
}

/**
 * Bound Method
 *
 * DESCRIPTION
 *
 * ARGUMENTS
 *
 * RETURN
 *
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1
 */
- (JSValueRef)putImageData:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv
{
    return NULL;
}

/*
 * Compositing
 */

BS_DEFINE_BOUND_SETTER(globalAlpha, setGlobalAlpha)
BS_DEFINE_BOUND_GETTER(globalAlpha, getGlobalAplha)
BS_DEFINE_BOUND_SETTER(globalCompositeOperation, setGlobalCompositeOperation)
BS_DEFINE_BOUND_GETTER(globalCompositeOperation, getGlobalCompositeOperation)

/**
 * Bound Method
 *
 * DESCRIPTION
 *
 * ARGUMENTS
 *
 * RETURN
 *
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1
 */
- (void)setGlobalAlpha:(JSContextRef)jsContext value:(JSValueRef)jsValue
{
    jsGlobalAlpha = jsValue;
    CGContextSetAlpha(self.context, JSValueToNumber(jsContext, jsGlobalAlpha, NULL));
}

/**
 * Bound Method
 *
 * DESCRIPTION
 *
 * ARGUMENTS
 *
 * RETURN
 *
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1
 */
- (JSValueRef)getGlobalAplha:(JSContextRef)jsContext
{
    return jsGlobalAlpha;
}

/**
 * Bound Method
 *
 * DESCRIPTION
 *
 * ARGUMENTS
 *
 * RETURN
 *
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1
 */
- (void)setGlobalCompositeOperation:(JSContextRef)jsContext value:(JSValueRef)jsValue
{
    jsGlobalCompositeOperation = jsValue;
    NSString* mode = [JSValueToNSString(jsContext, jsGlobalCompositeOperation) lowercaseString];
    if ([mode isEqualToString:@"source-over"]) {
        CGContextSetBlendMode(self.context, kCGBlendModeNormal);
    } else if ([mode isEqualToString:@"source-in"]) {
        CGContextSetBlendMode(self.context, kCGBlendModeSourceIn);
    } else if ([mode isEqualToString:@"source-out"]) {
        CGContextSetBlendMode(self.context, kCGBlendModeSourceOut);
    } else if ([mode isEqualToString:@"source-atop"]) {
        CGContextSetBlendMode(self.context, kCGBlendModeSourceAtop);
    } else if ([mode isEqualToString:@"destination-over"]) {
        CGContextSetBlendMode(self.context, kCGBlendModeDestinationOver);
    } else if ([mode isEqualToString:@"destination-in"]) {
        CGContextSetBlendMode(self.context, kCGBlendModeDestinationIn);
    } else if ([mode isEqualToString:@"destination-out"]) {
        CGContextSetBlendMode(self.context, kCGBlendModeDestinationOut);
    } else if ([mode isEqualToString:@"destination-atop"]) {
        CGContextSetBlendMode(self.context, kCGBlendModeDestinationAtop);
    } else if ([mode isEqualToString:@"lighter"]) {
        CGContextSetBlendMode(self.context, kCGBlendModeLighten);
    } else if ([mode isEqualToString:@"darker"]) {
        CGContextSetBlendMode(self.context, kCGBlendModeDarken);
    } else if ([mode isEqualToString:@"copy"]) {
        CGContextSetBlendMode(self.context, kCGBlendModeCopy);
    } else if ([mode isEqualToString:@"xor"]) {
        CGContextSetBlendMode(self.context, kCGBlendModeXOR);
    }
}

/**
 * Bound Method
 *
 * DESCRIPTION
 *
 * ARGUMENTS
 *
 * RETURN
 *
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1
 */
- (JSValueRef)getGlobalCompositeOperation:(JSContextRef)jsContext
{
    return jsGlobalCompositeOperation;
}

/*
 * Other
 */

BS_DEFINE_BOUND_FUNCTION(save, save)
BS_DEFINE_BOUND_FUNCTION(restore, restore)

/**
 * Bound Method
 *
 * DESCRIPTION
 *
 * ARGUMENTS
 *
 * RETURN
 *
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1
 */
- (JSValueRef)save:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv
{

//    NSMutableDictionary* state = [NSMutableDictionary new];

/*    JSValueRef jsFillStyle;
    JSValueRef jsStrokeStyle;
    JSValueRef jsShadowColor;
    JSValueRef jsShadowBlur;
    JSValueRef jsShadowOffsetX;
    JSValueRef jsShadowOffsetY;
    JSValueRef jsLineCap;
    JSValueRef jsLineJoin;
    JSValueRef jsLineWidth;
    JSValueRef jsMiterLimit;
    JSValueRef jsGlobalAlpha;
    JSValueRef jsGlobalCompositeOperation;

    CGColorRef shadowColor;
    double shadowBlur;
    double shadowOffsetX;
    double shadowOffsetY;*/

    CGContextSaveGState(self.context);
    return NULL;
}

/**
 * Bound Method
 *
 * DESCRIPTION
 *
 * ARGUMENTS
 *
 * RETURN
 *
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1
 */
- (JSValueRef)restore:(JSContextRef)jsContext argc:(size_t)argc argv:(const JSValueRef [])argv
{
    CGContextRestoreGState(self.context);
    return NULL;
}

@end
