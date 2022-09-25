package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.FlxCamera;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;

import feshixl.FeshSprite;
import feshixl.FeshCamera;

class PlayState extends BetterUIStates {
	private var camGame:FeshCamera;
	private var camGen:FeshCamera;

	private var camFollow:FlxObject;

	private var player:FeshSprite;

	override public function create():Void {
		camGame = new FeshCamera();

		FlxG.cameras.setDefaultDrawTarget(camGame, true);
		FlxG.cameras.reset(camGame);

		persistentUpdate = true;
		persistentDraw = true;

		var sky:SkyBackground = new SkyBackground();
		sky.cyan = 20;
		add(sky);

		var terrain:Terrain = new Terrain();

		player = new FeshSprite(0, terrain.maxiumHeight - (terrain.firstGenHeight * 64) - 64);
		player.loadGraphic(AssetPath.image("assets/images/ground1"));
		player.setGraphicSize(64, 64);
		player.updateHitbox();

		add(player);
		add(terrain);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollow.y = player.getMidpoint().y;
		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.04);

		super.create();
	}

	override public function update(elapsed:Float):Void {
		camFollow.y = player.getMidpoint().y;

		super.update(elapsed);
	}

	function generateTerrain():Void {
		//for(x in 0...)
	}

	function start_HelloWorld():Void {
		var helloWorld:FlxText = new FlxText("Hello World", 32);
		helloWorld.screenCenter();
		add(helloWorld);
	}
}