package fs.basicstructure;

import flash.display.Sprite;
import flash.events.Event;
import flash.Lib;
import fs.screenmanager.ScreenManager;

/**
 * 
 * This is a basic structure for a project. 
 * It contains basic screens and this class as a core.
 * To use it, make your Main class inherit from Game (this class)
 * It includes the basics of screen manager, Update and Render loops and previously mentioned screens.
 * These screens are meant to be used as templates for your own screens.
 * 
 * @author Henry D. Fernández B.
 */
class Game extends Sprite 
{
	private var inited : Bool;
	
	private var lastTime : Float;
	
	private var screenManager : ScreenManager;

	/* ENTRY POINT */
	function resize(e) 
	{
		if (!inited) 
			init();
		// else (resize or orientation change)
	}
	
	function init() 
	{
		if (inited) return;
			inited = true;

		//Screen Manager
		screenManager = ScreenManager.InitInstance(this);
		
		//Main loop
		Lib.current.stage.addEventListener(Event.ENTER_FRAME, MainLoop);
		
		// Stage:
		// stage.stageWidth x stage.stageHeight @ stage.dpiScale
		
		// Assets:
		// nme.Assets.getBitmapData("img/assetname.jpg");
	}

	/* SETUP */
	public function new() 
	{
		super();
		addEventListener(Event.ADDED_TO_STAGE, added);
	}
	
	function MainLoop(event : Event)
	{
		var time : Float = Lib.getTimer();
		var deltaTime : Float = time - lastTime;
		lastTime = time;
		
		//Basic loops
		ScreenManager.Update(deltaTime);
		ScreenManager.Draw(graphics);
	}

	function added(e) 
	{
		removeEventListener(Event.ADDED_TO_STAGE, added);
		stage.addEventListener(Event.RESIZE, resize);
		#if ios
		haxe.Timer.delay(init, 100); // iOS 6
		#else
		init();
		#end
	}
	
	public static function main() 
	{
		// static entry point
		Lib.current.stage.align = flash.display.StageAlign.TOP_LEFT;
		Lib.current.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
		Lib.current.addChild(new Game());
	}
}
