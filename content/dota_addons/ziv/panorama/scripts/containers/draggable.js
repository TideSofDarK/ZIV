var parentPanel = $.GetContextPanel().GetParent();

if (!GameUI.CustomUIConfig().PanelsQueue)
	GameUI.CustomUIConfig().PanelsQueue = [];

// Queue function
function AddToPanelsQueue()
{
	var panelsQueue = GameUI.CustomUIConfig().PanelsQueue;
	var panel = $.GetContextPanel();

	var num = panelsQueue.indexOf(panel);
	if (num > -1)
	{
		var temp = panelsQueue[num];

		panelsQueue.splice(num, 1);
		panelsQueue.push(temp);	
	}
	else
		panelsQueue.push(panel);

	// Set z-index
	for (var num in panelsQueue)
		if (panelsQueue[num])
			panelsQueue[num].style.zIndex = num + ";";
}

function RemoveFromPanelsQueue()
{
	var panelsQueue = GameUI.CustomUIConfig().PanelsQueue;
	var panel = $.GetContextPanel();

	var num = panelsQueue.indexOf(panel);
	if (num > -1)
		panelsQueue.splice(num, 1);
}

function OnDragStart( panelId, dragCallbacks )
{
  AddToPanelsQueue();

  var panel = $('#' + panelId);
  
  panel.style.verticalAlign = "top;";
  panel.style.horizontalAlign = "left;";

  dragCallbacks.displayPanel = panel;

  var cursor = GameUI.GetCursorPosition();

  dragCallbacks.offsetX = cursor[0] - panel.actualxoffset;
  dragCallbacks.offsetY = cursor[1] - panel.actualyoffset;
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
  // Show on top by click on panel
  $.GetContextPanel().SetPanelEvent("onmouseactivate", AddToPanelsQueue);

  $.RegisterEventHandler( 'DragStart', panel, OnDragStart );
  $.RegisterEventHandler( 'DragEnd', panel, OnDragEnd );

  panel.AddToPanelsQueue = AddToPanelsQueue;
  panel.RemoveFromPanelsQueue = RemoveFromPanelsQueue;	
})()