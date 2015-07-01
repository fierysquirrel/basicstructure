package fs.basicstructure.screens;

import com.fs.fluffeaters.screenmanager.GameScreen;

enum State
{
	Start;
	Play;
	Restart;
	Pause;
	Lose;
	Win;
	FadeIn;
	FadeOut;
	Debug;
}

/**
 * ...
 * @author Henry D. Fernández B.
 */
class GamePlayScreen extends GameScreen
{
	static public var NAME : String = "GAMEPLAY_SCREEN";
	
	public function new(worldNumber : Int, levelNumber : Int) 
	{
		super(NAME);
	}
}