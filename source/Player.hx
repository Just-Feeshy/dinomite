package;

import feshixl.FeshSprite;
import openfl.Lib;

class Player extends FeshSprite {
    public var gravity:Float = 0;
    public var jumpForce:Float = 0;

    public function new(x:Float = 0, y:Float = 0) {
        super(x, y);
    }

    override function update(elapsed:Float):Void {
        y += (jumpForce * elapsed) + ((gravity * Math.pow(elapsed, 2)) * 0.5);
        jumpForce -= Math.min(jumpForce - (elapsed * 10), 0);

        super.update(elapsed);
    }
}