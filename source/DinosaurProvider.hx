package;

import flixel.graphics.FlxGraphic;

class DinosaurProvider {
	public static var selectedDino:Int = 0;

	private static var dinosaurs:Array<Dinosaur>;

	public static function getAll():Array<Dinosaur> {
		if (dinosaurs == null) {
			dinosaurs = [
				make("T-Rex", "assets/images/dumb-dino1", 100000, 0, false, 0),
				make("Stegosaurus", "assets/images/dumb-dino2", 98000, 0, false, 750),
				make("Brontosaurus", "assets/images/dumb-dino3", 102000, 0, true, 1500)
			];
		}

		return dinosaurs;
	}

	static function make(name:String, path:String, gravity:Float, jumpForce:Float, canDoubleJump:Bool, scoreRequired:Int):Dinosaur {
		var graphic:FlxGraphic = AssetPath.image(path);
		graphic.persist = true;
		graphic.destroyOnNoUse = false;

		return {
			name: name,
			gravity: gravity,
			canDoubleJump: canDoubleJump,
			bitmap: graphic,
			scoreRequired: scoreRequired
		};
	}
}
