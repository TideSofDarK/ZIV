var teamColors = GameUI.CustomUIConfig().team_colors;

if (!teamColors) {
  GameUI.CustomUIConfig().team_colors = {}
  GameUI.CustomUIConfig().team_colors[DOTATeam_t.DOTA_TEAM_GOODGUYS] = "#3dd296;";
  GameUI.CustomUIConfig().team_colors[DOTATeam_t.DOTA_TEAM_BADGUYS ] = "#F3C909;";
  GameUI.CustomUIConfig().team_colors[DOTATeam_t.DOTA_TEAM_CUSTOM_1] = "#c54da8;";
  GameUI.CustomUIConfig().team_colors[DOTATeam_t.DOTA_TEAM_CUSTOM_2] = "#FF6C00;";
  GameUI.CustomUIConfig().team_colors[DOTATeam_t.DOTA_TEAM_CUSTOM_3] = "#3455FF;";
  GameUI.CustomUIConfig().team_colors[DOTATeam_t.DOTA_TEAM_CUSTOM_4] = "#65d413;";
  GameUI.CustomUIConfig().team_colors[DOTATeam_t.DOTA_TEAM_CUSTOM_5] = "#815336;";
  GameUI.CustomUIConfig().team_colors[DOTATeam_t.DOTA_TEAM_CUSTOM_6] = "#1bc0d8;";
  GameUI.CustomUIConfig().team_colors[DOTATeam_t.DOTA_TEAM_CUSTOM_7] = "#c7e40d;";
  GameUI.CustomUIConfig().team_colors[DOTATeam_t.DOTA_TEAM_CUSTOM_8] = "#8c2af4;";

  teamColors = GameUI.CustomUIConfig().team_colors;
}

teamColors[DOTATeam_t.DOTA_TEAM_NEUTRALS] = "#b53f51;";
teamColors[DOTATeam_t.DOTA_TEAM_NOTEAM]   = "#b53f51;";

function healthbar( panel )
{
  panel.HealthCheck = function(){
    if (panel == null)
      return;

    var offScreen = panel.OffScreen;
    var entity = panel.Entity;
    if (!offScreen && entity){
      if (!Entities.IsAlive(entity) || Entities.GetHealth(entity) == Entities.GetMaxHealth(entity)){
        panel.style.opacity = "0";

        $.Schedule(1/30, panel.HealthCheck);
        return;
      }

      //var pTeam = Players.GetTeam(Game.GetLocalPlayerID());
      var team = Entities.GetTeamNumber(entity);

      // Color by friendly/enemy
      /*if (team == pTeam)
        $.GetContextPanel().SetHasClass("Friendly", true);
      else
        $.GetContextPanel().SetHasClass("Friendly", false);*/

      panel.style.opacity = "1";
      var hp = Entities.GetHealth(entity);
      var hpMax = Entities.GetMaxHealth(entity);
      var hpPer = (hp * 100 / hpMax).toFixed(0);

      
      for (var i = 1; i <= 5; i++){
        var pan = panel.FindChildTraverse("HP" + i);
        var perc = Math.min(Math.max(0, hpPer), 20) * 5;

        pan.style.width = perc + "%;";
        pan.style.backgroundColor = teamColors[team];

        hpPer -= 20;
      }
    }

    $.Schedule(1/30, panel.HealthCheck);
  }

  $.Schedule(0.2, panel.HealthCheck);
}

handlers.healthbar = healthbar;