package;

import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite
{
	private static var game:FlxGame;

	var zoom:Float = 1;

	var fps:Int = 60;

	#if debug
	var fullscreen:Bool = false;
	#else
	var fullscreen:Bool = true;
	#end

	public function new()
	{
		super();
		
		game = new FlxGame(0, 0, PlayState, zoom, fps, fps, true, fullscreen);

		addChild(game);
	}
}
