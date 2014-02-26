var mod = require('bencoding.securely'),
	crypto = mod.createXPlatformCrypto(),
	password = "foo123456789",
	plainText = "mary had a little lamb, little lamb, little lamb",
	iOSOutput = "duSnwv3AGC5ICbn//3sjiL2L6kUNEMPjq+hniRdL9ow+QjGcM+2pBCw+3h19LAc3ugdEB5/ftwNVAO9sStSoNQ==";

var encyptedText = crypto.encrypt(password,plainText);
Ti.API.info('encyptedText = ' + encyptedText);

var decryptedText = crypto.decrypt(password, encyptedText);
Ti.API.info('decryptedText = ' + decryptedText);
Ti.API.info('Do they match? = ' + ((decryptedText == plainText) ? 'Yes' : 'No'));
if(Ti.Platform.Android){
	Ti.API.info('Output Cross Platform? = ' + ((crypto.decrypt(password, iOSOutput)==decryptedText) ? 'Yes' : 'No'));
}
