package;

import openfl.display.Sprite;
import feshixl.math.FeshMath3D;

class SpriteRotationSide extends Sprite {
    public var flipX(get, set):Bool;

    @:noCompletion var __flipX:Bool = false;

    public function new() {
        super();
    }

    @:keep @:noCompletion function get_flipX():Bool {
        return __flipX;
    }

    @:keep @:noCompletion function set_flipX(value:Bool):Bool {
        if(value != __flipX) {
            __transform.invert();
            __transform.rotate(Math.PI);

            __setTransformDirty();
        }

        return value = flipX;
    }
}