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


Ti.API.info('Demonstrate how to generate keys in a few ways');

var usingGUID = securely.generateDerivedKey(Ti.Platform.createUUID());	
Ti.API.info("Derived key using GUID = " + usingGUID);

var usingAppID = securely.generateDerivedKey(Ti.App.guid);
Ti.API.info("Derived key using App ID = " + usingAppID);

var randomKey = securely.generateRandomKey();
Ti.API.info("Random Key = " + randomKey);

win.open();

