package fs.basicstructure.screens;

import flash.text.TextField;
import flash.events.Event;
import com.fs.fluffeaters.events.GameEvent;
import com.fs.fluffeaters.screenmanager.ScreenManager;
import flash.geom.Point;
import aze.display.TileSprite;

/**
 * ...
 * @author Henry D. Fernández B.
 */
class ModalScreen extends UIScreen
{
	private var line1Message : String;
	private var line2Message : String;
	private var line3Message : String;
	
	private var spritesIniPos : Array<Point>;
	private var textsIniPos : Array<Point>;
	private var vel : Float;
	private var acc : Float;
	
	public function new(name : String, viewPath : String,line1Id : String,line2Id : String = "",line3Id : String = "") 
	{
		super(name, 0, 0, viewPath, true);
		
		this.line1Message = line1Id == "" ? "" : Helper.Translate(line1Id);
		this.line2Message = line2Id == "" ? "" : Helper.Translate(line2Id);
		this.line3Message = line3Id == "" ? "" : Helper.Translate(line3Id);
		vel = Helper.FixFloatScale2Screen(60);
		acc = Helper.FixFloatScale2Screen(2.2);// Globals.GRAVITY;
	}
	
	override public function LoadContent():Void 
	{
		super.LoadContent();
		
		var line1, line2, line3 : TextField;
		
		line1 = textFields.get("line1");
		line1.text = line1Message;
		line1.x = line1.x - line1.width / 2;
		line2 = textFields.get("line2");
		line2.text = line2Message;
		line2.x = line2.x - line2.width / 2;
		line3 = textFields.get("line3");
		line3.text = line3Message;
		line3.x = line3.x - line3.width / 2;
		
		spritesIniPos = new Array<Point>();
		
		for (s in sprites)
		{
			spritesIniPos.push(new Point(s.x, s.y));
			s.y -= Globals.SCREEN_HEIGHT;
		}
		
		textsIniPos = new Array<Point>();
		
		for (t in textFields)
		{
			textsIniPos.push(new Point(t.x, t.y));
			t.y -= Globals.SCREEN_HEIGHT;
		}
		
		for (u in uiObjects)
			u.UpdateY(-Globals.SCREEN_HEIGHT);
		
		Render();
	}
	
	override public function HandleBackButtonPressed(e : Event) : Void
	{
		StartClosing();
		//eventDispatcher.dispatchEvent(new GameEvent(ScreenManager.EVENT_SCREEN_EXITED,name));
	}
	
	override public function Update(gameTime:Float):Void 
	{
		super.Update(gameTime);
		
		var i = 0;
		var finish : Bool;
		vel -= acc;
		if (vel <= Helper.FixFloatScale2Screen(5))
			vel = Helper.FixFloatScale2Screen(5);
		
		
		finish = true;
		for (s in sprites)
		{
			if (s.y < spritesIniPos[i].y  && vel >= 0)
			{
				s.y += vel;
				finish = false;
			}
			else
				s.y = spritesIniPos[i].y;
			i++;
		}
		
		i = 0;
		for (t in textFields)
		{
			if (t.y < textsIniPos[i].y && vel >= 0)
			{
				t.y += vel;
				finish = false;
			}
			else
				t.y = textsIniPos[i].y;
			i++;
		}
		
		for (u in uiObjects)
		{
			if (u.y < u.GetInitialY() && vel >= 0)
			{
				u.UpdateY(vel);
				finish = false;
			}
			else
				u.InitializeY();
		}
		
		if (finish)
		{
			vel = 0;
			acc = 0;
		}
		
		Render();
	}
}