"use strict";

var Util = GameUI.CustomUIConfig().Util;

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

function LoadCharacters( callback ) {
    var requestParams = {
        Command: "LoadCharacters",
        SteamID: Util.GetSteamID32()
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