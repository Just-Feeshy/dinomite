package;

import flixel.FlxSprite;
import flixel.math.FlxRect;
import openfl.Lib;

class Player extends FlxSprite {
    public var gravity:Float = 0;
    public var jumpForce:Float = 0;

    public var isTouchingGround:Bool = false;

    @:final var clipRight:Float = 0.2;

    public function new(x:Float = 0, y:Float = 0) {
        super(x, y);

        loadGraphic(AssetPath.image("assets/images/dumb-dino2"), true, 16, 16);
        animation.add("idle", [0], 0, true);
        animation.add("walk", [1, 2], 2, true);
        animation.play("walk");
    }

    override function update(elapsed:Float):Void {
        y += (jumpForce * elapsed) + ((gravity * Math.pow(elapsed, 2)) * 0.5);

        super.update(elapsed);
    }
}
