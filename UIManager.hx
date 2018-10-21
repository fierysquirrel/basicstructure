package;

import openfl.display.SparrowTileset;
import openfl.display.Tile;
import openfl.display.Tilemap;
import flash.display.BitmapData;
import flash.geom.Point;
import flash.text.Font;
import openfl.Assets;

import fs.ui.*;

/**
 * ...
 * @author Fiery Squirrel
 */
class UIManager
{
	static public var UI_LAYER : String = "UILayer";
	
	private var downUIObj : UIObject;
	
	private var downIds : Array<Int>;
	
	private var uiObjects : Array<UIObject>;
	
	private var layers : Map<String,Tilemap>;
	
	public function new(layers : Map<String,Tilemap>) 
	{
		this.layers = layers;
		uiObjects = new Array<UIObject>();
		downUIObj = null;
		downIds = new Array<Int>();
	}
	
	public function Clean():Void 
	{
		for (uiObj in uiObjects)
		{
			uiObj.Clean();
			uiObjects.remove(uiObj);
		}
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
	
	public function Update(gameTime:Float):Void 
	{
		for (uiObj in uiObjects)
		{
			/*if (isClosing)
			{
				uiObj.SetAlpha(closingAlpha);
				Render();
			}*/
			
			uiObj.Update(gameTime);
		}
	}
	
	public function ParseObjects(xml : Xml) : Void
	{
		var state, text, id, spritesheetText, spriteName, layer, data, onActionHandlerName, backActiveName, backPressName, id, onCheckHandlerName, onUncheckHandlerName, checkedText, uncheckedText, image : String;
		var uiObjX, uiObjY, spriteX, spriteY, rotation, recX, recY, titleX, titleY, pagerX, pagerY, pagerSep : Float;
		var uiSpritesheet, backSpriteheet : BitmapData;
		var textSize, totalFishes, minFishes, world, activeColor, pressedColor : Int;
		var checked, hasTitle, hasPager, flipX, lockedWorld, isFeedback, unlocking, completedWorld : Bool;
		var options : Array<Option>;
		var sliderPages : Array<SliderPage>;
		var uiObj : UIObject;
		var sliderEle : SliderPageButton;
		var page : SliderPage;
		var tileLayer : Tilemap;
		var pos : Point;
		var font : Font;
		
		backActiveName = "";
		backPressName = "";
		font = null;
		activeColor = 0x000000;
		pressedColor = 0x000000;
		
		spritesheetText = xml.get("spritesheet");
		layer = xml.get("layer");
				
		//if (spritesheetText != "")
		//{
			tileLayer = GraphicManager.LoadTileLayer(spritesheetText);
			tileLayer.useTint = true;
			//AddLayer(layer,tileLayer);
		//}
		
		/*if (layers.exists(layer))
			tileLayer = layers.get(layerName);
		else
		{
			if (spritesheetText != "")
			{
				uiSpritesheet = Helper.LoadBitmapData(Globals.SPRITES_PATH + spritesheetText + ".png");
				data = Assets.getText(Globals.SPRITES_PATH + spritesheetText + ".xml");
				uiTileLayer = new SparrowTilesheet(uiSpritesheet, data);
				globalTileLayer = new TileLayer(uiTileLayer);
				globalTileLayer.useTint = true;
				AddLayer(UI_LAYER, globalTileLayer);
			}
		}*/
			
		for (e2 in xml.elements())
		{
			uiObj = null;
			id = e2.get("name");
			isFeedback = e2.get("isFeedback") == null ? false : e2.get("isFeedback") == "true";
			uiObjX = Std.parseFloat(e2.get("x"));
			uiObjY = Std.parseFloat(e2.get("y"));
			
			//TODO: Add the possibility to have elements in different layers
			
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
					textSize = GraphicManager.FixIntScale2Screen(Std.parseInt(e2.get("textsize")));
					//Button
					uiObj = new TextButton(id, tileLayer,uiObjX,uiObjY,onActionHandlerName,text,font,textSize,activeColor,pressedColor,backActiveName,backPressName);
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
					
					uiObj = new ImageButton(id,tileLayer,uiObjX,uiObjY,onActionHandlerName,activeColor, pressedColor,backActiveName,backPressName,image,flipX);
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
					textSize = GraphicManager.FixIntScale2Screen(Std.parseInt(e2.get("textsize")));
					//Button
					uiObj = new TextCheckBox(id, tileLayer, uiObjX, uiObjY, onCheckHandlerName,onUncheckHandlerName,checked, checkedText,uncheckedText,font, textSize,activeColor, pressedColor, backActiveName, backPressName);
					
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
					textSize = GraphicManager.FixIntScale2Screen(Std.parseInt(e2.get("textsize")));
					//Button
					uiObj = new ImageCheckBox(id, tileLayer, uiObjX, uiObjY, onCheckHandlerName, onUncheckHandlerName, checked, activeColor, pressedColor, backActiveName, backPressName, checkedText, uncheckedText);
				case TextSelect.XML:
					options = new Array<Option>();
					//TODO: Translate system
					checkedText = "";// Helper.Translate(e2.get("checkedText"));
					uncheckedText = "";// Helper.Translate(e2.get("uncheckedText"));
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
					textSize = GraphicManager.FixIntScale2Screen(Std.parseInt(e2.get("textsize")));
					//Button
					uiObj = new TextSelect(id, tileLayer, uiObjX, uiObjY, onActionHandlerName, options, 0, font, textSize, activeColor, pressedColor, backActiveName, backPressName);
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
							//TODO: Corregir lo de la traduccion
							//page = new SliderPage(Std.parseInt(e3.get("number")), tileLayer, GraphicManager.FixFloat2ScreenX(Std.parseFloat(e3.get("x"))), GraphicManager.FixFloat2ScreenY(Std.parseFloat(e3.get("y"))), ""/*Helper.Translate(e3.get("title")).toUpperCase()*/);
							page = new SliderPage(Std.parseInt(e3.get("number")), tileLayer, Std.parseFloat(e3.get("x")), Std.parseFloat(e3.get("y")), ""/*Helper.Translate(e3.get("title")).toUpperCase()*/);
							for (e4 in e3.elements())
							{
								//TODO: Fix this
								/*switch(e4.nodeName.toLowerCase())
								{
									//case WorldButton.XML:
									
									case "type"
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
										
										sliderEle = new WorldButton(e4.get("name"), tileLayer, Helper.FixFloat2ScreenX(Std.parseFloat(e4.get("x"))), Helper.FixFloat2ScreenY(Std.parseFloat(e4.get("y"))), world,onActionHandlerName,"",lockedWorld,minFishes,page,unlocking,completedWorld);
										sliderEle.SetScale(Helper.GetFixScale());
										page.AddElement(sliderEle);
									default:
								}*/
							}
							
							sliderPages.push(page);
						}
					}
					
					//Button
					//TODO: check this
					//uiObj = new Slider(id, tileLayer, uiObjX, uiObjY, sliderPages,"",0,hasTitle,titleX,titleY,hasPager,pagerX,pagerY,pagerSep);// onActionHandlerName);
				default:	
			}
			
			//TODO: Fix the scale
			//uiObj.SetScale(GraphicManager.GetFixScale());
			
			//if(isFeedback)
				//uiObj.SetEffect(Effect.Zoom);
			//uiObj.LoadContent();
			AddUIbject(uiObj);
		}
	}
	
	public function HandleCursorDown(cursorPos : Point,cursorId : Int) : Void
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
	}
	
	public function HandleCursorMove(cursorPos : Point, cursorId : Int) : Void
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
		}
	}
	
	public function HandleCursorUp(cursorPos : Point, cursorId : Int) : Void
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
		}
	}
	
}