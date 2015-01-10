var win = Ti.UI.createWindow({
	backgroundColor:'white', layout:'vertical'
});

var securely = require('bencoding.securely');
Ti.API.info("module is => " + securely);

var password = "foo";
var pdf = securely.createPDF();
	
var btnLock = Ti.UI.createButton({
	title:'Lock PDF', top:25, height:45, left:5, right:5	
});
win.add(btnLock);

var btnUnlock = Ti.UI.createButton({
	title:'Unlock PDF', top:25, height:45, left:5, right:5	
});
win.add(btnUnlock);


btnLock.addEventListener('click',function(x){

	function onProtected(e){
	    //Print full statement to the console
	    Ti.API.info(JSON.stringify(e));
	};
		
	var inputFile = Ti.Filesystem.getFile(Ti.Filesystem.resourcesDirectory, '2012pit.pdf');				
	var outputFile = Ti.Filesystem.getFile(Ti.Filesystem.applicationDataDirectory, 'locked.pdf');
	
	pdf.protect({
		userPassword:password,
		ownerPassword:password,
		from:inputFile.nativePath,
		to:outputFile.nativePath,
		allowCopy:false,
		allowPrint:true,
		completed:onProtected
	});
});

btnUnlock.addEventListener('click',function(x){
	
	function onUnlock(e){
		//Print full statement to the console
		Ti.API.info(JSON.stringify(e));
	};

	var protectedFile = Ti.Filesystem.getFile(Ti.Filesystem.applicationDataDirectory, 'locked.pdf'),
		unlockedFile = Ti.Filesystem.getFile(Ti.Filesystem.applicationDataDirectory, 'unlocked.pdf');
	
	if(!protectedFile.exists()){
		alert('Please run PDF Lock sample first');
		return;
	}
	
	pdf.unprotect({
		password:password,
		from:protectedFile.nativePath,
		to:unlockedFile.nativePath,
		completed:onUnlock
	});
});
win.open();

