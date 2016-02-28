'use strict';
var contextPanel = $.GetContextPanel();

//-----------------------------------------------------------------------------
//                              Styles
//-----------------------------------------------------------------------------
var MaterialStyles = {
  "AppBar" : [ "DarkTheme", "Primary500", "z-index3" ],
  "BackgroundPanel" : [ "DarkTheme", "Background", "z-index1" ],
  "SelectionRoot" : [ "DarkTheme", "Background", "z-index1" ],
  "CharacterNameLabel" : [ "DarkTheme", "PrimaryText", "z-index1" ],
  "CharacterDescrLabel" : [ "DarkTheme", "SecondaryText", "z-index1" ],
  "ChooseButton" : [ "DarkTheme", "PrimaryText", "z-index1" ],
};


// Set style recursively
function SetStyles( panel )
{
  var materialStyleName = panel.GetAttributeString("MaterialStyle", "");

  if (materialStyleName != "")
  {
    var styles = MaterialStyles[materialStyleName];

    if (styles != null)
      for(var styleName of styles)
        panel.AddClass(styleName);

  }

  var childCount = panel.GetChildCount();
  for (var i = 0; i < childCount; i++)
    SetStyles( panel.GetChild(i) );
}

(function () {
    SetStyles( contextPanel );
})();