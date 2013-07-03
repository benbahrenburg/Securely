var win = Ti.UI.createWindow({
	backgroundColor:'white'
});

var securely = require('bencoding.securely');
Ti.API.info("module is => " + securely);


var l = Titanium.UI.createLabel({
	text:'See Log for output',
	height:'auto',
	width:'auto'
});
win.add(l);


win.open();

