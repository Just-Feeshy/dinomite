package;

import flixel.FlxG;
import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.addons.ui.FlxUISubState;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import openfl.display.BitmapData;

class DinoSelection extends FlxUISubState {
	static inline var TOP_TITLE_PLACEMENT:Int = 116;
	static inline var OVERLAY_PIXEL_SIZE:Int = 8;
	static inline var CENTER_SHADOW_FLOOR:Float = 0.12;

	public var transition(null, set):Float = 0;

	var shadowOverlay:FlxSprite;
	var shadowGradient:BitmapData;
	var selectionCamera:FlxCamera;
	var selectedGroup:FlxSpriteGroup;
	var selectedItems:Array<FlxSprite> = [];
	var selectedItemCenters:Array<{x:Float, y:Float}> = [];
	var curSelectedItem:Int = 0;
	var selectedBaseY:Float = 0;
	var selectedSpacing:Float = 340;
	var titleGroup:FlxSpriteGroup;
	var selectedHint:FlxText;
	var showingSelectedScreen:Bool = false;
	var isClosing:Bool = false;

	final controls:Controls = new Controls('player1', Solo);
	final titleState:TitleState;

	public function new(titleState:TitleState) {
		super();

		this.titleState = titleState;

		var overlayWidth = Std.int(Math.ceil(FlxG.width / OVERLAY_PIXEL_SIZE));
		var overlayHeight = Std.int(Math.ceil(FlxG.height / OVERLAY_PIXEL_SIZE));
		shadowGradient = createShadowOverlayBitmap(overlayWidth, overlayHeight, 0xC0000000);

		shadowOverlay = new FlxSprite();
		shadowOverlay.scrollFactor.set(0, 0);
		shadowOverlay.antialiasing = false;
		shadowOverlay.pixelPerfectRender = true;
		shadowOverlay.pixels = shadowGradient;
		shadowOverlay.setGraphicSize(FlxG.width, FlxG.height);
		shadowOverlay.updateHitbox();
		shadowOverlay.alpha = 0;
	}

	override public function create():Void {
		selectionCamera = new FlxCamera();
		selectionCamera.bgColor.alpha = 0;
		FlxG.cameras.add(selectionCamera, false);

		selectedHint = new FlxText(0, FlxG.height - 48, "ENTER: Selected Screen  |  ESC: Close", 16);
		selectedHint.scrollFactor.set(0, 0);
		selectedHint.screenCenter(X);

		selectedGroup = new FlxSpriteGroup();
		selectedGroup.visible = false;
		selectedGroup.cameras = [selectionCamera];

		selectedBaseY = FlxG.height * 0.55;

		titleGroup = new FlxSpriteGroup();
		titleGroup.visible = false;
		titleGroup.cameras = [selectionCamera];
		makeSelectDinoTitle();

		var centerX = FlxG.width * 0.5;
		var startX = centerX - selectedSpacing;
		var dinoPaths = [
			"assets/images/dumb-dino1",
			"assets/images/dumb-dino2",
			"assets/images/dumb-dino3"
		];

		for (i in 0...dinoPaths.length) {
			var item = new DinoSelect(dinoPaths[i]);
			item.origin.set(item.frameWidth * 0.5, item.frameHeight * 0.5);

			var itemCenterX = startX + (selectedSpacing * i);
			var itemCenterY = selectedBaseY;
			selectedItemCenters.push({x: itemCenterX, y: itemCenterY});
			item.x = itemCenterX - (item.width * 0.5);
			item.y = itemCenterY - (item.height * 0.5);

			selectedItems.push(item);
			selectedGroup.add(item);
		}

		add(shadowOverlay);
		add(selectedHint);
		add(selectedGroup);
		add(titleGroup);

		changeSelectedItem(0, true);

		super.create();

        FlxTween.tween(this, {transition: 1}, 1, {ease: FlxEase.linear});
	}

	function makeSelectDinoTitle():Void {
		var text = "Select Dino";
		var size = 96;
		var amplitude = 8;
		var spacing = -3;

		var letterWidths:Array<Float> = [];
		var totalWidth:Float = 0;
		for (i in 0...text.length) {
			var probe = new FlxText(0, 0, text.charAt(i), size);
			letterWidths.push(probe.width);
			totalWidth += probe.width;
		}
		totalWidth += spacing * (text.length - 1);

		var startX = (FlxG.width - totalWidth) * 0.5;
		// var frontBaseY = selectedBaseY - 352;
		var frontBaseY = -TOP_TITLE_PLACEMENT;
		var shadowBaseY = frontBaseY + 8;

		var xCursor = startX;
		for (i in 0...text.length) {
			var ch = text.charAt(i);
			var phase = Math.PI * 0.5 * i;
			var waveY = Math.abs(Math.sin(phase)) * amplitude;

			var letterShadow = new FlxText(xCursor, shadowBaseY + waveY, ch, size);
			letterShadow.color = FlxColor.fromRGB(64, 64, 64);
			letterShadow.scrollFactor.set(0, 0);
			letterShadow.antialiasing = false;
			letterShadow.pixelPerfectRender = true;

			var letterFront = new FlxText(xCursor, frontBaseY + waveY, ch, size);
			letterFront.scrollFactor.set(0, 0);
			letterFront.antialiasing = false;
			letterFront.pixelPerfectRender = true;

			titleGroup.add(letterShadow);
			titleGroup.add(letterFront);

			xCursor += letterWidths[i] + spacing;
		}
	}

	function createShadowOverlayBitmap(width:Int, height:Int, edgeShadowColor:Int):BitmapData {
		var bitmap = new BitmapData(width, height, true, 0x00000000);
		var cx = width * 0.5;
		var cy = height * 0.5;
		var radius = Math.sqrt((cx * cx) + (cy * cy));

		var edgeA = (edgeShadowColor >> 24) & 0xFF;
		var edgeR = (edgeShadowColor >> 16) & 0xFF;
		var edgeG = (edgeShadowColor >> 8) & 0xFF;
		var edgeB = edgeShadowColor & 0xFF;

		for (y in 0...height) {
			for (x in 0...width) {
				var dx = x - cx;
				var dy = y - cy;
				var distance = Math.sqrt((dx * dx) + (dy * dy));
				var t = Math.min(distance / radius, 1);

				// Keep the center clear and ramp shadow stronger toward edges.
				var eased = t * t;
				var shadowMix = CENTER_SHADOW_FLOOR + ((1 - CENTER_SHADOW_FLOOR) * eased);
				var a = Std.int(edgeA * shadowMix);
				bitmap.setPixel32(x, y, (a << 24) | (edgeR << 16) | (edgeG << 8) | edgeB);
			}
		}

		return bitmap;
	}

	override public function update(elapsed:Float):Void {
		if (controls.BACK) {
			startCloseTransition();
			super.update(elapsed);
			return;
		}

		if (isClosing) {
			super.update(elapsed);
			return;
		}

		if (showingSelectedScreen) {
			if (controls.LEFT_UI) {
				changeSelectedItem(-1);
			} else if (controls.RIGHT_UI) {
				changeSelectedItem(1);
			}

			if (controls.ACCEPT) {
				hideSelectedScreen();
			}
		} else {
			if (controls.ACCEPT) {
				showSelectedScreen();
			}
		}

		super.update(elapsed);
	}

	function showSelectedScreen():Void {
		showingSelectedScreen = true;
		selectedGroup.visible = true;
		titleGroup.visible = true;
		selectedHint.visible = false;
	}

	function hideSelectedScreen():Void {
		showingSelectedScreen = false;
		selectedGroup.visible = false;
		titleGroup.visible = false;
		selectedHint.visible = true;
	}

	function startCloseTransition():Void {
		if (isClosing) {
			return;
		}

		isClosing = true;
		FlxTween.cancelTweensOf(this);
		FlxTween.tween(this, {transition: 0}, 0.35, {
			ease: FlxEase.quadOut,
			onComplete: function(_:FlxTween) {
				close();
			}
		});
	}

	function changeSelectedItem(change:Int, instant:Bool = false):Void {
		curSelectedItem += change;
		if (curSelectedItem < 0) {
			curSelectedItem = selectedItems.length - 1;
		}
		if (curSelectedItem >= selectedItems.length) {
			curSelectedItem = 0;
		}

		for (i in 0...selectedItems.length) {
			var isCurrent = i == curSelectedItem;
			var targetScale = isCurrent ? 8.1 : 6.0;
			var targetAlpha = isCurrent ? 1.0 : 0.55;
			selectedItems[i].color = isCurrent ? FlxColor.WHITE : FlxColor.fromRGB(170, 170, 170);
			tweenItemScale(i, targetScale, instant);
			tweenItemAlpha(i, targetAlpha, instant);
		}

		layoutSelectedItems(instant);
	}

	function layoutSelectedItems(instant:Bool):Void {
		var centerX = FlxG.width * 0.5;

		for (i in 0...selectedItems.length) {
			var relative = i - curSelectedItem;
			var targetX = centerX + (relative * selectedSpacing);
			var targetY = selectedBaseY;
			tweenItemCenter(i, targetX, targetY, instant);
		}
	}

	function tweenItemCenter(index:Int, targetCenterX:Float, targetCenterY:Float, instant:Bool):Void {
		var center = selectedItemCenters[index];
		FlxTween.cancelTweensOf(center);

		if (instant) {
			center.x = targetCenterX;
			center.y = targetCenterY;
			syncItemToCenter(index);
			return;
		}

		FlxTween.tween(center, {x: targetCenterX, y: targetCenterY}, 0.2, {
			ease: FlxEase.quadOut,
			onUpdate: function(_:FlxTween) {
				syncItemToCenter(index);
			},
			onComplete: function(_:FlxTween) {
				syncItemToCenter(index);
			}
		});
	}

	function tweenItemScale(index:Int, targetScale:Float, instant:Bool):Void {
		var item = selectedItems[index];
		FlxTween.cancelTweensOf(item.scale);

		if (instant) {
			item.scale.set(targetScale, targetScale);
			syncItemToCenter(index);
			return;
		}

		FlxTween.tween(item.scale, {x: targetScale, y: targetScale}, 0.16, {
			ease: FlxEase.quadOut,
			onUpdate: function(_:FlxTween) {
				syncItemToCenter(index);
			},
			onComplete: function(_:FlxTween) {
				syncItemToCenter(index);
			}
		});
	}

	function tweenItemAlpha(index:Int, targetAlpha:Float, instant:Bool):Void {
		var item = selectedItems[index];
		FlxTween.cancelTweensOf(item);

		if (instant) {
			item.alpha = targetAlpha;
			return;
		}

		FlxTween.tween(item, {alpha: targetAlpha}, 0.18, {ease: FlxEase.quadOut});
	}

	function syncItemToCenter(index:Int):Void {
		var item = selectedItems[index];
		var center = selectedItemCenters[index];
		item.updateHitbox();
		item.x = center.x - (item.width * 0.5);
		item.y = center.y - (item.height * 0.5);
	}

	override public function destroy():Void {
		FlxTween.cancelTweensOf(this);

		super.destroy();

		shadowGradient = FlxDestroyUtil.dispose(shadowGradient);
		if (selectionCamera != null) {
			FlxG.cameras.remove(selectionCamera, true);
			selectionCamera = null;
		}

		shadowOverlay = FlxDestroyUtil.destroy(shadowOverlay);
		selectedGroup = FlxDestroyUtil.destroy(selectedGroup);
		titleGroup = FlxDestroyUtil.destroy(titleGroup);
		selectedHint = FlxDestroyUtil.destroy(selectedHint);
	}

	@:noCompletion private function set_transition(value:Float):Float {
		var clamped = FlxMath.bound(value, 0, 1);
		var easedBounce = FlxEase.bounceOut(clamped);
		var easedExpo = FlxEase.expoOut(clamped);
		var easedBack = FlxEase.backOut(clamped);

		if (titleGroup != null) {
			titleGroup.y = FlxMath.lerp(-TOP_TITLE_PLACEMENT, selectedBaseY - 260, easedBounce);
		}

		if (shadowOverlay != null) {
			shadowOverlay.alpha = easedExpo;
		}

		if (selectionCamera != null) {
			selectionCamera.zoom = FlxMath.lerp(0, 1, easedBack);
		}

		titleState.camOptions.y = FlxMath.lerp(0, -FlxG.height, FlxEase.quadOut(clamped));
		return transition = clamped;
	}
}
