package;

import flixel.FlxG;
import flixel.FlxCamera;

class TitleState extends BetterUIStates {
    override public function create():Void {
        initSave();

        FlxG.switchState(new PlayState());

        super.create();
    }

    function initSave():Void {
        FlxG.save.bind('dinomite', 'Los Gay Boys');

        if(FlxG.save.data.highScore == null) {
            FlxG.save.data.highScore = 0;
        }
    }
}