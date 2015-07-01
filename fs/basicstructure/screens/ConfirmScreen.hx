package fs.basicstructure.screens;

/**
 * ...
 * @author Henry D. Fernández B.
 */
class ConfirmScreen extends ModalScreen
{
	static public var NAME : String = "CONFIRM_SCREEN";
	
	private var onConfirm : Void->Void;
	
	public function new(onConfirm : Void->Void,line1 : String,line2 : String = "",line3 : String = "") 
	{
		super(NAME,"assets/ui/confirm.xml",line1,line2,line3);
		
		this.onConfirm = onConfirm;
	}
	
	override public function Close():Void 
	{
		super.Close();
		
		eventDispatcher.dispatchEvent(new GameEvent(ScreenManager.EVENT_SCREEN_EXITED,NAME));
	}
	
	public function OnNoHandler() : Void
	{
		StartClosing();
	}
	
	public function OnYesHandler() : Void
	{
		onConfirm();
		StartClosing();
	}
}