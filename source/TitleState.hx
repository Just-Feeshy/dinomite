package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;

import openfl.ui.Mouse;

class TitleState extends BetterUIStates {
    var river:River;
    var terrain:Terrain;

    var title:FlxTypedSpriteGroup<FlxText>;
    var grpOptions:FlxTypedSpriteGroup<FlxText>;
    var creditsText:FlxText;
    var playerOptions:OptionGroup;

    #if web
    var options:Array<String> = ['PLAY', 'HOW TO PLAY', 'CREDITS'];
    #else
    var options:Array<String> = ['PLAY', 'CREDITS', 'OPTIONS', 'QUIT'];
    #end

    var credits:String = "Luke Barberry - Ex Game Director\n\nDiego Fonseca - Programmer\n\nJohn Jensen - Was There\n\n\nTrevor Lentz - Main Game Music\n\nCleyton Kauffman - Game Over Music\n\nFato Shadow - Title Screen Music\n\nOpenGameArt - Game Assets";
    var howToPlay:String = "";

    var tweened:Bool = false;

    var camOptions:FlxCamera;
    var camCredits:FlxCamera;
    var camBackground:FlxCamera;

    var curSelected:Int = 0;
    var selected:Bool = false;
    var creditMenu:Bool = false;

    public function new() {
        super("", "void");
    }

    override public function create():Void {
        Mouse.hide();

        initSave();
        controls.setKeyboardScheme(Solo);

        PlayState.GAME_FADE = "";

        if (FlxG.sound.music != null) {
			FlxG.sound.music.stop();
		}

		FlxG.sound.playMusic(AssetPath.music("fato_shadow_-_main_menu"));
        FlxG.sound.music.volume = FlxG.save.data.musicVolume * 0.01;
        FlxG.sound.music.fadeIn(10, 0, 0.5);

        camBackground = new FlxCamera();
        FlxG.cameras.setDefaultDrawTarget(camBackground, true);
		FlxG.cameras.reset(camBackground);

        camOptions = new FlxCamera();
        camCredits = new FlxCamera();
        FlxG.cameras.add(camOptions);
        FlxG.cameras.add(camCredits);

        camOptions.bgColor.alpha = 0;
        camCredits.bgColor.alpha = 0;
        camBackground.bgColor.alpha = 0;

        var moon:FlxSprite = new FlxSprite(0, 30).loadGraphic(AssetPath.image("assets/images/moon"));
		moon.scale.x *= 2;
		moon.scale.y *= 2;
		moon.updateHitbox();
		moon.x = FlxG.width - moon.width - 90;
		moon.scrollFactor.set(0.1, 0.1);
		add(moon);

        terrain = new Terrain();
        terrain.y = FlxG.height + terrain.height;
        terrain.speed = 10;
        add(terrain);

        river = new River(FlxG.height - 64);
        add(river);

        var riverBottom:FlxSprite = new FlxSprite(0, river.y + 128).makeGraphic(FlxG.width, Std.int(FlxG.height * 0.75), 0xff005784);
		riverBottom.scrollFactor.set(0, 1);
        add(riverBottom);

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

        playerOptions = new OptionGroup();
        add(playerOptions);

        creditsText = new FlxText(40, 40, credits, 32);
        add(creditsText);

        FlxTween.tween(terrain, {y: 772}, 1, {ease: FlxEase.quadOut});
        FlxTween.tween(title, {y: FlxG.height * 0.4}, 1, {ease: FlxEase.quadOut});

        title.cameras = [camOptions];
        grpOptions.cameras = [camOptions];
        moon.cameras = [camBackground];
        terrain.cameras = [camBackground];
        river.cameras = [camBackground];
        playerOptions.cameras = [camCredits];
        creditsText.cameras = [camCredits];

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
        if(!playerOptions.inUse) curSelected += change;

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

        if(FlxG.save.data.customKeys == null) {
            FlxG.save.data.customKeys = {
                UP: FlxKey.W,
                DOWN: FlxKey.S,
                PAUSE: FlxKey.ENTER,
            };
        }
    }

    public override function update(elapsed:Float):Void {
        camCredits.y = camOptions.y + FlxG.height;
        river.getX = terrain.x;

        if(!selected) {
            if(FlxG.keys.justPressed.UP || FlxG.keys.justPressed.W) {
                changeSelection(-1);
            }

            if(FlxG.keys.justPressed.DOWN || FlxG.keys.justPressed.S) {
                changeSelection(1);
            }

            if(controls.ACCEPT) {
                selected = true;

                switch(curSelected) {
                    case 0:
                        FlxG.switchState(new PlayState());
                    case 1:
                        selected = false;
                        creditsText.visible = true;
                        playerOptions.visible = false;
                        playerOptions.controlSelector = false;
                        playerOptions.inUse = false;
                        FlxTween.tween(camOptions, {y: -FlxG.height}, 1, {ease: FlxEase.quadOut});
                        creditMenu = true;
                    case 2:
                        selected = false;
                        creditsText.visible = false;
                        playerOptions.visible = true;
                        playerOptions.inUse = true;
                        FlxTween.tween(camOptions, {y: -FlxG.height}, 1, {ease: FlxEase.quadOut, onComplete: function(twn:FlxTween) {
                            playerOptions.controlSelector = true;
                        }});
                        creditMenu = true;
                    case 3:
                        #if sys
                        Sys.exit(0);
                        #end
                }
            }

            if(controls.BACK && creditMenu && !playerOptions.selected) {
                creditMenu = false;
                FlxTween.tween(camOptions, {y: 0}, 1, {ease: FlxEase.quadOut});
            }
        }

        super.update(elapsed);
    }
}