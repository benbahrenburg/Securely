var win = Ti.UI.createWindow({
	backgroundColor : 'white',
	layout : 'vertical'
});

var securely = require('bencoding.securely');
Ti.API.info("module is => " + securely);

var cert = securely.createRemoteCertificate({
	debug : true
});

var btnTest = Ti.UI.createButton({
	title : 'Get Remote Thumbprint',
	top : 25,
	height : 45,
	left : 5,
	right : 5
});
win.add(btnTest);

var label = Ti.UI.createLabel({
	top : 25,
	left : 5,
	right : 5,
	height : 70
});
win.add(label);

cert.addEventListener('completed', function(e) {
	Ti.API.info('thumbprint completed');
	Ti.API.info('response=' + JSON.stringify(e, null, "\t"));
	label.text = "SSL Thumbprint=" + e.thumbprint;
});

btnTest.addEventListener('click', function(x) {
	cert.getThumbprint({
		url : 'https://github.com'
	});
});

win.open();

