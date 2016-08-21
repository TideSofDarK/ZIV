"use strict";

var PlayerTables = GameUI.CustomUIConfig().PlayerTables;

function CreatePlayers() {

}

function SetStatusIcon(panel, status) {
	panel.SetHasClass("StatusDisconnected", status == "StatusDisconnected");
	panel.SetHasClass("StatusReady", status == "StatusReady");
	panel.SetHasClass("StatusConnected", status == "StatusConnected");
}

function Update() {
	$.Schedule(0.1, Update);

	for (var playerID = 0; playerID < GameUI.CustomUIConfig().mapMaxPlayers; playerID++) { //
		var playerInfo = Game.GetPlayerInfo( playerID );

		if (playerInfo != undefined) {
			var playerPanelName = "Player_" + playerID;
			var playerPanel = $("#"+playerPanelName);
			if (playerPanel) {
				playerPanel.FindChildTraverse("Avatar").steamid = playerInfo.player_steamid;
				playerPanel.FindChildTraverse("NameLabel").text = playerInfo.player_name;

				var statusIconPanel = playerPanel.FindChildTraverse("PlayerStatus");
				var statusTextPanel = playerPanel.FindChildTraverse("StatusLabel");
 
				if (playerInfo.player_connection_state == DOTAConnectionState_t.DOTA_CONNECTION_STATE_CONNECTED) {
					var playerStatus = PlayerTables.GetTableValue("gamesetup", "status");
					if (playerStatus && playerStatus[playerID]) {
						statusTextPanel.text = $.Localize("gamesetup_" + playerStatus[playerID]);

						if (playerStatus[playerID] == "ready") {
							SetStatusIcon(statusIconPanel, "StatusReady");
						} else { 
							SetStatusIcon(statusIconPanel, "StatusConnected");
						}
					} else {
						statusTextPanel.text = $.Localize("gamesetup_connected");

						SetStatusIcon(statusIconPanel, "StatusConnected");
					}
				} else {
					statusTextPanel.text = $.Localize("gamesetup_disconected");

					SetStatusIcon(statusIconPanel, "StatusDisconnected");
				}
			}
		}
	}
}

function CheckForHostPrivileges()
{
	var playerInfo = Game.GetLocalPlayerInfo();
	if ( !playerInfo )
		return;
 
	if (playerInfo.player_has_host_privileges) {
		Game.SetRemainingSetupTime( 3000 ); 
		Game.SetAutoLaunchEnabled( false );
	}
}

function Blur(args) {
	if (args.ui == "gamesetup") {
		$.GetContextPanel().AddClass("Blur");
	}
}

function RemoveBlur(args) {
	$.GetContextPanel().RemoveClass("Blur");
}

function OnGameSetupTableChanged(tableName, changesObject, deletionsObject) {
	if (changesObject["time"]) {
		var time = changesObject["time"]["time"]
		$("#TimeLabel").text = (Math.floor(time/60)) + ":" + (time%60);
	}
}

(function (){
	GameEvents.Subscribe( "ziv_apply_ui_blur", Blur );
	GameEvents.Subscribe( "ziv_remove_ui_blur", RemoveBlur );

	PlayerTables.SubscribeNetTableListener( 'gamesetup', OnGameSetupTableChanged );

	Game.PlayerJoinTeam(2);

	CheckForHostPrivileges();

	// Get max players for a map
	var mapInfo = Game.GetMapInfo();
	GameUI.CustomUIConfig().mapMaxPlayers = parseInt(mapInfo.map_display_name.replace( /^\D+/g, ''));

	for (var playerID = 0; playerID < GameUI.CustomUIConfig().mapMaxPlayers; playerID++) { //
		var playerPanelName = "Player_" + playerID;
		var playerPanel = $.CreatePanel("Panel", playerID < (GameUI.CustomUIConfig().mapMaxPlayers / 2) ? $("#PlayerListLeft") : $("#PlayerListRight"), playerPanelName);
		playerPanel.BLoadLayoutSnippet("Player" + (playerID >= (GameUI.CustomUIConfig().mapMaxPlayers / 2) ? "Right" : "Left"));
		
		playerPanel.SetHasClass("FramePadding", (playerID + 1) % 2 == 0);
	}

	Update();
})();