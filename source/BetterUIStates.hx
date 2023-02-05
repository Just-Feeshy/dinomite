package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.addons.ui.FlxUIState;

import transitions.TransitionSamples;
import transitions.TransitionBuilder;

class BetterUIStates extends FlxUIState {
    private static var transitionBuilds:Map<String, Class<TransitionBuilder>> = new Map<String, Class<TransitionBuilder>>();

    var transOutFinished:Bool = false;
    
    var transInType:String;
	var transOutType:String;

	final controls:Controls = new Controls('player1', Solo);

    public function new(?transInType:String, ?transOutType:String) {
        if(transInType != null) {
			this.transInType = transInType;
		}else {
			this.transInType = "";
		}

		if(transOutType != null) {
			this.transOutType = transOutType;
		}else {
			this.transOutType = "";
		}

		transitionBuilds.set("tile", TileTransition);
		transitionBuilds.set("void", VoidTransition);
		transitionBuilds.set("fade", FadeTransition);

		super();
    }

    /**
	* Based off of `FlxTransitionableState` class from HaxeFlixel.
	*/
	function createTransition(transType:String, fade:TransitionFade):TransitionBuilder {
		return Type.createInstance(transitionBuilds.get(transType), [0.5, fade]);
	}

	function finishedTransition() {
		transOutFinished = true;
	}

    @:noCompletion public function transitionIn():Void {
		if(transInType != null && transInType != "none") {
			var _transition = createTransition(transInType, IN);

			if(_transition == null) {
				return;
			}

			openSubState(_transition);
		}
	}

	@:noCompletion public function transitionOut(state:FlxState):Void {
		if(transOutType != null && transOutType != "none") {
			var _transition = createTransition(transOutType, OUT);

			if(_transition == null) {
				transOutFinished = true;
				return;
			}

			_transition.finishCallback = function() {
				finishedTransition();
				FlxG.switchState(state);
			};

			openSubState(_transition);
		}
	}

	override function switchTo(state:FlxState):Bool {
		if(transOutType.length == 0) {
			return true;
		}

		if(!transOutFinished) {
			transitionOut(state);
		}

		return transOutFinished;
	}
}