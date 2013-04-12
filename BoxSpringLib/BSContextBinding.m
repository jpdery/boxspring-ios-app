//
//  BGContextBinding.m
//  BoxSpringApp
//
//  Created by Jean-Philippe Déry on 2013-03-20.
//  Copyright (c) 2013 Jean-Philippe Déry. All rights reserved.
//

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
    NSString* color = [NSString stringWithJSString:JSValueToStringCopy(jsContext, jsValue, NULL)];
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
- (void)setStrokeStyle:(JSContextRef)jsContext value:(JSValueRef)jsValue
{

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
- (void)setShadowColor:(JSContextRef)jsContext value:(JSValueRef)jsValue
{

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
- (void)setShadowBlur:(JSContextRef)jsContext value:(JSValueRef)jsValue
{

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
- (void)setShadowOffsetX:(JSContextRef)jsContext value:(JSValueRef)jsValue
{

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
- (void)setShadowOffsetY:(JSContextRef)jsContext value:(JSValueRef)jsValue
{

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
- (void)setLineJoin:(JSContextRef)jsContext value:(JSValueRef)jsValue
{

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
- (void)setLineWidth:(JSContextRef)jsContext value:(JSValueRef)jsValue
{

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
- (void)setMiterLimit:(JSContextRef)jsContext value:(JSValueRef)jsValue
{

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
    return NULL;
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
    return NULL;
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
- (void)setGlobalCompositeOperation:(JSContextRef)jsContext value:(JSValueRef)jsValue
{

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
    return NULL;
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
    return NULL;
}

@end
