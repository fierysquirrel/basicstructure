package;

import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.TouchEvent;
import flash.Lib;
import flash.ui.Multitouch;
import flash.ui.MultitouchInputMode;
import flash.ui.Keyboard;
import screenevents.GameEvents;


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
	
	private var eventManager : EventManager;
	
	private var graphicManager : GraphicManager;
	
	private var textManager : TextManager;
	
	private var soundManager : SoundManager;
	
	private var languageManager : LanguageManager;
	
	private var analyticsManager : AnalyticsManager;
	
	private var debugger : Debugger;
	
	private var screenWidth : Int;
	
	private var screenHeight : Int;
	
	private var backgroundsPath : String;
	
	private var spritesPath : String;
	
	private var fontsPath : String;
	
	private var languagesPath : String;
	
	private var soundsPath : String;
	
	private var musicPath : String;
	
	private var multitouchSupported : Bool;
	
	private var containers : Array<Sprite>;
	
	/* ENTRY POINT */
	function resize(e : Event) 
	{
		if (!inited) 
			init();
		//else //(resize or orientation change)
	}
	
	function init() 
	{
		var gameContainer, debugContainer : Sprite;
		
		//Containers
		gameContainer = new Sprite();
		debugContainer = new Sprite();
		
		//Unattach mouse to containers
		gameContainer.mouseEnabled = false;
		debugContainer.mouseEnabled = false;
		
		//Order matters here, if debugContainer is not in the front, you won't see it.
		addChild(gameContainer);
		addChild(debugContainer);
		
		if (inited) return;
			inited = true;

		//Event Manager
		eventManager = EventManager.InitInstance();
		
		//Graphic Manager
		graphicManager = GraphicManager.InitInstance(screenWidth,screenHeight,backgroundsPath,spritesPath);
		
		//Text Manager
		textManager = TextManager.InitInstance(fontsPath);
		
		//Language Manager
		languageManager = LanguageManager.InitInstance(languagesPath);
		
		//Sound Manager
		soundManager = SoundManager.InitInstance(soundsPath,musicPath);
		
		//Analytics Manager
		analyticsManager = AnalyticsManager.InitInstance();
		
		//Debugging
		debugger = Debugger.InitInstance(debugContainer,GraphicManager.GetWidth(),GraphicManager.GetHeight());
		
		//Screen manager
		screenManager = ScreenManager.InitInstance(gameContainer);
		
		//Main loop
		Lib.current.stage.addEventListener(Event.ENTER_FRAME, MainLoop);
		
		//Input Events
		multitouchSupported = Multitouch.supportsTouchEvents;
		
		//TODO: Fix this, multituchsupported is not right
		#if(windows || mac)
			Lib.current.stage.addEventListener(MouseEvent.MOUSE_DOWN, HandleIOEvent);
			Lib.current.stage.addEventListener(MouseEvent.MOUSE_UP, HandleIOEvent);
			Lib.current.stage.addEventListener(MouseEvent.MOUSE_MOVE, HandleIOEvent);
			Lib.current.stage.addEventListener(MouseEvent.CLICK, HandleIOEvent);
		#else
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
		#end
		
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, HandleIOEvent);
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_UP, HandleIOEvent);
		
		ScreenManager.AddEvent(GameEvents.EVENT_EXIT_GAME, HandleGameExit);
		// Stage:
		// stage.stageWidth x stage.stageHeight @ stage.dpiScale
		
		// Assets:
		// nme.Assets.getBitmapData("img/assetname.jpg");
		
		//Debugger.Print("architecture: " + Capabilities.cpuArchitecture);
		//Debugger.Print("language: " + Capabilities.language);
		//Debugger.Print("manufacturer: " + Capabilities.manufacturer);
		//Debugger.Print("os: " + Capabilities.os);
		//Debugger.Print("aspect ratio: " + Capabilities.pixelAspectRatio);
		//Debugger.Print("player type: " + Capabilities.playerType);
		//Debugger.Print("dpi: " + Capabilities.screenDPI);
		//Debugger.Print("version: " + Capabilities.version);
	}

	/* SETUP */
	public function new(screenWidth : Int = 0, screenHeight : Int = 0, backgroundsPath : String = "",spritesPath : String = "",soundsPath : String = "",musicPath : String = "", fontsPath : String = "", languagesPath : String = "") 
	{
		super();
		
		this.screenWidth = screenWidth;
		this.screenHeight = screenHeight;
		this.backgroundsPath = backgroundsPath;
		this.spritesPath = spritesPath;
		this.fontsPath = fontsPath;
		this.languagesPath = languagesPath;
		this.soundsPath = soundsPath;
		this.musicPath = musicPath;
		
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
		SoundManager.Update(deltaTime);
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
	
	public function HandleGameExit(e : Event) : Void
	{
		//TODO: exit properly
	}
}
