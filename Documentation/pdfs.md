[<< back to the Securely main page](https://github.com/benbahrenburg/Securely)

BenCoding.Securely.PDF

The Securely Properties module is used to store values in the KeyChain using the same API as Titanium.App.Properties.  

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


<h2>Creating the PDF Object</h2>
The following demonstrates how to create a new instance of the Securely PDF component.

<pre><code>
var pdf = securely.createPDF();
</code></pre>

<h2>Methods</h2>

<h3>protect</h3>( Dictionary options )
Creates a new password protected PDF using an existing unprotected PDF.

<b>Parameters</b>

The protected method takes a dictionary with the following options:

<b>userPassword</b> - User level password to lock the PDF with

<b>ownerPassword</b> - Owner level password to lock the PDF with

<b>from</b> - The path for an existing unlocked PDF to be used as the source to create a new locked PDF

<b>to</b> - The output path for a new locked PDF to be created using the source PDF provided in the from parameter

<b>allowCopy</b> - (true/false) if the locked PDF should allow for copying

<b>allowPrint</b> - (true/false) if the locked PDF should allow for printing

<b>completed</b> - The callback method that will be called after the locked PDF is created.

<b>Example</b>
<pre><code>
function onProtected(e){
  //Print full statement to the console
	Ti.API.info(JSON.stringify(e));
};
			
var inputFile = Ti.Filesystem.getFile(Ti.Filesystem.resourcesDirectory, 'my.pdf');				
var outputFile = Ti.Filesystem.getFile(Ti.Filesystem.applicationDataDirectory, 'myLocked.pdf');

pdf.protect({
	userPassword:"your_password",
	ownerPassword:"your_password",
	from:inputFile.nativePath,
	to:outputFile.nativePath,
	allowCopy:false,
	allowPrint:true,
	completed:onProtected
});
</code></pre>

----

<h3>unprotect</h3>( Dictionary options )
Creates a new unlocked PDF from an existing locked PDF document.

<b>Parameters</b>
The unprotect method takes a dictionary with the following options:

<b>password</b> - Owner level password to unlock the PDF

<b>from</b> - The path for an existing password protected PDF to be used as the source to create a new unlocked PDF

<b>to</b> - The output path for a new unlocked PDF to be created using the source PDF provided in the from parameter


<b>completed</b> - The callback method that will be called after the unlocked PDF is created.


<b>Example</b>
<pre><code>
function onUnlock(e){
  //Print full statement to the console
	Ti.API.info(JSON.stringify(e));
};

var protectedFile = Ti.Filesystem.getFile(Ti.Filesystem.applicationDataDirectory, 'myLocked.pdf'),
	unlockedFile = Ti.Filesystem.getFile(Ti.Filesystem.applicationDataDirectory, 'myUnlocked.pdf');
		
pdf.unprotect({
	password:txtPassword.value,
	from:protectedFile.nativePath,
	to:unlockedFile.nativePath,
	completed:onUnlock
});
</code></pre>

----
