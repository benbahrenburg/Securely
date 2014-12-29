var win = Ti.UI.createWindow({
	backgroundColor:'white', layout:'vertical'
});

var securely = require('bencoding.securely');
Ti.API.info("module is => " + securely);

var cert = securely.createRemoteCertificate({
    debug:true
});

var btnTest = Ti.UI.createButton({
	title:'Get Remote Thunbprint', top:25, height:45, left:5, right:5	
});
win.add(btnTest);

btnTest.addEventListener('click',function(x){
    cert.getThumbprint({
       url:'https://github.com' 
    }); 	
});

win.open();

