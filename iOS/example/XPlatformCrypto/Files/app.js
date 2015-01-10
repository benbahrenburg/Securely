var mod = require('bencoding.securely'),
        crypto = mod.createXPlatformCrypto(),
        password = "foo123456789";
                                                
function testDecrypt(fileToDecrypt){
    function onCompleted(e){
       Ti.API.info(JSON.stringify(e));
       if(e.success){
            var dir = ((Ti.Platform.Android)?
                    Ti.Filesystem.externalStorageDirectory : 
                    Ti.Filesystem.applicationDataDirectory);
            var finalTestFile = Ti.Filesystem.getFile(dir,"decryped.png");
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
        readPath:fileToDecrypt,
        completed:onCompleted
    });        
};



function testEncrypt(){

    var plainImage = Ti.Filesystem.getFile(Ti.Filesystem.resourcesDirectory,"test.png");
    
    var outputPath = ((Ti.Platform.Android)?
                    Ti.Filesystem.externalStorageDirectory : 
                    Ti.Filesystem.applicationDataDirectory) + "encrypted.png"; 

    function onCompleted(e){
         Ti.API.info(JSON.stringify(e));
          if(e.success){
                    Ti.API.info("Try to open the file " + e.result);
                    Ti.API.info("Now we will show decrypt");
                    testDecrypt(e.result);                
           }else{              
              Ti.API.info("something went wrong check your logs");
              Ti.API.info("error:" + e.message);
          }
    }
    
 
    crypto.writeEncrypt({
        password:password,
        inputValue:plainImage,
        outputPath:outputPath,
        completed:onCompleted
    });        
};

testEncrypt();