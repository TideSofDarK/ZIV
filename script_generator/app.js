
var exec = require('child_process').exec;
var path = require('path');

var fs = require('fs')

// Script directories
var settings = require('./settings.json');                              // The settings file

/*
	Make links
*/
var deleteFolderRecursive = function(path) {
  if( fs.existsSync(path) ) {
    fs.readdirSync(path).forEach(function(file,index){
      var curPath = path + "/" + file;
      if(fs.lstatSync(curPath).isDirectory()) { // recurse
        deleteFolderRecursive(curPath);
      } else { // delete file
        fs.unlinkSync(curPath);
      }
    });
    fs.rmdirSync(path);
  }
};

function makeLink( dir, link ) {
	try {
	    fs.accessSync(link, fs.F_OK);
	    fs.rmdirSync(link);
	} 
	catch (e) {
	    // It isn't accessible
	}

	if (fs.statSync(dir).isDirectory())
	{
		var cmd = 'mklink /D /J ' + '"' + path.resolve(link).replace(/\//g, '\\') + '" "' + path.resolve(dir).replace(/\//g, '\\') + '"';
		exec(cmd, function(error, stdout, stderr){ });

		//fs.symlinkSync(path.resolve(dir), link, 'junction');
	}
	else
		fs.link(dir, link);	
}

function makeLinks( dotaPath ) {
	console.log('Making links!');
	/*
    // Cleanup the old copy of it
	deleteFolderRecursive("../dota");

	var dirs = require('./dirs.json');
	
	// Make dirs
	dirs.makeDirs.forEach(function(element, index, array){
 		fs.mkdirSync('../' + element);
	})

	// Create links
	dirs.linkDirs.forEach(function(element, index, array){
		makeLink( element.dir, element.link )
	})
*/
	// Make links for content and game dirs
	var content = '/content/dota_addons/' + settings.addonName;
	var game = '/game/dota_addons/' + settings.addonName;

	makeLink( ".." + content, dotaPath + content );
	makeLink( ".." + game, dotaPath + game );
}


function execScript() {
	// Get Steam path
	var cmd = "reg query HKEY_CURRENT_USER\\Software\\Valve\\Steam /v SteamPath";
	exec(cmd, function(error, stdout, stderr) {
		// Set Dota 2 dir from registry or settings
	  	var dotaPath = stdout.match(/(?=REG_SZ).*/g)[0].replace('REG_SZ', '').trim() + '/SteamApps/common/dota 2 beta/' || settings.dotaDir;
		
	  	// Run compiling
		makeLinks( dotaPath );
	});
}


execScript();