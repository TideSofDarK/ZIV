package {
	import flash.display.MovieClip;
	import ValveLib.Globals;
	
	import flash.utils.getQualifiedClassName;
	import flash.utils.getDefinitionByName;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.text.TextField;
	import flash.events.Event;
	import flash.display.*;
	
	public class CustomUI extends MovieClip{
		
		//these three variables are required by the engine
		public var gameAPI:Object;
		public var globals:Object;
		public var elementName:String;
		
		//constructor, you usually will use onLoaded() instead
		public function CustomUI() : void {
		}
		
		//this function is called when the UI is loaded
		public function onLoaded() : void {			
			//make this UI visible
			visible = true;

			//let the client rescale the UI
			Globals.instance.resizeManager.AddListener(this);

			globals.Loader_overlay.movieClip.removeChild(globals.Loader_overlay.movieClip.hud_overlay);
		}
	}
}