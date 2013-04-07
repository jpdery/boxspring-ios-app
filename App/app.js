
var Button = boxspring.define('boxspring.Button', {

    inherits: boxspring.View,
    
    constructor: function() {
        console.log('boxspring.Button constructor called');
        Button.parent.constructor.apply(this, arguments);
        return this;
    }

});

var w = new boxspring.Window(320, 480);
var v = new boxspring.View(115, 75, 11, 7)
w.addChild(v);
//
//console.log(boxspring.Button);

var b = new boxspring.Button(50, 50, 100, 100);
w.addChild(b);
