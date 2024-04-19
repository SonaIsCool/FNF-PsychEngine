package;

import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.math.FlxMath;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxCamera;
import flixel.ui.FlxBar;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class MinigameState extends MusicBeatState 
{
    public static var curMinigame:String = 'killbf';
    static var mghealthIncl:Array<String> = ['killbf'];
    static var mgcounterIncl:Array<String> = ['killbf'];
    var health:Float = 1;
    var healthBar:FlxBar;
    var healthicon:HealthIcon;
    public static var selectedhi:String = 'face';

    var camGame:FlxCamera;
    var camHUD:FlxCamera;

    var count:Int;
    var countertxt:FlxText;
    
    //kill bf minigame
    var grpbficons:FlxTypedGroup<HealthIcon>;
    var countdupl:Int;

    // stolen from tails gets trolled
	function onMouseDown(object:FlxObject){
        switch(curMinigame)
        {
            case 'killbf':
                for (unfunny in grpbficons)
                {
                    if(object==unfunny && (unfunny.alive)) {
                        FlxG.sound.play(Paths.sound('mg/bfkill', 'shared'));
                        unfunny.animation.curAnim.curFrame = 1;
                        count++;
                        unfunny.alive = false;
                        new FlxTimer().start(0.5, function(no:FlxTimer)
                        {
                            unfunny.kill();
                        });
                        health += 0.05;
                    }
                }
                if (count >= 250) win();
        }
	}

	function onMouseUp(object:FlxObject){

	}

	function onMouseOver(object:FlxObject){

	}

	function onMouseOut(object:FlxObject){

	}

    public function new(minigame:String)
    {
        curMinigame = minigame;
        super();
    }

    override public function create() {
        camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);
		FlxCamera.defaultCameras = [camGame];
        persistentUpdate = true;
        var stageback:BGSprite = new BGSprite('stageback', -100, -100);
        add(stageback);

        if(mghealthIncl.contains(curMinigame)) {
            var healthBarBG:AttachedSprite = new AttachedSprite('healthBar');
		    healthBarBG.y = FlxG.height * 0.89;
		    healthBarBG.screenCenter(X);
		    healthBarBG.scrollFactor.set();
		    healthBarBG.xAdd = -4;
		    healthBarBG.yAdd = -4;
		    add(healthBarBG);

		    healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
		    	'health', 0, 1);
		    healthBar.scrollFactor.set();
		    // healthBar
		    healthBar.alpha = ClientPrefs.healthBarAlpha;
            healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		    add(healthBar);
		    healthBarBG.sprTracker = healthBar;

		    healthicon = new HealthIcon(selectedhi, true);
		    healthicon.y = healthBar.y - 75;
		    healthicon.alpha = ClientPrefs.healthBarAlpha;
		    add(healthicon);

            healthBar.cameras = [camHUD];
		    healthBarBG.cameras = [camHUD];
		    healthicon.cameras = [camHUD];
        }
        countertxt = new FlxText(17, 17, 1000, 'bitch', 40);
		countertxt.setFormat(Paths.font(defaultUIFont), 40, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		countertxt.borderSize = 2;
		countertxt.scrollFactor.set(0,0);
		if(mgcounterIncl.contains(curMinigame)) add(countertxt);
        Conductor.changeBPM(140);
        FlxG.sound.playMusic(Paths.music('minigame', 'shared'), 1, true);

        switch(curMinigame)
        {
            case 'killbf':
                grpbficons = new FlxTypedGroup<HealthIcon>();
                add(grpbficons);

                for (i in 0...250) {
                    var unfunny:HealthIcon = new HealthIcon('bf', FlxG.random.bool(50));
                    unfunny.x = FlxG.random.int(35, FlxG.width - 35);
                    unfunny.y = -250 - (i * 110);
                    unfunny.scrollFactor.set(0,0);
                    unfunny.setGraphicSize(Std.int(unfunny.width * 0.75));
                    unfunny.updateHitbox();
                    grpbficons.add(unfunny);
                    FlxMouseEventManager.add(unfunny,onMouseDown,onMouseUp,onMouseOver,onMouseOut);
                }
        }
        super.create();
    }

    var winspr:FlxSprite;

    override function update(elapsed:Float) {
        var iconOffset:Int = 26;
		healthicon.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) + (150 * healthicon.scale.x - 150) / 2 - iconOffset;

        switch(ClientPrefs.iconbop.toLowerCase())
		{
			case 'default':
				var mult:Float = FlxMath.lerp(1, healthicon.scale.x, CoolUtil.boundTo(1 - (elapsed * 9), 0, 1));
				healthicon.scale.set(mult, mult);
				healthicon.updateHitbox();
			case 'dave and bambi':
				var multx:Float = FlxMath.lerp(1, healthicon.scale.x, CoolUtil.boundTo(1 - (elapsed * 9), 0, 1));
				var multy:Float = FlxMath.lerp(1, healthicon.scale.y, CoolUtil.boundTo(1 - (elapsed * 9), 0, 1));
				healthicon.scale.set(multx, multy);
				healthicon.updateHitbox();
			case 'vanilla (as of w7)':
				// nothing lol its tweened
			default:
				var mult:Float = FlxMath.lerp(1, healthicon.scale.x, CoolUtil.boundTo(1 - (elapsed * 9), 0, 1));
				healthicon.scale.set(mult, mult);
				healthicon.updateHitbox();
		}

		if (health > 1)
			health = 1;

		if (healthBar.percent < 20)
			healthicon.animation.curAnim.curFrame = 1;
		else
			healthicon.animation.curAnim.curFrame = 0;

        switch(curMinigame)
        {
            case 'killbf':
                for (unfunny in grpbficons)
                {
                    if(unfunny.alive) unfunny.y += 2.5;
                    if(unfunny.y == 640) { health -= 0.05; countdupl++; }
                }
                countertxt.text = 'kills: ${count}\nmisses: ${countdupl}';
        }
        if(controls.BACK)
        {
            MusicBeatState.switchState(new MinigameSelectState());
            FlxG.sound.playMusic(Paths.music('freakyMenu'));
            Conductor.changeBPM(102);
        }
        Conductor.songPosition = FlxG.sound.music.time;
        super.update(elapsed);
    }

	var lastBeatHit:Int = -1;
    function win()
    {
        winspr = new FlxSprite(0, 0);
        winspr.frames = Paths.getSparrowAtlas('mg/win', 'shared');
        winspr.animation.addByPrefix('win', 'win!', 24, false);
        winspr.animation.play('win');
        winspr.screenCenter();
        winspr.antialiasing = ClientPrefs.globalAntialiasing;
        add(winspr);
        new FlxTimer().start(2, function(no:FlxTimer)
        {
            MusicBeatState.switchState(new MinigameSelectState());
            FlxG.sound.playMusic(Paths.music('freakyMenu'));
            Conductor.changeBPM(102);
        });
        switch(curMinigame)
        {
            case 'killbf':
                for (unfunny in grpbficons)
                {
                    if (unfunny.alive) {
                        unfunny.animation.curAnim.curFrame = 1;
                        unfunny.alive = false;
                        new FlxTimer().start(0.5, function(no:FlxTimer)
                        {
                            unfunny.kill();
                        });
                        health += 0.05;
                    }
                }
        }
    }
	override function beatHit()
	{
		super.beatHit();
		if(lastBeatHit >= curBeat) 
        {
			return;
		}
        switch(ClientPrefs.iconbop.toLowerCase()) {
            case 'default':
                healthicon.scale.set(1.2, 1.2);
                healthicon.updateHitbox();
            case 'dave and bambi':
                healthicon.scale.set(1.3, 0.7);
                healthicon.updateHitbox();
            case 'vanilla (as of w7)':
                healthicon.scale.set(1.2, 1.2);
                new FlxTimer().start(0.001, function(no:FlxTimer)
                {
                    FlxTween.tween(healthicon, {"scale.x": 1, "scale.y": 1}, (0.5 / (Conductor.bpm / 100)));
                });
                healthicon.updateHitbox();
            default:
                healthicon.scale.set(1.2, 1.2);
                healthicon.updateHitbox();
        }
        lastBeatHit == curBeat;
    }
}