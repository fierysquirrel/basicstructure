package fs.basicstructure.screens;

import fs.helper.MathHelper;

/**
 * ...
 * @author Henry D. Fernández B.
 */
class DeveloperScreen extends MenuScreen
{
	static public var NAME : String = "DEVELOPER_SCREEN";
	
	private var timer : Float;
	private var waitTime : Float;
	
	public function new() 
	{
		super(NAME, 0, 0, "assets/ui/developer.xml",true);
		
		waitTime = MathHelper.ConvertSecToMillisec(2.5);
		timer = 0;
	}
	
	override public function LoadContent():Void 
	{
		super.LoadContent();
		
		/*var back, fiery : TileSprite;

		popupVeil.graphics.beginFill(Globals.BACKGROUND_COLOR);
		popupVeil.graphics.drawRect(0,0,Globals.SCREEN_WIDTH,Globals.SCREEN_HEIGHT);
		popupVeil.graphics.endFill();
		popupVeil.alpha = 1;

		fiery = sprites.get("fiery");
		
		fiery.r = 254/255;
		fiery.g = 135/255;
		fiery.b = 8 / 255;
		
		Render();*/
	}

	override public function Update(gameTime:Float):Void 
	{
		//super.Update(gameTime);
		
		/*if (timer < waitTime)
			timer += gameTime;
		else
			eventDispatcher.dispatchEvent(new GameScreenEvent(ScreenManager.EVENT_SCREEN_LOADED,new MainMenuScreen()));*/
	}
}