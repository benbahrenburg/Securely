[<< back to the Securely main page](https://github.com/benbahrenburg/Securely)

BenCoding.Securely

The key generation methods are available at the root of the securely module.

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


<h2>Methods</h2>

<h3>generateDerivedKey</h3>

The generateDerivedKey method takes an input string and uses this string as a seed to generate a derived key.  This key then can be used as a password or key for later encryption method.

<b>Arguments</b>

The generateDerivedKey method takes the following arguments ( order is important ).

<b>1. String</b> - (required) String to be used as the derived key's seed value.


<b>Return value</b>
String

<b>Example</b>
<pre><code>

var usingGUID = securely.generateDerivedKey(Ti.Platform.createUUID());	
Ti.API.info("Derived key using GUID = " + usingGUID);

</code></pre>

----

<h3>generateRandomKey</h3>

The generateRandomKey method generates a randomly generated key.  This key then can be used as a password or key for later encryption method.

<b>Arguments</b>
None

<b>Return value</b>
String

<b>Example</b>
<pre><code>

var randomKey = securely.generateRandomKey();
Ti.API.info("Random Key = " + randomKey);

</code></pre>

----
