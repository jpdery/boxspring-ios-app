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
        require("o");
        require("p");
        require("q");
        require("r");
        require("s");
        require("t");
        require("u");
        require("v");
        require("x");
        require("y");
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
                var inits = this.__propertyInits;
                for (var i = 0, l = inits.length; i < l; i++) {
                    inits[i].call(this);
                }
                return this;
            },
            destroy: function() {
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
    },
    o: function(require, module, exports, global) {
        "use strict";
        var Point = boxspring.define("boxspring.Point", {
            properties: {
                x: {
                    init: 0
                },
                y: {
                    init: 0
                }
            },
            constructor: function(x, y) {
                Point.parent.constructor.call(this);
                var point = arguments[0];
                if (point instanceof boxspring.Point) {
                    x = point.x;
                    y = point.y;
                }
                this.x = x || 0;
                this.y = y || 0;
                return this;
            }
        });
    },
    p: function(require, module, exports, global) {
        "use strict";
        var Size = boxspring.define("boxspring.Size", {
            properties: {
                x: {
                    init: 0
                },
                y: {
                    init: 0
                }
            },
            constructor: function(x, y) {
                Size.parent.constructor.call(this);
                var size = arguments[0];
                if (size instanceof boxspring.Size) {
                    x = size.x;
                    y = size.y;
                }
                this.x = x || 0;
                this.y = y || 0;
                return this;
            }
        });
    },
    q: function(require, module, exports, global) {
        "use strict";
        var Size = boxspring.Size;
        var Point = boxspring.Point;
        var Rect = boxspring.define("boxspring.Rect", {
            statics: {
                union: function(r1, r2) {
                    var x1 = Math.min(r1.origin.x, r2.origin.x);
                    var y1 = Math.min(r1.origin.y, r2.origin.y);
                    var x2 = Math.max(r1.origin.x + r1.size.x, r2.origin.x + r2.size.x);
                    var y2 = Math.max(r1.origin.y + r1.size.y, r2.origin.x + r2.size.y);
                    return new Rect(x1, y1, x2 - x1, y2 - y1);
                }
            },
            properties: {
                origin: {
                    init: function() {
                        return new Point(0, 0);
                    }
                },
                size: {
                    init: function() {
                        return new Size(0, 0);
                    }
                }
            },
            constructor: function(x, y, w, h) {
                Rect.parent.constructor.call(this);
                var rect = arguments[0];
                if (rect instanceof boxspring.Rect) {
                    x = rect.origin.x;
                    y = rect.origin.y;
                    w = rect.size.x;
                    h = rect.size.y;
                }
                this.origin = new Point(x, y);
                this.size = new Size(w, h);
                return this;
            }
        });
    },
    r: function(require, module, exports, global) {
        "use strict";
        var array = boxspring.array;
        boxspring.define("boxspring.Emitter", {
            addListener: function(type, listener) {
                type = type.toLowerCase();
                if (type === "propertychange" || type === "beforepropertychange") {
                    if (this.addPropertyChangeListener) {
                        this.addPropertyChangeListener(arguments[1], arguments[2], type === "beforepropertychange");
                        return this;
                    }
                }
                var listeners = this.__listeners || (this.__listeners = {});
                var events = listeners[type];
                if (events === undefined) {
                    events = listeners[type] = [];
                }
                if (array.index(events, listener) === null) array.push(events, listener);
                return this;
            },
            hasListener: function(type, listener) {
                type = type.toLowerCase();
                var events = this.__listeners[type];
                if (events === undefined) return this;
                return !!array.index(events, listener);
            },
            removeListener: function(type, listener) {
                type = type.toLowerCase();
                if (type === "propertychange" || type === "beforepropertychange") {
                    if (this.removePropertyChangeListener) {
                        this.removePropertyChangeListener(arguments[1], arguments[2], type === "beforepropertychange");
                        return this;
                    }
                }
                var events = this.__listeners[type];
                if (events === undefined) return this;
                array.remove(events, listener);
                return this;
            },
            removeListeners: function(type) {
                if (type) {
                    type = type.toLowerCase();
                    delete this.__listeners[type];
                    return this;
                }
                this.__listeners = [];
                return this;
            },
            on: function() {
                return this.addListener.apply(this, arguments);
            },
            off: function() {
                return this.removeListener.apply(this, arguments);
            },
            once: function(type, listener) {},
            emit: function(event) {
                if (typeof event === "string") {
                    event = new Event(event, false);
                }
                var type = event.type;
                var args = array.slice(arguments, 1);
                if (event.source === null) event.__setSource(this);
                var listeners = this.__listeners || (this.__listeners = {});
                var events = listeners[type];
                if (events) {
                    for (var i = 0, l = events.length; i < l; i++) {
                        events[i].apply(this, args);
                    }
                }
                if (!event.bubbles || event.stopped) return this;
                var responder = this.__responder;
                if (responder) {
                    arguments[0] = event;
                    responder.emit.apply(responder, arguments);
                }
                return this;
            },
            insertResponder: function(responder) {
                var parent = this.responder;
                if (parent) {
                    responder.responder = parent;
                }
                this.responder = responder;
            }
        });
    },
    s: function(require, module, exports, global) {
        "use strict";
        var ViewStyle = boxspring.define("boxspring.ViewStyle", {
            properties: {
                view: {
                    writable: false,
                    init: null
                },
                backgroundColor: {
                    onChange: function(val, old) {
                        this.view.redraw();
                    }
                },
                backgroundImage: {
                    onGet: function(val) {
                        return val && val.src || null;
                    },
                    onChange: function(val, old) {
                        if (old) {
                            old.removeEventListener("load", this.bound("__onBackgroundImageLoad"));
                            old = null;
                        }
                        val = new Image;
                        val.src = value;
                        val.addEventListener("load", this.bound("__onBackgroundImageLoad"));
                        this.view.redraw();
                    }
                },
                backgroundRepeat: {}
            },
            constructor: function(view) {
                ViewStyle.parent.constructor.call(this);
                this.__view = view;
                return this;
            },
            destroy: function() {
                this.__view = null;
                return this;
            },
            draw: function(context, area) {
                var x = area.origin.x;
                var y = area.origin.y;
                var w = area.size.x;
                var h = area.size.y;
                var backgroundColor = this.backgroundColor;
                if (backgroundColor) {
                    context.fillStyle = backgroundColor;
                    context.fillRect(x, y, w, h);
                }
                var backgroundImage = this.backgroundImage;
                if (backgroundImage && backgroundImage.naturalWidth && backgroundImage.naturalHeight) {
                    var pattern = context.createPattern(backgroundImage, this.backgroundRepeat || "repeat");
                    context.fillStyle = pattern;
                    context.fillRect(x, y, w, h);
                }
            },
            __onBackgroundImageLoad: function() {
                this.view.redraw();
            }
        });
    },
    t: function(require, module, exports, global) {
        "use strict";
        var array = boxspring.array;
        var Point = boxspring.Point;
        var Size = boxspring.Size;
        var Rect = boxspring.Rect;
        var Emitter = boxspring.Emitter;
        var ViewStyle = boxspring.ViewStyle;
        var View = boxspring.define("boxspring.View", {
            inherits: Emitter,
            properties: {
                name: {
                    init: null
                },
                size: {
                    init: function() {
                        return new Size(0, 0);
                    },
                    onChange: function(newSize, oldSize) {
                        var callback = this.bound("__onSizeChange");
                        newSize.addPropertyChangeListener("x", callback);
                        newSize.addPropertyChangeListener("y", callback);
                        oldSize.removePropertyChangeListener("x", callback);
                        oldSize.removePropertyChangeListener("y", callback);
                        this.reflow();
                    }
                },
                origin: {
                    init: function() {
                        return new Point(0, 0);
                    },
                    onChange: function(newOrigin, oldOrigin) {
                        var callback = this.bound("__onOriginChange");
                        newOrigin.addPropertyChangeListener("x", callback);
                        newOrigin.addPropertyChangeListener("y", callback);
                        oldOrigin.removePropertyChangeListener("x", callback);
                        oldOrigin.removePropertyChangeListener("y", callback);
                        this.reflow();
                    }
                },
                center: {
                    init: function() {
                        return new Point(0, 0);
                    },
                    onChange: function(newCenter, oldCenter) {
                        var callback = this.bound("__onCenterChange");
                        newCenter.addPropertyChangeListener("x", callback);
                        newCenter.addPropertyChangeListener("y", callback);
                        oldCenter.removePropertyChangeListener("x", callback);
                        oldCenter.removePropertyChangeListener("y", callback);
                        this.reflow();
                    }
                },
                contentOffset: {
                    init: function() {
                        return new Point(0, 0);
                    },
                    onChange: function() {
                        this.reflow();
                    }
                },
                visible: {
                    init: true,
                    onChange: function(newVisible, oldVisible) {
                        this.reflow();
                    }
                },
                opacity: {
                    init: 1,
                    onSet: function(newOpacity, oldOpacity) {
                        if (newOpacity > 1) newOpacity = 1;
                        if (newOpacity < 0) newOpacity = 0;
                        return newOpacity;
                    },
                    onChange: function(newOpacity, oldOpacity) {
                        this.reflow();
                    }
                },
                style: {
                    init: null,
                    onSet: function(val, old) {}
                },
                window: {
                    init: null
                },
                parent: {
                    init: null
                },
                children: {
                    init: function() {
                        return [];
                    },
                    onGet: function(value) {
                        return array.slice(value);
                    }
                }
            },
            constructor: function(w, h, x, y) {
                console.log("boxspring.View constructor called");
                View.parent.constructor.call(this);
                var rect = arguments[0];
                if (rect instanceof Rect) {
                    x = rect.origin.x;
                    y = rect.origin.y;
                    w = rect.size.x;
                    h = rect.size.y;
                }
                this.origin.x = x;
                this.origin.y = y;
                this.size.x = w;
                this.size.y = h;
                this.style = new ViewStyle(this);
                this.on("add", this.bound("onAdd"));
                this.on("remove", this.bound("onRemove"));
                this.on("addtoparent", this.bound("onAddToParent"));
                this.on("addtowindow", this.bound("onAddToWindow"));
                this.on("removefromparent", this.bound("onRemoveFromParent"));
                this.on("removefromwindow", this.bound("onRemoveFromWindow"));
                this.on("touchcancel", this.bound("onTouchCancel"));
                this.on("touchstart", this.bound("onTouchStart"));
                this.on("touchmove", this.bound("onTouchMove"));
                this.on("touchend", this.bound("onTouchEnd"));
                return this;
            },
            destroy: function() {
                this.removeFromParent();
                this.off("add", this.bound("onAdd"));
                this.off("remove", this.bound("onRemove"));
                this.off("addtoparent", this.bound("onAddToParent"));
                this.off("addtowindow", this.bound("onAddToWindow"));
                this.off("removefromparent", this.bound("onRemoveFromParent"));
                this.off("removefromwindow", this.bound("onRemoveFromWindow"));
                this.off("touchcancel", this.bound("onTouchCancel"));
                this.off("touchstart", this.bound("onTouchStart"));
                this.off("touchmove", this.bound("onTouchMove"));
                this.off("touchend", this.bound("onTouchEnd"));
                this.removeListeners();
                Renderer.free(this);
                return this.base("destroy");
            },
            moveTo: function(x, y) {
                var origin = this.origin;
                origin.x = x || 0;
                origin.y = y || 0;
                return this;
            },
            moveBy: function(x, y) {
                var origin = this.origin;
                origin.x += x || 0;
                origin.y += y || 0;
                return this;
            },
            resizeTo: function(x, y) {
                var size = this.size;
                size.x = x || 0;
                size.y = y || 0;
                return this;
            },
            resizeBy: function(x, y) {
                var size = this.size;
                size.x += x || 0;
                size.y += y || 0;
                return this;
            },
            addChild: function(view) {
                console.log(this.__children);
                return this.addChildAt(view, this.__children.length);
            },
            addChildAt: function(view, index) {
                var children = this.__children;
                if (index > children.length) {
                    index = children.length;
                } else if (index < 0) {
                    index = 0;
                }
                view.removeFromParent();
                array.splice(children, index, 1, view);
                view.responder = this;
                view.__setParent(this);
                view.__setWindow(this.window);
                this.emit("add", view);
                return this.reflow();
            },
            addChildBefore: function(child, before) {
                var index = this.getChildIndex(before);
                if (index === null) return this;
                return this.addChildAt(child, index);
            },
            addChildAfter: function(child, after) {
                var index = this.getChildIndex(before);
                if (index === null) return this;
                return this.addChildAt(child, index + 1);
            },
            removeChild: function(child, destroy) {
                var index = this.getChildIndex(child);
                if (index === null) return this;
                return this.removeChildAt(index, destroy);
            },
            removeChildAt: function(index, destroy) {
                var children = this.__children;
                var view = children[index];
                if (view === undefined) return this;
                array.splice(children, index, 1);
                view.__setParent(null);
                view.__setWindow(null);
                view.responder = null;
                this.emit("remove", view);
                if (destroy) view.destroy();
                return this.reflow();
            },
            removeFromParent: function(destroy) {
                if (this.__parent) {
                    this.__parent.removeChild(this, destroy);
                }
                return this;
            },
            getChild: function(name) {
                return array.find(this.__children, function(view) {
                    return view.name === name;
                });
            },
            getChildAt: function(index) {
                return this.__children[index] || null;
            },
            getChildIndex: function(child) {
                return array.indexOf(this.__children, child);
            },
            getChildAtPoint: function(x, y) {
                if (this.hits(x, y) === false) return null;
                var children = this.__children;
                for (var i = children.length - 1; i >= 0; i--) {
                    var child = children[i];
                    if (child.hits(x, y)) {
                        var origin = child.origin;
                        var relx = x - origin.x;
                        var rely = y - origin.y;
                        return child.getChildAtPoint(relx, rely) || child;
                    }
                }
                return null;
            },
            cascade: function(fn) {
                if (fn) {
                    fn.call(this, this);
                }
                array.invoke(this.__children, "cascade", fn);
                return this;
            },
            hits: function(x, y) {
                var point = arguments[0];
                if (point instanceof Point) {
                    x = point.x;
                    y = point.y;
                }
                var s = this.size;
                var o = this.origin;
                return x >= o.x && x <= o.x + s.x && y >= o.y && y <= o.y + s.y;
            },
            draw: function(context, area) {
             
                context.fillStyle = '#518d88';
                context.fillRect(area.origin.x, area.origin.y, area.size.x, area.size.y);
             
                return this;
            },
            redraw: function(area) {
                boxspring.Renderer.redraw(this, area || new Rect(0, 0, this.size.x, this.size.y));
                return this;
            },
            reflow: function() {
                boxspring.Renderer.reflow(this);
                return this;
            },
            onAdd: function(view) {},
            onRemove: function(view) {},
            onAddToParent: function(parent) {},
            onAddToWindow: function(masterView) {},
            onRemoveFromParent: function(parent) {},
            onRemoveFromWindow: function(masterView) {},
            onTouchCancel: function(e) {},
            onTouchStart: function(e) {},
            onTouchMove: function(e) {},
            onTouchEnd: function(e) {},
            __setParent: function(value) {
                var parent = this.__parent;
                if (parent && value === null) {
                    this.__parent = value;
                    return this.emit("removefromparent", parent);
                }
                if (parent === null && value) {
                    this.__parent = value;
                    return this.emit("addtoparent", parent);
                }
                return this;
            },
            __setWindow: function(value) {
                var window = this.__window;
                if (window && value === null) {
                    this.__window = value;
                    return this.emit("removefromwindow", window);
                }
                if (window === null && value) {
                    this.__window = value;
                    return this.emit("addtowindow", window);
                }
                return this;
            },
            __onSizeChange: function(val, old, key) {
                var origin = this.origin;
                var center = this.center;
                switch (key) {
                  case "x":
                    center.x = origin.x + val / 2;
                    break;
                  case "y":
                    center.y = origin.y + val / 2;
                    break;
                }
                this.reflow();
            },
            __onOriginChange: function(val, old, key) {
                var size = this.size;
                var center = this.center;
                switch (key) {
                  case "x":
                    center.x = val + size.x / 2;
                    break;
                  case "y":
                    center.y = val + size.y / 2;
                    break;
                }
                this.reflow();
            },
            __onCenterChange: function(val, old, key) {
                var size = this.__size;
                var origin = this.__origin;
                switch (key) {
                  case "x":
                    origin.x = val - size.x / 2;
                    break;
                  case "y":
                    origin.y = val - size.y / 2;
                    break;
                }
                this.reflow();
            },
            __onAddToWindow: function(window) {
                this.__window = window;
                array.invoke(this.__children, "emit", "addtowindow", window);
            },
            __onRemoveFromWindow: function(window) {
                this.__window = null;
                array.invoke(this.__children, "emit", "removefromwindow", window);
            }
        });
    },
    u: function(require, module, exports, global) {
        "use strict";
        var Window = boxspring.define("boxspring.Window", {
            inherits: boxspring.View,
            constructor: function() {
                console.log("boxspring.Window constructor called");
                return Window.parent.constructor.apply(this, arguments);
            },
            onAdd: function(view) {
                Window.parent.onAdd.call(this, view);
                view.__setWindow(this);
            },
            onRemove: function(view) {
                Window.parent.onRemove.call(this, view);
                view.__setWindow(null);
            },
          draw: function(context, area) {
             
                context.fillStyle = '#c0dedb';
                context.fillRect(area.origin.x, area.origin.y, area.size.x, area.size.y);
             
                return this;
            },
        });
    },
    v: function(require, module, exports, global) {
        "use strict";
        var array = boxspring.array;
        var Point = boxspring.Point;
        var Size = boxspring.Size;
        var Rect = boxspring.Rect;
        var Emitter = boxspring.Emitter;
        var Map = require("w");
        var buffers = new Map;
        var redraws = new Map;
        var instances = new Map;
        var Renderer = boxspring.define("boxspring.Renderer", {
            inherits: Emitter,
            statics: {
                redraw: function(view, area) {
                    var instance = instances.get(view instanceof boxspring.Window ? view : view.window);
                    if (instance) {
                        instance.redraw(view, area);
                    }
                    return this;
                },
                reflow: function(view) {
                    var instance = instances.get(view instanceof boxspring.Window ? view : view.window);
                    if (instance) {
                        instance.reflow(view);
                    }
                    return this;
                },
                free: function(view) {
                    var buffer = buffers.get(view);
                    if (buffer) {
                        buffer.width = 0;
                        buffer.height = 0;
                    }
                    buffers.remove(view);
                    redraws.remove(view);
                }
            },
            properties: {
                canvas: {
                    init: null
                }
            },
            __window: null,
            __canvas: null,
            __context: null,
            constructor: function(window) {
                if (instances.get(window)) {
                    throw new Error("A renderer is already defined for this window");
                }
                instances.set(window, this);
                Renderer.parent.constructor.call(this);
                this.__window = window;
                this.__canvas = document.createElement("canvas");
                this.__canvas.width = window.size.x;
                this.__canvas.height = window.size.y;
                document.body.appendChild(this.__canvas);
                this.__context = this.__canvas.getContext("2d");
                this.__nextFrame = null;
            },
            redraw: function(view, area) {
                var a = redraws.get(view);
                if (a) {
                    a = Rect.union(a, area);
                } else {
                    a = area;
                }
                redraws.set(view, a);
                if (this.__nextFrame === null) {
                    this.__nextFrame = requestAnimationFrame(this.render.bind(this));
                }
                return this;
            },
            reflow: function(view) {
                if (this.__nextFrame === null) {
                    this.__nextFrame = requestAnimationFrame(this.render.bind(this));
                }
                return this;
            },
            render: function() {
                this.__nextFrame = null;
                if (this.__window === null) return;
                this.__context.clearRect(0, 0, this.__window.size.x, this.__window.size.y);
                var self = this;
                var paint = function(view, offset) {
                    if (view.visible === false) return;
                    var context = null;
                    var buffer = buffers.get(view);
                    if (buffer === null) {
                        buffer = document.createElement("canvas");
                        buffer.width = view.size.x;
                        buffer.height = view.size.y;
                        context = buffer.getContext("2d");
                        context.save();
                        view.draw(context, new Rect(0, 0, view.size.x, view.size.y));
                        context.restore();
                        buffers.set(view, buffer);
                        redraws.remove(view);
                    }
                    var area = redraws.get(view);
                    if (area) {
                        context = buffer.getContext("2d");
                        context.save();
                        context.rect(area.origin.x, area.origin.y, area.size.x, area.size.y);
                        context.clip();
                        view.draw(context, area);
                        context.restore();
                        redraws.remove(view);
                    }
                    var origin = new Point(offset.x + view.origin.x, offset.y + view.origin.y);
                    self.__context.save();
                    self.__context.globalAlpha = view.opacity;
                    self.__context.drawImage(buffer, 0, 0, view.size.x, view.size.y, origin.x, origin.y, view.size.x, view.size.y);
                    var children = view.children;
                    for (var i = 0; i < children.length; i++) paint(children[i], origin);
                    self.__context.restore();
                };
                paint(this.__window, new Point);
                return this;
            }
        });
    },
    w: function(require, module, exports, global) {
        "use strict";
        var prime = require("5"), array = require("3");
        var Map = prime({
            constructor: function() {
                if (!this || this.constructor !== Map) return new Map;
                this.length = 0;
                this._values = [];
                this._keys = [];
            },
            set: function(key, value) {
                var index = array.indexOf(this._keys, key);
                if (index === -1) {
                    this._keys.push(key);
                    this._values.push(value);
                    this.length++;
                } else {
                    this._values[index] = value;
                }
                return this;
            },
            get: function(key) {
                var index = array.indexOf(this._keys, key);
                return index === -1 ? null : this._values[index];
            },
            count: function() {
                return this.length;
            },
            each: function(method, context) {
                for (var i = 0, l = this.length; i < l; i++) {
                    if (method.call(context, this._values[i], this._keys[i], this) === false) break;
                }
                return this;
            },
            backwards: function(method, context) {
                for (var i = this.length - 1; i >= 0; i--) {
                    if (method.call(context, this._values[i], this._keys[i], this) === false) break;
                }
                return this;
            },
            map: function(method, context) {
                var results = new Map;
                this.each(function(value, key) {
                    results.set(key, method.call(context, value, key, this));
                }, this);
                return results;
            },
            filter: function(method, context) {
                var results = new Map;
                this.each(function(value, key) {
                    if (method.call(context, value, key, this)) results.set(key, value);
                }, this);
                return results;
            },
            every: function(method, context) {
                var every = true;
                this.each(function(value, key) {
                    if (!method.call(context, value, key, this)) return every = false;
                }, this);
                return every;
            },
            some: function(method, context) {
                var some = false;
                this.each(function(value, key) {
                    if (method.call(context, value, key, this)) return !(some = true);
                }, this);
                return some;
            },
            index: function(value) {
                var index = array.indexOf(this._values, value);
                return index > -1 ? this._keys[index] : null;
            },
            remove: function(key) {
                var index = array.indexOf(this._keys, key);
                if (index !== -1) {
                    this._keys.splice(index, 1);
                    this.length--;
                    return this._values.splice(index, 1)[0];
                }
                return null;
            },
            keys: function() {
                return this._keys.slice();
            },
            values: function() {
                return this._values.slice();
            }
        });
        module.exports = Map;
    },
    x: function(require, module, exports, global) {
        "use strict";
        var Emitter = boxspring.Emitter;
        var ViewController = boxspring.define("boxspring.ViewController", {
            inherits: Emitter,
            properties: {
                view: {
                    init: null
                }
            },
            constructor: function() {
                ViewController.parent.constructor.call(this);
                this.loadView();
                this.view.insertResponder(this);
                this.on("touchcancel", this.bound("onTouchCancel"));
                this.on("touchstart", this.bound("onTouchStart"));
                this.on("touchmove", this.bound("onTouchMove"));
                this.on("touchend", this.bound("onTouchEnd"));
            },
            destroy: function() {
                this.off("touchcancel", this.bound("onTouchCancel"));
                this.off("touchstart", this.bound("onTouchStart"));
                this.off("touchmove", this.bound("onTouchMove"));
                this.off("touchend", this.bound("onTouchEnd"));
            },
            loadView: function() {
                this.view = new View;
            },
            onTouchCancel: function() {},
            onTouchStart: function() {},
            onTouchMove: function() {},
            onTouchEnd: function() {}
        });
    },
    y: function(require, module, exports, global) {
        "use strict";
        var Renderer = boxspring.Renderer;
        var Window = boxspring.Window;
        var ApplicationController = boxspring.define("boxspring.ApplicationController", {
            inherits: "boxspring.ViewController",
            renderer: null,
            constructor: function(size) {
                ApplicationController.parent.constructor.call(this);
                return this;
            },
            loadView: function() {
                this.view = new Window(320, 480);
                if (global.document) this.renderer = new Renderer(this.view);
            },
            __onTouchCancel: function(e) {},
            __onTouchStart: function(e) {},
            __onTouchMove: function(e) {},
            __onTouchEnd: function(e) {}
        });
    }
});
