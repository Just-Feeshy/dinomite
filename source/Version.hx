package;

import flixel.FlxG;
import flixel.system.FlxAssets;
import openfl.text.TextField;
import openfl.text.TextFormat;

/*
* WIP
*/
class Version extends TextField {
    public static var version:String = "1.0.0";

    public function new() {
        super();

        this.x = 10;

        this.selectable = false;

        defaultTextFormat = new TextFormat(FlxAssets.FONT_DEFAULT, 18, 0xFFFFFF);

        width = 150;
        height = 70;

        #if web
        this.y = FlxG.height - Std.int(height * 0.25) - 10;
        #else
        this.y = 10;
        #end

        text = "v" + version;
    }
}