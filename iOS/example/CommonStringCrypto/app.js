var mod = require('bencoding.securely'),
	crypto = mod.createCommonStringCrypto(),
	password = "foo123456789",
	plainText = "marry had a little lamb, little lamb, little lamb",
	iOSOutput = "eqh9NzzqApXbAv2NALC60K3orjdLIIJ4UQD9AHxjjkfSs57zs8X5eqP7lXiNocd9FXSqM0izPg1+EOvHVlgsUg==";

var encyptedText = crypto.encrypt(password,plainText);
Ti.API.info('encyptedText = ' + encyptedText);

var decryptedText = crypto.decrypt(password, encyptedText);
Ti.API.info('decryptedText = ' + decryptedText);
Ti.API.info('Do they match? = ' + ((decryptedText == plainText) ? 'Yes' : 'No'));
if(Ti.Platform.Android){
	Ti.API.info('Output Cross Platform? = ' + ((crypto.decrypt(password, iOSOutput)==decryptedText) ? 'Yes' : 'No'));
}

Ti.API.info("Now try encrypt an image file");

var plainImage = Ti.Filesystem.getFile(Ti.Filesystem.resourcesDirectory,"test.png");
var futureEncryptedFile = Ti.Filesystem.getFile(Ti.Filesystem.applicationDataDirectory,"encrypted.png");


function testDecrypt(fileToDecrypt){
	function onCompleted(e){
		if(e.success){
			Ti.API.info(JSON.stringify(e));
			//Create an empty file
			var test2 = Ti.Filesystem.getFile(Ti.Filesystem.applicationDataDirectory,"test2.png");
			if(test2.exists()){
				test2.deleteFile();
			}
			//Write the contents of the blob to a file, NOT RECOMMENDED FROM PRODUCTION WORK
			test2.write(e.result);
			Ti.API.info("now visit " + test2.nativePath);
			Ti.API.info("Should be decrypted");		
		}else{
			Ti.API.info("something went wrong check your logs");
		}
	}
	//This returns a callback with a blob
	crypto.readEncrypt({
		password:password,
		readPath:fileToDecrypt,
		completed:onCompleted
	});	
};



function testEncrypt(){

	function onCompleted(e){
		if(e.success){
			Ti.API.info(JSON.stringify(e));
			Ti.API.info("Try to open the file " + e.result);
			Ti.API.info("Now we will show decrypt");
			testDecrypt(e.result);		
		}else{
			Ti.API.info("something went wrong check your logs");
		}
	}
	
	crypto.writeEncrypt({
		password:password,
		inputValue:plainImage,
		outputPath:futureEncryptedFile.nativePath,
		completed:onCompleted
	});	
};


testEncrypt();


