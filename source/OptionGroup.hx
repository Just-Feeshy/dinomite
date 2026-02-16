package;

import flixel.FlxG;
import flixel.text.FlxText;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.util.FlxColor;
import flixel.input.keyboard.FlxKey;

import feshixl.math.FeshMath;

class OptionGroup extends FlxTypedSpriteGroup<FlxText> {
    public var selected(default, null):Bool = false;

    public var controlSelector:Bool = false;
    public var inUse:Bool = false;

    private var curSelected:Int = 0;
    private var sectionHeight:UInt = 0;

    private final optionSize:UInt = 20;

    private var options:Array<FlxText> = [];

    /*
    * Sprites and Shit
    */
    private var arrow:FlxText;

    final controls:Controls = new Controls('player1', Solo);

    public function new() {
        super();

        createSection("Player Settings", ['Jump: ${FlxKey.toStringMap.get(FlxG.save.data.customKeys.UP)}', 'Go Down: ${FlxKey.toStringMap.get(FlxG.save.data.customKeys.DOWN)}', 'Pause: ${FlxKey.toStringMap.get(FlxG.save.data.customKeys.PAUSE)}']);
        createSection("UI Settings", [
            'UI Up: ${FlxKey.toStringMap.get(FlxG.save.data.customKeys.UP_UI)}',
            'UI Down: ${FlxKey.toStringMap.get(FlxG.save.data.customKeys.DOWN_UI)}',
            'UI Left: ${FlxKey.toStringMap.get(FlxG.save.data.customKeys.LEFT_UI)}',
            'UI Right: ${FlxKey.toStringMap.get(FlxG.save.data.customKeys.RIGHT_UI)}'
        ]);

        arrow = new FlxText(0, options[0].y, "<", optionSize);
        arrow.x = options[0].x + options[0].width + arrow.width + 16;
        add(arrow);
    }

    function createSection(title:String, optionStr:Array<String>):Void {
        var title = new FlxText(40, sectionHeight + 40, title, 32);
        add(title);

        sectionHeight += 40 + Std.int(title.height) + 16;

        for(list in optionStr) {
            var op:FlxText = new FlxText(120, sectionHeight, list, optionSize);
            options.push(op);
            sectionHeight += optionSize * 2;
            add(op);
        }

        sectionHeight += 32;
    }

    function changeSelection(change:Int = 0):Void {
        if(controlSelector) curSelected += change;

		if (curSelected < 0)
			curSelected = options.length - 1;
		if (curSelected >= options.length)
			curSelected = 0;


        arrow.y = options[curSelected].y;
        arrow.x = options[curSelected].x + options[curSelected].width + arrow.width + 16;
    }

    function selectedSection():Void {
        switch(curSelected) {
            default:
                if(FlxG.keys.justPressed.ANY) {
                    var keyPressed:FlxKey = FlxG.keys.firstJustPressed();
                    var keyString:String = FlxKey.toStringMap.get(keyPressed);

                    selected = false;
                    options[curSelected].text = options[curSelected].text.split(":")[0] + ": " + keyString;
                    arrow.x = options[curSelected].x + options[curSelected].width + arrow.width + 16;
                    options[curSelected].color = FlxColor.WHITE;

                    switch(curSelected) {
                        case 0:
                            FlxG.save.data.customKeys.UP = keyPressed;
                        case 1:
                            FlxG.save.data.customKeys.DOWN = keyPressed;
                        case 2:
                            FlxG.save.data.customKeys.PAUSE = keyPressed;
                        case 3:
                            FlxG.save.data.customKeys.UP_UI = keyPressed;
                        case 4:
                            FlxG.save.data.customKeys.DOWN_UI = keyPressed;
                        case 5:
                            FlxG.save.data.customKeys.LEFT_UI = keyPressed;
                        case 6:
                            FlxG.save.data.customKeys.RIGHT_UI = keyPressed;
                    }

                    controls.setKeyboardScheme(Solo);
                    FlxG.save.flush();
                }
        }
    }

    override public function update(elapsed:Float):Void {
        if(!controlSelector) {
            return;
        }

        if(!selected) {
            if(controls.UP_UI) {
                changeSelection(-1);
            }

            if(controls.DOWN_UI) {
                changeSelection(1);
            }

            if(controls.ACCEPT) {
                selected = true;
                options[curSelected].color = FlxColor.YELLOW;
            }

            if(controls.BACK) {
                controlSelector = false;
                inUse = false;
            }
        }else {
            if(controls.BACK) {
                selected = false;

                for(i in 0...options.length) {
                    options[i].color = FlxColor.WHITE;
                }
            }

            selectedSection();
        }
    }
}
