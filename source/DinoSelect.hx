package;

import flixel.FlxSprite;

class DinoSelect extends FlxSprite {
	public function new(x:Float = 0, y:Float = 0, size:Int = 192) {
		super(x, y);

		loadGraphic(AssetPath.image("assets/images/dumb-dino1"), true, 16, 16);
		animation.add("idle", [0], 0, true);
		animation.add("walk", [1, 2], 2, true);
		animation.play("walk");

		setGraphicSize(size, size);
		updateHitbox();

		scrollFactor.set(0, 0);
		antialiasing = false;
		origin.set(frameWidth * 0.5, frameHeight * 0.5);
	}
}
