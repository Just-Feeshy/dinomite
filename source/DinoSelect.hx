package;

import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import openfl.display.BitmapData;
import openfl.utils.Assets as OpenFlAssets;
import openfl.utils.AssetType;
import StringTools;

class DinoSelect extends FlxSprite {
	static var processedSheets:Map<String, BitmapData> = [];
	static inline var FRAME_WIDTH:Int = 22;
	static inline var FRAME_HEIGHT:Int = 22;
	static inline var WHITE_BORDER:Int = 0xFFFFFFFF;

	var sourceGraphic:FlxGraphic;
	var borderColor:Int = WHITE_BORDER;
	var selectedIdle:Bool = false;

	public function new(bitmap:FlxGraphic, x:Float = 0, y:Float = 0) {
		super(x, y);
		sourceGraphic = bitmap;

		applyProcessedSheet();
		selectedIdle = false;
		refreshAnimationState();

		scrollFactor.set(0, 0);
		antialiasing = false;
		pixelPerfectRender = true;
	}

	public function setBorderColor(color:Int):Void {
		if (borderColor == color) {
			return;
		}

		borderColor = color;
		applyProcessedSheet();
		refreshAnimationState();
	}

	function applyProcessedSheet():Void {
		// Use a clone so each sprite has independent bitmap lifetime.
		loadGraphic(getProcessedSheet(sourceGraphic, borderColor).clone(), true, FRAME_WIDTH, FRAME_HEIGHT);
		ensureAnimations();
	}

	function ensureAnimations():Void {
		if (animation.getByName("idle") == null) {
			animation.add("idle", [0], 0, true);
		}
		if (animation.getByName("walk") == null) {
			animation.add("walk", [1, 2], 2, true);
		}
	}

	public function setSelectedIdle(value:Bool):Void {
		if (selectedIdle == value) {
			return;
		}

		selectedIdle = value;
		refreshAnimationState();
	}

	function refreshAnimationState():Void {
		if (selectedIdle) {
			if (animation.getByName("idle") != null) {
				animation.play("idle");
			}
		} else {
			if (animation.getByName("walk") != null) {
				animation.play("walk");
			}
		}
	}

	static function getProcessedSheet(bitmap:FlxGraphic, borderColor:Int):BitmapData {
		var key = bitmap != null && bitmap.key != null ? bitmap.key : "dino_default";
		key += "|" + StringTools.hex(borderColor, 8);
		if (processedSheets.exists(key)) {
			var cached = processedSheets.get(key);
			if (cached != null && cached.width > 0 && cached.height > 0) {
				return cached;
			}
			processedSheets.remove(key);
		}

		var source = getSourceBitmap(bitmap);
		var srcFrameW = 16;
		var srcFrameH = 16;
		var dstFrameW = 22;
		var dstFrameH = 22;
		var borderPadX = 3;
		var borderPadY = 3;

		var darkBg = 0xFF181818;
		var border = borderColor;

		var frameCols = Std.int(source.width / srcFrameW);
		var frameRows = Std.int(source.height / srcFrameH);
		var output = new BitmapData(frameCols * dstFrameW, frameRows * dstFrameH, true, 0x00000000);

		for (fy in 0...frameRows) {
			for (fx in 0...frameCols) {
				var srcX = fx * srcFrameW;
				var srcY = fy * srcFrameH;
				var dstX = fx * dstFrameW;
				var dstY = fy * dstFrameH;

				var x1 = dstX + dstFrameW - 1;
				var y1 = dstY + dstFrameH - 1;

				// Outer white border around the frame.
				for (x in dstX...x1 + 1) {
					output.setPixel32(x, dstY, border);
					output.setPixel32(x, y1, border);
				}
				for (y in dstY...y1 + 1) {
					output.setPixel32(dstX, y, border);
					output.setPixel32(x1, y, border);
				}

				// Fill interior with dark gray.
				for (y in dstY + 1...y1) {
					for (x in dstX + 1...x1) {
						output.setPixel32(x, y, darkBg);
					}
				}

				// Copy source pixels into center; keep transparent pixels dark gray.
				for (py in 0...srcFrameH) {
					for (px in 0...srcFrameW) {
						var pixel = source.getPixel32(srcX + px, srcY + py);
						var alpha = (pixel >> 24) & 0xFF;
						if (alpha > 0) {
							output.setPixel32(dstX + borderPadX + px, dstY + borderPadY + py, pixel);
						}
					}
				}
			}
		}

		processedSheets.set(key, output);
		return output;
	}

	static function getSourceBitmap(bitmap:FlxGraphic):BitmapData {
		if (bitmap != null) {
			bitmap.persist = true;
			bitmap.destroyOnNoUse = false;
			if (bitmap.bitmap != null) {
				return bitmap.bitmap;
			}
		}

		var imagePath = bitmap != null && bitmap.key != null ? bitmap.key : "assets/images/dumb-dino1";
		var openflPath = imagePath + ".png";
		if (OpenFlAssets.exists(openflPath, AssetType.IMAGE)) {
			var assetBitmap = OpenFlAssets.getBitmapData(openflPath, false);
			if (assetBitmap != null) {
				return assetBitmap;
			}
		}

		return new BitmapData(48, 16, true, 0xFFFF00FF);
	}
}
