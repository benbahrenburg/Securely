var win = Ti.UI.createWindow({
	backgroundColor:'white'
});

var securely = require('bencoding.securely');
Ti.API.info("module is => " + securely);

Ti.API.info("The properties object contains a secure version of the Ti.App.Properties API");


Ti.API.info("Next we will demonstrate string crypto");
var stringCrypto = securely.createStringCrypto();

var password = "helloworld";

Ti.API.info("AES Encryption Demo");
var testString = "Some string you want to protect from anyone being able to see";
var encryptedText = stringCrypto.AESEncrypt(password,testString);
Ti.API.info("Encrypted Test Passed? " + (encryptedText!=testString));
Ti.API.info("Encrypted value " + encryptedText);

var decryptedText = stringCrypto.AESDecrypt(password,encryptedText);	
Ti.API.info("Decrypted Test Passed? " + (decryptedText==testString));
Ti.API.info("Decrypted value " + decryptedText);	

Ti.API.info("DES Encryption Demo");
testString = "Some string you want to protect from anyone being able to see";
encryptedText = stringCrypto.DESEncrypt(password,testString);
Ti.API.info("Encrypted Test Passed? " + (encryptedText!=testString));
Ti.API.info("Encrypted value " + encryptedText);

decryptedText = stringCrypto.AESDecrypt(password,encryptedText);	
Ti.API.info("Decrypted Test Passed? " + (decryptedText==testString));
Ti.API.info("Decrypted value " + decryptedText);

function onDecrypt(e){	
	Ti.API.info(JSON.stringify(e));
};

function onEncrypt(e){
	Ti.API.info(JSON.stringify(e));
	if(e.success){
		stringCrypto.decrypt({
			password:password,
			value:e.result,
			resultType:e.resultType,
			completed:onDecrypt
		});			
	}		
};


var sampleFile = Ti.Filesystem.getFile(Ti.Filesystem.resourcesDirectory,"book.txt");
var bigTest = sampleFile.read();

Ti.API.info('Demo using blob');
stringCrypto.encrypt({
	password:password,
	value:bigTest,
	resultType:'blob',
	completed:onEncrypt
});

Ti.API.info('Demo using hex');
stringCrypto.encrypt({
	password:password,
	value:bigTest.text,
	resultType:'hex',
	completed:onEncrypt
});

Ti.API.info('Demo using text');
stringCrypto.encrypt({
	password:password,
	value:bigTest.text,
	resultType:'text',
	completed:onEncrypt
});



win.open();

