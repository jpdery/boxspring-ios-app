
var Button = boxspring.define('boxspring.Button', {

    inherits: boxspring.View,
    
    constructor: function() {
        console.log('boxspring.Button constructor called');
        Button.parent.constructor.apply(this, arguments);
        return this;
    },
    
    draw: function(context, area) {
        
        context.fillStyle = '#'+Math.floor(Math.random()*16777215).toString(16);;
        context.fillRect(
            area.origin.x,
            area.origin.y,
            area.size.x / 2,
            area.size.y
        );

        context.fillStyle = '#'+Math.floor(Math.random()*16777215).toString(16);;
        context.fillRect(
            area.origin.x + area.size.x / 2,
            area.origin.y,
            area.size.x / 2,
            area.size.y
        );
        
        context.fillStyle = 'rgba(255, 0, 0, 0.5)';
        context.fillRect(
            area.size.x / 2 - 50 / 2,
            area.size.y / 2 - 50 / 2,
            50,
            50
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

//var b = new boxspring.Button(120, 120, 100, 200);
//w.addChild(b);

//setInterval(function() {
//    b.redraw();
//}, 2000);

window.x = 0;
window.y = 0;
window.xdir = 1;
window.ydir = 1;
window.sizex = 50;
window.sizey = 50;

var self = this;

var PingPongView = boxspring.define('boxspring.PingPongView', {
   
    inherits: boxspring.View,
    
    constructor: function() {
        console.log('boxspring.PingPongView constructor called');
        PingPongView.parent.constructor.apply(this, arguments);
        return this;
    },
    
    draw: function(context, area) {
        
        var size = this.size;

        context.fillStyle = '#5f4c1c';
        context.fillRect(0, 0, size.x, size.y);
        
        if (x + xdir + sizex > size.x ||
            x + xdir < 0) {
            xdir = -1 * xdir;
        }
        if (y + ydir + sizey > size.y ||
            y + ydir < 0) {
            ydir = -1 * ydir;
        }
                
        x += xdir;
        y += ydir;
                                
        context.fillStyle = 'rgba(255, 255, 0, 0.75)';
        context.fillRect(x, y, sizex, sizey);
    }

})

var ppv = new boxspring.PingPongView(200, 300);

w.addChild(ppv);


setInterval(function() {
    ppv.redraw();
}, 16);

