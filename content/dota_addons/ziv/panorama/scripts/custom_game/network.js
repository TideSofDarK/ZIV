"use strict";

var authKey = null;
var url = null;

function SendRequest( requestParams, successCallback )
{
    if (!authKey || ! url)
    {
        $.Msg('Auth key or URL is empty!');
        return;
    }

    requestParams.AuthKey = authKey;

    $.AsyncWebRequest(url,
        {
            type: 'POST',
            data: { 
                CommandParams: JSON.stringify(requestParams) 
            },
            success: successCallback,
            error: (function(data){
                $.Msg(data);
            })
        });
}

function SetAuthParams( args )
{
    authKey = args.AuthKey;
    url = args.URL;
}

function GetSteamID32() {
    var playerInfo = Game.GetPlayerInfo(Game.GetLocalPlayerID());

    var steamID64 = playerInfo.player_steamid,
        steamIDPart = Number(steamID64.substring(3)),
        steamID32 = String(steamIDPart - 61197960265728);

    return steamID32;
}

function GetDate() {
    var today = new Date();
    var dd = today.getDate();
    var mm = today.getMonth()+1; //January is 0!
    var yyyy = today.getFullYear();

    return yyyy * 10000 + mm * 100 + dd;
}

function LoadCharacters( callback ) {
    var requestParams = {
        Command: "LoadCharacters",
        SteamID: GetSteamID32()
    };

    GameUI.CustomUIConfig().SendRequest( requestParams, callback );    
}

function DeleteCharacter( ID, callback ) {
    var requestParams = {
        Command: "DeleteCharacter",
        ID: ID
    };

    GameUI.CustomUIConfig().SendRequest( requestParams, callback );    
}

(function() {
    GameUI.CustomUIConfig().SendRequest = SendRequest;
    GameUI.CustomUIConfig().LoadCharacters = LoadCharacters;
    GameUI.CustomUIConfig().DeleteCharacter = DeleteCharacter;
    GameEvents.Subscribe( "su_auth_params", SetAuthParams );
})();