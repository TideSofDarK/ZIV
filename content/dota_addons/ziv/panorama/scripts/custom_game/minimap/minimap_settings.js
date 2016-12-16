"use strict";

var settings = {
	visible: true,
	rotation: 45,
	filter: function( entity ){
		return false;
	},
	marks: function( entity ){
		var type = "default";
		if (Entities.IsHero( entity ))
			return "hero";

		return type;		
	}
};

function SetMinimapSettings( newSettings ) {
	if (!newSettings)
		return;

	for(var key of Object.keys(newSettings)){
		if (!settings.hasOwnProperty(key))
			continue;

		settings[key] = newSettings[key];
		
		switch(key)	{
			case 'visible':
				$.GetContextPanel().visible = settings.visible;
				break;
			case 'rotation':
				UpdateRotation();
				break;
		}
	}
}

function updateRotation() {
	$('#ImagePanel').style.transform = 'rotateZ( ' + settings.rotation + 'deg );';

	var childCount = $('#MarksMap').GetChildCount();
	for(var i = 0; i < childCount; i++)
		$('#MarksMap').GetChild(i).style.transform = 'rotateZ( ' + -settings.rotation + 'deg );';

	childCount = $('#EventsMap').GetChildCount();
	for(var i = 0; i < childCount; i++)
		$('#EventsMap').GetChild(i).style.transform = 'rotateZ( ' + -settings.rotation + 'deg );';
}

(function()
{
	SetMinimapSettings(settings);
	GameUI.CustomUIConfig().SetMinimapSettings = SetMinimapSettings; 
})();