package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.math.FlxVelocity;
import flixel.group.FlxSpriteGroup;

class Terrain extends FlxSpriteGroup {
	private static var BLOCK_SIZE:Int = 64;

    @:final public var maxiumHeight:Float = Std.int(FlxG.height * 0.5) + 64;

    public var collisionMembers(default, null):Array<FlxSprite> = [];
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

    var genSide:Bool = false;
    var generatedC:Bool = false;

    public var cactusGenMin:UInt = 6;

    @:final public var startingVelocity:Float = 500;
    @:final public var startingAcceleration:Float = 20;

    public var backwardsVelocity(default, null):FlxPoint;

    var blockDistance:Float = 0;

    public function new() {
        super();

        backwardsVelocity = FlxPoint.get();

        genMap();

        acceleration.x = -startingAcceleration;
		backwardsVelocity.x = startingVelocity;
    }

    public function generateSide(x:Float = 0):Void {
        if(genLayersIndex >= genLayersMax) {
            genHeight = Math.ceil((FlxG.height * 0.5) * 0.015625) + FlxG.random.int(1, 6);
            genLayersMax = FlxG.random.int(5, 10);
            genDistance = FlxG.random.int(1, 3) * 2;
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
        blocks.sort((a, b) -> Std.int(a.x - b.x));

        while(Std.int(blocks[0].x) <= x) {
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
        for(block in collisionMembers) {
            if(block.x < player.x - BLOCK_SIZE) {
                collisionMembers.remove(block);
            }
        }

        for(cactus in cactis) {
            if(cactus.x < player.x - BLOCK_SIZE) {
                cactis.remove(cactus);
            }
        }
    }

	public function wallCollision(p:Player):Bool {
		var px = p.x;
		var py = p.y;

		for (block in collisionMembers) {
			var bx = block.x;
			if (px > bx - 65 && px < bx + 65) {
				var by = block.y;
				if (py > by - 64 && py < by + 64) {
					stopVelocity = true;
					p.x = bx - 64;
					return true;
				}
			}
		}

		p.x = 0;
		stopVelocity = false;
		return false;
	}

	public function topCollision(p:Player, gravity:Float, elapsed:Float):{gravity:Float, ground:Bool} {
		p.isTouchingGround = false;

		if (gravity <= 0) {
			gravity = 90000;
		}

		var px = p.x;
		var py = p.y;
		var pxCol = Std.int(px) >> 6 << 6; // Divide by 64, multiply by 64
		var prevCol = Std.int(px - 64) >> 6 << 6;
		var minimumHeight:Float = 0;
		var isOnBlock = false;
		var prevIsOnBlock = false;

		for (block in collisionMembers) {
			var bx = block.x;
			var bxFloor = Std.int(bx) >> 6 << 6;
			var bxCeil = (Std.int(bx) + 63) >> 6 << 6;

			if (bxFloor == pxCol || bxCeil == pxCol) {
				isOnBlock = true;
				if (minimumHeight > block.y) {
					minimumHeight = block.y;
				}
			}

			if (bxFloor == prevCol || bxCeil == prevCol) {
				prevIsOnBlock = true;
			}
		}

		if (isOnBlock) {
			var minY64 = minimumHeight - 64;
			if (prevIsOnBlock && py > minY64) {
				p.y = minY64;
			}

			if (py >= minY64) {
				p.isTouchingGround = true;
				if (p.gravity != 0) {
					p.jumpForce = 0;
				}
				gravity = 0;
			}
		}

		if (gravity > 0) {
			gravity += elapsed * 288000; // Pre-computed 4500 * 64
		}

		return {gravity: gravity, ground: p.isTouchingGround};
	}

	public function cactusCollision(p:Player):Bool {
		var px = p.x;
		var py = p.y;

		for (cactus in cactis) {
			var cx = cactus.x;
			if (px > cx - 60 && px < cx + 60) {
				var cy = cactus.y;
				if (py > cy - 60 && py < cy + 60) {
					return true;
				}
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
