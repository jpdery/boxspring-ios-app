//
//  BSScriptView.h
//  BoxSpringApp
//
//  Created by Jean-Philippe Déry on 2013-03-07.
//  Copyright (c) 2013 Jean-Philippe Déry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JavaScriptCore/JavaScriptCore.h>

@class BSBinding;

@interface BSScriptView : UIView

@property(nonatomic, readonly) JSGlobalContextRef jsGlobalContext;
@property(nonatomic, readonly) JSObjectRef jsGlobalObject;
@property(nonatomic, readonly) JSValueRef jsUndefinedValue;
@property(nonatomic, readonly) JSValueRef jsNullValue;
@property(nonatomic, readonly, copy) NSMutableDictionary* primeConstructors;
@property(nonatomic, readonly, copy) NSMutableDictionary* boundConstructors;
@property(nonatomic, readonly, copy) NSMutableArray* boundInstances;
@property(nonatomic, readonly, copy) NSDictionary* bindings;

/**
 * Load and evaluate a script at a specified path within the app folder
 *
 * @param  source The file to evaluate
 * @return void
 *
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1
 */
- (void)loadScript:(NSString*)source;

/**
 * Execute a string of javascript
 *
 * @param  string The string to evaluate
 * @return void
 *
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1
 */
- (void)evalString:(NSString*)string;

/**
 * Log an exception to the console
 *
 * @param  jsException The javascript exception object.
 * @return void
 *
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1
 */
- (void)log:(JSValueRef)jsException;

/**
 * Binds a binding instance to a given key of the global object
 *
 * @param  binding The binding instance
 * @param  key The key of the global object used to store the binding
 * @return void
 *
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1
 */
- (void)bind:(BSBinding*)binding toKey:(NSString*)key;

/**
 * Binds a binding instance to a given key of a specified object
 *
 * @param  binding The binding instance
 * @param  key The key of the specified object used to store the binding
 * @param  jsObject The javascript object the binding will be assigned to
 * @return void
 *
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1
 */
- (void)bind:(BSBinding*)binding toKey:(NSString*)key ofObject:(JSObjectRef)jsObject;

/**
 * Called when an javascript class object is defined using boxspring.define
 *
 * @param  jsObject The javascript object that has been defined
 * @param  name The name of the javascript class object
 * @return void
 *
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1
 */
- (void)didDefineObject:(JSObjectRef)jsObject name:(NSString*)name;

/**
 * Called when a javascript class object is called as a function
 *
 * @param  jsObject The javascript object that has been called
 * @param  name The name of the javascript class object
 * @param  argc The ammount of arguments given to the function
 * @param  argv The values of each arguments
 * @return The object the function returns
 *
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1
 */
- (JSObjectRef)didCallObjectAsFunction:(JSObjectRef)jsObject name:(NSString*)name argc:(size_t)argc argv:(const JSValueRef[])argv;

/**
 * Called when a javascript class object is called as a constructor using the 
 * new keyword
 *
 * @param  jsObject The javascript object that has been called
 * @param  name The name of the javascript class object
 * @param  argc The ammount of arguments given to the function
 * @param  argv The values of each arguments
 * @return The object the function returns
 *
 * @author Jean-Philippe Dery (jeanphilippe.dery@gmail.com)
 * @since  0.0.1
 */
- (JSObjectRef)didCallObjectAsConstructor:(JSObjectRef)jsObject name:(NSString*)name argc:(size_t)argc argv:(const JSValueRef[])argv;

@end
