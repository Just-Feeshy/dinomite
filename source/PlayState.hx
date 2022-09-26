package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.FlxCamera;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;

import feshixl.FeshCamera;

class PlayState extends BetterUIStates {
	private var camGame:FeshCamera;
	private var camGen:FeshCamera;

	private var camFollow:FlxObject;

	private var player:Player;
	private var terrain:Terrain;

	private var gravity:Float = 100000;
	private var jumpForce:Float = 0;

	private var addJumpForce:Bool = false;
	private var doubleJump:Bool = true;

	override public function create():Void {
		camGame = new FeshCamera();

		FlxG.cameras.setDefaultDrawTarget(camGame, true);
		FlxG.cameras.reset(camGame);

		persistentUpdate = true;
		persistentDraw = true;

		var sky:SkyBackground = new SkyBackground();
		sky.cyan = 20;
		add(sky);

		terrain = new Terrain();

		player = new Player(0, terrain.maxiumHeight - (terrain.firstGenHeight * 64) - 64);
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
		terrain.clearBlocksBeforeX(terrain.collisionMembers, player.x - 64);
		player.gravity = topCollision(player, elapsed);

		if(controls.UP && (jumpForce > -3000 && (player.isTouchingGround || doubleJump))) {
			if(!player.isTouchingGround) {
				doubleJump = false;
			}

			jumpForce -= 1000;
			addJumpForce = true;
		}else if(addJumpForce) {
			player.jumpForce = jumpForce;
			addJumpForce = false;
			jumpForce = 0;
		}

		if(player.isTouchingGround) {
			doubleJump = false;
		}

		super.update(elapsed);
	}

	function topCollision(p:Player, elapsed:Float):Float {
		player.isTouchingGround = false;

		if(gravity <= 0) {
			gravity = 100000;
		}

		for(i in 0...terrain.collisionMembers.length) {
			if(Math.floor(terrain.collisionMembers[i].x / 64) * 64 == Math.floor(p.x / 64) * 64 || Math.ceil(terrain.collisionMembers[i].x / 64) * 64 == Math.ceil(p.x / 64) * 64) {
				if(p.y >= terrain.collisionMembers[i].y - 64 && p.y < terrain.collisionMembers[i].y) {
					p.isTouchingGround = true;

					if(p.gravity != 0) {
						player.jumpForce = 0;
					}

					gravity = 0;
					break;
				}
			}
		}

		if(gravity > 0) {
			gravity += elapsed * 5000 * 64;
		}

		return gravity;
	}

	function start_HelloWorld():Void {
		var helloWorld:FlxText = new FlxText("Hello World", 32);
		helloWorld.screenCenter();
		add(helloWorld);
	}
}