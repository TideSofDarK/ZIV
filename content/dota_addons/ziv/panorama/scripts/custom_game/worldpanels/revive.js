var PlayerTables = GameUI.CustomUIConfig().PlayerTables;
var Util = GameUI.CustomUIConfig().Util;

function revive( panel ) {
  panel.SetPanelEvent("onactivate", function() { 

  });
  
  $.Schedule(0.2, panel.ItemCheck);
}

handlers.revive = revive;