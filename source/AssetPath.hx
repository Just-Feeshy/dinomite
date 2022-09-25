package;

import flixel.FlxG;
import flixel.graphics.FlxGraphic;

@:build(flixel.system.FlxAssets.buildFileReferences("assets", true))
class AssetPath {
    public static function image(path:String):FlxGraphic {
        var pathSplit:Array<String> = path.split(".");

        if(pathSplit.length > 0) {
            path = pathSplit[0];
        }

        var graphics:FlxGraphic = FlxG.bitmap.add(path + ".png", false, path);
        graphics.persist = false;
        return graphics;
    }
}