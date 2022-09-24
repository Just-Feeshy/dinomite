package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;

import feshixl.FeshCamera;
import feshixl.FeshSprite;

class PlayState extends BetterUIStates {
	override public function create():Void {
		var sky:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.fromRGB(0, 75, 75));
		sky.scrollFactor.set(0, 0);
		add(sky);

		super.create();
		add(new FlxText("Hello World", 32).screenCenter());
	}

	override public function update(elapsed:Float){
		super.update(elapsed);
	}
}