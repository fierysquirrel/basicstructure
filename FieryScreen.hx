package;

import screenevents.*;
import screentransitions.*;

/**
 * ...
 * @author Henry D. Fernández B.
 */
class FieryScreen extends UIScreen
{
	static public var NAME : String = "DEVELOPER_SCREEN";
	
	private var timer : Float;
	private var waitTime : Float;
	
	public function new(waitTime : Float = 0,x : Float = 0, y : Float = 0,viewPath : String = "assets/ui/", viewName : String = "developer.xml") 
	{
		super(NAME, x, y, viewPath, viewName, true);
		
		this.waitTime = waitTime;
		timer = 0;
	}
	
	override public function Update(gameTime:Float):Void 
	{
		if (timer < waitTime)
			timer += gameTime;
		else
			OnAnimationEnded();
	}
	
	public function OnAnimationEnded() : Void
	{
	}
}