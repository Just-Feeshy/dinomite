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

            if(value) {
                __transform.rotate(Math.PI);
            }else {
                __transform.rotate(0);
            }

            __setTransformDirty();
        }

        return value = flipX;
    }
}