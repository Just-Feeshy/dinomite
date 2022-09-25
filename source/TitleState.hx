package;

import flixel.FlxG;

class TitleState extends BetterUIStates {
    override public function create():Void {
        FlxG.switchState(new PlayState());

        super.create();
    }
}