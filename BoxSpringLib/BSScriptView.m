//
//  BSScriptView.m
//  BoxSpringApp
//
//  Created by Jean-Philippe Déry on 2013-03-07.
//  Copyright (c) 2013 Jean-Philippe Déry. All rights reserved.
//

#import "BSBinding.h"
#import "BSConsoleBinding.h"
#import "NSString+JavaScriptCoreString.h"

@implementation BSScriptView

@synthesize context;
@synthesize undefined;
@synthesize bindings;

/**
 * Initialize the script view
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1
 */
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        context = JSGlobalContextCreate(NULL);
		undefined = JSValueMakeUndefined(context);
		JSValueProtect(context, undefined);        
     
        
        BSConsoleBinding* consoleBinding = [[BSConsoleBinding alloc] initWithScriptView:self];
        [self addGlobalObject:@"console" usingBinding:consoleBinding withPrivateData:consoleBinding];
        [consoleBinding release];
    }
    return self;
}

- (void)loadScriptFromFile:(NSString *)file
{
    NSString* path = [NSString stringWithFormat:@"%@/App/%@", [[NSBundle mainBundle] resourcePath], file];
    
    NSString *script = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
	
	if( !script ) {
		NSLog(@"Error: Can't Find Script %@", path );
		return;
	}
	
	NSLog(@"Loading Script: %@", path );
	JSStringRef scriptJS = JSStringCreateWithCFString((CFStringRef)script);
	JSStringRef pathJS = JSStringCreateWithCFString((CFStringRef)path);
	
	JSValueRef exception = NULL;
	JSEvaluateScript(context, scriptJS, NULL, pathJS, 0, &exception );

    if (exception) {
    
    	JSStringRef jsLinePropertyName = JSStringCreateWithUTF8CString("line");
        JSStringRef jsFilePropertyName = JSStringCreateWithUTF8CString("sourceURL");
	
        JSObjectRef exObject = JSValueToObject( context, exception, NULL );
        JSValueRef line = JSObjectGetProperty( context, exObject, jsLinePropertyName, NULL );
        JSValueRef file = JSObjectGetProperty( context, exObject, jsFilePropertyName, NULL );
        
        NSLog(
            @"%@ at line %@ in %@",
            [NSString stringWithJSValue:exception fromContext:context],
            [NSString stringWithJSValue:line fromContext:context],
            [NSString stringWithJSValue:file fromContext:context]
         );
        
        JSStringRelease( jsLinePropertyName );
        JSStringRelease( jsFilePropertyName );
    
    }

	   
	JSStringRelease( scriptJS );
	JSStringRelease( pathJS );    
}

/**
 * Add an object of the given class to the global object.
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1
 */
- (void)addGlobalObject:(NSString*)objectName usingClass:(JSClassRef)objectClass withPrivateData:(void*)privateData
{
    // create a new object of the given class
    JSObjectRef jsObject = JSObjectMake(self.context, objectClass, privateData);
    if (jsObject != NULL) {
    
        // protect the object from being garbage collected
        JSValueProtect(self.context, jsObject);
        
        // convert the object name to a javascript string
        JSStringRef jsObjectName = [objectName jsStringValue];
        if (jsObjectName != NULL) {
        
            // add the object as a property of the global object
            JSObjectSetProperty(self.context, JSContextGetGlobalObject(self.context), jsObjectName, jsObject, kJSPropertyAttributeReadOnly, NULL);
            
            // release the reference to the name
            JSStringRelease(jsObjectName);
        }        
    }
}

- (void)addGlobalObject:(NSString*)objectName usingBinding:(BSBinding *)objectBinding withPrivateData:(void*)privateData
{
    [objectBinding retain];
    [self addGlobalObject:objectName usingClass:[self createJSClass:objectBinding.class] withPrivateData:privateData];
}

- (JSClassRef)createJSClass:(id)class
{
    NSMutableArray* functions = [[NSMutableArray alloc] init];
    NSMutableArray* properties = [[NSMutableArray alloc] init];
    
    Class base = BSBinding.class;
    for (Class superclass = class; superclass != base && [base isSubclassOfClass:base]; superclass = superclass.superclass) {
        u_int count;
        Method* methods = class_copyMethodList(object_getClass(superclass), &count);
        for (int i = 0; i < count; i++) {
            SEL selector = method_getName(methods[i]);
            NSString *name = NSStringFromSelector(selector);
			if ([name hasPrefix:@"_ptr_to_func_"] ) {
				[functions addObject: [name substringFromIndex:sizeof("_ptr_to_func_")-1] ];
			}
			else if( [name hasPrefix:@"_ptr_to_get_"] ) {
				// We only look for getters - a property that has a setter, but no getter will be ignored
				[properties addObject: [name substringFromIndex:sizeof("_ptr_to_get_")-1] ];
			}            
        }
        free(methods);
    }
    
    JSStaticValue *jsStaticValues = calloc(properties.count + 1, sizeof(JSStaticValue));
    for (int i = 0; i < properties.count; i++) {

        NSString* name = properties[i];        
        jsStaticValues[i].name = name.UTF8String;
        jsStaticValues[i].attributes = kJSPropertyAttributeDontDelete;
        
		SEL get = NSSelectorFromString([@"_ptr_to_get_" stringByAppendingString:name]);
		jsStaticValues[i].getProperty = (JSObjectGetPropertyCallback)[class performSelector:get];
        
		SEL set = NSSelectorFromString([@"_ptr_to_set_" stringByAppendingString:name]);
		if( [class respondsToSelector:set] ) {
			jsStaticValues[i].setProperty = (JSObjectSetPropertyCallback)[class performSelector:set];
		}
		else {
			jsStaticValues[i].attributes |= kJSPropertyAttributeReadOnly;
		}        
    }
    
   	JSStaticFunction* jsStaticFunctions = calloc(functions.count + 1, sizeof(JSStaticFunction));
	for( int i = 0; i < functions.count; i++ ) {

		NSString *name = functions[i];
		jsStaticFunctions[i].name = name.UTF8String;
		jsStaticFunctions[i].attributes = kJSPropertyAttributeDontDelete;
		
		SEL call = NSSelectorFromString([@"_ptr_to_func_" stringByAppendingString:name]);
		jsStaticFunctions[i].callAsFunction = (JSObjectCallAsFunctionCallback)[class performSelector:call];
	}
	
	JSClassDefinition jsClassDef = kJSClassDefinitionEmpty;
	jsClassDef.className = class_getName(class) + sizeof("BSBinding") - 1;
	//jsClassDef.finalize = EJBindingBaseFinalize;
	jsClassDef.staticValues = jsStaticValues;
	jsClassDef.staticFunctions = jsStaticFunctions;
    JSClassRef jsClass = JSClassCreate(&jsClassDef);
	
	free(jsStaticValues);
	free(jsStaticFunctions);
	
	[functions release];
	[properties release];
	
	return jsClass;
    
}

@end
