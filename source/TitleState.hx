package;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;

class TitleState extends BetterUIStates {
    var river:River;
    var terrain:Terrain;

    var title:FlxTypedSpriteGroup<FlxText>;
    var grpOptions:FlxTypedSpriteGroup<FlxText>;

    var options:Array<String> = ['PLAY', 'CREDITS', 'QUIT'];

    var tweened:Bool = false;

    var camOptions:FlxCamera;

    var curSelected:Int = 0;
    var selected:Bool = false;

    public function new() {
        super("", "tile");
    }

    override public function create():Void {
        initSave();

        //FlxG.mouse.visible = true;

        camOptions = new FlxCamera();
        FlxG.cameras.add(camOptions);

        var moon:FlxSprite = new FlxSprite(0, 30).loadGraphic(AssetPath.image("assets/images/moon"));
		moon.scale.x *= 2;
		moon.scale.y *= 2;
		moon.updateHitbox();
		moon.x = FlxG.width - moon.width - 90;
		moon.scrollFactor.set(0.1, 0.1);
		add(moon);

        terrain = new Terrain();
        terrain.y = FlxG.height + terrain.height;
        add(terrain);

        river = new River(FlxG.height - 64);
        add(river);

        title = new FlxTypedSpriteGroup<FlxText>();
        makeTitle();
        add(title);

        grpOptions = new FlxTypedSpriteGroup<FlxText>();

        for(i in 0...options.length) {
            var item:FlxText = new FlxText(40, (80 * i) + 360, options[i], 64);
            item.scrollFactor.set(0, 0);
            item.screenCenter(X);
            grpOptions.add(item);
        }

        add(grpOptions);

        FlxTween.tween(terrain, {y: 772}, 1, {ease: FlxEase.quadOut});
        FlxTween.tween(title, {y: FlxG.height * 0.4}, 1, {ease: FlxEase.quadOut});

        //FlxG.switchState(new PlayState());

        title.cameras = [camOptions];
        grpOptions.cameras = [camOptions];

        changeSelection();

        super.create();
    }

    function makeTitle():Void {
        var titleW = new FlxText(0, 0, "Dinomite", 128);
        titleW.y = -titleW.height - 64;
        titleW.screenCenter(X);

        var titleB = new FlxText(0, 0, "Dinomite", 128);
        titleB.color = FlxColor.BLACK;
        titleB.y = -titleB.height - 48;
        titleB.screenCenter(X);

        title.add(titleB);
        title.add(titleW);
    }

    function changeSelection(change:Int = 0):Void {
        curSelected += change;

		if (curSelected < 0)
			curSelected = options.length - 1;
		if (curSelected >= options.length)
			curSelected = 0;

        for(i in 0...options.length) {
            if(i == curSelected) {
                grpOptions.members[i].color = FlxColor.YELLOW;
            }else {
                grpOptions.members[i].color = FlxColor.WHITE;
            }
        }
    }

    function initSave():Void {
        FlxG.save.bind('dinomite', 'Los Gay Boys');

        if(FlxG.save.data.highScore == null) {
            FlxG.save.data.highScore = 0;
        }
    }

    public override function update(elapsed:Float):Void {
        river.getX = terrain.x;

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
                        FlxG.switchState(new PlayState());
                    case 2:
                        Sys.exit(0);
                }
            }
        }

        super.update(elapsed);
    }
}