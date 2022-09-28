package;

import feshixl.FeshGame;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.Lib;

class Main extends Sprite
{
	private static var game:FeshGame;

	var zoom:Float = 1;

	var fps:Int = 120;

	#if debug
	var fullscreen:Bool = false;
	#else
	var fullscreen:Bool = true;
	#end

	public static function main():Void {
		Lib.current.addChild(new Main());
	}

	public function new() {
		super();

		if (stage != null) {
			init();
		}else {
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}

	private function init(?E:Event):Void {
		if (hasEventListener(Event.ADDED_TO_STAGE)) {
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}

		setupGame();
	}

	private function setupGame():Void {
		game = new FeshGame(0, 0, TitleState, zoom, fps, fps, true, fullscreen);
		addChild(game);
	}
}
