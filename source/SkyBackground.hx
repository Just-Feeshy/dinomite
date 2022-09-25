package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import flixel.util.FlxDestroyUtil;
import openfl.display.BitmapData;

class SkyBackground extends FlxSprite {
    public var cyan(default, set):UInt = 255;

    public var skyColor(default, null):FlxColor = 0;
    public var darkerColor(default, null):FlxColor = 0;
    
    var bitmapGradiend:BitmapData;

    public function new() {
        super(0, 0);

        scrollFactor.set(0, 0);
    }

    function set_cyan(value:UInt):UInt {
        skyColor = FlxColor.fromRGB(0, value, value);
        darkerColor = FlxColor.fromRGB(0, Std.int(value * 0.5), Std.int(value * 0.5));

        if(bitmapGradiend != null) {
            bitmapGradiend = FlxDestroyUtil.dispose(bitmapGradiend);
        }

        bitmapGradiend = FlxGradient.createGradientBitmapData(FlxG.width, FlxG.height, [skyColor, darkerColor]);
        pixels = bitmapGradiend;

        return cyan = value;
    }

    override public function destroy():Void {
        super.destroy();

        bitmapGradiend = FlxDestroyUtil.dispose(bitmapGradiend);
    }
}