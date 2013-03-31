
/*
          var appController = new boxspring.ApplicationController();


        var View         = boxspring.View

        var view = new View(320, 480)
        view.style.backgroundColor = 'rgba(255, 0, 0, 0.5)'

        appController.view.addChild(view)
        
        */


boxspring.define('boxspring.View', {

    constructor: function() {
        console.log('JavaScript View constructor')
    }

})

boxspring.define('boxspring.Button', {

    inherits: boxspring.View,

    constructor: function() {
        boxspring.Button.parent.constructor.call(this)
        console.log('JavaScript Button Constructor')
    }  

});
//
//console.log(boxspring.View.prototype.constructor === boxspring.View);

//var view = new boxspring.View(300, 300);

var button = new boxspring.Button(300, 300);

//view.draw();

//console.log('TEST');
