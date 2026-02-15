package;

import feshixl.shaders.FeshShader;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.FlxCamera;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;

import feshixl.FeshCamera;
import feshixl.shaders.FeshShader;

class PlayState extends BetterUIStates {
	private var camGame:FeshCamera;
	private var camGen:FeshCamera;

	private var camFollow:FlxObject;

	private var player:Player;
	private var terrain:Terrain;
	private var river:River;

	private var scoreTxt:FlxText; 
	private var highScore:FlxText;

	private var gravity:Float = 100000;
	private var jumpForce:Float = 0;

	private var addJumpForce:Bool = false;

	private var wallCollided:Bool = false;

	public static var score:Int = 0;

	private var stopGame(default, set):Bool = false;

	@:final private var playerCamOffset:Int = 128;

	private var colorModSprites:Array<FlxSprite>;

	public static var GAME_FADE = "tile";

	public function new() {
		super("", "");
	}

	override public function create():Void {
		if (FlxG.sound.music != null) {
			FlxG.sound.music.stop();
		}

		FlxG.sound.playMusic(AssetPath.music("pixel-river"));

		camGame = new FeshCamera();

		FlxG.cameras.setDefaultDrawTarget(camGame, true);
		FlxG.cameras.reset(camGame);

		persistentUpdate = true;
		persistentDraw = true;

		var sky:SkyBackground = new SkyBackground();
		sky.cyan = 5;
		add(sky);

		terrain = new Terrain();
		terrain.genCactis = true;
		river = new River(360);

		var riverBottom:FlxSprite = new FlxSprite(0, 420).makeGraphic(FlxG.width, Std.int(FlxG.height * 0.75), 0xff005784);
		riverBottom.scrollFactor.set(0, 1);

		player = new Player(0, terrain.maxiumHeight - (terrain.firstGenHeight * 64) - 64);
		player.setGraphicSize(64, 64);
		player.updateHitbox();

		var moon:FlxSprite = new FlxSprite(0, 0).loadGraphic(AssetPath.image("assets/images/moon"));
		moon.scale.x *= 2;
		moon.scale.y *= 2;
		moon.updateHitbox();
		moon.x = FlxG.width - moon.width - 90;
		moon.scrollFactor.set(0.1, 0.1);
		add(moon);

		add(player);
		add(terrain);
		add(riverBottom);
		add(river);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollow.x = playerCamOffset;
		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.04);

		scoreTxt = new FlxText(20, 20, "Score: ", 32);
		scoreTxt.scrollFactor.set(0, 0);
		scoreTxt.borderSize = 20;

		highScore = new FlxText(20, 20 + scoreTxt.height, "High Score: " + FlxG.save.data.highScore, 16);
		highScore.scrollFactor.set(0, 0);

		add(scoreTxt);

		#if !debug
		add(highScore);
		#end

		colorModSprites = [
			player,
			terrain,
			riverBottom,
			river,
			moon,
		];

		super.create();
	}

	override public function update(elapsed:Float):Void {
		if(!stopGame) {
			river.getX = terrain.x;

			camFollow.y = player.getMidpoint().y + playerCamOffset;

			var collision = terrain.topCollision(player, gravity, elapsed);
			gravity = collision.gravity;
			player.gravity = gravity;

			wallCollided = terrain.wallCollision(player, elapsed);

			if(controls.DOWN) {
				gravity += (elapsed * 4500 * 64) * 8;
			}

			if(controls.UP && (jumpForce > -1200 && player.isTouchingGround) && !wallCollided) {
				jumpForce -= 600;
				addJumpForce = true;
			}else if(addJumpForce) {
				player.jumpForce = jumpForce;
				addJumpForce = false;
				jumpForce = 0;
			}

			if(controls.PAUSE) {
				pause();
			}

			if(score > 500 && terrain.cactusGenMin == 6) {
				terrain.cactusGenMin = 1;
			}

			if(terrain.cactusCollision(player)) {
				truelyDed();
			}

			ded();

			score = Std.int(-terrain.x * 0.01);
			scoreTxt.text = "Score: " + score;

			terrain.clean(player);
		}else {
			player.gravity = elapsed * 4500 * 64;
		}

		super.update(elapsed);
	}

	function start_HelloWorld():Void {
		var helloWorld:FlxText = new FlxText("Hello World", 32);
		helloWorld.screenCenter();
		add(helloWorld);
	}

	function pause():Void {
		persistentUpdate = false;
		persistentDraw = true;

		openSubState(new PauseSubstate());
	}

	override function onFocusLost():Void {
		super.onFocusLost();

		if(!stopGame && subState == null) {
			pause();
		}
	}

	function ded():Void {
		for(i in 0...terrain.collisionMembers.length) {
			if(player.y < terrain.collisionMembers[i].y) {
				return;
			}
		}

		truelyDed();
	}

	function truelyDed():Void {
		FlxG.sound.music.stop();

		if(score > FlxG.save.data.highScore) {
			FlxG.save.data.highScore = score;
			FlxG.save.flush();
		}

		player.velocity.y = -70;
		player.acceleration.y = 39.2;

		stopGame = true;
		openSubState(new GameOverSubstate());
	}

	function set_stopGame(value:Bool):Bool {
		if(terrain != null) {
			terrain.stopVelocity = true;
		}

		if(FlxG.sound.music.playing) {
			FlxG.sound.music.stop();
		}

		player.jumpForce = 0;
		return stopGame = value;
	}

	public override function closeSubState():Void {
		persistentUpdate = true;
		persistentDraw = true;

		super.closeSubState();
	}
}
