package;

import flixel.FlxG;
import openfl.text.TextField;
import openfl.text.TextFormat;

/*
* WIP
*/
class Version extends TextField {
    public static final version:String = "1.0.0";

    public function new() {
        super();

        this.x = 10;
        this.y = 10;

        this.selectable = false;

        defaultTextFormat = new TextFormat("_sans", 12, 0x000000);

        width = 150;
		height = 70;

        text = "v" + version;
    }
}