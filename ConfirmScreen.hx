package;

/**
 * ...
 * @author Henry D. Fernández B.
 */
class ConfirmScreen extends ModalScreen
{
	static public var NAME : String = "CONFIRM_SCREEN";
	
	private var onConfirm : Void->Void;
	
	public function new(onConfirm : Void->Void,viewPath : String = "assets/ui/", view : String = "confirm.xml") 
	{
		super(NAME,viewPath,view);
		
		this.onConfirm = onConfirm;
	}
	
	override public function Close():Void 
	{
		super.Close();
		
		ScreenManager.ExitScreen(this);
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