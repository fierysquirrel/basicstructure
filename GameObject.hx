package;

import aze.display.TileGroup;
import aze.display.TileLayer;
import aze.display.TileSprite;
import aze.display.behaviours.TileGroupTransform;
import flash.geom.Point;

/**
 * ...
 * @author Fiery Squirrel
 */
class GameObject
{
	public var x : Float;
	public var y : Float;
	public var velocity : Point;
	public var acceleration : Point;
	
	private var type : String;
	private var id : String;
	private var layer : TileLayer;
	private var initialX : Float;
	private var initialY : Float;
	private var sprite : TileGroup;
	private var spriteTrasform : TileGroupTransform;
	private var camera : Camera;
	private var isDestroying : Bool;
	
	public function new(type : String,id : String,x : Float, y : Float) 
	{
		this.type = type;
		this.id = id;
		this.x = x;
		this.y = y;
		initialX = x;
		initialY = y;
		velocity = new Point();
		acceleration = new Point();
		isDestroying = false;
	}
	
	public function LoadContent(layer : TileLayer) : Void
	{
		this.layer = layer;
		sprite = new TileGroup(layer);
		spriteTrasform = new TileGroupTransform(sprite);
		sprite.x = x;
		sprite.y = y;
		spriteTrasform.scale = GraphicManager.GetFixScale();
		layer.addChild(sprite);
	}
	
	public function GetType() : String
	{
		return type;
	}
	
	public function GetID() : String
	{
		return id;
	}
	
	private function AddSprite(sprite : TileSprite) : Void
	{
		this.sprite.addChild(sprite);
		spriteTrasform.addProxy(sprite);
		spriteTrasform.update();
	}
	
	private function AddSpriteAt(sprite : TileSprite, index : Int) : Void
	{
		this.sprite.addChildAt(sprite,index);
		spriteTrasform.addProxy(sprite);
		spriteTrasform.update();
	}
	
	public function GetSprite() : TileGroup
	{
		return sprite;
	}
	
	public function SetRotation(value : Float) : Void
	{
		if (spriteTrasform != null)
			spriteTrasform.rotation = value;
	}
	
	public function SetScale(value : Float) : Void
	{
		if (spriteTrasform != null)
			spriteTrasform.scale = value;
	}
	
	public function SetScaleX(value : Float) : Void
	{
		for (s in sprite.children)
			cast(s, TileSprite).scaleX = value;
	}
	
	public function SetScaleY(value : Float) : Void
	{
		for (s in sprite.children)
			cast(s, TileSprite).scaleY = value;
	}
	
	public function Update(gameTime : Float) : Void
	{
		UpdatePosition();
		if(spriteTrasform != null)
			spriteTrasform.update();
	}
	
	public function Draw(camera : Camera = null) : Void
	{
		this.camera = camera;
		
		if (sprite != null)
		{
			if (camera == null)
			{
				sprite.x = x;
				sprite.y = y;
			}
			else
			{
				sprite.visible = camera.IsVisible(this);
				sprite.x = camera.World2ScreenX(x);
				sprite.y = camera.World2ScreenY(y);
			}
			
		}
	}
	
	public function UpdatePosition() : Void
	{
		velocity.x += acceleration.x;
		velocity.y += acceleration.y;
		x += velocity.x;
		y += velocity.y;
	}
	
	public function Clean() : Void
	{
		if(sprite != null)
			layer.removeChild(sprite);
	}
	
	public function Destroy() : Void
	{
		isDestroying = true;
	}
	
	public function IsDestroying() : Bool
	{
		return isDestroying;
	}
}