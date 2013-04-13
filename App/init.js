var window = this

boxspring.define('boxspring.JSConsole', {inherits: null});
boxspring.define('boxspring.JSImage', {inherits: null});

window.console = new boxspring.JSConsole();
window.Image = new boxspring.JSImage();