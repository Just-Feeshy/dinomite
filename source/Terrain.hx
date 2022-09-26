package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.math.FlxVelocity;
import flixel.group.FlxSpriteGroup;

class Terrain extends FlxSpriteGroup {
    @:final public var maxiumHeight:Float = Std.int(FlxG.height * 0.5) + 64;

    public var collisionMembers(default, null):Array<FlxSprite> = [];

    public var firstGenHeight(default, null):UInt = 0;
    public var genHeight(default, null):UInt = 0;

    public var collisionWall(default, set):Bool = false;

    var genDistance:UInt = 0;

    var genLayersIndex:UInt = 0;
    var genLayersMax:UInt = 0;

    var genSide:Bool = false;

    @:final public var startingVelocity:Float = 200;
    @:final public var startingAcceleration:Float = 20;

    public var backwardsVelocity(default, null):FlxPoint;

    public function new() {
        super();

        backwardsVelocity = FlxPoint.get();

        genMap();

        acceleration.x = -startingAcceleration;
		backwardsVelocity.x = startingVelocity;
    }

    public function generateSide(x:Float = 0):Void {
        if(genLayersIndex >= genLayersMax) {
            genHeight = Math.ceil((FlxG.height * 0.5) / 64) + FlxG.random.int(1, 10);
            genLayersMax = FlxG.random.int(3, 7);
            genDistance = FlxG.random.int(2, 8);
            genLayersIndex = 0;
            genSide = false;
            return;
        }

        if(genDistance > 0) {
            genDistance--;
            return;
        }

        var index:UInt = 1;

        var grass:FlxSprite = new FlxSprite(x, maxiumHeight - (genHeight * 64) - 64).loadGraphic(AssetPath.image("assets/images/grass"));
        grass.setGraphicSize(64, 64);
        grass.updateHitbox();
        add(grass);

        var floor:FlxSprite = new FlxSprite(x, maxiumHeight - (genHeight * 64)).loadGraphic(AssetPath.image("assets/images/ground1"));
        floor.setGraphicSize(64, 64);
        floor.updateHitbox();
        addBlock(floor);

        while(index < genHeight) {
            var ground:FlxSprite = new FlxSprite(x, ((index) * 64) + maxiumHeight - (genHeight * 64)).loadGraphic(AssetPath.image("assets/images/ground2"));
		    ground.setGraphicSize(64, 64);
		    ground.updateHitbox();
		    addBlock(ground);

            index++;
        }

        genLayersIndex++;
    }

    public function addBlock(sprite:FlxSprite):Void {
        collisionMembers.push(sprite);
        add(sprite);
    }

    function genMap():Void {
        genLayersMax = FlxG.random.int(3, 7);
        firstGenHeight = Math.ceil((FlxG.height * 0.5) / 64) + FlxG.random.int(1, 10);
        genHeight = firstGenHeight;

        for(x in 0...Math.ceil(FlxG.width / 64)) {
            generateSide(x * 64);
        }
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
        member.sort();
    }

    override public function update(elapsed:Float):Void {
        super.update(elapsed);

        if(!collisionWall) {
            backwardsVelocity.x += elapsed * 10;
        }else {
            backwardsVelocity.x = 0;
        }

        if(width + x < FlxG.width) {
            if(!genSide && width + x < FlxG.width + genDistance) {
                genSide = true;
            }
            
            if(genSide) {
                generateSide(width + (genDistance * 64));
                deleteSide();
            }
        }
    }

    @:noCompletion override function updateMotion(elapsed:Float):Void {
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