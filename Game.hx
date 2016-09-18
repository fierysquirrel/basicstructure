package;

import flash.Lib;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.TouchEvent;
import flash.ui.Multitouch;
import flash.ui.MultitouchInputMode;
import screenevents.GameEvents;
import openfl.net.SharedObject;
import openfl.net.SharedObjectFlushStatus;
import openfl.system.Capabilities;
import openfl.ui.Keyboard;

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
	/*Default paths*/
	static public var FONTS_PATH : String 			= "assets/fonts/";
	static public var MUSIC_PATH : String 			= "assets/soundtracks/";
	static public var BACKGROUNDS_PATH : String		= "assets/backgrounds/";
	static public var SOUNDS_PATH : String 			= "assets/sounds/";
	static public var SPRITES_PATH : String 			= "assets/sprites/";
	static public var LANGUAGES_PATH : String 		= "assets/languages/";
	static public var USER_STORAGE_NAME : String 	= "user";
	
	static public var USER_ID : String;
	
	private var inited : Bool;
	
	private var lastTime : Float;
	
	private var screenManager : ScreenManager;
	
	private var eventManager : EventManager;
	
	private var graphicManager : GraphicManager;
	
	private var textManager : TextManager;
	
	private var soundManager : SoundManager;
	
	private var languageManager : LanguageManager;
	
	private var analyticsManager : AnalyticsManager;
	
	private var fieryPlay : FieryPlay;
	
	private var debugger : Debugger;
	
	private var screenWidth : Int;
	
	private var screenHeight : Int;
	
	private var backgroundsPath : String;
	
	private var spritesPath : String;
	
	private var fontsPath : String;
	
	private var languagesPath : String;
	
	private var defaultLanguage : String;
	
	private var soundsPath : String;
	
	private var musicPath : String;
	
	private var multitouchSupported : Bool;
	
	private var analyticsDB : String;
	
	private var googleAnalyticsID : String;
	
	private var containers : Array<Sprite>;
	
	/* ENTRY POINT */
	function resize(e : Event) 
	{
		if (inited)
			Resize();
		else
			init();
	}
	
	/*
	 * Override this method to initialize your game.
	 * Since many systems are initialized here, you should initialize yours AFTER this method runs.
	 * */
	function init() 
	{
		var gameContainer, debugContainer : Sprite;
		var userSharedObj : SharedObject;
		
		//Containers
		gameContainer = new Sprite();
		debugContainer = new Sprite();
		
		//Unattach mouse to containers
		gameContainer.mouseEnabled = false;
		debugContainer.mouseEnabled = false;
		
		//Order matters here, if debugContainer is not in the front, you won't see it.
		addChild(gameContainer);
		addChild(debugContainer);
		
		//User data
		userSharedObj = SharedObject.getLocal(USER_STORAGE_NAME);
		
		if (userSharedObj.data.id == null)
		{
			USER_ID = MathHelper.CreateID(50);
			userSharedObj.data.id = USER_ID;
			StorageHelper.SaveData(userSharedObj);
		}
		else
			USER_ID = userSharedObj.data.id;
		
		if (inited) return;
			inited = true;

		//Event Manager
		eventManager = EventManager.InitInstance();
		
		//Graphic Manager
		graphicManager = GraphicManager.InitInstance(screenWidth,screenHeight,backgroundsPath,spritesPath);
		
		//Text Manager
		textManager = TextManager.InitInstance(fontsPath);
		
		//Fiery Play
		fieryPlay = FieryPlay.InitInstance();
		//Init Fiery Play
		FieryPlay.Init();
		
		//Language Manager
		languageManager = LanguageManager.InitInstance(languagesPath,defaultLanguage);
		
		//Sound Manager
		soundManager = SoundManager.InitInstance(soundsPath,musicPath);
		
		//Analytics Manager
		analyticsManager = AnalyticsManager.InitInstance(analyticsDB);
		
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
		
		#if mobile
		if (googleAnalyticsID != "")
			GAnalytics.startSession(googleAnalyticsID);
		#end
		
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, HandleIOEvent);
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_UP, HandleIOEvent);
		
		ScreenManager.AddEvent(GameEvents.EVENT_EXIT_GAME, HandleGameExit);
	}
	
	private function Resize() : Void
	{
		//TODO: we are trying to fix the android problemwith the resolution
		//GraphicManager.Resize();
	}
	
	/* SETUP */
	public function new(screenWidth : Int = 0, screenHeight : Int = 0, backgroundsPath : String = "",spritesPath : String = "",soundsPath : String = "",musicPath : String = "", fontsPath : String = "", languagesPath : String = "",defaultLanguage : String = "", analyticsDB : String = "", googleAnalyticsID : String = "") 
	{
		super();
		
		this.screenWidth = screenWidth;
		this.screenHeight = screenHeight;
		this.backgroundsPath = backgroundsPath == "" ? BACKGROUNDS_PATH : backgroundsPath;
		this.spritesPath = spritesPath == "" ? SPRITES_PATH : spritesPath;
		this.fontsPath = fontsPath == "" ? FONTS_PATH : fontsPath;
		this.languagesPath = languagesPath == "" ? LANGUAGES_PATH : languagesPath;
		this.defaultLanguage = defaultLanguage;
		this.soundsPath = soundsPath == "" ? SOUNDS_PATH : soundsPath;
		this.musicPath = musicPath == "" ? MUSIC_PATH : musicPath;
		this.analyticsDB = analyticsDB;
		this.googleAnalyticsID = googleAnalyticsID;
		
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
		#if mobile
		if (googleAnalyticsID != "")
			GAnalytics.stopSession();
		#end
		
		#if cpp
		Sys.exit(0);
		#end
	}
}
