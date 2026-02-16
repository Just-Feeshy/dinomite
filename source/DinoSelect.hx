package;

import flixel.FlxSprite;
import openfl.display.BitmapData;
import openfl.utils.Assets as OpenFlAssets;
import openfl.utils.AssetType;

class DinoSelect extends FlxSprite {
	static var processedSheets:Map<String, BitmapData> = [];

	public function new(imagePath:String, x:Float = 0, y:Float = 0) {
		super(x, y);

		// Use a clone so each sprite has independent bitmap lifetime.
		loadGraphic(getProcessedSheet(imagePath).clone(), true, 22, 22);
		animation.add("idle", [0], 0, true);
		animation.add("walk", [1, 2], 2, true);
		animation.play("walk");

		scrollFactor.set(0, 0);
		antialiasing = false;
		pixelPerfectRender = true;
	}

	static function getProcessedSheet(imagePath:String):BitmapData {
		if (processedSheets.exists(imagePath)) {
			var cached = processedSheets.get(imagePath);
			if (cached != null && cached.width > 0 && cached.height > 0) {
				return cached;
			}
			processedSheets.remove(imagePath);
		}

		var source = getSourceBitmap(imagePath);
		var srcFrameW = 16;
		var srcFrameH = 16;
		var dstFrameW = 22;
		var dstFrameH = 22;
		var borderPadX = 3;
		var borderPadY = 3;

		var darkBg = 0xFF181818;
		var border = 0xFFFFFFFF;

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

		processedSheets.set(imagePath, output);
		return output;
	}

	static function getSourceBitmap(imagePath:String):BitmapData {
		var openflPath = imagePath + ".png";
		if (OpenFlAssets.exists(openflPath, AssetType.IMAGE)) {
			var assetBitmap = OpenFlAssets.getBitmapData(openflPath, false);
			if (assetBitmap != null) {
				return assetBitmap;
			}
		}

		var graphic = AssetPath.image(imagePath);
		if (graphic != null) {
			graphic.persist = true;
			graphic.destroyOnNoUse = false;
			if (graphic.bitmap != null) {
				return graphic.bitmap;
			}
		}

		return new BitmapData(48, 16, true, 0xFFFF00FF);
	}
}
