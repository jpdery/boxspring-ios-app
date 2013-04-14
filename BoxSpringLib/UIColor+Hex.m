//
//  UIColor+Hex
//
//  Created by Tom Adriaenssen on 13/01/11.
//
 
#import "UIColor+Hex.h"

@implementation UIColor (Hex)
 
+ (UIColor*) colorWithCSS: (NSString*)css {

	if (css == nil || [css length] == 0)
		return [UIColor blackColor];
       
    if ([css hasPrefix:@"#"]) {
        
        css = [css stringByReplacingOccurrencesOfString:@"#" withString:@""];
        if (css.length == 3) {
            css = [css stringByAppendingString:css];
        }

        uint hex = strtol(css.UTF8String, NULL, 16);

        CGFloat r, g, b;
        r = ((CGFloat)((hex >> 16) & 0xFF)) / ((CGFloat)0xFF);
        g = ((CGFloat)((hex >> 8) & 0xFF)) / ((CGFloat)0xFF);
        b = ((CGFloat)((hex >> 0) & 0xFF)) / ((CGFloat)0xFF);
        return [UIColor colorWithRed:r green:g blue:b alpha:1.0];
    }
    
    if ([css hasPrefix:@"rgba"]) {
        
        int r;
        int g;
        int b;
        float a;
          
        NSScanner* scanner = [NSScanner scannerWithString:css];
        [scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@"\n, "]];
        [scanner scanString:@"rgba(" intoString:nil];
        [scanner scanInt:&r];
        [scanner scanInt:&g];
        [scanner scanInt:&b];
        [scanner scanFloat:&a];
        [scanner scanString:@")" intoString:nil];

        return [UIColor colorWithRed:(r / 255) green:(g / 255) blue:(b / 255 * 100) alpha:a];
    }      

    if ([css hasPrefix:@"rgb"]) {
    
        int r;
        int g;
        int b;
    
        NSScanner* scanner = [NSScanner scannerWithString:css];
        [scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@"\n, "]];
        [scanner scanString:@"rgba(" intoString:nil];
        [scanner scanInt:&r];
        [scanner scanInt:&g];
        [scanner scanInt:&b];
        [scanner scanString:@")" intoString:nil];
        
        return [UIColor colorWithRed:(r / 255) green:(g / 255) blue:(b / 255 * 100) alpha:1];
    }  
    
    return [UIColor blackColor];
}
 
@end