package;

import flixel.text.FlxText;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;

class OptionGroup extends FlxTypedSpriteGroup<FlxText> {
    private var curSelected:Int = 0;
    private var sectionHeight:UInt = 0;

    private final optionSize:UInt = 20;

    private var options:Array<FlxText> = [];

    private var volume:UInt = 100;

    public function new() {
        super();

        createSection("Music Settings", ["Volume: < 100 >"]);
    }

    private function createSection(title:String, optionStr:Array<String>):Void {
        var title = new FlxText(40, sectionHeight + 40, title, 32);
        add(title);

        sectionHeight += 40 + Std.int(title.height) + 16;

        for(list in optionStr) {
            var op:FlxText = new FlxText(120, sectionHeight, list, optionSize);
            options.push(op);
            sectionHeight += optionSize + 8;
            add(op);
        }
    }

    override public function update(elapsed:Float):Void {

    }
}