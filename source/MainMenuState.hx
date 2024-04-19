package;

import flixel.ui.FlxButton;
#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import Achievements;
import editors.MasterEditorMenu;
import flixel.input.keyboard.FlxKey;
import flixel.addons.display.FlxBackdrop;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.addons.ui.FlxUICheckBox;

using StringTools;

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.5.2h'; //This is also used for Discord RPC
	public static var curSelected:Int = 0;
	var disableInput:Bool = false; //Disable this to hide the easter egg
	var easterEggEnabled:Bool = true; //Disable this to hide the easter egg
	var easterEggKeyCombination:Array<FlxKey> = [
		FlxKey.LEFT,
		FlxKey.DOWN,
		FlxKey.UP,
		FlxKey.RIGHT,
		FlxKey.UP,
		FlxKey.DOWN,
		FlxKey.LEFT,
		FlxKey.DOWN,
		FlxKey.UP,
		FlxKey.RIGHT,		
		FlxKey.UP,
		FlxKey.RIGHT,		
		FlxKey.UP,
		FlxKey.RIGHT,
		FlxKey.DOWN,
		FlxKey.LEFT,
	];
	var lastKeysPressed:Array<FlxKey> = [];

	var menuItems:FlxTypedGroup<FlxSprite>;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;
	private var camOther:FlxCamera;
	var yScroll:Float;
	
	var optionShit:Array<String> = [
		'story_mode',
		'freeplay',
		'mini',
		//'manual',
		#if MODS_ALLOWED 'mods', #end
		#if ACHIEVEMENTS_ALLOWED 'awards', #end
		'credits',
		'options'
	];

	var bg:FlxSprite;
	var magenta:FlxSprite;
	var camFollow:FlxObject;
	var camFollowPos:FlxObject;
	var debugKeys:Array<FlxKey>;

	var engi:FlxSprite;

	var checker:FlxBackdrop = new FlxBackdrop(Paths.image('coolCheckerWeStoleFromMicdUpLol'), 0.2, 0.2, true, true);

	var thisthing:FlxSprite;
	var funi:Float = 0;

	var stupid:FlxSprite;

	var bruhbruh = FlxColor.fromRGB(FlxG.random.int(0,255),FlxG.random.int(0,255),FlxG.random.int(0,255));

	var realcheck:CheckboxThingie;

	var randomimagepaths:Array<String> = [];

	function onMouseDown(object:FlxObject){
		if(!selectedSomethin && !disableInput){
				for(obj in menuItems.members){
					if(obj==object){
						selectFunny();
						break;
					}
				}
				/*if(realcheck==object){
					doathing();
					//break;
				}*/
			}
	}
	function onMouseUp(object:FlxObject){

	}

	function onMouseOver(object:FlxObject){
		if(!selectedSomethin && !disableInput){
			for(idx in 0...menuItems.members.length){
				var obj = menuItems.members[idx];
				if(obj==object){
					if(idx!=curSelected){
						FlxG.sound.play(Paths.sound('scrollMenu'));
						changeItem(idx,true);
					}
				}
			}
		}
	}

	function onMouseOut(object:FlxObject){

	}
	private var grpNotes:FlxTypedGroup<FlxSprite>;
	var freeplayButton:FlxButton;
	var invisiblecheck:FlxUICheckBox = null;

	override function create()
	{
		WeekData.loadTheFirstEnabledMod();
		FreeplayState.sc_add = 0;
		FlxG.mouse.visible = true;
		PlayState.inminigame = false;
		yScroll = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end
		debugKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));

		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		camOther = new FlxCamera();
		camOther.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement);
		FlxG.cameras.add(camOther);
		FlxCamera.defaultCameras = [camGame];

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		bg = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.alpha = 0.7;
		bg.updateHitbox();
		bg.screenCenter();
		bg.color = bruhbruh;
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);

		// magenta.scrollFactor.set();

		checker.velocity.x = -45;
		checker.velocity.y = -16;
		checker.color = bruhbruh;
		add(checker);

		randomimagepaths = sys.FileSystem.readDirectory('assets/images/randombox');
		//trace(randomimagepaths);

		stupid = new FlxSprite(750, 0, 'assets/images/randombox/' + randomimagepaths[FlxG.random.int(0, randomimagepaths.length - 1)]);
		/*stupid.frames = Paths.getSparrowAtlas('randomBox');
		stupid.animation.addByIndices('idle', 'random', [FlxG.random.int(0, 28)], "", 0);
		stupid.animation.play('idle');*/
		stupid.screenCenter(Y);
		add(stupid);

		thisthing = new FlxSprite(-100, -5);
		thisthing.frames = Paths.getSparrowAtlas('thisidk');
		thisthing.animation.addByPrefix('idle', 'thingidk', 12, true);
		thisthing.animation.play('idle');
		thisthing.updateHitbox();
		thisthing.setGraphicSize(Std.int(thisthing.width * 1.2));
		thisthing.antialiasing = ClientPrefs.globalAntialiasing;
		add(thisthing);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var scale:Float = 1;
		/*if(optionShit.length > 6) {
			scale = 6 / optionShit.length;
		}*/

		grpNotes = new FlxTypedGroup<FlxSprite>();
		add(grpNotes);

		for (i in 0...optionShit.length)
		{
			var offset:Float = 108 - (Math.max(optionShit.length, 4) - 4) * 100;
			var menuItem:FlxSprite = new FlxSprite(45, (i * 160)  + offset);
			menuItem.scale.x = scale;
			menuItem.scale.y = scale;
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[i]);
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItems.add(menuItem);
			var scr:Float = (optionShit.length - 4) * (1.33 / optionShit.length);
			if(optionShit.length < 6) scr = 0;
			menuItem.scrollFactor.set(0, scr);
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			//menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
			menuItem.updateHitbox();
			FlxMouseEventManager.add(menuItem,onMouseDown,onMouseUp,onMouseOver,onMouseOut);
		}

		FlxG.camera.follow(camFollowPos, null, 1);

		var textfuny:String = #if PSYCH_WATERMARKS "Psych Engine v" + psychEngineVersion + #end "\nFriday Night Funkin' v0.2.7\nGamer Engine vIDK [PLAYTEST BUILD]\n\n\n\n\n\nputo el que lo lea";
		var versionShit:FlxText = new FlxText(12, FlxG.height -  #if PSYCH_WATERMARKS 64 #else 44 #end, 0, textfuny, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		// NG.core.calls.event.logEvent('swag').send();

		changeItem();

		#if ACHIEVEMENTS_ALLOWED
		Achievements.loadAchievements();
		var leDate = Date.now();
		if (leDate.getDay() == 5 && leDate.getHours() >= 18) {
			var achieveID:Int = Achievements.getAchievementIndex('friday_night_play');
			if(!Achievements.isAchievementUnlocked(Achievements.achievementsStuff[achieveID][2])) { //It's a friday night. WEEEEEEEEEEEEEEEEEE
				Achievements.achievementsMap.set(Achievements.achievementsStuff[achieveID][2], true);
				giveAchievement('friday_night_play');
				ClientPrefs.saveSettings();
			}
		}
		#end

		engi = new FlxSprite(FlxG.width * FlxG.random.float(0, 0.8), FlxG.random.float(-10, FlxG.height + 10), Paths.image('engineer gaming'));
		engi.angularVelocity = 15;
		engi.visible = FlxG.random.bool(5);
		add(engi);

		if(!ClientPrefs.asd && TitleState.switchedToMainMenu) {
			disableInput = true;
			var black:FlxSprite = new FlxSprite(-50, -50).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
			black.alpha = 0;
			black.scrollFactor.set(0, 0);
			black.cameras = [camOther];
			add(black);

			var string:String = '!!! DISCLAIMER !!!\n
			this engine is not entirely created by us, its a modificaion of already existing psych engine.\ngo support the original engine at\n\nhttps://gamebanana.com/mods/309789\n\nalso this is a playtest build, expect fails';
			var text:FlxText = new FlxText(0, 150, 1000, string, 16);
			text.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			text.screenCenter(X);
			text.alpha = 0;
			text.scrollFactor.set(0, 0);
			text.cameras = [camOther];
			add(text);

			/*var text2:FlxText = new FlxText(25, ClientPrefs.getResolution()[1] - 44, 500, 'Don\'t show me this again', 16);
			text2.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			text2.alpha = 0;
			text2.scrollFactor.set(0, 0);
			text2.cameras = [camOther];
			add(text2);*/

			freeplayButton = new FlxButton(0, 560, "    Got it", function() {
				FlxTween.tween(freeplayButton, {alpha: 0}, 0.5);
				FlxTween.tween(text, {alpha: 0}, 0.5);
				FlxTween.tween(black, {alpha: 0}, 1, {onComplete: function(no:FlxTween){disableInput = false;}});
				FlxTween.tween(invisiblecheck, {alpha: 0}, 1);
				FlxTween.tween(invisiblecheck.box, {alpha: 0}, 1);
				FlxTween.tween(invisiblecheck.mark, {alpha: 0}, 1);
			});
			freeplayButton.setGraphicSize(Std.int(freeplayButton.width * 2.5), Std.int(freeplayButton.height * 2.5));
			freeplayButton.updateHitbox();
			freeplayButton.label.setFormat("VCR OSD Mono", 24, FlxColor.BLACK, CENTER);
			freeplayButton.label.wordWrap = false;
			freeplayButton.label.autoSize = true;
			freeplayButton.screenCenter(X);
			freeplayButton.alpha = 0;
			freeplayButton.scrollFactor.set(0, 0);
			freeplayButton.cameras = [camOther];
			add(freeplayButton);

			//realcheck = new CheckboxThingie(0, 0, false);
			invisiblecheck = new FlxUICheckBox(10, 10, null, null, 'Don\'t show me this again', 300, null, function(){
				trace('CHECKED!');
				//doathing();
			});
			/*realcheck.frames = Paths.getSparrowAtlas('checkbox but red');
			realcheck.setGraphicSize(Std.int(realcheck.width / 2), Std.int(realcheck.width / 2));*/
			invisiblecheck.setGraphicSize(Std.int(invisiblecheck.width * 1.5), Std.int(invisiblecheck.height * 1.5));
			invisiblecheck.updateHitbox();
			invisiblecheck.cameras = [camOther];
			//invisiblecheck.alpha = 0;
			invisiblecheck.textIsClickable = false;
			//add(invisiblecheck);

			/*realcheck.sprTracker = text2;
			realcheck.offsetX = 15;
			realcheck.offsetY = 15;
			realcheck.cameras = [camOther];*/
			/*FlxMouseEventManager.add(realcheck,onMouseDown,onMouseUp,onMouseOver,onMouseOut);
			add(realcheck); */

			FlxTween.tween(text, {alpha: 1}, 1);
			FlxTween.tween(freeplayButton, {alpha: 1}, 1);
			FlxTween.tween(black, {alpha: 0.69}, 2);
			//FlxTween.tween(text2, {alpha: 1}, 1, {startDelay: 3});
			FlxTween.tween(invisiblecheck, {alpha: 1}, 1, {startDelay: 3});
			FlxTween.tween(invisiblecheck.box, {alpha: 1}, 1, {startDelay: 3});
			FlxTween.tween(invisiblecheck.mark, {alpha: 1}, 1, {startDelay: 3});
			FlxG.sound.music.fadeOut(0.25, 0.25);
			TitleState.switchedToMainMenu = false;
		}
		super.create();
	}

	#if ACHIEVEMENTS_ALLOWED
	// Unlocks "Freaky on a Friday Night" achievement
	function giveAchievement(achievement:String) {
		add(new AchievementObject(achievement, camAchievement));
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
		trace('Giving achievement "${achievement}"');
	}
	#end

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		engi.scrollFactor.set(funi * 1.6, (yScroll * ((optionShit.length - 4) * 0.23)) * 3);
		bg.scrollFactor.set(funi / 4, yScroll / 1.5);
		thisthing.scrollFactor.set(funi / 1.5, 0);
		checker.scrollFactor.set(funi / 1.3, yScroll);
		stupid.scrollFactor.set(funi / 2, yScroll / 10);
		if (FlxG.sound.music.volume < 0.8 && !disableInput)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}
		menuItems.forEach(function(spr:FlxSprite)
		{
			if (spr.ID == curSelected)
			{
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
			}
		});
		var lerpVal:Float = CoolUtil.boundTo(elapsed * 7.5, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		if (!selectedSomethin && !disableInput)
		{
			if (controls.UI_UP_P || FlxG.mouse.wheel == 1)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.UI_DOWN_P || FlxG.mouse.wheel == -1)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
				selectFunny();
			}
			#if desktop
			else if (FlxG.keys.anyJustPressed(debugKeys))
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end
		}
		if(easterEggEnabled && !disableInput)
		{
			var finalKey:FlxKey = FlxG.keys.firstJustPressed();
			if(finalKey != FlxKey.NONE) {
				lastKeysPressed.push(finalKey); //Convert int to FlxKey
				var constnotexpos:Float = (FlxG.width / 2) + 100;
				if (FlxG.keys.justPressed.LEFT) {
					var notething:FlxSprite = new FlxSprite(constnotexpos, FlxG.height * 1.2);
					notething.frames = Paths.getSparrowAtlas('NOTE_assets');
					notething.animation.addByPrefix('idle', 'purple0');
					notething.animation.play('idle');
					notething.velocity.y = -360;
					notething.antialiasing = ClientPrefs.globalAntialiasing;
					notething.scrollFactor.set(0, yScroll);
					notething.setGraphicSize(Std.int(notething.width / 1.75));
					grpNotes.add(notething);
					var newShader:ColorSwap = new ColorSwap();
					notething.shader = newShader.shader;
					newShader.hue = ClientPrefs.arrowHSV[0][0] / 360;
					newShader.saturation = ClientPrefs.arrowHSV[0][1] / 100;
					newShader.brightness = ClientPrefs.arrowHSV[0][2] / 100;
				}
				if (FlxG.keys.justPressed.DOWN) {
					var notething:FlxSprite = new FlxSprite(constnotexpos + 80, FlxG.height * 1.2);
					notething.frames = Paths.getSparrowAtlas('NOTE_assets');
					notething.animation.addByPrefix('idle', 'blue0');
					notething.animation.play('idle');
					notething.velocity.y = -360;
					notething.antialiasing = ClientPrefs.globalAntialiasing;
					notething.scrollFactor.set(0, yScroll);
					notething.setGraphicSize(Std.int(notething.width / 1.75));
					grpNotes.add(notething);
					var newShader:ColorSwap = new ColorSwap();
					notething.shader = newShader.shader;
					newShader.hue = ClientPrefs.arrowHSV[1][0] / 360;
					newShader.saturation = ClientPrefs.arrowHSV[1][1] / 100;
					newShader.brightness = ClientPrefs.arrowHSV[1][2] / 100;
				}
				if (FlxG.keys.justPressed.UP) {
					var notething:FlxSprite = new FlxSprite(constnotexpos + 160, FlxG.height * 1.2);
					notething.frames = Paths.getSparrowAtlas('NOTE_assets');
					notething.animation.addByPrefix('idle', 'green0');
					notething.animation.play('idle');
					notething.velocity.y = -360;
					notething.antialiasing = ClientPrefs.globalAntialiasing;
					notething.scrollFactor.set(0, yScroll);
					notething.setGraphicSize(Std.int(notething.width / 1.75));
					grpNotes.add(notething);
					var newShader:ColorSwap = new ColorSwap();
					notething.shader = newShader.shader;
					newShader.hue = ClientPrefs.arrowHSV[2][0] / 360;
					newShader.saturation = ClientPrefs.arrowHSV[2][1] / 100;
					newShader.brightness = ClientPrefs.arrowHSV[2][2] / 100;
				}
				if (FlxG.keys.justPressed.RIGHT) {
					var notething:FlxSprite = new FlxSprite(constnotexpos + 240, FlxG.height * 1.2);
					notething.frames = Paths.getSparrowAtlas('NOTE_assets');
					notething.animation.addByPrefix('idle', 'red0');
					notething.animation.play('idle');
					notething.velocity.y = -360;
					notething.antialiasing = ClientPrefs.globalAntialiasing;
					notething.scrollFactor.set(0, yScroll);
					notething.setGraphicSize(Std.int(notething.width / 1.75));
					grpNotes.add(notething);
					var newShader:ColorSwap = new ColorSwap();
					notething.shader = newShader.shader;
					newShader.hue = ClientPrefs.arrowHSV[3][0] / 360;
					newShader.saturation = ClientPrefs.arrowHSV[3][1] / 100;
					newShader.brightness = ClientPrefs.arrowHSV[3][2] / 100;
				}
				if(lastKeysPressed.length > easterEggKeyCombination.length)
				{
					lastKeysPressed.shift();
				}
				
				if(lastKeysPressed.length == easterEggKeyCombination.length)
				{
					var isDifferent:Bool = false;
					for (i in 0...lastKeysPressed.length) {
						if(lastKeysPressed[i] != easterEggKeyCombination[i]) {
							isDifferent = true;
							break;
						}
					}
					if(!isDifferent) {
						trace('Easter egg triggered!');
						//FlxG.save.data.psykaEasterEgg = !FlxG.save.data.psykaEasterEgg;
						FlxG.sound.play(Paths.sound('secretSound'));
						lastKeysPressed = [];
						/*var black:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
						black.alpha = 0;
						add(black);
						FlxTween.tween(black, {alpha: 1}, 1, {onComplete:
							function(twn:FlxTween) {
								FlxTransitionableState.skipNextTransIn = true;
								FlxTransitionableState.skipNextTransOut = true;
								MusicBeatState.switchState(new TitleState());
							}
						});
						closedState = true;
						transitioning = true;*/
						var achieveID:Int = Achievements.getAchievementIndex('tutpatr');
						if(!Achievements.isAchievementUnlocked(Achievements.achievementsStuff[achieveID][2])) { //It's a friday night. WEEEEEEEEEEEEEEEEEE
							Achievements.achievementsMap.set(Achievements.achievementsStuff[achieveID][2], true);
							giveAchievement('tutpatr');
							ClientPrefs.saveSettings();
						}
					}
				}
			}
		}

		super.update(elapsed);
	}

	function selectFunny()
	{
		if (optionShit[curSelected] == 'manual')
		{
			CoolUtil.browserLoad('https://docs.google.com/document/d/1WTli5fHJ0cXECsM9hk8Yx1-Yc77pF9AHl66ZuBpxDRY/edit?usp=sharing');
		}
		else
		{
			selectedSomethin = true;
			FlxG.sound.play(Paths.sound('confirmMenu'));
			//if(ClientPrefs.flashing) FlxFlicker.flicker(magenta, 1.1, 0.15, false);
			menuItems.forEach(function(spr:FlxSprite)
			{
				if (curSelected != spr.ID)
				{
					FlxTween.tween(spr, {alpha: 0}, 0.4, {
						ease: FlxEase.quadOut,
						onComplete: function(twn:FlxTween)
						{
							spr.kill();
						}
					});
				}
				else
				{
					FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
					{
						var daChoice:String = optionShit[curSelected];
						switch (daChoice)
						{
							case 'story_mode':
								MusicBeatState.switchState(new StoryMenuState());
							case 'freeplay':
								MusicBeatState.switchState(new FreeplayState());
							case 'mini':
								MusicBeatState.switchState(new MinigameSelectState());
							#if MODS_ALLOWED
							case 'mods':
								MusicBeatState.switchState(new ModsMenuState());
							#end
							case 'awards':
								MusicBeatState.switchState(new AchievementsMenuState());
							case 'credits':
								MusicBeatState.switchState(new CreditsState());
							case 'options':
								MusicBeatState.switchState(new options.OptionsState());
						}
					});
					//FlxTween.tween(spr, {x: spr.x + 1280}, 1, {ease: FlxEase.expoIn});
					//funi = 0.5;
				}
			});
		}
	}
	function changeItem(huh:Int = 0, ?force:Bool = false)
	{
		if(force){
			curSelected=huh;
		}else{
			curSelected += huh;
		}

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');
			spr.updateHitbox();

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
				spr.offset.x = 0.15 * (spr.frameWidth / 5);
				spr.offset.y = 0.15 * spr.frameHeight;
				FlxG.log.add(spr.frameWidth);
			}
		});
	}
}
