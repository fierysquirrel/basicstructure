package;

/**
 * ...
 * @author Henry D. Fernández B.
 */
class AlertScreen extends ModalScreen
{
	static public var NAME : String = "ALERT_SCREEN";
	
	private var onConfirm : Void->Void;
	
	public function new(onConfirm : Void->Void = null,viewPath : String = "assets/ui/", view : String = "alert.xml") 
	{
		super(NAME, viewPath, view);
		
		this.onConfirm = onConfirm;
	}
	
	public function OnOkHandler() : Void
	{
		if (onConfirm != null)
			onConfirm();
			
		StartClosing();
	}
	
	override public function Close():Void 
	{
		super.Close();
		
		eventDispatcher.dispatchEvent(new GameEvent(GameEvents.EVENT_SCREEN_EXITED,NAME));
	}
}