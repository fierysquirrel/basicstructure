package;
import openfl.display.Sprite;
import openfl.geom.Point;

/**
 * ...
 * @author Fiery Squirrel
 */
class Camera
{
	public var x : Float;
	public var y : Float;
	
	public var debugSprite : Sprite;
	
	private var initialX : Float;
	private var initialY : Float;
	private var width : Float;
	private var height : Float;
	private var widthLimit : Float;
	private var heightLimit : Float;
	private var lockGameObject : GameObject;
	private var isLocked : Bool;
	
	public function new(x : Float, y : Float, width : Float = 0, height : Float = 0, widthLimit : Float = 0, heightLimit : Float = 0) 
	{
		this.x = x;
		this.y = y;
		initialX = x;
		initialY = y;
		this.width = width == 0 ? GraphicManager.GetWidth() : width;
		this.height = height == 0 ? GraphicManager.GetHeight() : height;
		this.widthLimit = widthLimit == 0 ? this.width : widthLimit;
		this.heightLimit = heightLimit == 0 ? this.height : heightLimit;
		
		debugSprite = new Sprite();		
		debugSprite.graphics.lineStyle(3,0x000000,1);
		debugSprite.graphics.beginFill(0x000000,0);
		debugSprite.graphics.drawRect(-widthLimit/2,-heightLimit/2, widthLimit, heightLimit);			
		debugSprite.graphics.endFill();
		debugSprite.x = x;
		debugSprite.y = y;
	}
	
	public function GetWidth() : Float
	{
		return width;
	}
	
	public function GetHeight() : Float
	{
		return height;
	}
	
	public function Lock(gameObject : GameObject) : Void
	{
		this.lockGameObject = gameObject;
		isLocked = true;
	}
	
	public function Unlock() : Void
	{
		isLocked = false;
	}
	
	public function GetRelativeX() : Float
	{
		return x - initialX;
	}
	
	public function GetRelativeY() : Float
	{
		return y - initialY;
	}
	
	public function World2Screen(pos : Point) : Point
	{
		return new Point(pos.x - x + width / 2,pos.y - y + height / 2);
	}
	
	public function World2ScreenX(posX : Float) : Float
	{
		return posX - x + width / 2;
	}
	
	public function World2ScreenY(posY : Float) : Float
	{
		return posY - y + height / 2;
	}
	
	public function Screen2World(pos : Point) : Point
	{
		return new Point(pos.x + x - width / 2,pos.y + y - height / 2);
	}
	
	public function Screen2WorldX(posX : Float) : Float
	{
		return posX + x - width / 2;
	}
	
	public function Screen2WorldY(posY : Float) : Float
	{
		return posY + y - height / 2;
	}
	
	public function Update(gameTime : Float) : Void
	{
		if (isLocked)
		{
			if (lockGameObject != null)
			{
				//Moving Right
				if (lockGameObject.x > x + widthLimit / 2)
					x = lockGameObject.x - widthLimit / 2;
				//Moving Left
				if (lockGameObject.x < x - widthLimit / 2)
					x = lockGameObject.x + widthLimit / 2;
				//Moving Down
				if (lockGameObject.y > y + heightLimit / 2)
					y = lockGameObject.y - heightLimit / 2;
				//Moving Up
				if (lockGameObject.y < y - heightLimit / 2)
					y = lockGameObject.y + heightLimit / 2;
			}
		}
		
		//debugSprite.x = x;
		//debugSprite.y = y;
	}
	
	public function IsVisible(object : GameObject) : Bool
	{
		var insideX, insideY : Bool;
		
		insideX = object.x + object.GetSprite().width / 2 >= x - width / 2 && object.x - object.GetSprite().width / 2 <= x + width / 2;
		insideY = object.y + object.GetSprite().height / 2 >= y - height / 2 && object.y - object.GetSprite().height / 2 <= y + height / 2;
		
		return insideX && insideY;
	}
	
	public function MoveX(value : Float) : Void
	{
		x += value;
	}
	
	public function MoveY(value : Float) : Void
	{
		y += value;
	}
}