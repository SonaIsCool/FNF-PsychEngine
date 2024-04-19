package/* flixel.system*/;//die

import flixel.text.FlxText;
import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.system.FlxAssets;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.Lib;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flixel.FlxG;
import flixel.FlxState;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

//basically FlxSplash (haxeflixel boot up screen) but kinda customizable bc why not :trol
class FlxSplashCustom extends FlxState
{
	//public static var nextState:Class<FlxState>;

	/**
	 * @since 4.8.0
	 */
	public static var muted:Bool = #if html5 true #else false #end;

	var _sprite:Sprite;
	var _gfx:Graphics;
	//var _text:TextField;
	var _text:FlxText;

	var _times:Array<Float>;
	var _colors:Array<Int>;
	var _functions:Array<Void->Void>;
	var _curPart:Int = 0;
	var _cachedBgColor:FlxColor;
	var _cachedTimestep:Bool;
	var _cachedAutoPause:Bool;

    var rand:Int;
	var camfuni:FlxCamera;

	///////  tip: DONT USE ClientPrefs.loadPrefs() when starting from FlxSplashCustom
	///////  use FlxG.save.data instead
	// nvm doesnt work either

	static var aaa:Int = 0;
	override public function create():Void
	{
		_cachedBgColor = FlxG.cameras.bgColor;
		FlxG.cameras.bgColor = FlxColor.BLACK;

		// This is required for sound and animation to synch up properly
		_cachedTimestep = FlxG.fixedTimestep;
		FlxG.fixedTimestep = false;

		_cachedAutoPause = FlxG.autoPause;
		FlxG.autoPause = false;

		#if FLX_KEYBOARD
		FlxG.keys.enabled = false;
		#end

        rand = FlxG.random.int(0, 3);
        CoolUtil.precacheSound('fard', 'shared');
		CoolUtil.precacheSound('flixel but chrima', 'shared');

		aaa++;
		/*if (aaa == 1)
		{
			ClientPrefs.loadPrefs();
			options.GraphicsSettingsSubState.onChangeRes();
			Highscore.load();
			FlxG.resetGame();
			return;
		}*/
		_times = [0.041, 0.184, 0.334, 0.495, 0.636];

		_colors = [0x00b922, 0xffc132, 0xf5274e, 0x3641ff, 0x04cdfb];
		//this order: center, top left, top right, bottom left, bottom right
		if (FlxG.save.data.instop) _colors = [0x0098a6, 0x38eeff, 0x00afbf, 0x065961, 0x00909e];

		_functions = [drawGreen, drawYellow, drawRed, drawBlue, drawLightBlue];

		for (time in _times)
		{
			new FlxTimer().start(time + 0.75, timerCallback);
		}

		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		_sprite = new Sprite();
		FlxG.stage.addChild(_sprite);
		_gfx = _sprite.graphics;

		/*_text = new TextField();
		_text.selectable = false;
		_text.embedFonts = true;
		var dtf = new TextFormat(FlxAssets.FONT_DEFAULT, 16, 0xffffff);
		dtf.align = TextFormatAlign.CENTER;
		_text.defaultTextFormat = dtf;
		_text.text = "";*/

		_text = new FlxText(0,0);
		//_text.selectable = false;
		//_text.embedFonts = true;
		//var dtf = new TextFormat(FlxAssets.FONT_DEFAULT, 16, 0xffffff);
		//dtf.align = TextFormatAlign.CENTER;
		_text.setFormat(FlxAssets.FONT_DEFAULT, 16, 0xFF000000, CENTER);
		_text.text = "HaxeFlixel";
		if (FlxG.save.data.jumpscare != 'Gamer Engine')
		{
			_text.screenCenter(X);
		}

		//FlxG.stage.addChild(_text);
		add(_text);

		camfuni = new FlxCamera(0, 0);
		camfuni.bgColor.alpha = 0;
		FlxG.cameras.add(camfuni);

		persistentUpdate = true;
		persistentDraw = true;

		super.create();

		if (FlxG.save.data.jumpscare == 'Disabled')
		{
			onComplete();
		}
		//onResize(stageWidth, stageHeight);
	}

	override public function destroy():Void
	{
		_sprite = null;
		_gfx = null;
		_text = null;
		_times = null;
		_colors = null;
		_functions = null;
		super.destroy();
	}

	override public function update(elapsed:Float):Void
	{
		if (FlxG.save.data.jumpscare != 'Gamer Engine')
		{
			_sprite.x = (FlxG.width / 2);
			_sprite.y = (FlxG.height / 2) - 20 * FlxG.game.scaleY;
	
			//_text.width = FlxG.width / FlxG.game.scaleX;
			_text.x = 0;
			_text.y = _sprite.y + 80 * FlxG.game.scaleY;
	
			_text.screenCenter(X);
		}
		else
		{
			_sprite.x = (FlxG.width / 3);
			_sprite.y = (FlxG.height / 2);

			//_text.width = FlxG.width / FlxG.game.scaleX;
			_text.x = ((FlxG.width / 2) + 10) - 40;
			_text.y = 0;
			_text.bold = true;
			if(_curPart != 0) 
			{
				_text.setFormat(Paths.font('vcr.ttf'), 48, _colors[_curPart - 1], CENTER);
				_text.bold = true;
			}
			else
			{
				_text.setFormat(Paths.font('vcr.ttf'), 48, FlxColor.BLACK, CENTER);
				_text.bold = true;
			}
			_text.screenCenter(Y);

		}
		super.update(elapsed);
	}

	/*override public function onResize(Width:Int, Height:Int):Void
	{
		super.onResize(Width, Height);

		_sprite.x = (Width / 2);
		_sprite.y = (Height / 2) - 20 * FlxG.game.scaleY;

		_text.width = Width / FlxG.game.scaleX;
		_text.x = 0;
		_text.y = _sprite.y + 80 * FlxG.game.scaleY;

		_sprite.scaleX = _text.scale.x = FlxG.game.scaleX;
		_sprite.scaleY = _text.scale.y = FlxG.game.scaleY;

		_text.screenCenter(X);
		if (FlxG.save.data.jumpscare == 'Gamer Engine')
		{
			_sprite.x = (Width + 75);
			_sprite.y = (Height / 2);

			_text.width = Width / FlxG.game.scaleX;
			_text.x = _sprite.x + _sprite.width + 20;
			_text.y = 0;
			_text.screenCenter(Y);
	
			_sprite.scaleX = _text.scale.x = FlxG.game.scaleX;
			_sprite.scaleY = _text.scale.y = FlxG.game.scaleY;
		}
		
	}*/

	function timerCallback(Timer:FlxTimer):Void
	{
		_functions[_curPart]();
		_text.color = _colors[_curPart];
		_text.text = "HaxeFlixel";
		_curPart++;
		
		if (FlxG.save.data.jumpscare != 'Gamer Engine')
		{
			_text.screenCenter(X);
		}

        #if FLX_SOUND_SYSTEM
		if (!muted && _curPart == 1)
		{
			var leDate = Date.now();
			if (leDate.getMonth() == 11) {
				FlxG.sound.play(Paths.sound('flixel but chrima', 'shared'), 1);
			} else FlxG.sound.load(FlxAssets.getSound("flixel/sounds/flixel")).play(); //just so it syncs
		}
		#end

		if (!FlxG.save.data.instop) {
        	switch (rand)
        	{
            	case 1:
            	    if (_curPart == 5)
            	    {
            	        FlxG.sound.play(Paths.sound('fard', 'shared'), 5);
            	        new FlxTimer().start(0.6, function(br:FlxTimer){onComplete();});
            	    }
            	case 2:
            	    if (_curPart != 5)
            	    {
            	        _sprite.rotation = FlxG.random.int(0, 360);
            	        _text.angle = FlxG.random.int(0, 360);
            	    }
            	    else
            	    {
            	        _sprite.rotation = 0;
            	        _text.angle = 0;
            	        FlxTween.tween(_sprite, {alpha: 0}, 3.0, {ease: FlxEase.quadOut, onComplete: onComplete});
		    	        FlxTween.tween(_text, {alpha: 0}, 3.0, {ease: FlxEase.quadOut});
            	    }
				case 3:
					if (_curPart == 5)
					{
						new FlxTimer().start(1.1, function(br:FlxTimer){
							FlxG.sound.play(Paths.sound('deltaruneExplosion', 'shared'), 5);

							var explosion:FlxSprite = new FlxSprite(0,0);
							explosion.frames = Paths.getSparrowAtlas('explosion');
							explosion.animation.addByPrefix('the', 'explosion0', 24, false);
							explosion.animation.play('the');
							explosion.antialiasing = false;
							explosion.setGraphicSize(Std.int(explosion.width * 6));
							explosion.updateHitbox();
							explosion.cameras = [camfuni];
							add(explosion);
							explosion.screenCenter();

							new FlxTimer().start(0.4, function(br:FlxTimer){onComplete();});
						});
					}
            	default: 
            	    if (_curPart == 5)
            	    {
            	        // Make the logo a tad bit longer, so our users fully appreciate our hard work :D
            	        FlxTween.tween(_sprite, {alpha: 0}, 3.0, {ease: FlxEase.quadOut, onComplete: onComplete});
		    	        FlxTween.tween(_text, {alpha: 0}, 3.0, {ease: FlxEase.quadOut});
            	    }
        	}
		}
		else
		{
			new FlxTimer().start(1.2, function(no:FlxTimer){
				_text.text = "Let's go back to where we left.";
				FlxTween.tween(_sprite, {alpha: 0}, 2.0, {ease: FlxEase.quadOut, onComplete: onComplete});
			});
		}
    }

	function drawGreen():Void
	{
		_gfx.beginFill(_colors[0]);
		_gfx.moveTo(0, -37);
		_gfx.lineTo(1, -37);
		_gfx.lineTo(37, 0);
		_gfx.lineTo(37, 1);
		_gfx.lineTo(1, 37);
		_gfx.lineTo(0, 37);
		_gfx.lineTo(-37, 1);
		_gfx.lineTo(-37, 0);
		_gfx.lineTo(0, -37);
		_gfx.endFill();
	}

	function drawYellow():Void
	{
		_gfx.beginFill(_colors[1]);
		_gfx.moveTo(-50, -50);
		_gfx.lineTo(-25, -50);
		_gfx.lineTo(0, -37);
		_gfx.lineTo(-37, 0);
		_gfx.lineTo(-50, -25);
		_gfx.lineTo(-50, -50);
		_gfx.endFill();
	}

	function drawRed():Void
	{
		_gfx.beginFill(_colors[2]);
		_gfx.moveTo(50, -50);
		_gfx.lineTo(25, -50);
		_gfx.lineTo(1, -37);
		_gfx.lineTo(37, 0);
		_gfx.lineTo(50, -25);
		_gfx.lineTo(50, -50);
		_gfx.endFill();
	}

	function drawBlue():Void
	{
		_gfx.beginFill(_colors[3]);
		_gfx.moveTo(-50, 50);
		_gfx.lineTo(-25, 50);
		_gfx.lineTo(0, 37);
		_gfx.lineTo(-37, 1);
		_gfx.lineTo(-50, 25);
		_gfx.lineTo(-50, 50);
		_gfx.endFill();
	}

	function drawLightBlue():Void
	{
		_gfx.beginFill(_colors[4]);
		_gfx.moveTo(50, 50);
		_gfx.lineTo(25, 50);
		_gfx.lineTo(1, 37);
		_gfx.lineTo(37, 1);
		_gfx.lineTo(50, 25);
		_gfx.lineTo(50, 50);
		_gfx.endFill();
	}

	function onComplete(?Tween:FlxTween):Void
	{
		FlxG.cameras.bgColor = _cachedBgColor;
		FlxG.fixedTimestep = _cachedTimestep;
		FlxG.autoPause = _cachedAutoPause;
		#if FLX_KEYBOARD
		FlxG.keys.enabled = true;
		#end
		FlxG.stage.removeChild(_sprite);
		//FlxG.stage.removeChild(_text);
		remove(_text);
		//FlxG.switchState(Type.createInstance(nextState, []));
		//FlxG.game._gameJustStarted = true;
		FlxG.switchState(new TitleState());
	}
}