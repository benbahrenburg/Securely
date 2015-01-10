var win = Ti.UI.createWindow({
	backgroundColor:'white',
	layout:'vertical'
});

var securely = require('bencoding.securely');
Ti.API.info("module is => " + securely);

var fileCrypto = securely.createFileCrypto();
var password = "foo";

var btnEncrypt = Ti.UI.createButton({
	title:'Encrypt', top:25, height:45, left:5, right:5	
});
win.add(btnEncrypt);

var btnDecrypt = Ti.UI.createButton({
	title:'Decrypt', top:25, height:45, left:5, right:5	
});
win.add(btnDecrypt);

btnEncrypt.addEventListener('click',function(x){

	function onEncryptCompleted(e){
		//Print full statement to the console
		Ti.API.info(JSON.stringify(e));
	};
	
	var plainTextFile = Ti.Filesystem.getFile(Ti.Filesystem.resourcesDirectory, 'anne11.txt'),
		futureEncrypted = Ti.Filesystem.getFile(Ti.Filesystem.applicationDataDirectory, 'encryptedFile.txt');
				
	fileCrypto.AESEncrypt({
		password:password,
		from:plainTextFile.nativePath,
		to:futureEncrypted.nativePath,
		completed:onEncryptCompleted
	});
});

btnDecrypt.addEventListener('click',function(x){
	
	function onDecryptCompleted(e){
		//Print full statement to the console
		Ti.API.info(JSON.stringify(e));
	};

	var encryptedFile = Ti.Filesystem.getFile(Ti.Filesystem.applicationDataDirectory, 'encryptedFile.txt'),
		futureDecrypted = Ti.Filesystem.getFile(Ti.Filesystem.applicationDataDirectory, 'decryptedFile.txt');
	
	if(!encryptedFile.exists()){
		alert('Please run encrypt sample first');
		return;
	}
				
	fileCrypto.AESDecrypt({
		password:password,
		from:encryptedFile.nativePath,
		to:futureDecrypted.nativePath,
		completed:onDecryptCompleted
	});
});

win.open();

