[<< back to the Securely main page](https://github.com/benbahrenburg/Securely)

BenCoding.Securely.FileCrypto

The Securely FileCrypto module is used to encrypt and decrypt files using the AES encryption algorithm.  

<h2>Getting Started</h2>
* First you need to download and install the module as discussed [here.](https://github.com/benbahrenburg/Securely)
* You can now use the module via the commonJS require method, example shown below.

<pre><code>
var securely = require('bencoding.securely');
</code></pre>

<h2>Requiring Securely into your project</h2>

Requiring the module into your project

<pre><code>
//Require the securely module into your project
var securely = require('bencoding.securely');

</code></pre>


<h2>Creating the FileCrypto Object</h2>

The following demonstrates how to create a new instance of the Securely FileCrypto component.

<pre><code>
var fileCrypto = securely.createFileCrypto()
</code></pre>

<h2>Methods</h2>

<h3>AESEncrypt</h3> 

As the name implies this method uses the AES encryption algorithm to encrypt a file.  The password is used as the AES key during the encryption process.

<b>Parameters</b>

The AESEncrypt method takes a dictionary with the  following properties.

<b>1. password</b> - (required) The password used as the encryption seed.

<b>2. from</b> - (required) The file nativePath you wish to be encrypted

<b>3. to</b> - (required) The file nativePath in which the encrypted file should be generated to. If the file exists, it will be deleted before being created.

<b>4. completed</b> - (required) The callback method used to return the results of the encryption process.


<b>Example</b>
<pre><code>

function onEncryptCompleted(e){
  //Print full statement to the console
	Ti.API.info(JSON.stringify(e));
	if(e.success){
		alert('Encrypted file created at: ' + e.to);
		var test = Ti.Filesystem.getFile(e.to);
		if(!test.exists()){
			Ti.API.info("test failed, file missing");
		}else{
			Ti.API.info("Test file contents:\n" + (test.read()).text);	
		}	
	}else{
		alert('failed due to: ' + e.message);
	}
};

var plainTextFile = Ti.Filesystem.getFile(Ti.Filesystem.resourcesDirectory, 'PlainText.txt'),
	  futureEncrypted = Ti.Filesystem.getFile(Ti.Filesystem.applicationDataDirectory, 'encryptedFile.txt');

fileCrypto.AESEncrypt({
	password:"your password",
	from:plainTextFile.nativePath,
	to:futureEncrypted.nativePath,
	completed:onEncryptCompleted
});

</code></pre>

----

<h3>AESDecrypt</h3>

As the name implies this method uses the AES encryption algorithm to decrypt a file.  The password is used as the AES key during the encryption process.

<b>Parameters</b>

The AESDecrypt method takes a dictionary with the  following properties.

<b>1. password</b> - (required) The password used as the encryption seed.

<b>2. from</b> - (required) The file nativePath you wish to be decrypt

<b>3. to</b> - (required) The file nativePath in which the unencrypted file should be generated to. If the file exists, it will be deleted before being created.

<b>4. completed</b> - (required) The callback method used to return the results of the decryption process.


<b>Example</b>
<pre><code>

function onDecryptCompleted(e){
  //Print full statement to the console
	Ti.API.info(JSON.stringify(e));
	if(e.success){
		alert('Decrypted file created at: ' + e.to);
		var test = Ti.Filesystem.getFile(e.to);
		if(!test.exists()){
			Ti.API.info("test failed, file missing");
		}else{
			Ti.API.info("Test file contents:\n" + (test.read()).text);	
		}	
	}else{
		alert('failed due to: ' + e.message);
	}
};

var encryptedFile = Ti.Filesystem.getFile(Ti.Filesystem.applicationDataDirectory, 'encryptedFile.txt'),
	  futureDecrypted = Ti.Filesystem.getFile(Ti.Filesystem.applicationDataDirectory, 'decryptedFile.txt');

fileCrypto.AESDecrypt({
	password:"your password",
	from:encryptedFile.nativePath,
	to:futureDecrypted.nativePath,
	completed:onDecryptCompleted
});
</code></pre>

----
