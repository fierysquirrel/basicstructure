package fs.basicstructure.screens;

import aze.display.TileGroup;
import com.fs.fluffeaters.events.GameEvent;
import com.fs.fluffeaters.events.GameScreenEvent;
import com.fs.fluffeaters.gameplay.Level;
import com.fs.fluffeaters.screenmanager.ScreenManager;
import com.fs.fluffeaters.ui.ImageCheckBox;
import com.fs.fluffeaters.ui.UIObject;
import flash.events.Event;
import flash.Lib;
import flash.net.URLRequest;

/**
 * ...
 * @author Henry D. Fernández B.
 */
class PauseScreen extends MenuScreen
{
	static public var NAME : String = "PAUSE_SCREEN";
	
	var worldNumber : Int;
	
	//Statistics
	var level : Level;
	var restarts : Int;
	var fails : Int;
	var globalScale : Float;
	var vel : Float;
	var acc : Float;
	var numberOfBounces : Int;
	
	public function new(worldNumber : Int, level : Level, restarts : Int, fails : Int) 
	{
		super(NAME,0,0, "assets/ui/pause_menu.xml",true);
		
		this.worldNumber = worldNumber;
		
		Helper.PauseSound(Globals.GAMEPLAY_SOUNDTRACK);
		
		this.level = level;
		this.restarts = restarts;
		this.fails = fails;
		globalScale = Helper.GetFixScale() * 0.1;
		vel = 0;
		acc = Globals.GRAVITY * 2;
		numberOfBounces = 0;
	}
	
	override public function LoadContent():Void 
	{
		super.LoadContent();
		
		var imageBtn : ImageCheckBox;
		
		for (u in uiObjects)
		{
			if (u.GetId() == "sound")
			{
				imageBtn = cast(u, ImageCheckBox);
				if (Globals.SOUNDS_ON)
					imageBtn.Check();
				else
					imageBtn.Uncheck();
			}
			
			if(u.GetId() != "sound" && u.GetId() != "back")
				u.UpdateY( -Globals.SCREEN_HEIGHT);
		}
		
		for (s in sprites)
			s.y -= Globals.SCREEN_HEIGHT;
		
		Render();
	}
	
	override public function Update(gameTime:Float):Void 
	{
		super.Update(gameTime);
		
		if (!isClosing)
		{
			vel += acc;
			
			for (u in uiObjects)
			{
				if (u.GetId() != "sound" && u.GetId() != "back")
				{
					if (u.y >= u.GetInitialY())
					{
						if (vel > 0)
						{
							if (numberOfBounces > 3)
							{
								vel = 0;
								acc = 0;
								//u.InitializeY();
							}
							else
							{
								//u.InitializeY();
								vel = -vel/2;
								//acc = acc / 2;
								numberOfBounces++;
							}
						}
					}
					
					u.UpdateY(vel);
				}
			}
			
			for (s in sprites)
				s.y += vel;
				
			Render();
		}
	}
	public function OnSoundsOnHandler(button : UIObject) : Void
	{
		var imageBtn : ImageCheckBox;
		
		imageBtn = cast(button, ImageCheckBox);
		Helper.TurnSoundsOn();
		Helper.TurnMusicOn();
		Helper.TurnVibrationOn();
		Helper.SaveConfigInfo();
	}
	
	public function OnSoundsOffHandler(button : UIObject) : Void
	{
		var imageBtn : ImageCheckBox;
		
		imageBtn = cast(button, ImageCheckBox);
		Helper.TurnSoundsOff();
		Helper.TurnMusicOff();
		Helper.TurnVibrationOff();
		Helper.SaveConfigInfo();
	}
	
	public function OnMainMenuHandler() : Void
	{
		//Statistics 
		Helper.SendStatistics(level, restarts, fails);
		
		Helper.PlaySoundtrack(Globals.MAIN_SOUNDTRACK);
		eventDispatcher.dispatchEvent(new GameScreenEvent(ScreenManager.EVENT_SCREEN_LOADED,new MainMenuScreen()));
	}
	
	public function OnLevelSelectionHandler() : Void
	{
		//Statistics 
		Helper.SendStatistics(level, restarts, fails);
		
		Helper.PlaySoundtrack(Globals.MAIN_SOUNDTRACK);
		eventDispatcher.dispatchEvent(new GameScreenEvent(ScreenManager.EVENT_SCREEN_LOADED,new LevelSelectionScreen(worldNumber)));
	}
	
	public function OnHelpHandler() : Void
	{
		eventDispatcher.dispatchEvent(new GameScreenEvent(ScreenManager.EVENT_SCREEN_LOADED, new HelpScreen(worldNumber, level.GetNumber(),worldNumber, level.GetNumber())));
		
		//var request:URLRequest = new URLRequest(Globals.POLL_URL);
		//Lib.getURL(request);
	}
	
	override public function Close():Void 
	{
		super.Close();
		
		Helper.ResumeSoundtrack(Globals.GAMEPLAY_SOUNDTRACK);
		eventDispatcher.dispatchEvent(new GameEvent(ScreenManager.EVENT_SCREEN_EXITED,NAME));
	}
	override public function HandleBackButtonPressed(e : Event) : Void
	{
		StartClosing();
	}
	
	public function OnBackHandler() : Void
	{
		StartClosing();
	}
}