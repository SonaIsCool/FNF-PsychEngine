package;

import flixel.math.FlxMath;
import flixel.util.FlxTimer;
import flixel.ui.FlxButton;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxColor;
import flixel.addons.display.FlxBackdrop;
import flixel.FlxSubState;
#if desktop
import sys.FileSystem;
#end

using StringTools;

class MinigameSelectState extends MusicBeatState
{
	public var mgList:Array<Dynamic> = [ // display name, description, icon, bg color, type bc idk, if it can be pressed, pending (in case its been worked on, or just planned)
	['kill bf', 'lmfao\ncontrols: just click the bf icons lo', 'killBf', 0xFF755a70, 'point & click', true, false],
	['get out of my head', 'the pain never stops', 'sus', 0xFF361414, 'mania', true, false],
	['literally rhds in fnf', 'not visually stable, keeping the "dont rely on visual cues" mechanic\nfor some reason', 'rhds', 0xFF0db826, 'mania (1k)', true, false],
	['carlos', 'carlos', 'carlos', 0xFF4a9eff, 'mania', true, false],
	['low quality .jpegs are funny', 'they are and you cant tell me otherwise', 'pico', 0xFF7b167d, 'mania', true, false],
	['more soon...', ' ', 'none', 0xFF7c7e82, 'none', false, false]
	];
	private var iconArray:Array<AttachedSprite> = [];
	private var iconArray2:Array<AttachedSprite> = [];
	private var grpTexts:FlxTypedGroup<Alphabet>;
	var intendedColor:Int;
	private static var curSelected = 0;
	private static var curSelectedIcon = 0;
	private var curDirectory = 0;
	var bg:FlxSprite;
	var colorTween:FlxTween;
	var thedesc:FlxText;
	var thingy:FlxText;
	var checker:FlxBackdrop = new FlxBackdrop(Paths.image('coolCheckerWeStoleFromMicdUpLol'), 0.2, 0.2, true, true);
	static var iconnamearray:Array<String> = ['face', 'bf', 'gf', 'dad', 'spooky', 'pico', 'mom', 'monster', 'senpai-pixel', 'tankman', 'sus', 'carlos'];
	var icon:HealthIcon;
	var curDifficulty:Int = 1;
	private static var lastDifficultyName:String = '';
	var playbutton:FlxButton;

	override function create()
	{
		FlxG.mouse.visible = true;
		FlxG.camera.bgColor = FlxColor.BLACK;
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Minigames Select Menu", null);
		#end
		PlayState.inminigame = true;
		PlayState.chartingMode = false;
		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.scrollFactor.set();
		bg.color = mgList[curSelected][3];
		add(bg);
		bg.screenCenter();
		intendedColor = bg.color;

		checker.velocity.x = -100;
		checker.velocity.y = -50;
		checker.color = bg.color;
		add(checker);

		grpTexts = new FlxTypedGroup<Alphabet>();
		add(grpTexts);

		for (i in 0...mgList.length)
		{
			var pending:Bool = mgList[i][6];
			var scale:Float = Math.min(20 / (mgList[i][0].length), 1);

			var leText:Alphabet = new Alphabet(0, (70 * i) + 30, mgList[i][0], true, false, 0, scale);
			leText.isMenuItem = true;
			leText.targetY = i;
			leText.yAdd = (-200 + ((scale / 2) - 0.5));
			leText.xAdd = 200;
			grpTexts.add(leText);

			
			var texture:String = 'mgicons/' + mgList[i][2];
			//if(!FileSystem.exists(texture)) texture = 'mgicons/none';

			var awesomeicon:AttachedSprite = new AttachedSprite(texture);
			awesomeicon.xAdd = leText.x - 195;
			awesomeicon.yAdd = -38;
			awesomeicon.sprTracker = leText;

			#if desktop
			if(!Paths.fileExists('images/' + texture + '.png', IMAGE)) icon.loadGraphic(Paths.returnGraphic('mgicons/none'));
			trace(Paths.fileExists('images/' + texture + '.png', IMAGE) + ', ' + Paths.getPath('images/' + texture + '.png', IMAGE));
			#end
			// using a FlxGroup is too much fuss!
			iconArray.push(awesomeicon);
			add(awesomeicon);

			if (pending) 
			{
				var picon:AttachedSprite = new AttachedSprite('mg_pending');
				picon.xAdd = -45;
				picon.yAdd = 75;
				picon.sprTracker = awesomeicon;
				picon.setGraphicSize(Std.int(picon.width * 0.6));
				picon.updateHitbox();
				leText.color = 0xffff4242;
				iconArray2.push(picon);
				add(picon);
			}
			
		}

		if(lastDifficultyName == '')
		{
			lastDifficultyName = CoolUtil.defaultDifficulty;
		}
		curDifficulty = Math.round(Math.max(0, CoolUtil.defaultDifficulties.indexOf(lastDifficultyName)));
		
		var fuckbg:FlxSprite = new FlxSprite(0,0).makeGraphic(FlxG.width, 85, FlxColor.BLACK);
		fuckbg.alpha = 0.5;
		fuckbg.scrollFactor.set(0,0);
		add(fuckbg);

		var funnitext:FlxText = new FlxText(17, 17, 1000, 'MINIGAMES (IN EARLY DEVELOPMENT   !!!!!!)', 40);
		funnitext.setFormat(Paths.font(defaultUIFont), 40, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		funnitext.borderSize = 2;
		funnitext.scrollFactor.set(0,0);
		add(funnitext);

		icon = new HealthIcon('face', true);
		icon.x = FlxG.width - 150;
		icon.y -= 5;
		icon.scrollFactor.set(0,0);
		icon.setGraphicSize(Std.int(icon.width * 0.5));
		icon.updateHitbox();
		add(icon);

		var fuckbg:FlxSprite = new FlxSprite(0,270).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		fuckbg.alpha = 0.5;
		fuckbg.scrollFactor.set(0,0);
		add(fuckbg);

		thedesc = new FlxText(17, 287, 0, "", 32);
		thedesc.setFormat(Paths.font(defaultUIFont), 40, FlxColor.WHITE, LEFT);
		thedesc.wordWrap = false;
		thedesc.autoSize = true;
		add(thedesc);

		thingy = new FlxText(0, 600, 0, "", 32);
		thingy.setFormat(Paths.font(defaultUIFont), 32, FlxColor.WHITE, CENTER);
		thingy.screenCenter(X);
		add(thingy);

		playbutton = new FlxButton(0, 650, "Play", function() {
			if (!gonnaenter) selectFunny();
		});
		playbutton.setGraphicSize(Std.int(playbutton.width * 2.5), Std.int(playbutton.height * 2.5));
		playbutton.updateHitbox();
		playbutton.screenCenter(X);
		playbutton.label.setFormat(Paths.font(defaultUIFont), 24, FlxColor.BLACK, CENTER);
		setAllLabelsOffset(playbutton, 0, 10);
		add(playbutton);

		lastDifficultyName = CoolUtil.difficulties[curDifficulty];
		changeSelection();
		changeIcon();
		MusicBeatState.disableWindowRename = false;
		super.create();
	}
	var gonnaenter:Bool = false;
	var blockinput:Bool = false;
	override function update(elapsed:Float)
	{
		checker.color = bg.color;
		if(!gonnaenter) {
			if (!blockinput) {
				if (controls.UI_UP_P || FlxG.mouse.wheel == 1)
				{
					changeSelection(-1, true);
				}
				if (controls.UI_DOWN_P || FlxG.mouse.wheel == -1)
				{
					changeSelection(1, true);
				}
				if (controls.UI_LEFT_P)
				{
					changeIcon(-1);
				}
				if (controls.UI_RIGHT_P)
				{
					changeIcon(1);
				}
			}
			var ctrl = FlxG.keys.justPressed.CONTROL;
			if(ctrl)
			{
				persistentUpdate = true;
				blockinput = true;
				openSubState(new GameplayChangersSubstate());
			}
			if (!blockinput) {
				if (controls.BACK)
				{
					if(colorTween != null) {
						colorTween.cancel();
					}
					MusicBeatState.switchState(new MainMenuState());
				}

				if (controls.ACCEPT && playbutton.visible)
				{
					selectFunny();
				}
			}
		}
		FlxG.camera.zoom = FlxMath.lerp(1, FlxG.camera.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125), 0, 1));
		super.update(elapsed);
	}
	override function closeSubState() {
		blockinput = false;
		changeSelection(0, false);
		persistentUpdate = true;
		super.closeSubState();
	}

	function changeSelection(change:Int = 0, playSound:Bool = true)
	{
		if (playSound) FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = mgList.length - 1;
		if (curSelected >= mgList.length)
			curSelected = 0;

		var bullShit:Int = 0;
		for (item in grpTexts.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}

		thedesc.text = (mgList[curSelected][6] ? '[Pending] ' : '') + mgList[curSelected][1];
		thingy.text = 'Type: ' + mgList[curSelected][4].toUpperCase();
		thingy.screenCenter(X);
		playbutton.visible = (mgList[curSelected][5] && !mgList[curSelected][6]);
		icon.visible = !thingy.text.toLowerCase().contains('mania');

		var newColor:Int = mgList[curSelected][3];
		if(newColor != intendedColor) {
			if(colorTween != null) {
				colorTween.cancel();
			}
			intendedColor = newColor;
			colorTween = FlxTween.color(bg, 1, bg.color, intendedColor, {
				onComplete: function(twn:FlxTween) {
					colorTween = null;
				}
			});
		}
	}

	function changeIcon(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelectedIcon += change;

		if (curSelectedIcon < 0)
			curSelectedIcon = iconnamearray.length - 1;
		if (curSelectedIcon >= iconnamearray.length)
			curSelectedIcon = 0;

		icon.changeIcon(iconnamearray[curSelectedIcon]);
	}

	function selectFunny()
	{
		gonnaenter = true;
		
		if(colorTween != null) {
			colorTween.cancel();
		}

		if (ClientPrefs.flashing) bg.color = FlxColor.WHITE;
		FlxG.camera.zoom += 0.025;
		colorTween = FlxTween.color(bg, 0.5, bg.color, FlxColor.BLACK, {
			onComplete: function(twn:FlxTween) {
				colorTween = null;
			}, startDelay: 0.01
		});

		FlxG.sound.music.stop();
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

		new FlxTimer().start(1.23, function(no:FlxTimer){
			switch(mgList[curSelected][0]) {
				case 'kill bf':
					MinigameState.selectedhi = iconnamearray[curSelectedIcon];
					FreeplayState.destroyFreeplayVocals();
					Paths.setCurrentLevel('shared');
					LoadingState.loadAndSwitchState(new MinigameState('killbf'), true);

				case 'get out of my head':
					var poop:String = Highscore.formatSong('amogus', 1);
					trace(poop);
					PlayState.SONG = Song.loadFromJson('amogus', 'amogus');
					PlayState.storyDifficulty = curDifficulty;
					FreeplayState.destroyFreeplayVocals();
					Paths.setCurrentLevel('shared');
					LoadingState.loadAndSwitchState(new PlayState(), true);

				case 'literally rhds in fnf':
					var poop:String = Highscore.formatSong('built-to-scale', 1);
					trace(poop);
					PlayState.SONG = Song.loadFromJson('built-to-scale', 'built-to-scale');
					PlayState.storyDifficulty = curDifficulty;
					FreeplayState.destroyFreeplayVocals();
					LoadingState.loadAndSwitchState(new PlayState(), true);

				case 'the skeleton appears':
					var poop:String = Highscore.formatSong('fourth-wall', 1);
					trace(poop);
					PlayState.SONG = Song.loadFromJson('fourth-wall', 'fourth-wall');
					PlayState.storyDifficulty = curDifficulty;
					FreeplayState.destroyFreeplayVocals();
					LoadingState.loadAndSwitchState(new PlayState(), true);

				case 'low quality .jpegs are funny':
					var poop:String = Highscore.formatSong('compression', 1);
					trace(poop);
					PlayState.SONG = Song.loadFromJson('compression', 'compression');
					PlayState.storyDifficulty = curDifficulty;
					FreeplayState.destroyFreeplayVocals();
					LoadingState.loadAndSwitchState(new PlayState(), true);

				case 'carlos':
					var poop:String = Highscore.formatSong('carlos', 1);
					trace(poop);
					if (ClientPrefs.lowQuality) PlayState.SONG = Song.loadFromJson('carlos-no-spam', 'carlos');
					else PlayState.SONG = Song.loadFromJson('carlos', 'carlos');
					PlayState.storyDifficulty = curDifficulty;
					FreeplayState.destroyFreeplayVocals();
					LoadingState.loadAndSwitchState(new PlayState(), true);

				default:
					var poop:String = Highscore.formatSong('placeholder', 1);
					trace(poop);
					PlayState.SONG = Song.loadFromJson('placeholder', 'placeholder');
					PlayState.storyDifficulty = curDifficulty;
					FreeplayState.destroyFreeplayVocals();
					LoadingState.loadAndSwitchState(new PlayState(), true);
			}
		});
	}

	function setAllLabelsOffset(button:FlxButton, x:Float, y:Float)
	{
		for (point in button.labelOffsets)
		{
			point.set(x, y);
		}
	}
}