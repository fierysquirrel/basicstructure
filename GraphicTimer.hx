package;

import openfl.display.Tile;
import openfl.display.TileGroup;
import openfl.display.Tilemap;

/**
 * ...
 * @author Fiery Squirrel
 */
class GraphicTimer extends Timer
{
	private var sprite : TileGroup;
	private var transform : TileGroupTransform;
	private var text : Text;
	private var isCritical : Bool;
	private var currTime : Int;
	
	/*
	 * Duration in seconds.
	 * */
	public function new(layer : Tilemap, text : Text,duration : Float, type : Timer.TimerType, onComplete : Void -> Void) 
	{
		super(MathHelper.ConvertSecToMillisec(duration), type, onComplete, OnRunning);
		
		sprite = new TileGroup(layer);
		transform = new TileGroupTransform(sprite);
		this.text = text;
		layer.view.addChild(text);
		this.type = type;
		isCritical = false;
		
		currTime = Math.ceil(curr);
		
		AddOnCompleteMethod(OnComplete);
	}
	
	public function SetX(value : Float) : Void
	{
		sprite.x = value;
	}
	
	public function SetY(value : Float) : Void
	{
		sprite.y = value;
	}
	
	private function AddChild(child : Tile) : Void
	{
		sprite.addChild(child);
		transform.addProxy(child);
	}
	
	public function GetSprite() : TileGroup
	{
		return sprite;
	}
	
	override public function GetCurrentTime() : Int
	{
		return currTime;
	}
	
	private function OnRunning(time : Float) : Void
	{
		currTime = Math.ceil(MathHelper.ConvertMillisecToSec(time));
		
		if(currTime >= 10)
			text.text = Std.string(currTime);
		else
			text.text = "0" + Std.string(currTime);
	}
	
	private function OnComplete() : Void
	{
		switch(type)
		{
			case Timer.TimerType.Forward:
				text.text = Std.string(goal);
			case Timer.TimerType.Backward:
				text.text = "00";
		}
	}
	
	public function MakeCritical() : Void
	{
		isCritical = true;
	}
	
	override public function Update(gameTime:Float):Void 
	{
		super.Update(gameTime);
		
		transform.update();
	}
}