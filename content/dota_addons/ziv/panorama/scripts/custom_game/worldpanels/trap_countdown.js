var time = -1.0;

Number.prototype.clamp = function(min, max) {
  return Math.min(Math.max(this, min), max);
};

function round(value, decimals) {
    return Number(Math.round(value+'e'+decimals)+'e-'+decimals);
}

function Countdown()
{
  var wp = $.GetContextPanel().WorldPanel
  var offScreen = $.GetContextPanel().OffScreen;
  if (!offScreen && wp){
    var ent = wp.entity;
    if (ent){
      if (time === -1.0) {
        time = parseFloat( wp.data["delay"] );
      }
      
      time = (time - 1/20).clamp(0, parseFloat( wp.data["delay"] ));
      $("#CountdownLabel").text = round(time * 10, 0);
    }
  }
  if ($("#CountdownLabel").text == "0" && $("#CountdownLabel").BHasClass("Nil") == false) {
    var boom = wp.data["boom"];
    if (!boom) {
      boom = "BOOM!";
    }
    $("#CountdownLabel").text = boom;
    $("#CountdownLabel").AddClass("Nil");
  }
  else
  {
    $.Schedule(1/20, Countdown);
  }
}

(function()
{
  Countdown();
})();