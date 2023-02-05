package;

import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import openfl.utils.Assets as OpenFlAssets;
import openfl.media.Sound;

@:build(flixel.system.FlxAssets.buildFileReferences("assets", true))
class AssetPath {
    private static var musicFormat:String = #if web "mp3" #else "ogg" #end;

    public static function image(path:String):FlxGraphic {
        var pathSplit:Array<String> = path.split(".");

        if(pathSplit.length > 0) {
            path = pathSplit[0];
        }

        var graphics:FlxGraphic = FlxG.bitmap.add(path + ".png", false, path);
        graphics.persist = false;
        return graphics;
    }

    public static function music(path:String):Sound {
        var pathSplit:Array<String> = path.split(".");

        if(pathSplit.length > 0) {
            path = pathSplit[0];
        }

        return OpenFlAssets.getSound("assets/music/" + path + "." + musicFormat, true);
    }

    public static function musicString(path):String {
        var pathSplit:Array<String> = path.split(".");

        if(pathSplit.length > 0) {
            path = pathSplit[0];
        }

        return "assets/music/" + path + "." + musicFormat;
    }
}