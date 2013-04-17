
var w = new boxspring.Window(320, 480);

var colorize = function() {
    return '#' + Math.floor(Math.random()*16777215).toString(16);
}

var DiceView = boxspring.define('boxspring.PingPongView', {
   
    inherits: boxspring.View,
    
    constructor: function() {
        
        DiceView.parent.constructor.apply(this, arguments)

        var self = this;
        var draw = function() {
            self.redraw();
        }

        setInterval(draw, 250);

        return this
    },
    
    draw: function(context, area) {

        context.clearRect(0, 0, this.size.x, this.size.y);
        context.fillStyle = colorize();
        context.fillRect(0, 0, this.size.x, this.size.y);
        
        context.fillStyle = colorize();
        context.arc(40, 40, 20, 0, Math.PI * 2, true);
        context.fill();

        context.fillStyle = colorize();
        context.arc(this.size.x - 40, this.size.y - 40, 20, 0, Math.PI * 2, true);
        context.fill();
        
        context.fillStyle = colorize();
        context.arc(this.size.x - 40, 40, 20, 0, Math.PI * 2, true);
        context.fill();        

        context.fillStyle = colorize();
        context.arc(40, this.size.y - 40, 20, 0, Math.PI * 2, true);
        context.fill();   
    }

})

var ppv = new boxspring.PingPongView(
    200,
    200,
    w.size.x / 2 - 100,
    w.size.y / 2 - 100
);

w.addChild(ppv);



