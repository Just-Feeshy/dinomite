package;

import flixel.system.FlxAssets.FlxShader;
import openfl.display.BitmapData;

class BloodMoonShader extends FlxShader {
    public var redness(default, set):Float = 0;

    @:glFragmentSource('
        #pragma header

        uniform float red;

        void main() {
            vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv);
            gl_FragColor = vec4(color.r, color.g * (1.0 - red), color.b * (1.0 - red), color.a);
        }
    ')
    public function new() {
        super();
    }

    function set_redness(value:Float):Float {
        red.value = [value];
        return redness = value;
    }
}