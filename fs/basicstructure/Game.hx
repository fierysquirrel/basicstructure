package fs.basicstructure;

import flash.display.Sprite;
import flash.events.Event;
import flash.Lib;
import fs.graphicmanager.GraphicManager;
import fs.languagemanager.LanguageManager;
import fs.screenmanager.ScreenManager;
import fs.screenmanager.events.GameEvents;
import fs.soundmanager.SoundManager;
import fs.textmanager.TextManager;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.TouchEvent;
import flash.ui.Multitouch;
import flash.ui.MultitouchInputMode;

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
	
	private var graphicManager : GraphicManager;
	
	private var textManager : TextManager;
	
	private var soundManager : SoundManager;
	
	private var languageManager : LanguageManager;
	
	private var screenWidth : Int;
	
	private var screenHeight : Int;
	
	private var spritesPath : String;
	
	private var fontsPath : String;
	
	private var languagesPath : String;
	
	private var soundsPath : String;
	
	private var multitouchSupported : Bool;

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

		//Graphic Manager
		graphicManager = GraphicManager.InitInstance(screenWidth,screenHeight,spritesPath);
		
		//Text Manager
		textManager = TextManager.InitInstance(fontsPath);
		
		//Language Manager
		languageManager = LanguageManager.InitInstance(languagesPath);
		
		//Sound Manager
		soundManager = SoundManager.InitInstance(soundsPath);
		
		//Screen manager
		screenManager = ScreenManager.InitInstance(this);
		//TODO: check this event and the rest, generalize it and re-structure
		//ScreenManager.AddEvent(GameEvents.EVENT_EXIT_GAME, EventsHandler);
		
		//Main loop
		Lib.current.stage.addEventListener(Event.ENTER_FRAME, MainLoop);
		
		//Input Events
		multitouchSupported = Multitouch.supportsTouchEvents;
		
		if (multitouchSupported)
		{
			Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
			
			Lib.current.stage.addEventListener(TouchEvent.TOUCH_BEGIN, HandleIOEvent);
			Lib.current.stage.addEventListener(TouchEvent.TOUCH_MOVE, HandleIOEvent);
			Lib.current.stage.addEventListener(TouchEvent.TOUCH_END, HandleIOEvent);
			Lib.current.stage.addEventListener(TouchEvent.TOUCH_TAP, HandleIOEvent);
		}
		else
		{
			Lib.current.stage.addEventListener(MouseEvent.MOUSE_DOWN, HandleIOEvent);
			Lib.current.stage.addEventListener(MouseEvent.MOUSE_UP, HandleIOEvent);
			Lib.current.stage.addEventListener(MouseEvent.MOUSE_MOVE, HandleIOEvent);
			Lib.current.stage.addEventListener(MouseEvent.CLICK, HandleIOEvent);
		}
		
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, HandleIOEvent);
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_UP, HandleIOEvent);
		
		// Stage:
		// stage.stageWidth x stage.stageHeight @ stage.dpiScale
		
		// Assets:
		// nme.Assets.getBitmapData("img/assetname.jpg");
	}

	/* SETUP */
	public function new(screenWidth : Int = 0, screenHeight : Int = 0, spritesPath : String = "",soundsPath : String = "", fontsPath : String = "", languagesPath : String = "") 
	{
		super();
		
		this.screenWidth = screenWidth;
		this.screenHeight = screenHeight;
		this.spritesPath = spritesPath;
		this.fontsPath = fontsPath;
		this.languagesPath = languagesPath;
		this.soundsPath = soundsPath;
		
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
	
	function HandleIOEvent(event : Event)
	{	
		var mouseEvnt : MouseEvent;
		var touchEvnt : TouchEvent;
		var keyboardEvnt : KeyboardEvent;
		
		if (event.type == KeyboardEvent.KEY_DOWN || event.type == KeyboardEvent.KEY_UP)
		{
			keyboardEvnt = cast(event, KeyboardEvent);
			ScreenManager.HandleKeyboardEvent(keyboardEvnt);
		}
		if (event.type == MouseEvent.MOUSE_DOWN || event.type == MouseEvent.MOUSE_MOVE || event.type == MouseEvent.MOUSE_UP || event.type == MouseEvent.CLICK)
		{
			mouseEvnt = cast(event, MouseEvent);
			ScreenManager.HandleMouseEvent(mouseEvnt);
		}
		else if (event.type == TouchEvent.TOUCH_BEGIN || event.type == TouchEvent.TOUCH_MOVE || event.type == TouchEvent.TOUCH_END || event.type == TouchEvent.TOUCH_TAP)
		{
			touchEvnt = cast(event, TouchEvent);
			ScreenManager.HandleTouchEvent(touchEvnt);
		}
	}
	
	public function Exit()
	{
		//TODO: exit properly
	}
}
