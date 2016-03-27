package;

import aze.display.TileGroup;
import aze.display.TileLayer;
import aze.display.TileSprite;
import aze.display.behaviours.TileGroupTransform;

/**
 * ...
 * @author Fiery Squirrel
 */
class Logo extends TileGroup
{
	public static var NAME : String = "Logo";
	
	private var transform : TileGroupTransform;
	
	public function new(layer:TileLayer) 
	{
		super(layer);
		
		transform = new TileGroupTransform(this);
	}
	
	private function AddSprite(name : String, r : Float = 1, g : Float = 1, b: Float = 1) : TileSprite
	{
		var sprite : TileSprite;
		
		sprite = new TileSprite(layer, name);
		sprite.r = r;
		sprite.g = g;
		sprite.b = b;
		sprite.scale = GraphicManager.GetFixScale();
		addChild(sprite);
		transform.addProxy(sprite);
		
		return sprite;
	}
	
	public function Update(gameTime : Float) : Void
	{
		transform.update();
	}
}