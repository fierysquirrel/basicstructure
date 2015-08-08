package fs.basicstructure.screens;

import fs.screenmanager.Layer;
import aze.display.TileSprite;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.geom.Point;
import flash.net.SharedObject;
import flash.text.Font;
import fs.graphicmanager.GraphicManager;
import fs.languagemanager.LanguageManager;
import fs.screenmanager.GameScreen;
import fs.textmanager.Text;
import fs.textmanager.TextManager;
import fs.ui.*;
import openfl.Assets;

/**
 * ...
 * @author Henry D. Fernández B.
 */
class UIScreen extends GameScreen
{	
	static public var UI_LAYER : String = "UILayer";
	
	private var view : String;
	
	private var uiObjects : Array<UIObject>;
	private var isPressingObj : Bool;
	private var backgroundLayer : Sprite;
	private var downUIObj : UIObject;
	private var downIds : Array<Int>;
	private var background : Bitmap;
	private var isClosing : Bool;
	private var closingAlpha : Float;
	private var isClosed : Bool;
	private var texts : Map<String,Text>;
	
	public function new(name : String,x : Float,y : Float,viewPath : String, isPopup : Bool = false) 
	{
		super(name,x,y,isPopup);
		
		this.view = viewPath;
		uiObjects = new Array<UIObject>();
		texts = new Map<String,Text>();
		downUIObj = null;
		downIds = new Array<Int>();
		isClosing = false;
		closingAlpha = 1;
		isClosed = false;
	}
	
	override public function LoadContent():Void 
	{
		super.LoadContent();
		
		backgroundLayer = new Sprite();

		addChild(backgroundLayer);

		//Parse view
		ParseView(view);
			
		Render();
	}
	
	private function ParseView(view : String) :Void
	{
		var str : String;
		var xml : Xml;
		
		try
		{
			if (view != "")
			{
				trace(view);
				str = Assets.getText(view);
				xml = Xml.parse(str).firstElement();
				
				ParseViewHeader(xml);
				for (e in xml.elements())
					ParseViewBody(e);
			}
		}
		catch (e : String)
		{
			trace(e);
		}
	}
	
	private function ParseViewHeader(xml : Xml) : Void
	{
		var backText : String;
		
		try
		{
			if (xml.nodeName.toLowerCase() == "menu")
			{	
				backText = xml.get("background") == null ? "" : xml.get("background");
				//isPopup = xml.get("popup") == "true" ? true : false;

				if (backText != "")
				{
					//TODO: check this
					background = GraphicManager.LoadBitmap(backText);
					background.scaleX = GraphicManager.GetMaxScale();
					background.scaleY = GraphicManager.GetMaxScale();
					background.x = (GraphicManager.GetWidth() - background.width) / 2;
					background.y = (GraphicManager.GetHeight() - background.height) / 2;
					backgroundLayer.addChild(background);
				}
			}			
		}
		catch (e : String)
		{
			throw e;
		}
	}
	
	private function ParseViewBody(xml : Xml) : Void
	{
		try
		{
			switch(xml.nodeName.toLowerCase())
			{
				case "uiobjects":
					ParseUIObjects(xml);
				case "sprites":
					ParseSprites(xml);
				case "textfields":
					ParseTextFields(xml);
				default:
			}
		}
		catch(e : String)
		{
			throw e;
		}
	}
	
	private function ParseUIObjects(xml : Xml) : Void
	{
		var state, text, id, spritesheet, spriteName, layer, data, onActionHandlerName, backActiveName, backPressName, id, onCheckHandlerName, onUncheckHandlerName, checkedText, uncheckedText, image : String;
		var uiObjX, uiObjY, spriteX, spriteY, rotation, recX, recY, titleX, titleY, pagerX, pagerY, pagerSep : Float;
		var textSize, totalFishes, minFishes, world, activeColor,pressColor, order : Int;
		var checked, hasTitle, hasPager, flipX, lockedWorld, isFeedback, unlocking, completedWorld : Bool;
		var options : Array<Option>;
		var sliderPages : Array<SliderPage>;
		var uiObj : UIObject;
		var page : SliderPage;
		var tileLayer : Layer;
		var worldInfo : SharedObject;
		var pos : Point;
		var font : Font;
		
		backActiveName = "";
		backPressName = "";
		
		spritesheet = xml.get("spritesheet");
		layer = xml.get("layer");
		order = Std.parseInt(xml.get("order"));
				
		tileLayer = GraphicManager.LoadTileLayer(spritesheet,order);
		tileLayer.useTint = true;
		AddLayer(layer,tileLayer);
		
		//if (GetLayer(UI_LAYER) != null)
		//{
			for (e2 in xml.elements())
			{
				uiObj = null;
				id = e2.get("name");
				isFeedback = e2.get("isFeedback") == null ? false : e2.get("isFeedback") == "true";
				pos = GraphicManager.FixPoint2Screen(new Point(Std.parseFloat(e2.get("x")), Std.parseFloat(e2.get("y"))));
				uiObjX = pos.x;
				uiObjY = pos.y;
		
				switch(e2.nodeName.toLowerCase())
				{
					case TextButton.XML:
						
						text = e2.get("text");
						for (e3 in e2.elements())
						{
							if (e3.nodeName.toLowerCase() == "sprite")
							{
								state = e3.get("state");
								
								switch(state)
								{
									case "active":
										backActiveName = e3.get("name");
									case "pressed":
										backPressName = e3.get("name");
								}
							}
						}
						
						//Add on press handler name
						onActionHandlerName = e2.get("onPress");
						textSize = GraphicManager.FixIntScale2Screen(Std.parseInt(e2.get("text")));
						font = TextManager.GetFont(e2.get("font"));
						activeColor = Std.parseInt(e2.get("activeColor"));
						pressColor = Std.parseInt(e2.get("pressColor"));
						//Button
						uiObj = new TextButton(id, tileLayer,uiObjX,uiObjY,onActionHandlerName,text,font,textSize,activeColor,pressColor,backActiveName,backPressName);
					case ImageButton.XML:
						
						for (e3 in e2.elements())
						{
							if (e3.nodeName.toLowerCase() == "sprite")
							{
								state = e3.get("state");
								
								switch(state)
								{
									case "active":
										backActiveName = e3.get("name");
									case "pressed":
										backPressName = e3.get("name");
								}
							}
						}
						
						rotation = e2.get("rotation") != null ? Std.parseFloat(e2.get("rotation")) : 0;
						image = e2.get("image");
						flipX = e2.get("flipX") == null ? false : e2.get("flipX") == "true";
						//img = data.get(e2.get("image"));
						
						//Add on press handler name
						onActionHandlerName = e2.get("onPress");
						activeColor = Std.parseInt(e2.get("activeColor"));
						pressColor = Std.parseInt(e2.get("pressColor"));
						uiObj = new ImageButton(id,tileLayer,uiObjX,uiObjY,onActionHandlerName,activeColor,pressColor,backActiveName,backPressName,image,flipX);
					case TextCheckBox.XML:
						checkedText = e2.get("checkedText");
						uncheckedText = e2.get("uncheckedText");
						checked = e2.get("checked") == null ? false : e2.get("checked") == "true";
						for (e3 in e2.elements())
						{
							if (e3.nodeName.toLowerCase() == "sprite")
							{
								state = e3.get("state");
								
								switch(state)
								{
									case "active":
										backActiveName = e3.get("name");
									case "pressed":
										backPressName = e3.get("name");
								}
							}
						}
						//Add on press handler name
						onCheckHandlerName = e2.get("onCheck");
						onUncheckHandlerName = e2.get("onUncheck");
						textSize = GraphicManager.FixIntScale2Screen(Std.parseInt(e2.get("text")));
						font = TextManager.GetFont(e2.get("font"));
						activeColor = Std.parseInt(e2.get("activeColor"));
						pressColor = Std.parseInt(e2.get("pressColor"));
						//Button
						uiObj = new TextCheckBox(id, tileLayer, uiObjX, uiObjY, onCheckHandlerName,onUncheckHandlerName,checked, checkedText,uncheckedText,font, textSize,activeColor,pressColor, backActiveName, backPressName);
						
					case ImageCheckBox.XML:
						checkedText = e2.get("checkedImage");
						uncheckedText = e2.get("uncheckedImage");
						checked = e2.get("checked") == null ? false : e2.get("checked") == "true";
						for (e3 in e2.elements())
						{
							if (e3.nodeName.toLowerCase() == "sprite")
							{
								state = e3.get("state");
								
								switch(state)
								{
									case "active":
										backActiveName = e3.get("name");
									case "pressed":
										backPressName = e3.get("name");
								}
							}
						}
						//Add on press handler name
						onCheckHandlerName = e2.get("onCheck");
						onUncheckHandlerName = e2.get("onUncheck");
						activeColor = Std.parseInt(e2.get("activeColor"));
						pressColor = Std.parseInt(e2.get("pressColor"));
						
						//Button
						uiObj = new ImageCheckBox(id, tileLayer, uiObjX, uiObjY, onCheckHandlerName, onUncheckHandlerName, checked,activeColor,pressColor, backActiveName, backPressName, checkedText, uncheckedText);
					case TextSelect.XML:
						options = new Array<Option>();
						checkedText = LanguageManager.Translate(e2.get("checkedText"));
						uncheckedText = LanguageManager.Translate(e2.get("uncheckedText"));
						for (e3 in e2.elements())
						{
							switch(e3.nodeName.toLowerCase())
							{
								case "sprite":
									state = e3.get("state");
								
									switch(state)
									{
										case "active":
											backActiveName = e3.get("name");
										case "pressed":
											backPressName = e3.get("name");
									}
								case "options":
									for (e4 in e3.elements())
										options.push(new Option(e4.get("name"),e4.get("value")));
							}
						}
						//Add on press handler name
						onActionHandlerName = e2.get("onChange");
						textSize = GraphicManager.FixIntScale2Screen(Std.parseInt(e2.get("text")));
						font = TextManager.GetFont(e2.get("font"));
						activeColor = Std.parseInt(e2.get("activeColor"));
						pressColor = Std.parseInt(e2.get("pressColor"));
						//Button
						uiObj = new TextSelect(id, tileLayer, uiObjX, uiObjY, onActionHandlerName, options, 0, font, textSize,activeColor,pressColor, backActiveName, backPressName);
					case Slider.XML:
						sliderPages = new Array<SliderPage>();
						
						hasTitle = e2.get("hasTitle") == null ? true : e2.get("hasTitle") == "true";
						hasPager = e2.get("hasPager") == null ? true : e2.get("hasPager") == "true";
						titleX = GraphicManager.FixFloat2ScreenX(Std.parseFloat(e2.get("titleX")));
						titleY = GraphicManager.FixFloat2ScreenY(Std.parseFloat(e2.get("titleY")));
						pagerX = GraphicManager.FixFloat2ScreenX(Std.parseFloat(e2.get("pagerX")));
						pagerY = GraphicManager.FixFloat2ScreenY(Std.parseFloat(e2.get("pagerY")));
						pagerSep = GraphicManager.FixFloat2ScreenX(Std.parseFloat(e2.get("pagerSeparation")));
						onActionHandlerName = e2.get("onPress");
						totalFishes = 0;
						//Pages
						for (e3 in e2.elements())
						{							
							if (e3.nodeName.toLowerCase() == SliderPage.XML)
							{
								page = new SliderPage(Std.parseInt(e3.get("number")), tileLayer, GraphicManager.FixFloat2ScreenX(Std.parseFloat(e3.get("x"))), GraphicManager.FixFloat2ScreenY(Std.parseFloat(e3.get("y"))), LanguageManager.Translate(e3.get("title")).toUpperCase());
								/*for (e4 in e3.elements())
								{
									switch(e4.nodeName.toLowerCase())
									{
										case WorldButton.XML:
											world = Std.parseInt(e4.get("number"));
											worldInfo = Helper.LoadWorldInfo(world);
											totalFishes += worldInfo.data.fishes;
											minFishes = Std.parseInt(e4.get("min-fishes"));
											//lockedWorld = worldInfo.data.locked == "yes" || totalFishes < minFishes;
											unlocking = worldInfo.data.locked == "yes" && totalFishes >= minFishes;
											lockedWorld = totalFishes < minFishes || unlocking;
											//Debugging
											if(Globals.DEBUG_LEVELS)
												lockedWorld = false;
												
											if (world == Globals.FIRST_WORLD)
												completedWorld = worldInfo.data.fishes >= (Globals.NUMBER_OF_FISHES * Globals.NUMBER_OF_LEVELS) - Globals.NUMBER_OF_FISHES * 3;
											else
												completedWorld = worldInfo.data.fishes >= (Globals.NUMBER_OF_FISHES * Globals.NUMBER_OF_LEVELS);
											
											trace(totalFishes);
											trace((Globals.NUMBER_OF_FISHES * Globals.NUMBER_OF_LEVELS));
											sliderEle = new WorldButton(e4.get("name"), tileLayer, Helper.FixFloat2ScreenX(Std.parseFloat(e4.get("x"))), Helper.FixFloat2ScreenY(Std.parseFloat(e4.get("y"))), world,onActionHandlerName,"",lockedWorld,minFishes,page,unlocking,completedWorld);
											sliderEle.SetScale(Helper.GetFixScale());
											page.AddElement(sliderEle);
										case ComingSoonWorldButton.XML:
											sliderEle = new ComingSoonWorldButton(e4.get("name"), tileLayer, Helper.FixFloat2ScreenX(Std.parseFloat(e4.get("x"))), Helper.FixFloat2ScreenY(Std.parseFloat(e4.get("y"))), Std.parseInt(e4.get("number")));
											sliderEle.SetScale(Helper.GetFixScale());
											page.AddElement(sliderEle);
										default:
									}
								}*/
								
								sliderPages.push(page);
							}
						}
						
						//Button
						//uiObj = new Slider(id, tileLayer, uiObjX, uiObjY, sliderPages,"",0,hasTitle,titleX,titleY,hasPager,pagerX,pagerY,pagerSep);// onActionHandlerName);
					default:	
				}
				
				if (uiObj != null)
				{
					uiObj.SetScale(GraphicManager.GetFixScale());
					//if(isFeedback)
					//	uiObj.SetEffect(Effect.Zoom);
					//uiObj.LoadContent();
					AddUIbject(uiObj);
				}
			}
		//}
	}
	
	private function ParseTextFields(xml : Xml) : Map<String,Text>
	{
		var font, text, xAlign, yAlign : String;
		var translate : Bool;
		var size, color, letterSpacing : Int;
		var textField : Text;
		var pos : Point;
		var texts : Map<String,Text>;
		
		texts = new Map<String,Text>();
		for (e in xml.elements())
		{
			if (e.nodeType == Xml.Element)
			{
				name = e.get("name");
				font = e.get("font");
				text = e.get("value");// translate ? LanguageManager.Translate(e.get("value")) : e.get("value");
				pos = GraphicManager.FixPoint2Screen(new Point(Std.parseFloat(e.get("x")), Std.parseFloat(e.get("y"))));
				size =  GraphicManager.FixIntScale2Screen(Std.parseInt(e.get("size")));
				color = Std.parseInt(e.get("color"));
				
				/*translate = e.get("translate") == null ? true : e.get("translate") == "true";
				
				
				
				xAlign = e.get("x-align") == null ? "center" : e.get("x-align");
				yAlign = e.get("y-align") == null ? "center" : e.get("y-align");
				
				letterSpacing = GraphicManager.FixIntScale2Screen(Std.parseInt(e.get("letterspacing")));*/
				
					
				textField = TextManager.CreateText(font, text, pos, size, color);// , letterSpacing, pos, xAlign, yAlign);
				trace(textField);
				texts.set(name, textField);
				
				AddText(name, textField);
			}
		}
		
		return texts;
	}
	
	private function ParseSprites(xml : Xml) : Map<String,TileSprite>
	{
		var spritesheet, spriteName, layer, data, id : String;
		var spriteX, spriteY : Float;
		var sprite : TileSprite;
		var tilelayer : Layer;
		var elements : Map<String,TileSprite>;
		var order : Int;
		
		spritesheet = xml.get("spritesheet");
		layer = xml.get("layer");
		order = Std.parseInt(xml.get("order"));
				
		tilelayer = GraphicManager.LoadTileLayer(spritesheet,order);
		tilelayer.useTint = true;
		AddLayer(layer,tilelayer);
		
		elements = new Map<String,TileSprite>();
		
		if (GetLayer(layer) != null)
		{
			for (e2 in xml.elements())
			{
				if (e2.nodeType == Xml.Element)
				{
					if (e2.nodeName == "sprite")
					{
						id = e2.get("id");
						spriteName = e2.get("name");
						//layerIndex = spritesheetText;
						spriteX = GraphicManager.FixFloat2ScreenX(Std.parseFloat(e2.get("x")));
						spriteY = GraphicManager.FixFloat2ScreenY(Std.parseFloat(e2.get("y")));
						sprite = new TileSprite(GetLayer(layer), spriteName);
						sprite.r = 1;
						sprite.g = 1;
						sprite.b = 1;
						sprite.x = spriteX;
						sprite.y = spriteY;
						sprite.scaleX = GraphicManager.GetFixScale();
						sprite.scaleY = GraphicManager.GetFixScale();
						
						elements.set(id, sprite);
						AddSprite(id,layer,sprite);
					}
				}
			}
		}
		
		return elements;
	}
	
	public function AddUIbject(uiObj : UIObject)
	{
		if (uiObj != null)
		{
			uiObjects.push(uiObj);
			uiObj.layer.addChild(uiObj);	
			//AddToLayer(UI_LAYER,uiObj);
		}
	}
	
	public function AddText(key : String,text : Text) : Void
	{
		if (!texts.exists(key))
		{
			texts.set(key, text);
			//addChild(text);
		}
	}
	
	public function AddSprite(key : String,layer : String,sprite : TileSprite)
	{
		if (sprite != null)
		{
			sprites.set(key, sprite);
			AddToLayer(layer,sprite);
		}
	}
	
	override public function Clean():Void 
	{
		super.Clean();
		
		for (uiObj in uiObjects)
		{
			uiObj.Clean();
			uiObjects.remove(uiObj);
		}

		if(background != null)
			background = null;
	}
	
	override private function HandleCursorDown(cursorPos : Point,cursorId : Int) : Void
	{
		for (o in uiObjects)
		{
			if(o.HandleMouseDownEvent(cursorPos, this,downIds.length > 0,cursorId))
			{
				if(downUIObj == null)
				{
					downIds.push(cursorId);
					downUIObj = o;
				}
				else
				{
					if (downUIObj == o)
						downIds.push(cursorId);
				}

				break;
			}
		}

		Render();
	}
	
	override private function HandleCursorMove(cursorPos : Point, cursorId : Int) : Void
	{
		var isCursorDown : Bool;

		if (downUIObj != null)
		{
			for (o in uiObjects)
			{
				if (downUIObj == o)
				{
					isCursorDown = false;
					for(c in downIds)
					{
						if(cursorId == c)
						{
							isCursorDown = true;
							break;
						}
					}

					if(isCursorDown)
					{
						if (o.HandleMouseMoveEvent(cursorPos, this, (downIds.length - 1) > 0,cursorId))
						{
							downIds.remove(cursorId);
							if(downIds.length <= 0)
								downUIObj = null;
						}
					}
				}
			}

			Render();
		}
	}
	
	override private function HandleCursorUp(cursorPos : Point, cursorId : Int) : Void
	{
		if (downUIObj != null)
		{
			for (o in uiObjects)
			{
				if (downUIObj == o)
				{
					downIds.remove(cursorId);
					if (o.HandleMouseUpEvent(cursorPos, this,downIds.length > 0,cursorId) && downIds.length <= 0)
						downUIObj = null;
				}
			}

			if(downIds.length <= 0)
			{
				for (o in uiObjects)
				{
					if(o.GetType() == Button.TYPE)
						o.HandleMouseUpEvent(cursorPos, this,false);
				}
			}


			Render();
		}
	}
	
	override public function Update(gameTime:Float):Void 
	{
		super.Update(gameTime);
		
		if (!isClosed)
		{
			if (isClosing)
			{
				if (isPopup)
				{
					if (popupVeil != null)
					{
						popupVeil.alpha = closingAlpha;// * Globals.VEIL_ALPHA;
					}
				}
				
				if (closingAlpha > 0)
					closingAlpha -= 0.05;
				else
				{
					closingAlpha = 0;
					isClosed = true;
					Close();
				}
				
				if (background != null)
					background.alpha = closingAlpha;
				
				for (s in sprites)
				{
					if(s != null)
						s.alpha = closingAlpha;
				}
				
				for (t in texts)
				{
					if(t != null)
						t.alpha = closingAlpha;
				}
			}
			
			for (uiObj in uiObjects)
			{
				if (isClosing)
				{
					uiObj.SetAlpha(closingAlpha);
					Render();
				}
				
				uiObj.Update(gameTime);
			}
		}
	}
	
	public function StartClosing() : Void
	{
		isClosing = true;
	}
	
	public function Close() : Void
	{
	}
	
	override public function AddElementsToRender() : Void
	{
		super.AddElementsToRender();
		for (t in texts)
			addChild(t);
	}
}