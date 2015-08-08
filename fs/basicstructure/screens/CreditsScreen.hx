package fs.basicstructure.screens;

/**
 * ...
 * @author Henry D. Fernández B.
 */
class CreditsScreen extends UIScreen
{
	static public var NAME : String = "CREDITS_SCREEN";
	
	public function new() 
	{
		super(NAME, 0, 0, "assets/ui/credits_menu.xml");
	}
}