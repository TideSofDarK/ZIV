"use strict";

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
					var playerStatus = CustomNetTables.GetTableValue("gamesetup", "status");
					if (playerStatus && playerStatus[playerID]) {
						statusTextPanel.text = $.Localize("gamesetup_") + playerStatus[playerID];

						SetStatusIcon(statusIconPanel, "StatusConnected");
					} else {
						statusTextPanel.text = $.Localize("gamesetup_choosing_character");

						SetStatusIcon(statusIconPanel, "StatusReady");
					}
				} else {
					statusTextPanel.text = $.Localize("gamesetup_disconected");

					SetStatusIcon(statusIconPanel, "StatusDisconnected");
				}
			}
		}
	}
}

(function (){
	Game.SetAutoLaunchEnabled( false );

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