[<< back to the Securely main page](https://github.com/benbahrenburg/Securely)

BenCoding.Securely.StringCrypto

The Securely StringCrypto module is used to encrypt and decrypt strings using a variety of methods.  

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


<h2>Creating the StringCrypto Object</h2>

The following demonstrates how to create a new instance of the Securely StringCrypto component.

<pre><code>
var stringCrypto = securely.createStringCrypto();
</code></pre>

<h2>Methods</h2>

<h3>AESEncrypt</h3>

As the name implies this method uses the AES encryption algorithm to encrypt a string. This method returns an AES encrypted string of the plain text provided.  The password is used as the AES key during the encryption process.

<b>Arguments</b>

The AESEncrypt method takes the following arguments ( order is important ).

<b>1. Password</b> - (required) The password used as the encryption seed.

<b>2. text</b> - (required) The text you wish to encrypt.

<b>3. useHex</b> - (optional default of true) A boolean flag if you want the value to be converted to hex on the return. If false, you must provide the same parameter into the decrypt method.

<b>Return value</b>
string ( encrypted )

<b>Example</b>
<pre><code>

var plainTextString = "this is a clear text example string";
var usingGUID = securely.generateDerivedKey(Ti.Platform.createUUID());  
Ti.API.info("Derived key using GUID = " + usingGUID);
var aesEncryptedString = stringCrypto.AESEncrypt(usingGUID,plainTextString);
Ti.API.info("aesEncryptedString =" + aesEncryptedString);

</code></pre>

----

<h3>AESDecrypt</h3>

As the name implies this method uses the AES encryption algorithm to decrypt an AES encrypted string. This method decrypts the provided encrypted text using the password provided. After decryption is completed, a plain text string is returned.

<b>Arguments</b>

The AESDecrypt method takes the following arguments ( order is important ).

<b>1. Password</b> - (required) The password used as the encryption seed.

<b>2. text</b> - (required) The encrypted text you wish to decrypt.

<b>3. useHex</b> - (optional default of true) A boolean flag if the values should be converted to hex during the decryption process.  Is configuration must make that used in the AESEncrypt method call used to encrypt the string.

<b>Return value</b>
string ( plain text )

<b>Example</b>
<pre><code>

Ti.API.info("Demonstrate using AES Decryption");
var aesDecryptedString = stringCrypto.AESDecrypt(usingGUID,aesEncryptedString);
Ti.API.info('aesDecryptedString=' + aesDecryptedString);

</code></pre>

----
<h3>DESEncrypt</h3>

As the name implies this method uses the DES encryption algorithm to encrypt a string. This method returns an DES encrypted string of the plain text provided.  The password is used as the DES key during the encryption process.

<b>Arguments</b>

The DESEncrypt method takes the following arguments ( order is important ).

<b>1. Password</b> - (required) The password used as the encryption seed.

<b>2. text</b> - (required) The text you wish to encrypt.

<b>3. useHex</b> - (optional default of true) A boolean flag if you want the value to be converted to hex on the return. If false, you must provide the same parameter into the decrypt method.

<b>Return value</b>
string ( encrypted )

<b>Example</b>
<pre><code>

var plainTextString = "this is a clear text example string";
var usingGUID = securely.generateDerivedKey(Ti.Platform.createUUID());  

Ti.API.info("Demonstrate using DES Encryption");
var desEncryptedString = stringCrypto.DESEncrypt(usingGUID,plainTextString);
Ti.API.info("desEncryptedString =" + desEncryptedString);

</code></pre>

----

<h3>DESDecrypt</h3>

As the name implies this method uses the DES encryption algorithm to decrypt an DES encrypted string. This method decrypts the provided encrypted text using the password provided. After decryption is completed, a plain text string is returned.

<b>Arguments</b>

The DESDecrypt method takes the following arguments ( order is important ).

<b>1. Password</b> - (required) The password used as the encryption seed.

<b>2. text</b> - (required) The encrypted text you wish to decrypt.

<b>3. useHex</b> - (optional default of true) A boolean flag if the values should be converted to hex during the decryption process.  Is configuration must make that used in the DESEncrypt method call used to encrypt the string.


<b>Return value</b>
string ( plain text )

<b>Example</b>
<pre><code>

Ti.API.info("Demonstrate using DES Decryption");
var desDecryptedString = stringCrypto.DESDecrypt(usingGUID,desEncryptedString);
Ti.API.info('desDecryptedString=' + desDecryptedString);

</code></pre>

----

<h3>sha256</h3>

This method takes a string value and returns a sha256 hash of the results.

<b>Arguments</b>

The sha256 method takes the following argument.

<b>text</b> - (required) The text you wish to hash.

<b>Return value</b>
string

----

<h3>sha512</h3>

This method takes a string value and returns a sha512 hash of the results.

<b>Arguments</b>

The sha512 method takes the following argument.

<b>text</b> - (required) The text you wish to hash.

<b>Return value</b>
string

----

<h3>toHex</h3>

This method takes a string value and returns a hex value of the results.

<b>Arguments</b>

The toHex method takes the following argument.

<b>text</b> - (required) The text you wish to hash.

<b>Return value</b>
string

----

<h3>fromHex</h3>

This method takes a hex value and returns a string

<b>Arguments</b>

The fromHex method takes the following argument.

<b>text</b> - (required) The hash code you wish converted to a string


<b>Return value</b>
string

----
