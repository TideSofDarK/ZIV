var parentPanel = $.GetContextPanel().GetParent();

function OnDragStart( panelId, dragCallbacks )
{
  var panel = $('#' + panelId);
  
  panel.style.verticalAlign = "top;";
  panel.style.horizontalAlign = "left;";

  dragCallbacks.displayPanel = panel;

  var cursor = GameUI.GetCursorPosition();

  dragCallbacks.offsetX = cursor[0] - panel.actualxoffset;//250;
  dragCallbacks.offsetY = cursor[1] - panel.actualyoffset;//20;
  dragCallbacks.removePositionBeforeDrop = false;
  return false;
} 

function OnDragEnd( panelId, draggedPanel )
{
  $('#' + panelId).SetParent(parentPanel);
  return false; 
} 

function NullDragStart( panelId, dragCallbacks)
{
  return true;
}

function NullDragEnd( panelId, draggedPanel)
{
  return true;
}

(function(){
  var panel = $.GetContextPanel();

  $.RegisterEventHandler( 'DragStart', panel, OnDragStart );
  $.RegisterEventHandler( 'DragEnd', panel, OnDragEnd );


})()