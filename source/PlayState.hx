package;

import flixel.text.FlxText;
import flixel.FlxState;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

class PlayState extends FlxState {
	override public function create():Void {
		super.create();
		add(new FlxText("Hello World", 32).screenCenter());
	}

	override public function update(elapsed:Float){
		super.update(elapsed);
	}
}