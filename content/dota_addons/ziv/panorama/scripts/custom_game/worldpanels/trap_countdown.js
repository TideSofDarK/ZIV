var time = -1.0;

Number.prototype.clamp = function(min, max) {
  return Math.min(Math.max(this, min), max);
};

function round(value, decimals) {
    return Number(Math.round(value+'e'+decimals)+'e-'+decimals);
}

function trapCountdown( panel )
{
  panel.Countdown = function(){
    var offScreen = panel.OffScreen;
    var entity = panel.Entity;

    if (!offScreen && entity){
      if (time === -1.0) {
        time = parseFloat( panel.Data["delay"] );
      }
      
      time = (time - 1/20).clamp(0, parseFloat( panel.Data["delay"] ));
      panel.FindChildTraverse("CountdownLabel").text = round(time * 10, 0);
    }

    if (panel.FindChildTraverse("CountdownLabel").text == "0" && panel.FindChildTraverse("CountdownLabel").BHasClass("Nil") == false) {
      var boom = panel.Data["boom"];
      if (!boom) {
        boom = "BOOM!";
      }

      panel.FindChildTraverse("CountdownLabel").text = boom;
      panel.FindChildTraverse("CountdownLabel").AddClass("Nil");
    }
    else
    {
      $.Schedule(1/20, panel.Countdown);
    }
  }

  $.Schedule(0.2, panel.Countdown);
}

handlers.trap_countdown = trapCountdown;