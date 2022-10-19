package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.addons.ui.FlxUISubState;

class PauseSubstate extends FlxUISubState {
    var background:FlxSprite;

    var grpItems:FlxTypedGroup<FlxText>;

    #if web
    var menuItems:Array<String> = ['RESUME', 'RESET', 'TITLE SCREEN'];
    #else
    var menuItems:Array<String> = ['RESUME', 'RESET', 'TITLE SCREEN', 'QUIT'];
    #end

    var curSelected:Int = 0;

    var selected:Bool = false;

    @:final var controls:Controls = new Controls('player1', Solo);

    public function new() {
        super();

        if(FlxG.sound.music.playing) {
			FlxG.sound.music.pause();
		}

        background = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        background.alpha = 0.6;
        background.scrollFactor.set(0, 0);
        add(background);

        grpItems = new FlxTypedGroup<FlxText>();
        add(grpItems);

        for(i in 0...menuItems.length) {
            var item:FlxText = new FlxText(40, (45 * i) + 360, menuItems[i], 32);
            item.scrollFactor.set(0, 0);
            grpItems.add(item);
        }

        changeSelection();

        cameras = [FlxG.camera];
    }

    function changeSelection(change:Int = 0):Void {
        curSelected += change;

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

        for(i in 0...grpItems.length) {
            if(i == curSelected) {
                grpItems.members[i].color = FlxColor.YELLOW;
            }else {
                grpItems.members[i].color = FlxColor.WHITE;
            }
        }
    }

    public override function update(elapsed:Float):Void {
        if(!selected) {
            if(controls.UP_P) {
                changeSelection(-1);
            }

            if(controls.DOWN_P) {
                changeSelection(1);
            }

            if(controls.ACCEPT) {
                selected = true;

                switch(curSelected) {
                    case 0:
                        FlxG.sound.music.resume();

                        close();
                    case 1:
                        PlayState.score = 0;
                        FlxG.resetState();
                    case 2:
                        PlayState.score = 0;
                        FlxG.switchState(new TitleState());
                    case 3:
                        #if sys
                        Sys.exit(0);
                        #end
                }
            }
        }

        super.update(elapsed);
    }
}