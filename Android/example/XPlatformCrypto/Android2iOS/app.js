var mod = require('bencoding.securely'),
        crypto = mod.createXPlatformCrypto(),
        password = "foo123456789";
        
function decryptAndroid(){
	Ti.API.info("Sample file encrypted from iOS Project");
	var testFile = Ti.Filesystem.getFile(Ti.Filesystem.resourcesDirectory,"androidencrypted.png");	
   
    function onCompleted(e){
       Ti.API.info(JSON.stringify(e));
       if(e.success){
       		var finalTestFile = Ti.Filesystem.getFile(Ti.Filesystem.applicationDataDirectory,"androiddecryped.png");
            //Create an empty file
            if(finalTestFile.exists()){
               finalTestFile.deleteFile();
            }
            //Write the contents of the blob to a file, NOT RECOMMENDED FROM PRODUCTION WORK
            finalTestFile.write(e.result);
            Ti.API.info("now visit " + finalTestFile.nativePath);
            Ti.API.info("Should be decrypted");                
        }else{
            Ti.API.info("something went wrong check your logs");
        }
    }
  				  
    //This returns a callback with a blob
    crypto.readEncrypt({
        password:password,
        readPath:testFile,
        completed:onCompleted
    });   	
};
                                           

decryptAndroid();