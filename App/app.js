
var Button = boxspring.define('boxspring.Button', {

    inherits: boxspring.View,
    
    constructor: function() {
        console.log('boxspring.Button constructor called');
        Button.parent.constructor.apply(this, arguments);
        return this;
    }

});

var w = new boxspring.Window(320, 480);
//var v = new boxspring.View(100, 100, 50, 50)
//w.addChild(v);
//
//var v = new boxspring.View(100, 100, 50, 250)
//w.addChild(v);

//
//console.log(boxspring.Button);

var b = new boxspring.Button(50, 50, 100, 200);
w.addChild(b);
