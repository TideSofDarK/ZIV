var PlayerTables = GameUI.CustomUIConfig().PlayerTables;
var subscription = null; 

const HA_CENTER = 0;
const HA_LEFT   = 1; 
const HA_RIGHT  = 2; 
const VA_BOTTOM = 0; 
const VA_CENTER = 1; 
const VA_TOP    = 2; 


$.Msg("barebones_worldpanels.js");
var panels = {};
var entities = [];
//{panel, position, entity, offsetX, offsetY, hAlign, vAlign, entityHeight, edge}

// panel deletion call?
// Delete call to server for cleanup

function Position( wp, k )
{
    var pos = wp.position;
    if (!pos){
      if (!Entities.IsValidEntity(wp.entity)){
        panels[k].panel.DeleteAsync(0);
        delete panels[k];
        return
      }

      pos = Entities.GetAbsOrigin(wp.entity);
      if (entities.indexOf(wp.entity) === -1){
        wp.panel.visible = false;
        return
      }
      wp.panel.visible = true;

      pos[2] += wp.entityHeight || 0;
    }
 
    var wx = Game.WorldToScreenX(pos[0], pos[1], pos[2]);
    var wy = Game.WorldToScreenY(pos[0], pos[1], pos[2]);
    var sw = GameUI.CustomUIConfig().screenwidth;
    var sh = GameUI.CustomUIConfig().screenheight;
    var scale = 1080 / sh;

    var x = scale * wx + wp.offsetX;
    wx = wx + wp.offsetX
    var y = scale * wy + wp.offsetY;
    wy = wy + wp.offsetY

    var pw = wp.panel.actuallayoutwidth;
    var ph = wp.panel.actuallayoutheight;

    switch(wp.hAlign){
      case HA_LEFT:
        break;
      case HA_RIGHT:
        x-= pw;
        break;
      case HA_CENTER:
      default:
        x-= pw/2;
        break;
    };
    switch(wp.vAlign){
      case VA_TOP:
        break;
      case VA_CENTER:
        y-= ph/2;
        break;
      case VA_BOTTOM:
      default:
        y-= ph;
        break;
    };

    if (wp.edge !== -1){
      var padx = sw * wp.edge / 100;
      var pady = sh * wp.edge / 100;

      var oldx = x;
      var oldy = y;

      x = Math.max(padx,Math.min((sw-pw-padx)*scale, x));
      y = Math.max(pady,Math.min((sh-ph-pady)*scale, y));

      //$.Msg(oldx, ' -- ', oldy, '          ', wx, ' -- ', wy, '          ', x, ' -- ', y)

      if (x !== oldx || y !== oldy){
        wp.panel.OnEdge = true;

        var center =  Game.ScreenXYToWorld(sw/2, sh/2)
        var center2 = GameUI.GetScreenWorldPosition(sw/2, sh/2 + 1)
        if (center && center2){
          var diff = [center2[0]-center[0], center2[1]-center[1]]
          var diff2 = [pos[0]-center[0], pos[1]-center[1]]

          var ang = Math.atan2(diff2[1], diff2[0]) - Math.atan2(diff[1], diff[0]) - Math.PI/2
          x = Math.cos(ang)
          y = -1*Math.sin(ang)
          var xscale = ((sw-2*padx)/2 / x)
          var yscale = ((sh-2*pady)/2 / y)
          var minscale = Math.min(Math.abs(xscale), Math.abs(yscale));
          x = x * minscale + sw/2
          y = y * minscale + sh/2

          x = x - pw * (x/(sw-pw));
          y = y - ph * (y/(sh-ph));

          x *= scale;
          y *= scale;

          x = x.toFixed(1)
          y = y.toFixed(1)

        }
        else{
          x = NaN;
          y = NaN;
        }
        
      }
      else
        wp.panel.OnEdge = false;

    }
    else{
      if (x < pw || x > sw || y < ph || y > sh)
        wp.panel.OffScreen = true;
      else
        wp.panel.OffScreen = false;
    }

    if (!isFinite(x) || isNaN(x) || !isFinite(y) || isNaN(y))
    {
      x = -1000;
      y = -1000;
      wp.panel.visible = false;
    }
    else
    {
      wp.panel.visible = true;  
    }
    
    wp.panel.style.position = x + "px " + y + "px 0px;";
    
    wp.panel.X = x;
    wp.panel.Y = y;
}

function UpdateParams( panel )
{
    var sh = GameUI.CustomUIConfig().screenheight;
    var scale = 1080 / sh;

    panel.X = panel.actualxoffset * scale;
    panel.Y = panel.actualyoffset * scale;

    panel.Width = panel.actuallayoutwidth * scale;
    panel.Height = panel.actuallayoutheight * scale;
}

function WorldPanelChange(id, changes, dels)
{
  //$.Msg("change ", id, ' -- ', changes, ' -- ', dels);
  for (var k in changes){
    var wp = panels[k];
    if (!wp){
      wp = {};
      panels[k] = wp;
    }

    if (changes[k].layout !== wp.layout){
      if (wp.panel)
        wp.panel.DeleteAsync(0);

      wp.panel = $.CreatePanel( "Panel", $.GetContextPanel(), "" );
      wp.panel.BLoadLayout(changes[k].layout, false, false);
      wp.panel.WorldPanel = wp;
      wp.panel.Data = wp.data;
      wp.panel.OnEdge = false;
      wp.panel.OffScreen = false;

      wp.panel.X = 0;
      wp.panel.Y = 0;

      wp.panel.DeleteWorldPanel = function(pan){ 
        return function(){
          pan.DeleteAsync(0);
          delete panels[k];
        }
      }(wp.panel);

      wp.Position = function() {
        return function(){
          Position(wp, k);
        }
      }(wp, k);

      wp.panel.UpdateParams = function() {
        return function(){
          UpdateParams(wp.panel);
        }
      }(wp.panel);

      wp.panel.UpdateParams();
    }

    for (j in changes[k]){
      if (j == "position"){
        wp[j] = changes[k][j].split(' ');
        wp[j] = [parseFloat(wp[j][0]), parseFloat(wp[j][1]), parseFloat(wp[j][2])]
      }
      else
        wp[j] = changes[k][j];
    }
    
    //wp.dirty = true;
    wp.offsetX = wp.offsetX || 0;
    wp.offsetY = wp.offsetY || 0;
    wp.entityHeight = wp.entityHeight || 0;
    wp.hAlign = wp.hAlign || HA_CENTER;
    wp.vAlign = wp.vAlign || VA_BOTTOM;
    wp.edge = wp.edge || -1;

  }

  for (var k in dels){
    panels[k].panel.DeleteAsync(0);
    delete panels[k];
  }
}

//-----------------------------------------------------------------------------
// Panels reposition
//-----------------------------------------------------------------------------
var positionPanels = [];

function IsInside( checkElem, elem )
{
    var lt_c = { x: checkElem.X, y: checkElem.Y };
    var rb_c = { x: checkElem.X + checkElem.Width, y: checkElem.Y + checkElem.Height };

    var lt = { x: elem.X, y: elem.Y };
    var rb = { x: elem.X + elem.Width, y: elem.Y + elem.Height };
    
    return { 
        x: rb.x - lt_c.x >= 0,
        y: rb.y - lt_c.y >= 0
    };
}

function RemoveIntersectsGrid( checkElem, elem )
{
    var isInside = IsInside( checkElem, elem );
    if (isInside.x && Math.abs(checkElem.Y - elem.Y) < 2)
    {
        var newPosX = elem.X + elem.Width;
      
        var offset = checkElem.Y % checkElem.Height;
        offset = isNaN(offset) ? 0 : offset
        var count = offset / checkElem.Height < 0.5 ? 0 : 1;

        checkElem.style.position = parseInt(newPosX) + "px " + parseInt(checkElem.Y - offset + count * checkElem.Height ) + "px 0px;";
        checkElem.UpdateParams();
    }
}

function CheckElement( elem )
{
    var index = positionPanels.indexOf(elem);
    positionPanels.forEach(function(item, i, arr){
        if (i >= index)
            return;

        RemoveIntersectsGrid( elem, item );
    });
}

function RepositionItems()
{
    positionPanels.forEach(function(item, i, arr) {
        var offset = item.Y % item.Height;
        offset = isNaN(offset) ? 0 : offset
        var count = offset / item.Height < 0.5 ? 0 : 1;

        item.style.position = parseInt(item.X) + "px " + parseInt(item.Y - offset + count * item.Height ) + "px 0px;";
        item.UpdateParams();
    });

    positionPanels.sort(function(a, b){
        if (Math.abs(a.Y - b.Y) < 3)
          return a.X < b.X ? -1 : 1;

        return a.Y < b.Y ? -1 : 1;
    });

    positionPanels.forEach(function(item, i, arr) {
        CheckElement(item);
    });
}

function PositionPanels()
{
  positionPanels = [];

  //$.Msg(Object.keys(panels).length);
  for (var k in panels){
    var wp = panels[k];
    wp.Position();
    wp.panel.UpdateParams();

    positionPanels.push(wp.panel);
  }

  RepositionItems();

  $.Schedule(1/200, PositionPanels);
}

function ScreenHeightWidth()
{
  var panel = $.GetContextPanel();

  GameUI.CustomUIConfig().screenwidth = panel.actuallayoutwidth;
  GameUI.CustomUIConfig().screenheight = panel.actuallayoutheight;  

  $.Schedule(1/2, ScreenHeightWidth);
}

function UpdateEntities()
{
  if (Object.keys(panels).length > 0)
    entities = Entities.GetAllEntities();

  $.Schedule(1/10, UpdateEntities);
}

(function()
{ 
  var pt = "worldpanels_" +  Game.GetLocalPlayerID()
  ScreenHeightWidth(); 
  PositionPanels();
  UpdateEntities();

  entities = Entities.GetAllEntities();

  if ($.GetContextPanel().subscription !== undefined){
    PlayerTables.UnsubscribeNetTableListener($.GetContextPanel().subscription);
  }

  subscription = PlayerTables.SubscribeNetTableListener(pt, WorldPanelChange);

  var tab = PlayerTables.GetAllTableValues(pt);
  for (var k in tab){
    var change = {};
    change[k] = tab[k];
    WorldPanelChange(pt, change, {}); 
  } 

  $.GetContextPanel().subscription = subscription;
})();