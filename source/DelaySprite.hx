package;

import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;

typedef DelayedAnimation = {
    var animation:String;
    var timer:Float;
}

class DelaySprite extends FlxSprite {
    public var onFinishedAnimation:(name:String) -> Void;

    var readyPlayAnim:Array<DelayedAnimation>;

    public function new(?X:Float = 0, ?Y:Float = 0, ?SimpleGraphic:FlxGraphicAsset) {
        super(X, Y, SimpleGraphic);

        readyPlayAnim = [];
        animation.onFinish.add(handleFinishedAnimation);
    }

    public function playAnim(Anim:String, Timer:Float) {
        readyPlayAnim.push({animation: Anim, timer: Timer});
    }

    override function update(elapsed:Float):Void {
        super.update(elapsed);

        var index:Int = 0;

        while(index < readyPlayAnim.length) {
            var delayedAnim:DelayedAnimation = readyPlayAnim[index++];

            if(delayedAnim.timer <= 0) {
                animation.play(delayedAnim.animation);
                readyPlayAnim.remove(delayedAnim);
            }else {
                delayedAnim.timer -= elapsed;
            }
        }
    }

    function handleFinishedAnimation(name:String):Void {
        if(onFinishedAnimation != null) {
            onFinishedAnimation(name);
        }
    }
}
