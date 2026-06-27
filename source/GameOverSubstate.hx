package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.addons.ui.FlxUISubState;

class GameOverSubstate extends FlxUISubState {
    var background:FlxSprite;
    var gameOverText:FlxText;

    final controls:Controls = new Controls('player1', Solo);

    public function new() {
        super();

        FlxG.sound.playMusic(AssetPath.music("Retro_No_hope"));

        background = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        background.alpha = 0.6;
        background.scrollFactor.set(0, 0);
        add(background);

        var shadowTheHedghog:FlxText = new FlxText(0, 0, "You Died", 64);
        shadowTheHedghog.color = FlxColor.BLACK;
        shadowTheHedghog.scrollFactor.set(0, 0);
        shadowTheHedghog.screenCenter();
        shadowTheHedghog.y += 8;
        add(shadowTheHedghog);

        gameOverText = new FlxText(0, 0, "You Died", 64);
        gameOverText.scrollFactor.set(0, 0);
        gameOverText.screenCenter();
        add(gameOverText);

        var scoreText:FlxText = new FlxText(0, 0, "Score: " + PlayState.score + "\nHigh Score: " + FlxG.save.data.highScore, 16);
        scoreText.scrollFactor.set(0, 0);
        scoreText.screenCenter();
        scoreText.y += (shadowTheHedghog.height) + 8;
        add(scoreText);
    }

    public override function update(elapsed:Float):Void {
        if(controls.ACCEPT) {
            PlayState.score = 0;
            FlxG.resetState();
            close();
        }

        super.update(elapsed);
    }
}
