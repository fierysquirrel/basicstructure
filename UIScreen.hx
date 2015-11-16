package;

import aze.display.TileLayer;
import aze.display.TileSprite;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.geom.Point;
import flash.net.SharedObject;
import flash.text.Font;
import openfl.Assets;


/**
 * ...
 * @author Henry D. Fernández B.
 */
class UIScreen extends GameScreen
{	
	static public var UI_LAYER : String = "UILayer";
	
	private var view : String;
	
	private var uiObjects : Map<String,UIObject>;
	private var isPressingObj : Bool;
	private var backgroundLayer : Sprite;
	private var downUIObj : UIObject;
	private var downIds : Array<Int>;
	private var background : Bitmap;
	private var isClosing : Bool;
	private var closingAlpha : Float;
	private var isClosed : Bool;
	private var texts : Map<String,Text>;
	private var timerManager : TimerManager;
	
	public function new(name : String,x : Float,y : Float,viewPath : String, isPopup : Bool = false) 
	{
		super(name,x,y,isPopup);
		
		this.view = viewPath;
		uiObjects = new Map<String,UIObject>();
		texts = new Map<String,Text>();
		downUIObj = null;
		downIds = new Array<Int>();
		isClosing = false;
		closingAlpha = 1;
		isClosed = false;
		timerManager = new TimerManager();
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
					background = GraphicManager.LoadBitmap(GraphicManager.GetBackgroundsPath() + backText);
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
					Parsetexts(xml);
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
		var state, text, id, spritesheet, spriteName, layer, data, onActionHandlerName, backActiveName, backPressName, id, onCheckHandlerName, onUncheckHandlerName, checkedText, uncheckedText, image, fontId,onSoundHandlerName : String;
		var uiObjX, uiObjY, spriteX, spriteY, rotation, recX, recY, titleX, titleY, pagerX, pagerY, pagerSep,minSpeed,maxSpeed,threshold : Float;
		var textSize, activeColor,pressColor, order, titleColor, titleBackColor,titleBackSep : Int;
		var checked, hasTitle, hasPager, flipX, isFeedback : Bool;
		var options : Array<Option>;
		var sliderPages : Array<SliderPage>;
		var uiObj : UIObject;
		var page : SliderPage;
		var tileLayer : Layer;
		var pos : Point;
		var font : Font;
		var sliderTitle : SliderTitle;
		
		backActiveName = "";
		backPressName = "";
		
		spritesheet = xml.get("spritesheet");
		layer = xml.get("layer");
		order = Std.parseInt(xml.get("order"));
		
		onSoundHandlerName = "OnSoundHandlerName";
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
				activeColor = 0xffffff;
				pressColor = 0xffffff;
				switch(e2.nodeName.toLowerCase())
				{
					case TextButton.XML:
						
						text = LanguageManager.Translate(e2.get("text"));
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
						textSize = GraphicManager.FixIntScale2Screen(Std.parseInt(e2.get("size")));
						font = TextManager.GetFont(e2.get("font"));
						activeColor = Std.parseInt(e2.get("activeColor"));
						pressColor = Std.parseInt(e2.get("pressColor"));
						
						fontId = e2.get("font");
						//Button
						uiObj = new TextButton(id, tileLayer,uiObjX,uiObjY,onActionHandlerName,text,fontId,textSize,activeColor,pressColor,backActiveName,backPressName,onSoundHandlerName);
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
										activeColor = Std.parseInt(e3.get("color"));
									case "pressed":
										backPressName = e3.get("name");
										pressColor = Std.parseInt(e3.get("color"));
								}
							}
						}
						
						rotation = e2.get("rotation") != null ? Std.parseFloat(e2.get("rotation")) : 0;
						image = e2.get("image");
						flipX = e2.get("flipX") == null ? false : e2.get("flipX") == "true";
						
						//Add on press handler name
						onActionHandlerName = e2.get("onPress");
						uiObj = new ImageButton(id,tileLayer,uiObjX,uiObjY,onActionHandlerName,activeColor,pressColor,backActiveName,backPressName,image,flipX,onSoundHandlerName);
					case TextCheckBox.XML:
						checkedText = LanguageManager.Translate(e2.get("checkedText"));
						uncheckedText = LanguageManager.Translate(e2.get("uncheckedText"));
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
										activeColor = Std.parseInt(e3.get("color"));
									case "pressed":
										backPressName = e3.get("name");
										pressColor = Std.parseInt(e3.get("color"));
								}
							}
						}
						//Add on press handler name
						onCheckHandlerName = e2.get("onCheck");
						onUncheckHandlerName = e2.get("onUncheck");
						
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
						textSize = GraphicManager.FixIntScale2Screen(Std.parseInt(e2.get("size")));
						font = TextManager.GetFont(e2.get("font"));
						activeColor = Std.parseInt(e2.get("activeColor"));
						pressColor = Std.parseInt(e2.get("pressColor"));
						fontId = e2.get("font");
						//Button
						uiObj = new TextSelect(id, tileLayer, uiObjX, uiObjY,fontId ,onActionHandlerName,options, 0, font, textSize,activeColor,pressColor, backActiveName, backPressName);
					case Slider.XML:
						sliderPages = new Array<SliderPage>();
						
						hasTitle = e2.get("hasTitle") == null ? true : e2.get("hasTitle") == "true";
						hasPager = e2.get("hasPager") == null ? true : e2.get("hasPager") == "true";
						
						pagerX = GraphicManager.FixFloat2ScreenX(Std.parseFloat(e2.get("pagerX")));
						pagerY = GraphicManager.FixFloat2ScreenY(Std.parseFloat(e2.get("pagerY")));
						pagerSep = GraphicManager.FixFloat2ScreenX(Std.parseFloat(e2.get("pagerSeparation")));
						
						onActionHandlerName = e2.get("onPress");
						minSpeed = GraphicManager.FixFloat2ScreenX(Std.parseFloat(e2.get("minSpeed")));
						maxSpeed = GraphicManager.FixFloat2ScreenX(Std.parseFloat(e2.get("maxSpeed")));
						threshold = GraphicManager.FixFloat2ScreenX(Std.parseFloat(e2.get("threshold")));
						
						sliderTitle = null;
						if (hasTitle)
						{
							titleX = GraphicManager.FixFloat2ScreenX(Std.parseFloat(e2.get("titleX")));
							titleY = GraphicManager.FixFloat2ScreenY(Std.parseFloat(e2.get("titleY")));
							fontId = e2.get("titleFont");
							textSize = GraphicManager.FixIntScale2Screen(Std.parseInt(e2.get("titleSize")));
							titleColor = Std.parseInt(e2.get("titleColor"));
							titleBackColor = Std.parseInt(e2.get("titleBackColor"));
							titleBackSep = GraphicManager.FixIntScale2Screen(Std.parseInt(e2.get("titleBackSeparation")));
							
							
							sliderTitle = new SliderTitle(TextManager.GetFont(fontId).fontName, textSize, titleColor,titleBackColor,titleBackSep, GraphicManager.FixIntScale2Screen(3), new Point(titleX, titleY), "center", "middle", false);
						}
						
						//Pages
						for (e3 in e2.elements())
						{
							if (e3.nodeName.toLowerCase() == SliderPage.XML)
							{
								page = new SliderPage(Std.parseInt(e3.get("number")), tileLayer, GraphicManager.FixFloat2ScreenX(Std.parseFloat(e3.get("x"))), GraphicManager.FixFloat2ScreenY(Std.parseFloat(e3.get("y"))), LanguageManager.Translate(e3.get("title")).toUpperCase());
								
								for (e4 in e3.elements())
									ParseSliderElements(tileLayer,page, e4,onActionHandlerName);
								
								sliderPages.push(page);
							}
						}
						
						//Button
						uiObj = new Slider(id, tileLayer, uiObjX, uiObjY, sliderPages, onActionHandlerName, 0, GraphicManager.GetWidth(), minSpeed, maxSpeed, threshold, sliderTitle , 1 ,hasPager, pagerX, pagerY, pagerSep);// onActionHandlerName);
					default:	
				}
				
				if (uiObj != null)
				{
					uiObj.SetScale(GraphicManager.GetFixScale());
					//if(isFeedback)
					//	uiObj.SetEffect(Effect.Zoom);
					//uiObj.LoadContent();
					AddUIbject(id,uiObj);
				}
			}
		//}
	}
	
	private function OnSoundHandlerName() : Void
	{
		SoundManager.PlayLoadedSound("ui-object-click.wav");
	}
	
	private function ParseSliderElements(tileLayer : TileLayer,page : SliderPage, elementType : Xml,actionHandlerName : String) : Void
	{
	}
	
	private function Parsetexts(xml : Xml) : Map<String,Text>
	{
		var font, text, xAlign, yAlign : String;
		var translate : Bool;
		var size, color, letterSpacing,order : Int;
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
				translate = e.get("translate") == null ? true : e.get("translate") == "true";
				text = translate ? LanguageManager.Translate(e.get("value")) : e.get("value");
				pos = GraphicManager.FixPoint2Screen(new Point(Std.parseFloat(e.get("x")), Std.parseFloat(e.get("y"))));
				size =  GraphicManager.FixIntScale2Screen(Std.parseInt(e.get("size")));
				order =  e.get("order") == null ? 0 : Std.parseInt(e.get("order"));
				color = Std.parseInt(e.get("color"));
				
				xAlign = e.get("x-align") == null ? "center" : e.get("x-align");
				yAlign = e.get("y-align") == null ? "middle" : e.get("y-align");
				
				letterSpacing = GraphicManager.FixIntScale2Screen(Std.parseInt(e.get("letterspacing")));
				
				textField = TextManager.CreateText(font, text, pos, size, color, letterSpacing, xAlign, yAlign, order);
				
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
		var order, flipHor, flipVer : Int;
		
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
						sprite.r = e2.get("r") == null ? 1 : Std.parseFloat(e2.get("r"))/255;
						sprite.g = e2.get("g") == null ? 1 : Std.parseFloat(e2.get("g"))/255;
						sprite.b = e2.get("b") == null ? 1 : Std.parseFloat(e2.get("b"))/255;
						sprite.x = spriteX;
						sprite.y = spriteY;
						
						flipHor = e2.get("flip-hor") == null ? 1 : -1;
						flipVer = e2.get("flip-ver") == null ? 1 : -1;
						sprite.scaleX = GraphicManager.GetFixScale() * flipHor;
						sprite.scaleY = GraphicManager.GetFixScale() * flipVer;
						
						elements.set(id, sprite);
						AddSprite(id,layer,sprite);
					}
				}
			}
		}
		
		return elements;
	}
	
	public function AddUIbject(key : String,uiObj : UIObject)
	{
		if (uiObj != null)
		{
			if (!uiObjects.exists(key))
			{
				uiObjects.set(key, uiObj);
				uiObj.layer.addChild(uiObj);	
			}
			
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
		
		for (k in uiObjects.keys())
		{
			uiObjects.get(k).Clean();
			uiObjects.remove(k);
		}
		
		for (k in texts.keys())
		{
			removeChild(texts.get(k));
			texts.remove(k);
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
				if (o != null && downUIObj != null)
				{
					if (downUIObj == o)
					{
						downIds.remove(cursorId);
						if (o.HandleMouseUpEvent(cursorPos, this,downIds.length > 0,cursorId) && downIds.length <= 0)
							downUIObj = null;
					}
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
					if (backgroundColor != null)
					{
						backgroundColor.alpha = closingAlpha;// * Globals.VEIL_ALPHA;
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
			
			for (t in texts)
				t.Update(gameTime);
			
				
			//Timer Manager System
			timerManager.Update(gameTime);
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
		
		var orderedTexts : Array<Text>;
		
		orderedTexts = new Array<Text>();
		
		for (t in texts)
			orderedTexts.push(t);
		
		//Order
		orderedTexts.sort(SortText);
			
		//Texts
		for (t in orderedTexts)
			addChild(t);
	}
	
	private function SortText(x : Text,y : Text) : Int
	{
		if (x.GetOrder() == y.GetOrder())
			return 0;
		else if (x.GetOrder() > y.GetOrder())
			return 1;
		else
			return -1;
	}
	
	public function StartTimerTask(duration : Float, onComplete : Void -> Void, onRunning : Float -> Void = null) : Void
	{
		timerManager.StartTimerTask(duration, onComplete, onRunning);
	}
}