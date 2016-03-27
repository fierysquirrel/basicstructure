package;

import flash.events.Event;

/**
 * ...
 * @author Henry D. Fernández B.
 */
class ModalScreen extends UIScreen
{	
	public function new(name : String, viewPath : String,viewName : String) 
	{
		super(name, 0, 0, viewPath,viewName, true);
	}
	
	override public function HandleBackButtonPressed(e : Event) : Void
	{
		StartClosing();
	}
}