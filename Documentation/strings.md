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
var pdf = securely.createStringCrypto();
</code></pre>

<h2>Methods</h2>

<h3>AESEncrypt</h3> return string ( encrypted )

As the name implies this method uses the AES encryption algorithm to encrypt a string. This method returns an AES encrypted string of the plain text provided.  The password is used as the AES key during the encryption process.

<b>Arguments</b>

The AESEncrypt method takes the following arguments ( order is important ).

<b>1. Password</b> - (required) The password used as the encryption seed.

<b>2. text</b> - (required) The text you wish to encrypt.

<b>3. useHex</b> - (optional default of true) A boolean flag if you want the value to be converted to hex on the return. If false, you must provide the same parameter into the decrypt method.


<b>Example</b>
<pre><code>

</code></pre>

----

<h3>AESDecrypt</h3> return string ( plain text )

As the name implies this method uses the AES encryption algorithm to decrypt an AES encrypted string. This method decrypts the provided encrypted text using the password provided. After decryption is completed, a plain text string is returned.

<b>Arguments</b>

The AESDecrypt method takes the following arguments ( order is important ).

<b>1. Password</b> - (required) The password used as the encryption seed.

<b>2. text</b> - (required) The encrypted text you wish to decrypt.

<b>3. useHex</b> - (optional default of true) A boolean flag if the values should be converted to hex during the decryption process.  Is configuration must make that used in the AESEncrypt method call used to encrypt the string.

<b>Example</b>
<pre><code>

</code></pre>

----
