BenCoding.Securely.Properties

The Securely Properties moduel is used to store values in the KeyChain using the same API as Titanium.App.Properties.  

<h2>Getting Started</h2>
* First you need to download and install the module as discussed [here.](https://github.com/benbahrenburg/Securely)
* You can now use the module via the commonJS require method, example shown below.

<pre><code>
var securely = require('bencoding.securely');
</code></pre>

<h2>Creating the Properties Object</h2>

Requiring the module into your project

<pre><code>
//Require the securely module into your project
var securely = require('bencoding.securely');
//Create a new properties object
var properties = securely.createProperties();
</code></pre>

<h2>Methods</h2>

<b>addEventListener</b>( String name, Callback<Object> callback )
Adds the specified callback as an event listener for the named event.

<b>Parameters</b>
name : String
Name of the event.
callback : Callback<Object>
Callback function to invoke when the event is fired.

<b>Returns</b>
void

<b>Example</b>
<pre><code>
function onChange(e){
    Ti.API.info("Property " + e.source + " changed");
};
//Use the properties variable shown in the require section
properties.addEventListener('changed',onChange);
</code></pre>

----

<b>getBool</b>( String property, [Boolean default] ) : Boolean
Returns the value of a KeyChain Property as a boolean data type.

<b>Parameters</b>
property : String
Name of property.
default : Boolean (optional)
Default value to return if KeyChain Property does not exist.

<b>Returns</b>
Boolean

<b>Example</b>
<pre><code>
//Use the properties variable shown in the require section
Titanium.API.debug('Bool: ' + properties.getBool('whatever',true));
</code></pre>

----

<b>getDouble</b>( String property, [Number default] ) : Number
Returns the value of a KeyChain Property as a double (double-precision, floating point) data type.
This method must only be used to retrieve properties created with setDouble.

<b>Parameters</b>
property : String
Name of property.
default : Number (optional)
Default value to return if KeyChain Property does not exist.

<b>Returns</b>
Number


<b>Example</b>
<pre><code>
//Use the properties variable shown in the require section
Titanium.API.debug('Double: ' + (properties.getDouble('whatever',2.5));
</code></pre>

----

<b>getInt</b>( String property, [Number default] ) : Number
Returns the value of a KeyChain Property as an integer data type.
This method must only be used to retrieve properties created with setInt.
Use getDouble and setDouble to store values outside the integer data type range of -2,147,483,648 to 2,147,483,647.

<b>Parameters</b>
property : String
Name of property.
default : Number (optional)
Default value to return if KeyChain Property does not exist.

<b>Returns</b>
Number

<b>Example</b>
<pre><code>
//Use the properties variable shown in the require section
Titanium.API.debug('int: ' +  properties.getInt('whatever',1));
</code></pre>

----

<b>getList</b>( String property, [Object[] default] ) : Object[]
Returns the value of a KeyChain Property as an array data type.

<b>Parameters</b>
property : String
Name of property.
default : Object[] (optional)
Default value to return if KeyChain Property does not exist.

<b>Returns</b>
Object[]

<b>Example</b>
<pre><code>
//Use the properties variable shown in the require section
Titanium.API.debug('StringList: ' + properties.getList('whatever'));
</code></pre>

----

<b>getObject</b>( String property, [Object default] ) : Object
Returns the value of a KeyChain Property as an object.

<b>Parameters</b>
property : String
Name of property.
default : Object (optional)
Default value to return if KeyChain Property does not exist.

<b>Returns</b>
Object

<b>Example</b>
<pre><code>
//Use the properties variable shown in the require section
Titanium.API.debug('Object: ' + properties.getObject('whatever'));
</code></pre>

----

<b>getString</b>( String property, [String default] ) : String
Returns the value of a KeyChain Property as a string data type.

<b>Parameters</b>
property : String
Name of property.
default : String (optional)
Default value to return if KeyChain Property does not exist.

<b>Returns</b>
String

<b>Example</b>
<pre><code>
//Use the properties variable shown in the require section
Titanium.API.debug('String: ' + properties.getString('whatever','foo'));
</code></pre>

----

<b>hasProperty</b>( String property ) : Boolean
Indicates whether a KeyChain Property exists.

<b>Parameters</b>
property : String
Name of property.

<b>Returns</b>
Boolean

<b>Example</b>
<pre><code>
//Use the properties variable shown in the require section
var exists = properties.hasProperty('String');
Titanium.API.info('String Property '+ ((exists)? " Exists" : " Doesn't Exist"));
</code></pre>

----

<b>listProperties</b>( ) : Object[]
Returns an array of KeyChain Property names.

<b>Returns</b>
Object[]

<b>Example</b>
<pre><code>
//Use the properties variable shown in the require section
//Will provide the name of all properties
var foo = properties.listProperties();
</code></pre>

----

<b>removeEventListener</b>( String name, Callback<Object> callback )
Removes the specified callback as an event listener for the named event.
Multiple listeners can be registered for the same event, so the callback parameter is used to determine which listener to remove.
When adding a listener, you must save a reference to the callback function in order to remove the listener later:
var listener = function() { Ti.API.info("Event listener called."); }
window.addEventListener('click', listener);
To remove the listener, pass in a reference to the callback function:
window.removeEventListener('click', listener);

<b>Parameters</b>
name : String
Name of the event.
callback : Callback<Object>
Callback function to remove. Must be the same function passed to addEventListener.

<b>Returns</b>
void

<b>Example</b>
<pre><code>
//Use the properties variable shown in the require section
//Remove the method we added in the addEventListener section
properties.removeEventListener('changed',onChange);

</code></pre>

----

<b>removeProperty</b>( String property )
Removes a KeyChain Property if it exists, or does nothing otherwise.

<b>Parameters</b>
property : String
Name of property.

<b>Returns</b>
void

<b>Example</b>
<pre><code>
//Use the properties variable shown in the require section
var exists = properties.hasProperty('String');
Titanium.API.info('String Property '+ ((exists)? " Exists" : " Doesn't Exist"));
properties.removeProperty('String');
exists = properties.hasProperty('String');
Titanium.API.info('String Property '+ ((exists)? " Exists" : " Doesn't Exist"));
</code></pre>

----

<b>removeAllProperties</b>
Removes all KeyChain properties

<b>Parameters</b>
N/A

<b>Returns</b>
void

<b>Example</b>
<pre><code>
//Use the properties variable shown in the require section
var exists = properties.hasProperty('String');
Titanium.API.info('String Property '+ ((exists)? " Exists" : " Doesn't Exist"));
properties.removeAllProperties();
exists = properties.hasProperty('String');
Titanium.API.info('String Property '+ ((exists)? " Exists" : " Doesn't Exist"));
</code></pre>

----

<b>setBool</b>( String property, Boolean value )
Sets the value of a KeyChain Property as a boolean data type. The KeyChain Property will be created if it does not exist.

<b>Parameters</b>
property : String
Name of property.
value : Boolean
Property value.

<b>Returns</b>
void

<b>Example</b>
<pre><code>
//Use the properties variable shown in the require section
properties.setString('String','I am a String Value ');
</code></pre>

----

<b>setDouble</b>( String property, Number value )
Sets the value of a KeyChain Property as a double (double-precision, floating point) data type. The KeyChain Property will be created if it does not exist.

<b>Parameters</b>
property : String
Name of property.
value : Number
Property value.

<b>Returns</b>
void

<b>Example</b>
<pre><code>
//Use the properties variable shown in the require section
properties.setDouble('Double',10.6);
</code></pre>

----

<b>setInt</b>( String property, Number value )
Sets the value of a KeyChain Property as an integer data type. The KeyChain Property will be created if it does not exist.
Use getDouble and setDouble to store values outside the integer data type range of -2,147,483,648 to 2,147,483,647.

<b>Parameters</b>
property : String
Name of property.
value : Number
KeyChain Property value, within the range -2,147,483,648 to 2,147,483,647.

<b>Returns</b>
void

<b>Example</b>
<pre><code>
//Use the properties variable shown in the require section
properties.setInt('Int',10);
</code></pre>

----

<b>setList</b>( String property, Object[] value )
Sets the value of a KeyChain Property as an array data type. The KeyChain Property will be created if it does not exist.

<b>Parameters</b>
property : String
Name of property.
value : Object[]
Property value.
<b>Returns</b>
void

<b>Example</b>
<pre><code>
var array = [
  {name:'Name 1', address:'1 Main St'},
	{name:'Name 2', address:'2 Main St'},
	{name:'Name 3', address:'3 Main St'},
	{name:'Name 4', address:'4 Main St'}	
];

//Use the properties variable shown in the require section
properties.setList('MyList',array);
</code></pre>

----

<b>setObject</b>( String property, Object value )
Sets the value of a KeyChain Property as an object data type. The KeyChain Property will be created if it does not exist.

<b>Parameters</b>
property : String
Name of property.
value : Object
Property value.
<b>Returns</b>
void

<b>Example</b>
<pre><code>
var array = [
	{name:'Name 1', address:'1 Main St'},
	{name:'Name 2', address:'2 Main St'},
	{name:'Name 3', address:'3 Main St'},
	{name:'Name 4', address:'4 Main St'}	
];
	
//Use the properties variable shown in the require section
properties.setObject('MyObject',array);
</code></pre>

----

<h2>Events</h2>

<b>changed</b>
The event is fired when the application changes a KeyChain Property directly using one of the Properties methods.

<h2>Dependent Projects</h2>
Securely for iOS uses several wonderful open source projects.  I highly encourage you to check them out using the information below.

JSONKit 

Project: [http://github.com/johnezang/JSONKit](http://github.com/johnezang/JSONKit)

PDKeychainBindingsController

Project: [https://github.com/carlbrown/PDKeychainBindingsController](https://github.com/carlbrown/PDKeychainBindingsController)

<h2>FAQ</h2>

<h3>What happens when I uninstall my App?</h3>
Please note the keyChain entries will still present on the device after you uninstall your app.  You will need to design your app workflow to handle this if there is a need to remove or refresh these entries.

This is a feature of the Apple KeyChain API itself and beyond the control of the module.

