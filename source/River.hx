package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

class River extends FlxSpriteGroup {
    var blockDistance:Float = 0;

    var startingY:Float = 0;
    var totalTicks:Float = 0;

    public var getX:Float = 0;

    public function new(startingY:Float = 0) {
        this.startingY = startingY;
        super(0, startingY);

        scrollFactor.set(0, 1);
        genMap();
    }

    function genMap():Void {
        for(i in 0...Math.ceil(FlxG.width / 64)) {
            var water:FlxSprite = new FlxSprite(i * 64, 0).loadGraphic(AssetPath.image("assets/images/water"));
            water.setGraphicSize(64, 64);
            water.updateHitbox();
            add(water);

            blockDistance += 64;
        }

        blockDistance -= 64;
        screenCenter(X);
    }

    override public function update(elapsed:Float):Void {
        x = getX - (totalTicks * 64);

        if(members[0].x < -64) {
            remove(members[0], true);
        }

        if(members[members.length - 1].x < FlxG.width) {
            var water:FlxSprite = new FlxSprite(blockDistance + 64, 0).loadGraphic(AssetPath.image("assets/images/water"));
            water.setGraphicSize(64, 64);
            water.updateHitbox();
            add(water);

            blockDistance += 64;
        }

        totalTicks += elapsed;
        super.update(elapsed);
    }
}