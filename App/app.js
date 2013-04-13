
var Button = boxspring.define('boxspring.Button', {

    inherits: boxspring.View,
    
    constructor: function() {
        console.log('boxspring.Button constructor called');
        Button.parent.constructor.apply(this, arguments);
        return this;
    },
    
    draw: function(context, area) {
        
        console.log("Hum, hum");
        
        context.fillStyle = '#496865';
        context.fillRect(
            area.origin.x,
            area.origin.y,
            area.size.x / 2,
            area.size.y
        );

        context.fillStyle = '#164d48';
        context.fillRect(
            area.origin.x + area.size.x / 2,
            area.origin.y,
            area.size.x / 2,
            area.size.y
        );
    
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

var b = new boxspring.Button(120, 120, 100, 200);
w.addChild(b);
