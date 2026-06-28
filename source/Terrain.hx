package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.math.FlxVelocity;
import flixel.group.FlxSpriteGroup;

class Terrain extends FlxSpriteGroup {
	private static var BLOCK_SIZE:Int = 64;
	private static inline var FIRST_PLATFORM_GAP_DISTANCE:UInt = 1;

    public final maxiumHeight:Float = Std.int(FlxG.height * 0.5) + 64;

    public var collisionMembers(default, null):Array<FlxSprite> = [];
	public var groundMembers(default, null):Array<FlxSprite> = [];
    public var floorMembers(default, null):Array<FlxSprite> = [];
    public var cactis(default, null):Array<FlxSprite> = [];

    public var firstGenHeight(default, null):UInt = 0;
    public var genHeight(default, null):UInt = 0;

    public var collisionWall(default, set):Bool = false;

    public var stopVelocity:Bool = false;
    public var genCactis:Bool = false;

    public var speed:UInt = 15;

    var genDistance:UInt = 0;

    var genLayersIndex:UInt = 0;
    var genLayersMax:UInt = 0;
    var completedPlatforms:UInt = 0;

    var genSide:Bool = false;
    var generatedC:Bool = false;

    public var cactusGenMin:UInt = 6;

    public final startingVelocity:Float = 500;
    public final startingAcceleration:Float = 20;

    public var backwardsVelocity(default, null):FlxPoint;

    var blockDistance:Float = 0;

	private static inline var WALL_SNAP_EPSILON:Float = 7;

    public function new() {
        super();

        backwardsVelocity = FlxPoint.get();

        genMap();

        acceleration.x = -startingAcceleration;
		backwardsVelocity.x = startingVelocity;
    }

    public function generateSide(x:Float = 0):Void {
        if(genLayersIndex >= genLayersMax) {
            completedPlatforms++;

            genHeight = Math.ceil((FlxG.height * 0.5) * 0.015625) + FlxG.random.int(-5, -1);
            genLayersMax = FlxG.random.int(5, 10);
            genDistance = completedPlatforms == 1 ? FIRST_PLATFORM_GAP_DISTANCE : FlxG.random.int(1, 3) * 2;
            genLayersIndex = 0;
            generatedC = false;
            genSide = false;
            return;
        }

        if(genLayersIndex == FlxG.random.int(cactusGenMin, 8) && !generatedC && genCactis) {
            generatedC = true;

            var cactus:FlxSprite = new FlxSprite(x, maxiumHeight - (genHeight * BLOCK_SIZE) - BLOCK_SIZE).loadGraphic(AssetPath.image("assets/images/cactus"));
            cactus.setGraphicSize(BLOCK_SIZE, BLOCK_SIZE);
            cactus.updateHitbox();
            add(cactus);

            cactis.push(cactus);
        }

        var index:UInt = 1;

        var grass:FlxSprite = new FlxSprite(x, maxiumHeight - (genHeight * BLOCK_SIZE) - BLOCK_SIZE).loadGraphic(AssetPath.image("assets/images/grass"));
        grass.setGraphicSize(BLOCK_SIZE, BLOCK_SIZE);
        grass.updateHitbox();
        add(grass);

        var floor:FlxSprite = new FlxSprite(x, maxiumHeight - (genHeight * BLOCK_SIZE)).loadGraphic(AssetPath.image("assets/images/ground1"));
        floor.setGraphicSize(BLOCK_SIZE, BLOCK_SIZE);
        floor.updateHitbox();
        addBlock(floor);

        while(index < genHeight) {
            var ground:FlxSprite = new FlxSprite(x, ((index) * BLOCK_SIZE) + maxiumHeight - (genHeight * BLOCK_SIZE)).loadGraphic(AssetPath.image("assets/images/ground2"));
		    ground.setGraphicSize(BLOCK_SIZE, BLOCK_SIZE);
		    ground.updateHitbox();
		    addBlock(ground);

            floorMembers.push(ground);
            index++;
        }

        genLayersIndex++;
    }

    public function addBlock(sprite:FlxSprite):Void {
        collisionMembers.push(sprite);
        add(sprite);
    }

    public function clearBlocksBeforeX(blocks:Array<FlxSprite>, x:Float, destroy:Bool = false):Void {
        if(blocks.length == 0) {
            return;
        }

        blocks.sort((a, b) -> Std.int(a.x - b.x));

        while(blocks.length > 0 && Std.int(blocks[0].x) <= x) {
            if(destroy) {
                blocks[0].destroy();
                remove(blocks[0], true);
            }else {
                blocks.shift();
            }
        }
    }

    function genMap():Void {
        genLayersMax = FlxG.random.int(5, 8);
        firstGenHeight = Math.ceil((FlxG.height * 0.5) * 0.015625) + FlxG.random.int(1, 10);
        genHeight = firstGenHeight;

        for(x in 0...Math.ceil(FlxG.width * 0.015625)) {
            if(genDistance > 0) {
                genDistance--;
                continue;
            }

            generateSide(x * 64);
        }

        blockDistance = width;
    }

    public function clean(player:Player):Void {
        clearBlocksBeforeX(collisionMembers, player.x - BLOCK_SIZE);
        clearBlocksBeforeX(cactis, player.x - BLOCK_SIZE);
	}

	public function wallCollision(p:Player, elapsed:Float):Bool {
		var pxRight = p.x + p.width;
		var pxLeft = p.x;
		var pyTop = p.y;
		var pyBottom = p.y + p.height;
		var sweepX = Math.abs(backwardsVelocity.x * elapsed);

		for(block in collisionMembers) {
			var bxLeft = block.x;
			var bxRight = block.x + block.width;
			var byTop = block.y;
			var byBottom = block.y + block.height;

			var overlapsY = pyBottom > byTop && pyTop < byBottom;
			// Terrain moves left after this check, so sweep the player's X extent forward
			// by this frame's terrain movement to prevent tunneling at high speed.
			var sweptRight = pxRight + sweepX + WALL_SNAP_EPSILON;
			var sweptLeft = pxLeft - WALL_SNAP_EPSILON;
			var touchesOrOverlapsX = sweptRight >= bxLeft && sweptLeft < bxRight;
			if(overlapsY && touchesOrOverlapsX) {
				stopVelocity = true;
				return true;
			}
		}

		stopVelocity = false;
		return false;
	}

	public function topCollision(p:Player, gravity:Float, elapsed:Float):{gravity:Float, ground:Bool} {
		p.isTouchingGround = false;

		if(gravity <= 0) {
			gravity = 0;
		}

		var pxLeft = p.x;
		var pxRight = p.x + p.width;
		var pyBottom = p.y + p.height;
		var bestGroundTop = Math.POSITIVE_INFINITY;

		for(block in collisionMembers) {
			var bxLeft = block.x;
			var bxRight = block.x + block.width;
			var overlapsX = pxRight > bxLeft && pxLeft < bxRight;
			if(!overlapsX) {
				continue;
			}

			if(block.y < bestGroundTop) {
				bestGroundTop = block.y;
			}
		}

		if(bestGroundTop != Math.POSITIVE_INFINITY) {
			var standY = bestGroundTop - p.height;
			var fallingOrOnGround = gravity >= 0;
			var closeToSurface = pyBottom >= bestGroundTop - WALL_SNAP_EPSILON;
			if(fallingOrOnGround && closeToSurface) {
				p.y = standY;
				p.isTouchingGround = true;
				p.jumpForce = 0;
				gravity = 0;
			}
		}

		if(!p.isTouchingGround) {
			gravity += elapsed * 450000;
		}

		return {gravity: gravity, ground: p.isTouchingGround};
	}

	public function cactusCollision(p:Player, shrinkCactusHitbox:Bool = false):Bool {
		var pxLeft = p.x;
		var pxRight = p.x + p.width;
		var pyTop = p.y;
		var pyBottom = p.y + p.height;
		var cactusScale = shrinkCactusHitbox ? 0.75 : 1;

		for(cactus in cactis) {
			var insetX = cactus.width * (1 - cactusScale) * 0.5;
			var insetY = cactus.height * (1 - cactusScale) * 0.5;
			var cxLeft = cactus.x + 2 + insetX;
			var cxRight = cactus.x + cactus.width - 2 - insetX;
			var cyTop = cactus.y + insetY;
			var cyBottom = cactus.y + cactus.height - 1 - insetY;
			if(pxRight > cxLeft && pxLeft < cxRight && pyBottom > cyTop && pyTop < cyBottom) {
				return true;
			}
		}

		return false;
	}


    function set_collisionWall(value:Bool):Bool {
        if(!value) {
            acceleration.x = -startingAcceleration;
            backwardsVelocity.x = startingVelocity;
        }else {
            acceleration.x = 0;
        }

        return collisionWall = value;
    }

    function deleteSide():Void {
        if(members.length == 0) {
            return;
        }

        if(collisionMembers.length == 0) {
            return;
        }

        clearBlocksBeforeX(members, -(FlxG.width * 0.5) - 64, true);
    }

    override public function update(elapsed:Float):Void {
        super.update(elapsed);

        if(x <= 19000 * 100) {
            if(!collisionWall) {
                backwardsVelocity.x += elapsed * speed;
            }else {
                backwardsVelocity.x = 0;
            }
        }

        if(blockDistance + x < FlxG.width) {
            if(!genSide && width + x < FlxG.width + (genDistance * 64)) {
                genSide = true;
                generateSide(blockDistance + (genDistance * 64));
                blockDistance += 64 + (genDistance * 64);
            }

            if(genSide) {
                deleteSide();
                generateSide(blockDistance);
                blockDistance += 64;
            }
        }
    }

    @:noCompletion override function updateMotion(elapsed:Float):Void {
        if(!stopVelocity) {
            super.updateMotion(elapsed);

            var velocityDelta:Float = 0.5 * (FlxVelocity.computeVelocity(backwardsVelocity.x, acceleration.x, drag.x, maxVelocity.x, elapsed) - backwardsVelocity.x);
            backwardsVelocity.x += velocityDelta;
            var delta = backwardsVelocity.x * elapsed;
            backwardsVelocity.x += velocityDelta;
            x -= delta;

            velocityDelta = 0.5 * (FlxVelocity.computeVelocity(backwardsVelocity.y, acceleration.y, drag.y, maxVelocity.y, elapsed) - backwardsVelocity.y);
            backwardsVelocity.y += velocityDelta;
            delta = backwardsVelocity.y * elapsed;
            backwardsVelocity.y += velocityDelta;
            y -= delta;
        }
    }
}
