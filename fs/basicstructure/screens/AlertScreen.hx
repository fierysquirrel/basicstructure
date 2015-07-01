package fs.basicstructure.screens;

/**
 * ...
 * @author Henry D. Fernández B.
 */
class AlertScreen extends ModalScreen
{
	static public var NAME : String = "ALERT_SCREEN";
	
	public function new(line1 : String,line2 : String = "",line3 : String = "") 
	{
		super(NAME, "assets/ui/alert.xml",line1,line2,line3);
	}
	
	public function OnOkHandler() : Void
	{
		StartClosing();
	}
	
	override public function Close():Void 
	{
		super.Close();
		
		eventDispatcher.dispatchEvent(new GameEvent(ScreenManager.EVENT_SCREEN_EXITED,NAME));
	}
}