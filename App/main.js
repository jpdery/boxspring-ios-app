(function(modules) {
    var cache = {}, require = function(id) {
        var module = cache[id];
        if (!module) {
            module = cache[id] = {};
            var exports = module.exports = {};
            modules[id].call(exports, require, module, exports, window);
        }
        return module.exports;
    };
    window["boxspring"] = require("0");
})({
    "0": function(require, module, exports, global) {
        "use strict";
        require("1");
        require("n");
        module.exports = boxspring;
    },
    "1": function(require, module, exports, global) {
        "use strict";
        if (global.boxspring === undefined) {
            global.boxspring = {};
        }
        boxspring.version = "0.0.1-dev";
        global.requestAnimationFrame = require("2").request;
        global.cancelAnimationFrame = require("2").cancel;
        boxspring.prime = require("5");
        boxspring.array = require("7");
        boxspring.number = require("8");
        boxspring.object = require("a");
        boxspring.regexp = require("c");
        boxspring.string = require("e");
        boxspring.func = require("g");
        boxspring.date = require("i");
        require("k");
        require("l");
        require("m");
    },
    "2": function(require, module, exports, global) {
        "use strict";
        var array = require("3");
        var requestFrame = global.requestAnimationFrame || global.webkitRequestAnimationFrame || global.mozRequestAnimationFrame || global.oRequestAnimationFrame || global.msRequestAnimationFrame || function(callback) {
            return setTimeout(callback, 1e3 / 60);
        };
        var callbacks = [];
        var iterator = function(time) {
            var split = callbacks.splice(0, callbacks.length);
            for (var i = 0, l = split.length; i < l; i++) split[i](time || (time = +(new Date)));
        };
        var cancel = function(callback) {
            var io = array.indexOf(callbacks, callback);
            if (io > -1) callbacks.splice(io, 1);
        };
        var request = function(callback) {
            var i = callbacks.push(callback);
            if (i === 1) requestFrame(iterator);
            return function() {
                cancel(callback);
            };
        };
        exports.request = request;
        exports.cancel = cancel;
    },
    "3": function(require, module, exports, global) {
        "use strict";
        var array = require("4")["array"];
        var names = ("pop,push,reverse,shift,sort,splice,unshift,concat,join,slice,toString,indexOf,lastIndexOf,forEach,every,some" + ",filter,map,reduce,reduceRight").split(",");
        for (var methods = {}, i = 0, name, method; name = names[i++]; ) if (method = Array.prototype[name]) methods[name] = method;
        if (!methods.filter) methods.filter = function(fn, context) {
            var results = [];
            for (var i = 0, l = this.length >>> 0; i < l; i++) if (i in this) {
                var value = this[i];
                if (fn.call(context, value, i, this)) results.push(value);
            }
            return results;
        };
        if (!methods.indexOf) methods.indexOf = function(item, from) {
            for (var l = this.length >>> 0, i = from < 0 ? Math.max(0, l + from) : from || 0; i < l; i++) {
                if (i in this && this[i] === item) return i;
            }
            return -1;
        };
        if (!methods.map) methods.map = function(fn, context) {
            var length = this.length >>> 0, results = Array(length);
            for (var i = 0, l = length; i < l; i++) {
                if (i in this) results[i] = fn.call(context, this[i], i, this);
            }
            return results;
        };
        if (!methods.every) methods.every = function(fn, context) {
            for (var i = 0, l = this.length >>> 0; i < l; i++) {
                if (i in this && !fn.call(context, this[i], i, this)) return false;
            }
            return true;
        };
        if (!methods.some) methods.some = function(fn, context) {
            for (var i = 0, l = this.length >>> 0; i < l; i++) {
                if (i in this && fn.call(context, this[i], i, this)) return true;
            }
            return false;
        };
        if (!methods.forEach) methods.forEach = function(fn, context) {
            for (var i = 0, l = this.length >>> 0; i < l; i++) {
                if (i in this) fn.call(context, this[i], i, this);
            }
        };
        var toString = Object.prototype.toString;
        array.isArray = Array.isArray || function(self) {
            return toString.call(self) === "[object Array]";
        };
        module.exports = array.implement(methods);
    },
    "4": function(require, module, exports, global) {
        "use strict";
        var prime = require("5"), type = require("6");
        var slice = Array.prototype.slice;
        var ghost = prime({
            constructor: function ghost(self) {
                this.valueOf = function() {
                    return self;
                };
                this.toString = function() {
                    return self + "";
                };
                this.is = function(object) {
                    return self === object;
                };
            }
        });
        var shell = function(self) {
            if (self == null || self instanceof ghost) return self;
            var g = shell[type(self)];
            return g ? new g(self) : self;
        };
        var register = function() {
            var g = prime({
                inherits: ghost
            });
            return prime({
                constructor: function(self) {
                    return new g(self);
                },
                define: function(key, descriptor) {
                    var method = descriptor.value;
                    this[key] = function(self) {
                        return arguments.length > 1 ? method.apply(self, slice.call(arguments, 1)) : method.call(self);
                    };
                    g.prototype[key] = function() {
                        return shell(method.apply(this.valueOf(), arguments));
                    };
                    prime.define(this.prototype, key, descriptor);
                    return this;
                }
            });
        };
        for (var types = "string,number,array,object,date,function,regexp".split(","), i = types.length; i--; ) shell[types[i]] = register();
        module.exports = shell;
    },
    "5": function(require, module, exports, global) {
        "use strict";
        var has = function(self, key) {
            return Object.hasOwnProperty.call(self, key);
        };
        var each = function(object, method, context) {
            for (var key in object) if (method.call(context, object[key], key, object) === false) break;
            return object;
        };
        if (!{
            valueOf: 0
        }.propertyIsEnumerable("valueOf")) {
            var buggy = "constructor,toString,valueOf,hasOwnProperty,isPrototypeOf,propertyIsEnumerable,toLocaleString".split(",");
            var proto = Object.prototype;
            each = function(object, method, context) {
                for (var key in object) if (method.call(context, object[key], key, object) === false) return object;
                for (var i = 0; key = buggy[i]; i++) {
                    var value = object[key];
                    if ((value !== proto[key] || has(object, key)) && method.call(context, value, key, object) === false) break;
                }
                return object;
            };
        }
        var create = Object.create || function(self) {
            var constructor = function() {};
            constructor.prototype = self;
            return new constructor;
        };
        var getOwnPropertyDescriptor = Object.getOwnPropertyDescriptor;
        var define = Object.defineProperty;
        try {
            var obj = {
                a: 1
            };
            getOwnPropertyDescriptor(obj, "a");
            define(obj, "a", {
                value: 2
            });
        } catch (e) {
            getOwnPropertyDescriptor = function(object, key) {
                return {
                    value: object[key]
                };
            };
            define = function(object, key, descriptor) {
                object[key] = descriptor.value;
                return object;
            };
        }
        var implement = function(proto) {
            each(proto, function(value, key) {
                if (key !== "constructor" && key !== "define" && key !== "inherits") this.define(key, getOwnPropertyDescriptor(proto, key) || {
                    writable: true,
                    enumerable: true,
                    configurable: true,
                    value: value
                });
            }, this);
            return this;
        };
        var prime = function(proto) {
            var superprime = proto.inherits;
            var constructor = has(proto, "constructor") ? proto.constructor : superprime ? function() {
                return superprime.apply(this, arguments);
            } : function() {};
            if (superprime) {
                var superproto = superprime.prototype;
                var cproto = constructor.prototype = create(superproto);
                constructor.parent = superproto;
                cproto.constructor = constructor;
            }
            constructor.define = proto.define || superprime && superprime.define || function(key, descriptor) {
                define(this.prototype, key, descriptor);
                return this;
            };
            constructor.implement = implement;
            return constructor.implement(proto);
        };
        prime.has = has;
        prime.each = each;
        prime.create = create;
        prime.define = define;
        module.exports = prime;
    },
    "6": function(require, module, exports, global) {
        "use strict";
        var toString = Object.prototype.toString, types = /number|object|array|string|function|date|regexp|boolean/;
        var type = function(object) {
            if (object == null) return "null";
            var string = toString.call(object).slice(8, -1).toLowerCase();
            if (string === "number" && isNaN(object)) return "null";
            if (types.test(string)) return string;
            return "object";
        };
        module.exports = type;
    },
    "7": function(require, module, exports, global) {
        "use strict";
        var array = require("3");
        module.exports = array.implement({
            set: function(i, value) {
                this[i] = value;
                return this;
            },
            get: function(i) {
                return i in this ? this[i] : null;
            },
            count: function() {
                return this.length;
            },
            each: function(method, context) {
                for (var i = 0, l = this.length; i < l; i++) {
                    if (i in this && method.call(context, this[i], i, this) === false) break;
                }
                return this;
            },
            backwards: function(method, context) {
                for (var i = this.length - 1; i >= 0; i--) {
                    if (i in this && method.call(context, this[i], i, this) === false) break;
                }
                return this;
            },
            index: function(value) {
                var index = array.indexOf(this, value);
                return index === -1 ? null : index;
            },
            remove: function(i) {
                return array.splice(this, i, 1)[0];
            }
        });
    },
    "8": function(require, module, exports, global) {
        "use strict";
        var number = require("9");
        module.exports = number.implement({
            limit: function(min, max) {
                return Math.min(max, Math.max(min, this));
            },
            round: function(precision) {
                precision = Math.pow(10, precision || 0).toFixed(precision < 0 ? -precision : 0);
                return Math.round(this * precision) / precision;
            },
            times: function(fn, context) {
                for (var i = 0; i < this; i++) fn.call(context, i, null, this);
                return this;
            },
            random: function(max) {
                return Math.floor(Math.random() * (max - this + 1) + this);
            }
        });
    },
    "9": function(require, module, exports, global) {
        "use strict";
        var number = require("4")["number"];
        var names = "toExponential,toFixed,toLocaleString,toPrecision,toString,valueOf".split(",");
        for (var methods = {}, i = 0, name, method; name = names[i++]; ) if (method = Number.prototype[name]) methods[name] = method;
        module.exports = number.implement(methods);
    },
    a: function(require, module, exports, global) {
        "use strict";
        var prime = require("5"), object = require("b");
        object.implement({
            set: function(key, value) {
                this[key] = value;
                return this;
            },
            get: function(key) {
                var value = this[key];
                return value != null ? value : null;
            },
            count: function() {
                var length = 0;
                prime.each(this, function() {
                    length++;
                });
                return length;
            },
            each: function(method, context) {
                return prime.each(this, method, context);
            },
            map: function(method, context) {
                var results = {};
                prime.each(this, function(value, key, self) {
                    results[key] = method.call(context, value, key, self);
                });
                return results;
            },
            filter: function(method, context) {
                var results = {};
                prime.each(this, function(value, key, self) {
                    if (method.call(context, value, key, self)) results[key] = value;
                });
                return results;
            },
            every: function(method, context) {
                var every = true;
                prime.each(this, function(value, key, self) {
                    if (!method.call(context, value, key, self)) return every = false;
                });
                return every;
            },
            some: function(method, context) {
                var some = false;
                prime.each(this, function(value, key, self) {
                    if (!some && method.call(context, value, key, self)) return !(some = true);
                });
                return some;
            },
            index: function(value) {
                var key = null;
                prime.each(this, function(match, k) {
                    if (value === match) {
                        key = k;
                        return false;
                    }
                });
                return key;
            },
            remove: function(key) {
                var value = this[key];
                delete this[key];
                return value;
            },
            keys: function() {
                var keys = [];
                prime.each(this, function(value, key) {
                    keys.push(key);
                });
                return keys;
            },
            values: function() {
                var values = [];
                prime.each(this, function(value, key) {
                    values.push(value);
                });
                return values;
            }
        });
        object.each = prime.each;
        if (typeof JSON !== "undefined") object.implement({
            encode: function() {
                return JSON.stringify(this);
            }
        });
        module.exports = object;
    },
    b: function(require, module, exports, global) {
        "use strict";
        var object = require("4")["object"];
        var names = "hasOwnProperty,isPrototypeOf,propertyIsEnumerable,toLocaleString,toString,valueOf".split(",");
        for (var methods = {}, i = 0, name, method; name = names[i++]; ) if (method = Object.prototype[name]) methods[name] = method;
        module.exports = object.implement(methods);
    },
    c: function(require, module, exports, global) {
        "use strict";
        module.exports = require("d");
    },
    d: function(require, module, exports, global) {
        "use strict";
        var regexp = require("4")["regexp"];
        var names = "exec,test,toString".split(",");
        for (var methods = {}, i = 0, name, method; name = names[i++]; ) if (method = RegExp.prototype[name]) methods[name] = method;
        module.exports = regexp.implement(methods);
    },
    e: function(require, module, exports, global) {
        "use strict";
        var string = require("f");
        string.implement({
            clean: function() {
                return string.trim((this + "").replace(/\s+/g, " "));
            },
            camelize: function() {
                return (this + "").replace(/-\D/g, function(match) {
                    return match.charAt(1).toUpperCase();
                });
            },
            hyphenate: function() {
                return (this + "").replace(/[A-Z]/g, function(match) {
                    return "-" + match.toLowerCase();
                });
            },
            capitalize: function() {
                return (this + "").replace(/\b[a-z]/g, function(match) {
                    return match.toUpperCase();
                });
            },
            escape: function() {
                return (this + "").replace(/([-.*+?^${}()|[\]\/\\])/g, "\\$1");
            },
            number: function() {
                return parseFloat(this);
            }
        });
        if (typeof JSON !== "undefined") string.implement({
            decode: function() {
                return JSON.parse(this);
            }
        });
        module.exports = string;
    },
    f: function(require, module, exports, global) {
        "use strict";
        var string = require("4")["string"];
        var names = ("charAt,charCodeAt,concat,contains,endsWith,indexOf,lastIndexOf,localeCompare,match,replace,search,slice,split" + ",startsWith,substr,substring,toLocaleLowerCase,toLocaleUpperCase,toLowerCase,toString,toUpperCase,trim,valueOf").split(",");
        for (var methods = {}, i = 0, name, method; name = names[i++]; ) if (method = String.prototype[name]) methods[name] = method;
        if (!methods.trim) methods.trim = function() {
            return (this + "").replace(/^\s+|\s+$/g, "");
        };
        module.exports = string.implement(methods);
    },
    g: function(require, module, exports, global) {
        "use strict";
        module.exports = require("h");
    },
    h: function(require, module, exports, global) {
        "use strict";
        var function_ = require("4")["function"];
        var names = "apply,bind,call,isGenerator,toString".split(",");
        for (var methods = {}, i = 0, name, method; name = names[i++]; ) if (method = Function.prototype[name]) methods[name] = method;
        module.exports = function_.implement(methods);
    },
    i: function(require, module, exports, global) {
        "use strict";
        module.exports = require("j");
    },
    j: function(require, module, exports, global) {
        "use strict";
        var date = require("4")["date"];
        var names = ("getDate,getDay,getFullYear,getHours,getMilliseconds,getMinutes,getMonth,getSeconds,getTime,getTimezoneOffset" + ",getUTCDate,getUTCDay,getUTCFullYear,getUTCHours,getUTCMilliseconds,getUTCMinutes,getUTCMonth,getUTCSeconds,setDate,setFullYear" + ",setHours,setMilliseconds,setMinutes,setMonth,setSeconds,setTime,setUTCDate,setUTCFullYear,setUTCHours,setUTCMilliseconds" + ",setUTCMinutes,setUTCMonth,setUTCSeconds,toDateString,toISOString,toJSON,toLocaleDateString,toLocaleFormat,toLocaleString" + ",toLocaleTimeString,toString,toTimeString,toUTCString,valueOf").split(",");
        date.now = Date.now || function() {
            return +(new Date);
        };
        for (var methods = {}, i = 0, name, method; name = names[i++]; ) if (method = Date.prototype[name]) methods[name] = method;
        module.exports = date.implement(methods);
    },
    k: function(require, module, exports, global) {
        "use strict";
        var fn = require("h");
        var slice = Array.prototype.slice;
        fn.implement({
            bound: function(thisArg) {
                var args = slice.call(arguments, 1), self = this;
                return function() {
                    return self.apply(thisArg, args.concat(slice.call(arguments)));
                };
            }
        });
        module.exports = fn;
    },
    l: function(require, module, exports, global) {
        "use strict";
        var array = require("3");
        var number = require("8");
        array.implement({
            clean: function() {
                return array.filter(this, function(item) {
                    return item !== null && item !== undefined;
                });
            },
            invoke: function(methodName) {
                var args = array.slice(arguments, 1);
                return array.map(this, function(item) {
                    return item[methodName].apply(item, args);
                });
            },
            associate: function(keys) {
                var obj = {}, length = Math.min(this.length, keys.length);
                for (var i = 0; i < length; i++) obj[keys[i]] = this[i];
                return obj;
            },
            contains: function(item, from) {
                return array.indexOf(this, item, from) != -1;
            },
            append: function(items) {
                this.push.apply(this, items);
                return this;
            },
            last: function() {
                return this.length ? this[this.length - 1] : null;
            },
            random: function() {
                return this.length ? this[number.random(0, this.length - 1)] : null;
            },
            include: function(item) {
                if (!array.contains(this, item)) array.push(this, item);
                return this;
            },
            combine: function(items) {
                for (var i = 0, l = items.length; i < l; i++) array.include(this, items[i]);
                return this;
            },
            empty: function() {
                this.length = 0;
                return this;
            },
            pick: function() {
                for (var i = 0, l = this.length; i < l; i++) {
                    if (this[i] !== null && this[i] !== undefined) return this[i];
                }
                return null;
            },
            find: function(fn, context) {
                for (var i = 0, l = this.length; i < l; i++) {
                    var item = this[i];
                    if (fn.call(context, item, i, this)) return item;
                }
                return null;
            }
        });
        module.exports = array;
    },
    m: function(require, module, exports, global) {
        "use strict";
        var prime = boxspring.prime;
        var array = boxspring.array;
        var string = boxspring.string;
        var object = boxspring.object;
        if (global.__classes__ === undefined) global.__classes__ = {};
        boxspring.define = function(name, prototype) {
            prototype.__kind__ = name;
            if (prototype.inherits === undefined) {
                prototype.inherits = __classes__["boxspring.Object"];
            } else if (typeof prototype.inherits === "string") {
                prototype.inherits = __classes__[prototype.inherits];
            }
            __classes__[name] = prime(prototype);
            assign(name, __classes__[name]);
            return __classes__[name];
        };
        boxspring.implement = function(name, key, val) {
            var klass = classes[name];
            if (klass === null) {
                throw new Error("Class " + name + " does not exists, cannot implement");
            }
            prime.implement(klass, key, val);
            return this;
        };
        var assign = function(key, val, obj) {
            if (!obj) obj = global;
            var nodes = array.isArray(key) ? key : key.split(".");
            if (nodes.length === 1) {
                obj[key] = val;
                return;
            }
            var node = array.shift(nodes);
            assign(nodes, val, obj[node] || (obj[node] = {}));
        };
    },
    n: function(require, module, exports, global) {
        "use strict";
        require("1");
        var object = boxspring.object;
        var array = boxspring.array;
        var func = boxspring.func;
        boxspring.define("boxspring.Object", {
            inherits: null,
            __afterListeners: null,
            __beforeListeners: null,
            constructor: function() {
                console.log("boxspring.Object Constructor Called");
                var inits = this.__propertyInits;
                for (var i = 0, l = inits.length; i < l; i++) {
                    inits[i].call(this);
                }
                if (this.__bound_constructor) {
                    this.__bound_constructor.apply(this, arguments);
                }
                return this;
            },
            destroy: function() {
                if (this.__bound_destroy) {
                    this.__bound_destroy.apply(this, arguments);
                }
                return this;
            },
            addPropertyChangeListener: function(property, listener, before) {
                var listeners = before ? this.__beforeListeners || (this.__beforeListeners = {}) : this.__afterListeners || (this.__afterListeners = {});
                var events = listeners[property];
                if (events === undefined) {
                    events = listeners[property] = [];
                }
                if (array.index(events, listener) === null) array.push(events, listener);
                return this;
            },
            removePropertyChangeListener: function(property, listener, before) {
                var listeners = before ? this.__beforeListeners || (this.__beforeListeners = {}) : this.__afterListeners || (this.__afterListeners = {});
                var events = listeners[property];
                if (events === undefined) return this;
                array.remove(events, listener);
                return this;
            },
            removePropertyChangeListeners: function(property, before) {
                var listeners = before ? this.__beforeListeners || (this.__beforeListeners = {}) : this.__afterListeners || (this.__afterListeners = {});
                if (property) {
                    var events = listeners[property];
                    if (events) array.empty(events);
                    return this;
                }
                if (before) {
                    this.__beforeListeners = {};
                } else {
                    this.__afterListeners = {};
                }
                return this;
            },
            dispatchPropertyChangeEvent: function(property, newValue, oldValue, before) {
                var listeners = before ? this.__beforeListeners : this.__afterListeners;
                if (listeners === null) return this;
                var events = listeners[property];
                if (events) {
                    for (var i = 0, l = events.length; i < l; i++) events[i].call(this, newValue, oldValue, property);
                }
                return this;
            },
            bound: function(name) {
                var bound = this._bound || (this._bound = {});
                return bound[name] || (bound[name] = func.bound(this[name], this));
            },
            define: function(key, description) {
                var value = description.value;
                if (key === "statics") {
                    object.each(value, function(func, property) {
                        if (property !== "constructor" || property !== "inherits" || property !== "define") {
                            this[property] = func;
                        }
                    }, this);
                    return;
                }
                if (key === "mixins") {}
                if (key === "properties") {
                    if (!this.prototype.__propertyInits) this.prototype.__propertyInits = [];
                    var parent = this.parent;
                    object.each(value, function(descriptor, property) {
                        this.prototype.__propertyInits.push(function() {
                            init.call(this, property, descriptor);
                        });
                        if (parent) {
                            var parentDescriptor = Object.getOwnPropertyDescriptor(parent.constructor.prototype, property);
                            if (parentDescriptor) {
                                parent[property] = {
                                    set: parentDescriptor.set,
                                    get: parentDescriptor.get
                                };
                            }
                        }
                        Object.defineProperty(this.prototype, property, {
                            set: function(newValue) {
                                if (descriptor.readonly) throw new Error("Property " + property + " is read-only");
                                var bind = bound.call(this, property, descriptor);
                                var oldValue = this[bind];
                                var curValue = setterCallback.call(this, descriptor, newValue, oldValue);
                                if (curValue === undefined) {
                                    curValue = newValue;
                                }
                                if (curValue === oldValue) return;
                                this.dispatchPropertyChangeEvent(property, curValue, oldValue, true);
                                this[bind] = curValue;
                                this.dispatchPropertyChangeEvent(property, curValue, oldValue);
                                changeCallback.call(this, descriptor, curValue, oldValue);
                            },
                            get: function() {
                                var bind = bound.call(this, property, descriptor);
                                var curValue = this[bind];
                                var retValue = getterCallback.call(this, descriptor, curValue);
                                if (retValue === undefined) {
                                    retValue = curValue;
                                }
                                return retValue;
                            }
                        });
                    }, this);
                    return;
                }
                this.prototype[key] = value;
            }
        });
        var init = function(property, descriptor) {
            var bind = descriptor.bind || (descriptor.bind = "__" + property);
            if (!(bind in this)) this[bind] = lamda(descriptor.init).call(this);
        };
        var lamda = function(value) {
            return typeof value === "function" ? value : function() {
                return value;
            };
        };
        var bound = function(property, descriptor) {
            var bind = descriptor.bind || (descriptor.bind = "__" + property);
            if (!(bind in this)) this[bind] = lamda(descriptor.init).call(this);
            return bind;
        };
        var setterCallback = function(descriptor, newValue, oldValue) {
            var onSet = descriptor.onSet;
            if (onSet) {
                return onSet.call(this, newValue, oldValue);
            }
            return undefined;
        };
        var getterCallback = function(descriptor, newValue, oldValue) {
            var onGet = descriptor.onGet;
            if (onGet) {
                return onGet.call(this, newValue, oldValue);
            }
            return undefined;
        };
        var changeCallback = function(descriptor, newValue, oldValue) {
            var onChange = descriptor.onChange;
            if (onChange) {
                return onChange.call(this, newValue, oldValue);
            }
            return undefined;
        };
    }
});
