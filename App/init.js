
window = this;

boxspring.define('core.Window',  {inherits: null})
boxspring.define('core.Console', {inherits: null})
boxspring.define('core.Image', {inherits: null});

// console
var _console = new core.Console();
window.console = _console;

// timers
var _window = new core.Window();
window.setTimeout = function(cb, t){ return _window.setTimeout(cb, t); };
window.setInterval = function(cb, t){ return _window.setInterval(cb, t); };
window.clearTimeout = function(id){ return _window.clearTimeout(id); };
window.clearInterval = function(id){ return _window.clearInterval(id); };
window.requestAnimationFrame = function(cb, element){ return _window.setTimeout(cb, 16); };

window.Image = function Image() {
    return new core.Image();
}
