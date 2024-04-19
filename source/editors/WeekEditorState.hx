package editors;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.system.FlxSound;
import openfl.utils.Assets;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUITabMenu;
import flixel.ui.FlxButton;
import openfl.net.FileReference;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import flash.net.FileFilter;
import lime.system.Clipboard;
import haxe.Json;
#if sys
import sys.io.File;
import sys.FileSystem;
#end
import WeekData;
import flixel.addons.display.FlxBackdrop;

using StringTools;

class WeekEditorState extends MusicBeatState
{
	var txtWeekTitle:FlxText;
	var bgSprite:FlxSprite;
	var bgYellow:FlxSprite;
	var lock:FlxSprite;
	var txtTracklist:FlxText;
	var grpWeekCharacters:FlxTypedGroup<MenuCharacter>;
	var weekThing:MenuItem;
	var missingFileText:FlxText;

	var weekFile:WeekFile = null;
	public static var changedstate:Bool = false;
	public function new(weekFile:WeekFile = null)
	{
		super();
		this.weekFile = WeekData.createWeekFile();
		if(weekFile != null) this.weekFile = weekFile;
		else weekFileName = 'week1';
	}

	override function create() {
		txtWeekTitle = new FlxText(FlxG.width * 0.7, 10, 0, "", 32);
		txtWeekTitle.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, RIGHT);
		txtWeekTitle.alpha = 0.7;
		
		var ui_tex = Paths.getSparrowAtlas('campaign_menu_UI_assets');
		var bgYellow:FlxSprite = new FlxSprite(0, 56).makeGraphic(FlxG.width, 386, FlxColor.WHITE);
		bgSprite = new FlxSprite(0, 56);
		bgSprite.antialiasing = ClientPrefs.globalAntialiasing;

		weekThing = new MenuItem(0, bgSprite.y + 396, weekFileName);
		weekThing.y += weekThing.height + 20;
		weekThing.antialiasing = ClientPrefs.globalAntialiasing;
		add(weekThing);

		var blackBarThingie:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 56, FlxColor.BLACK);
		add(blackBarThingie);
		
		grpWeekCharacters = new FlxTypedGroup<MenuCharacter>();
		
		lock = new FlxSprite();
		lock.frames = ui_tex;
		lock.animation.addByPrefix('lock', 'lock');
		lock.animation.play('lock');
		lock.antialiasing = ClientPrefs.globalAntialiasing;
		add(lock);
		
		missingFileText = new FlxText(0, 0, FlxG.width, "");
		missingFileText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		missingFileText.borderSize = 2;
		missingFileText.visible = false;
		add(missingFileText); 
		
		var charArray:Array<String> = weekFile.weekCharacters;
		for (char in 0...3)
		{
			var weekCharacterThing:MenuCharacter = new MenuCharacter((FlxG.width * 0.25) * (1 + char) - 150, charArray[char]);
			weekCharacterThing.y += 70;
			grpWeekCharacters.add(weekCharacterThing);
		}

		add(bgYellow);
		add(bgSprite);
		add(grpWeekCharacters);

		var tracksSprite:FlxSprite = new FlxSprite(FlxG.width * 0.07, bgSprite.y + 435).loadGraphic(Paths.image('Menu_Tracks'));
		tracksSprite.antialiasing = ClientPrefs.globalAntialiasing;
		add(tracksSprite);

		txtTracklist = new FlxText(FlxG.width * 0.05, tracksSprite.y + 60, 0, "", 32);
		txtTracklist.alignment = CENTER;
		txtTracklist.font = Paths.font("vcr.ttf");
		txtTracklist.color = 0xFFe55777;
		add(txtTracklist);
		add(txtWeekTitle);

		addEditorBox();
		reloadAllShit();

		FlxG.mouse.visible = true;

		scsR.value = Math.round(save_stupid1);
		scsG.value = Math.round(save_stupid2);
		scsB.value = Math.round(save_stupid3);

		scsR_f.value = Math.round(save_stupid4);
		scsG_f.value = Math.round(save_stupid5);
		scsB_f.value = Math.round(save_stupid6);

		defaultColors(changedstate);
		super.create();
	}

	var UI_box:FlxUITabMenu;
	var blockPressWhileTypingOn:Array<FlxUIInputText> = [];
	function addEditorBox() {
		var tabs = [
			{name: 'Week', label: 'Week'},
			{name: 'Other', label: 'Other'},
		];
		UI_box = new FlxUITabMenu(null, tabs, true);
		UI_box.resize(250, 375);
		UI_box.x = FlxG.width - UI_box.width - 5;
		UI_box.y = FlxG.height - UI_box.height - 5;
		UI_box.scrollFactor.set();
		addWeekUI();
		addOtherUI();
		
		UI_box.selected_tab_id = 'Week';
		add(UI_box);

		var loadWeekButton:FlxButton = new FlxButton(0, 650, "Load Week", function() {
			loadWeek();
		});
		loadWeekButton.screenCenter(X);
		loadWeekButton.x -= 120;
		add(loadWeekButton);
		
		var freeplayButton:FlxButton = new FlxButton(0, 650, "Freeplay", function() {
			changedstate = true;
			MusicBeatState.switchState(new WeekEditorFreeplayState(weekFile));
			
		});
		freeplayButton.screenCenter(X);
		add(freeplayButton);
	
		var saveWeekButton:FlxButton = new FlxButton(0, 650, "Save Week", function() {
			saveWeek(weekFile);
		});
		saveWeekButton.screenCenter(X);
		saveWeekButton.x += 120;
		add(saveWeekButton);
	}

	var songsInputText:FlxUIInputText;
	var backgroundInputText:FlxUIInputText;
	var displayNameInputText:FlxUIInputText;
	var weekNameInputText:FlxUIInputText;
	var weekFileInputText:FlxUIInputText;
	
	var opponentInputText:FlxUIInputText;
	var boyfriendInputText:FlxUIInputText;
	var girlfriendInputText:FlxUIInputText;

	var hideCheckbox:FlxUICheckBox;

	public static var weekFileName:String = 'week1';
	
	function addWeekUI() {
		var tab_group = new FlxUI(null, UI_box);
		tab_group.name = "Week";
		
		songsInputText = new FlxUIInputText(10, 30, 200, '', 8);
		blockPressWhileTypingOn.push(songsInputText);

		opponentInputText = new FlxUIInputText(10, songsInputText.y + 40, 70, '', 8);
		blockPressWhileTypingOn.push(opponentInputText);
		boyfriendInputText = new FlxUIInputText(opponentInputText.x + 75, opponentInputText.y, 70, '', 8);
		blockPressWhileTypingOn.push(boyfriendInputText);
		girlfriendInputText = new FlxUIInputText(boyfriendInputText.x + 75, opponentInputText.y, 70, '', 8);
		blockPressWhileTypingOn.push(girlfriendInputText);

		backgroundInputText = new FlxUIInputText(10, opponentInputText.y + 40, 120, '', 8);
		blockPressWhileTypingOn.push(backgroundInputText);
		

		displayNameInputText = new FlxUIInputText(10, backgroundInputText.y + 60, 200, '', 8);
		blockPressWhileTypingOn.push(backgroundInputText);

		weekNameInputText = new FlxUIInputText(10, displayNameInputText.y + 60, 150, '', 8);
		blockPressWhileTypingOn.push(weekNameInputText);

		weekFileInputText = new FlxUIInputText(10, weekNameInputText.y + 40, 100, '', 8);
		blockPressWhileTypingOn.push(weekFileInputText);
		reloadWeekThing();

		hideCheckbox = new FlxUICheckBox(10, weekFileInputText.y + 40, null, null, "Hide Week from Story Mode?", 100);
		hideCheckbox.callback = function()
		{
			weekFile.hideStoryMode = hideCheckbox.checked;
		};

		tab_group.add(new FlxText(songsInputText.x, songsInputText.y - 18, 0, 'Songs:'));
		tab_group.add(new FlxText(opponentInputText.x, opponentInputText.y - 18, 0, 'Characters:'));
		tab_group.add(new FlxText(backgroundInputText.x, backgroundInputText.y - 18, 0, 'Background Asset:'));
		tab_group.add(new FlxText(displayNameInputText.x, displayNameInputText.y - 18, 0, 'Display Name:'));
		tab_group.add(new FlxText(weekNameInputText.x, weekNameInputText.y - 18, 0, 'Week Name (for Reset Score Menu):'));
		tab_group.add(new FlxText(weekFileInputText.x, weekFileInputText.y - 18, 0, 'Week File:'));

		tab_group.add(songsInputText);
		tab_group.add(opponentInputText);
		tab_group.add(boyfriendInputText);
		tab_group.add(girlfriendInputText);
		tab_group.add(backgroundInputText);

		tab_group.add(displayNameInputText);
		tab_group.add(weekNameInputText);
		tab_group.add(weekFileInputText);
		tab_group.add(hideCheckbox);
		UI_box.addGroup(tab_group);
	}

	var weekBeforeInputText:FlxUIInputText;
	var difficultiesInputText:FlxUIInputText;
	var lockedCheckbox:FlxUICheckBox;
	var hiddenUntilUnlockCheckbox:FlxUICheckBox;

	public static var scsR:FlxUINumericStepper;
	public static var scsG:FlxUINumericStepper;
	public static var scsB:FlxUINumericStepper;
	public static var scsR_f:FlxUINumericStepper;
	public static var scsG_f:FlxUINumericStepper;
	public static var scsB_f:FlxUINumericStepper;

	public static var stupid1:Int = 249;
	public static var stupid2:Int = 207;
	public static var stupid3:Int = 81;
	public static var stupid4:Int = 51;
	public static var stupid5:Int = 255;
	public static var stupid6:Int = 255;

	public static var save_stupid1:Int = 249;
	public static var save_stupid2:Int = 207;
	public static var save_stupid3:Int = 81;
	public static var save_stupid4:Int = 51;
	public static var save_stupid5:Int = 255;
	public static var save_stupid6:Int = 255;
	
	var copyColor:FlxButton;

	function addOtherUI() {
		var tab_group = new FlxUI(null, UI_box);
		tab_group.name = "Other";

		lockedCheckbox = new FlxUICheckBox(10, 30, null, null, "Week starts Locked", 100);
		lockedCheckbox.callback = function()
		{
			weekFile.startUnlocked = !lockedCheckbox.checked;
			lock.visible = lockedCheckbox.checked;
			hiddenUntilUnlockCheckbox.alpha = 0.4 + 0.6 * (lockedCheckbox.checked ? 1 : 0);
		};

		hiddenUntilUnlockCheckbox = new FlxUICheckBox(10, lockedCheckbox.y + 25, null, null, "Hidden until Unlocked", 110);
		hiddenUntilUnlockCheckbox.callback = function()
		{
			weekFile.hiddenUntilUnlocked = hiddenUntilUnlockCheckbox.checked;
		};
		hiddenUntilUnlockCheckbox.alpha = 0.4;

		weekBeforeInputText = new FlxUIInputText(10, hiddenUntilUnlockCheckbox.y + 55, 100, '', 8);
		blockPressWhileTypingOn.push(weekBeforeInputText);

		difficultiesInputText = new FlxUIInputText(10, weekBeforeInputText.y + 60, 200, '', 8);
		blockPressWhileTypingOn.push(difficultiesInputText);
		
		tab_group.add(new FlxText(weekBeforeInputText.x, weekBeforeInputText.y - 28, 0, 'Week File name of the Week you have\nto finish for Unlocking:'));
		tab_group.add(new FlxText(difficultiesInputText.x, difficultiesInputText.y - 20, 0, 'Difficulties:'));
		tab_group.add(new FlxText(difficultiesInputText.x, difficultiesInputText.y + 20, 0, 'Default difficulties are "Easy, Normal, Hard"\nwithout quotes.'));
		tab_group.add(weekBeforeInputText);
		tab_group.add(difficultiesInputText);
		tab_group.add(hiddenUntilUnlockCheckbox);
		tab_group.add(lockedCheckbox);

		
		var funiY:Float = 228;

		scsR = new FlxUINumericStepper(10, funiY, 20, 255, 0, 255, 0);
		scsG = new FlxUINumericStepper(80, funiY, 20, 255, 0, 255, 0);
		scsB = new FlxUINumericStepper(150,funiY, 20, 255, 0, 255, 0);

		tab_group.add(scsR);
		tab_group.add(scsG);
		tab_group.add(scsB);

		scsR_f = new FlxUINumericStepper(10, (scsR.y + scsR.height) + 30, 20, 255, 0, 255, 0);
		scsG_f = new FlxUINumericStepper(80, (scsR.y + scsR.height) + 30, 20, 255, 0, 255, 0);
		scsB_f = new FlxUINumericStepper(150,(scsR.y + scsR.height) + 30, 20, 255, 0, 255, 0);

		tab_group.add(scsR_f);
		tab_group.add(scsG_f);
		tab_group.add(scsB_f);

		if(weekFile.storyColor == null) // aka it doesnt exist
		{
			weekFile.storyColor = [249, 207, 81];
		}
		weekFile.storyColor[0] = Math.round(scsR.value);
		weekFile.storyColor[1] = Math.round(scsG.value);
		weekFile.storyColor[2] = Math.round(scsB.value);
		scsR.value = Math.round(weekFile.storyColor[0]);
		scsG.value = Math.round(weekFile.storyColor[1]);
		scsB.value = Math.round(weekFile.storyColor[2]);
		
		if(weekFile.storyFlashColor == null) // aka it doesnt exist
		{
			weekFile.storyFlashColor = [51, 255, 255];
		}
		weekFile.storyFlashColor[0] = Math.round(scsR_f.value);
		weekFile.storyFlashColor[1] = Math.round(scsG_f.value);
		weekFile.storyFlashColor[2] = Math.round(scsB_f.value);
		scsR_f.value = Math.round(weekFile.storyFlashColor[0]);
		scsG_f.value = Math.round(weekFile.storyFlashColor[1]);
		scsB_f.value = Math.round(weekFile.storyFlashColor[2]);
		//updateColorShit();
		//updateFlashy();
		tab_group.add(new FlxText(scsR.x, scsR.y - 20, 0, 'Campaign BG Color:'));
		tab_group.add(new FlxText(scsR_f.x, scsR_f.y - 20, 0, 'Campaign Title Flash Color:'));

		var thing:FlxButton = new FlxButton(10, (scsR_f.y + scsR_f.height) + 15, "Default Colors", function() {
			defaultColors(false);
		});
		/*var thing2:FlxButton = new FlxButton(thing.x + 120, (scsR_f.y + scsR_f.height) + 15, "Autosaved Colors", function() {
			defaultColors(true);
		});*/
		var pasteColor:FlxButton = new FlxButton(thing.x + 150, (scsR_f.y + scsR_f.height) + 30, "Paste Colors", function() {
			if(Clipboard.text != null) {
				var leColor:Array<Int> = [];
				var splitted:Array<String> = Clipboard.text.trim().split(',');
				for (i in 0...splitted.length) {
					var toPush:Int = Std.parseInt(splitted[i]);
					if(!Math.isNaN(toPush)) {
						if(toPush > 255) toPush = 255;
						else if(toPush < 0) toPush *= -1;
						leColor.push(toPush);
					}
				}

				if(leColor.length > 2) {
					scsR.value = leColor[0]; // if you want to use freeplay colors in story mode and viceversa
					scsG.value = leColor[1];
					scsB.value = leColor[2];
					if(leColor.length > 5) {
						scsR_f.value = leColor[3];
						scsG_f.value = leColor[4];
						scsB_f.value = leColor[5];
					}
					updateColorShit();
					updateFlashy();
				}
			}
		});
		copyColor = new FlxButton(pasteColor.x, pasteColor.y - pasteColor.height, "Copy Colors", function() {
			Clipboard.text = '${scsR.value},${scsG.value},${scsB.value},${scsR_f.value},${scsG_f.value},${scsB_f.value}';
		});

		tab_group.add(thing);
		tab_group.add(copyColor);
		tab_group.add(pasteColor);

		UI_box.addGroup(tab_group);
	}
	function updateColorShit()
	{
		save_stupid1 = Math.round(scsR.value);
		save_stupid2 = Math.round(scsG.value);
		save_stupid3 = Math.round(scsB.value);
		if(weekFile.storyColor != null) {
			weekFile.storyColor[0] = Math.round(scsR.value);
			weekFile.storyColor[1] = Math.round(scsG.value);
			weekFile.storyColor[2] = Math.round(scsB.value);

			if (bgYellow != null) bgYellow.color = FlxColor.fromRGB(Std.int(scsR.value), Std.int(scsG.value), Std.int(scsB.value));
			if (bgSprite != null) bgSprite.color = FlxColor.fromRGB(Std.int(scsR.value), Std.int(scsG.value), Std.int(scsB.value));
			for (bruj in 0...grpWeekCharacters.length)
			{
				if (grpWeekCharacters.members[bruj] != null) grpWeekCharacters.members[bruj].color = FlxColor.fromRGB(Std.int(scsR.value), Std.int(scsG.value), Std.int(scsB.value));
			}

			scsR.value = Math.round(weekFile.storyColor[0]);
			scsG.value = Math.round(weekFile.storyColor[1]);
			scsB.value = Math.round(weekFile.storyColor[2]);
		}
		else
		{
			weekFile.storyColor[0] = stupid1;
			weekFile.storyColor[1] = stupid2;
			weekFile.storyColor[2] = stupid3;
			
			if (bgYellow != null) bgYellow.color = FlxColor.fromRGB(Std.int(scsR.value), Std.int(scsG.value), Std.int(scsB.value));
			if (bgSprite != null) bgSprite.color = FlxColor.fromRGB(Std.int(scsR.value), Std.int(scsG.value), Std.int(scsB.value));
			for (bruj in 0...grpWeekCharacters.length)
			{
				if (grpWeekCharacters.members[bruj] != null) grpWeekCharacters.members[bruj].color = FlxColor.fromRGB(Std.int(scsR.value), Std.int(scsG.value), Std.int(scsB.value));
			}

			scsR.value = Math.round(weekFile.storyColor[0]);
			scsG.value = Math.round(weekFile.storyColor[1]);
			scsB.value = Math.round(weekFile.storyColor[2]);
		}
		/*save_stupid1 = Math.round(weekFile.storyColor[0]);
		save_stupid2 = Math.round(weekFile.storyColor[1]);
		save_stupid3 = Math.round(weekFile.storyColor[2]);*/
	}

	function updateFlashy()
	{
		save_stupid4 = Math.round(scsR_f.value);
		save_stupid5 = Math.round(scsG_f.value);
		save_stupid6 = Math.round(scsB_f.value);
		if(weekFile.storyFlashColor != null) {
			weekFile.storyFlashColor[0] = Math.round(scsR_f.value);
			weekFile.storyFlashColor[1] = Math.round(scsG_f.value);
			weekFile.storyFlashColor[2] = Math.round(scsB_f.value);

			weekThing.flashColor = FlxColor.fromRGB(Std.int(scsR_f.value), Std.int(scsG_f.value), Std.int(scsB_f.value));

			scsR_f.value = Math.round(weekFile.storyFlashColor[0]);
			scsG_f.value = Math.round(weekFile.storyFlashColor[1]);
			scsB_f.value = Math.round(weekFile.storyFlashColor[2]);
		}
		else
		{
			weekFile.storyFlashColor[0] = stupid4;
			weekFile.storyFlashColor[1] = stupid5;
			weekFile.storyFlashColor[2] = stupid6;

			weekThing.flashColor = FlxColor.fromRGB(Std.int(scsR_f.value), Std.int(scsG_f.value), Std.int(scsB_f.value));

			scsR_f.value = Math.round(weekFile.storyFlashColor[0]);
			scsG_f.value = Math.round(weekFile.storyFlashColor[1]);
			scsB_f.value = Math.round(weekFile.storyFlashColor[2]);
		}
	}
	function defaultColors(uhh:Bool = false) {
		if (!uhh) {
			scsR.value = stupid1;
			scsG.value = stupid2;
			scsB.value = stupid3;

			scsR_f.value = stupid4;
			scsG_f.value = stupid5;
			scsB_f.value = stupid6;

			weekFile.storyColor[0] = Math.round(scsR.value);
			weekFile.storyColor[1] = Math.round(scsG.value);
			weekFile.storyColor[2] = Math.round(scsB.value);

			weekFile.storyFlashColor[0] = Math.round(scsR_f.value);
			weekFile.storyFlashColor[1] = Math.round(scsG_f.value);
			weekFile.storyFlashColor[2] = Math.round(scsB_f.value);
		} else {
			scsR.value = save_stupid1;
			scsG.value = save_stupid2;
			scsB.value = save_stupid3;

			scsR_f.value = save_stupid4;
			scsG_f.value = save_stupid5;
			scsB_f.value = save_stupid6;

			weekFile.storyColor[0] = Math.round(scsR.value);
			weekFile.storyColor[1] = Math.round(scsG.value);
			weekFile.storyColor[2] = Math.round(scsB.value);

			weekFile.storyFlashColor[0] = Math.round(scsR_f.value);
			weekFile.storyFlashColor[1] = Math.round(scsG_f.value);
			weekFile.storyFlashColor[2] = Math.round(scsB_f.value);

			save_stupid1 = Math.round(weekFile.storyColor[0]);
			save_stupid2 = Math.round(weekFile.storyColor[1]);
			save_stupid3 = Math.round(weekFile.storyColor[2]);

			save_stupid4 = Math.round(weekFile.storyFlashColor[0]);
			save_stupid5 = Math.round(weekFile.storyFlashColor[1]);
			save_stupid6 = Math.round(weekFile.storyFlashColor[2]);
		}
		updateColorShit();
		updateFlashy();
	}
	//Used on onCreate and when you load a week
	function reloadAllShit() {
		var weekString:String = weekFile.songs[0][0];
		for (i in 1...weekFile.songs.length) {
			weekString += ', ' + weekFile.songs[i][0];
		}
		songsInputText.text = weekString;
		backgroundInputText.text = weekFile.weekBackground;
		displayNameInputText.text = weekFile.storyName;
		weekNameInputText.text = weekFile.weekName;
		weekFileInputText.text = weekFileName;
		
		opponentInputText.text = weekFile.weekCharacters[0];
		boyfriendInputText.text = weekFile.weekCharacters[1];
		girlfriendInputText.text = weekFile.weekCharacters[2];

		hideCheckbox.checked = weekFile.hideStoryMode;

		weekBeforeInputText.text = weekFile.weekBefore;

		difficultiesInputText.text = '';
		if(weekFile.difficulties != null) difficultiesInputText.text = weekFile.difficulties;

		lockedCheckbox.checked = !weekFile.startUnlocked;
		lock.visible = lockedCheckbox.checked;
		
		hiddenUntilUnlockCheckbox.checked = weekFile.hiddenUntilUnlocked;
		hiddenUntilUnlockCheckbox.alpha = 0.4 + 0.6 * (lockedCheckbox.checked ? 1 : 0);

		scsR.value = stupid1;
		scsG.value = stupid2;
		scsB.value = stupid3;

		scsR_f.value = stupid4;
		scsG_f.value = stupid5;
		scsB_f.value = stupid6;

		if(weekFile.storyColor != null) {
			/*weekFile.storyColor[0] = Math.round(scsR.value);
			weekFile.storyColor[1] = Math.round(scsG.value);
			weekFile.storyColor[2] = Math.round(scsB.value);*/
			scsR.value = Math.round(weekFile.storyColor[0]);
			scsG.value = Math.round(weekFile.storyColor[1]);
			scsB.value = Math.round(weekFile.storyColor[2]);
		}

		if(weekFile.storyFlashColor != null) {
			/*weekFile.storyFlashColor[0] = Math.round(scsR_f.value);
			weekFile.storyFlashColor[1] = Math.round(scsG_f.value);
			weekFile.storyFlashColor[2] = Math.round(scsB_f.value);*/
			scsR_f.value = Math.round(weekFile.storyFlashColor[0]);
			scsG_f.value = Math.round(weekFile.storyFlashColor[1]);
			scsB_f.value = Math.round(weekFile.storyFlashColor[2]);
		}

		updateColorShit();
		updateFlashy();

		reloadBG();
		reloadWeekThing();
		updateText();
	}

	function updateText()
	{
		for (i in 0...grpWeekCharacters.length) {
			grpWeekCharacters.members[i].changeCharacter(weekFile.weekCharacters[i]);
		}

		var stringThing:Array<String> = [];
		for (i in 0...weekFile.songs.length) {
			stringThing.push(weekFile.songs[i][0]);
		}

		txtTracklist.text = '';
		for (i in 0...stringThing.length)
		{
			txtTracklist.text += stringThing[i] + '\n';
		}

		txtTracklist.text = txtTracklist.text.toUpperCase();

		txtTracklist.screenCenter(X);
		txtTracklist.x -= FlxG.width * 0.35;
		
		txtWeekTitle.text = weekFile.storyName.toUpperCase();
		txtWeekTitle.x = FlxG.width - (txtWeekTitle.width + 10);
	}

	function reloadBG() {
		bgSprite.visible = true;
		var assetName:String = weekFile.weekBackground;

		var isMissing:Bool = true;
		if(assetName != null && assetName.length > 0) {
			if( #if MODS_ALLOWED FileSystem.exists(Paths.modsImages('menubackgrounds/menu_' + assetName)) || #end
			Assets.exists(Paths.getPath('images/menubackgrounds/menu_' + assetName + '.png', IMAGE), IMAGE)) {
				bgSprite.loadGraphic(Paths.image('menubackgrounds/menu_' + assetName));
				isMissing = false;
			}
		}

		if(isMissing) {
			bgSprite.visible = false;
		}
	}

	function reloadWeekThing() {
		weekThing.visible = true;
		missingFileText.visible = false;
		var assetName:String = weekFileInputText.text.trim();
		
		var isMissing:Bool = true;
		if(assetName != null && assetName.length > 0) {
			if( #if MODS_ALLOWED FileSystem.exists(Paths.modsImages('storymenu/' + assetName)) || #end
			Assets.exists(Paths.getPath('images/storymenu/' + assetName + '.png', IMAGE), IMAGE)) {
				weekThing.loadGraphic(Paths.image('storymenu/' + assetName));
				isMissing = false;
			}
		}

		if(isMissing) {
			weekThing.visible = false;
			missingFileText.visible = true;
			missingFileText.text = 'MISSING FILE: images/storymenu/' + assetName + '.png';
		}
		recalculateStuffPosition();

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Week Editor", "Editing: " + weekFileName);
		#end
	}
	
	override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>) {
		if(id == FlxUIInputText.CHANGE_EVENT && (sender is FlxUIInputText)) {
			if(sender == weekFileInputText) {
				weekFileName = weekFileInputText.text.trim();
				reloadWeekThing();
			} else if(sender == opponentInputText || sender == boyfriendInputText || sender == girlfriendInputText) {
				weekFile.weekCharacters[0] = opponentInputText.text.trim();
				weekFile.weekCharacters[1] = boyfriendInputText.text.trim();
				weekFile.weekCharacters[2] = girlfriendInputText.text.trim();
				updateText();
			} else if(sender == backgroundInputText) {
				weekFile.weekBackground = backgroundInputText.text.trim();
				reloadBG();
			} else if(sender == displayNameInputText) {
				weekFile.storyName = displayNameInputText.text.trim();
				updateText();
			} else if(sender == weekNameInputText) {
				weekFile.weekName = weekNameInputText.text.trim();
			} else if(sender == songsInputText) {
				var splittedText:Array<String> = songsInputText.text.trim().split(',');
				for (i in 0...splittedText.length) {
					splittedText[i] = splittedText[i].trim();
				}

				while(splittedText.length < weekFile.songs.length) {
					weekFile.songs.pop();
				}

				for (i in 0...splittedText.length) {
					if(i >= weekFile.songs.length) { //Add new song
						weekFile.songs.push([splittedText[i], 'dad', [146, 113, 253]]);
					} else { //Edit song
						weekFile.songs[i][0] = splittedText[i];
						if(weekFile.songs[i][1] == null || weekFile.songs[i][1]) {
							weekFile.songs[i][1] = 'dad';
							weekFile.songs[i][2] = [146, 113, 253];
						}
					}
				}
				updateText();
			} else if(sender == weekBeforeInputText) {
				weekFile.weekBefore = weekBeforeInputText.text.trim();
			} else if(sender == difficultiesInputText) {
				weekFile.difficulties = difficultiesInputText.text.trim();
			}
		} else if(id == FlxUINumericStepper.CHANGE_EVENT && (sender is FlxUINumericStepper)) {
			if(sender == scsR || sender == scsG || sender == scsB) {
				updateColorShit();
			} else if(sender == scsR_f || sender == scsG_f || sender == scsB_f) {
				updateFlashy();
			} 
		}
	}
	
	var elapsedtime:Float = 0;
	override function update(elapsed:Float)
	{
		elapsedtime += elapsed;

		if(loadedWeek != null) {
			weekFile = loadedWeek;
			loadedWeek = null;

			reloadAllShit();
		}

		var blockInput:Bool = false;
		for (inputText in blockPressWhileTypingOn) {
			if(inputText.hasFocus) {
				FlxG.sound.muteKeys = [];
				FlxG.sound.volumeDownKeys = [];
				FlxG.sound.volumeUpKeys = [];
				blockInput = true;

				if(FlxG.keys.justPressed.ENTER) inputText.hasFocus = false;
				break;
			}
		}

		copyColor.offset.set(FlxG.random.float(-2, 2), FlxG.random.float(-2, 2));
		copyColor.angle = FlxG.random.float(-2, 2);
		copyColor.label.angle = copyColor.angle;
		copyColor.label.offset.copyFrom(copyColor.offset);

		if(!blockInput) {
			FlxG.sound.muteKeys = TitleState.muteKeys;
			FlxG.sound.volumeDownKeys = TitleState.volumeDownKeys;
			FlxG.sound.volumeUpKeys = TitleState.volumeUpKeys;
			if(FlxG.keys.justPressed.ESCAPE) {
				MusicBeatState.switchState(new editors.MasterEditorMenu());
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
			}
		}

		if (elapsedtime > 0.5) {
			save_stupid1 = Math.round(weekFile.storyColor[0]);
			save_stupid2 = Math.round(weekFile.storyColor[1]);
			save_stupid3 = Math.round(weekFile.storyColor[2]);

			save_stupid4 = Math.round(weekFile.storyFlashColor[0]);
			save_stupid5 = Math.round(weekFile.storyFlashColor[1]);
			save_stupid6 = Math.round(weekFile.storyFlashColor[2]);

			//trace('$save_stupid1, $save_stupid2, $save_stupid3, $save_stupid4, $save_stupid5, $save_stupid6');

			/*lock.y = weekThing.y;
			missingFileText.y = weekThing.y + 36;
			missingFileText.color = weekThing.color;*/
		}
		//trace(elapsed);

		lock.y = weekThing.y;
		missingFileText.y = weekThing.y + 36;
		missingFileText.color = weekThing.color;
		if(controls.ACCEPT)
		{
			weekThing.startFlashing();
			if(weekThing.isFlashing) FlxG.sound.play(Paths.sound('confirmMenu'));
			else {
				FlxG.sound.play(Paths.sound('cancelMenu'));
				weekThing.color = FlxColor.WHITE;
			}
		}
		super.update(elapsed);
	}

	function recalculateStuffPosition() {
		weekThing.screenCenter(X);
		lock.x = weekThing.width + 10 + weekThing.x;
	}

	private static var _file:FileReference;
	public static function loadWeek() {
		var jsonFilter:FileFilter = new FileFilter('JSON', 'json');
		_file = new FileReference();
		_file.addEventListener(Event.SELECT, onLoadComplete);
		_file.addEventListener(Event.CANCEL, onLoadCancel);
		_file.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
		_file.browse([jsonFilter]);
	}
	
	public static var loadedWeek:WeekFile = null;
	public static var loadError:Bool = false;
	private static function onLoadComplete(_):Void
	{
		_file.removeEventListener(Event.SELECT, onLoadComplete);
		_file.removeEventListener(Event.CANCEL, onLoadCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);

		#if sys
		var fullPath:String = null;
		@:privateAccess
		if(_file.__path != null) fullPath = _file.__path;

		if(fullPath != null) {
			var rawJson:String = File.getContent(fullPath);
			if(rawJson != null) {
				loadedWeek = cast Json.parse(rawJson);
				if(loadedWeek.weekCharacters != null && loadedWeek.weekName != null) //Make sure it's really a week
				{
					var cutName:String = _file.name.substr(0, _file.name.length - 5);
					trace("Successfully loaded file: " + cutName);
					loadError = false;

					weekFileName = cutName;
					_file = null;
					return;
				}
			}
		}
		loadError = true;
		loadedWeek = null;
		_file = null;
		#else
		trace("File couldn't be loaded! You aren't on Desktop, are you?");
		#end
	}

	/**
		* Called when the save file dialog is cancelled.
		*/
		private static function onLoadCancel(_):Void
	{
		_file.removeEventListener(Event.SELECT, onLoadComplete);
		_file.removeEventListener(Event.CANCEL, onLoadCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
		_file = null;
		trace("Cancelled file loading.");
	}

	/**
		* Called if there is an error while saving the gameplay recording.
		*/
	private static function onLoadError(_):Void
	{
		_file.removeEventListener(Event.SELECT, onLoadComplete);
		_file.removeEventListener(Event.CANCEL, onLoadCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
		_file = null;
		trace("Problem loading file");
	}

	public static function saveWeek(weekFile:WeekFile) {
		var data:String = Json.stringify(weekFile, "\t");
		if (data.length > 0)
		{
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data, weekFileName + ".json");
		}
	}
	
	private static function onSaveComplete(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.notice("Successfully saved file.");
	}

	/**
		* Called when the save file dialog is cancelled.
		*/
		private static function onSaveCancel(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
	}

	/**
		* Called if there is an error while saving the gameplay recording.
		*/
	private static function onSaveError(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.error("Problem saving file");
	}
}

class WeekEditorFreeplayState extends MusicBeatState
{
	var weekFile:WeekFile = null;
	public function new(weekFile:WeekFile = null)
	{
		super();
		this.weekFile = WeekData.createWeekFile();
		if(weekFile != null) this.weekFile = weekFile;
	}

	var bg:FlxSprite;
	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var iconArray:Array<HealthIcon> = [];

	var curSelected = 0;

	var checker:FlxBackdrop = new FlxBackdrop(Paths.image('coolCheckerWeStoleFromMicdUpLol'), 0.2, 0.2, true, true);
	override function create() {
		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.antialiasing = ClientPrefs.globalAntialiasing;

		bg.color = FlxColor.WHITE;
		add(bg);

		checker.velocity.x = -100;
		checker.velocity.y = -50;
		checker.color = bg.color;
		add(checker);

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...weekFile.songs.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, weekFile.songs[i][0], true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpSongs.add(songText);

			if (songText.width > 980)
			{
				var textScale:Float = 980 / songText.width;
				songText.scale.x = textScale;
				for (letter in songText.lettersArray)
				{
					letter.x *= textScale;
					letter.offset.x *= textScale;
				}
				//songText.updateHitbox();
				//trace(songs[i].songName + ' new scale: ' + textScale);
			}

			var icon:HealthIcon = new HealthIcon(weekFile.songs[i][1]);
			icon.sprTracker = songText;
			icon.offsetX = songText.width + 10;
			icon.offsetY = -30;

			// using a FlxGroup is too much fuss!
			iconArray.push(icon);
			add(icon);

			// songText.x += 40;
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			// songText.screenCenter(X);
		}

		addEditorBox();
		changeSelection();
		super.create();
	}
	
	var UI_box:FlxUITabMenu;
	var blockPressWhileTypingOn:Array<FlxUIInputText> = [];
	function addEditorBox() {
		var tabs = [
			{name: 'Freeplay', label: 'Freeplay'},
		];
		UI_box = new FlxUITabMenu(null, tabs, true);
		UI_box.resize(250, 200);
		UI_box.x = FlxG.width - UI_box.width - 100;
		UI_box.y = FlxG.height - UI_box.height - 60;
		UI_box.scrollFactor.set();
		
		UI_box.selected_tab_id = 'Week';
		addFreeplayUI();
		add(UI_box);

		var blackBlack:FlxSprite = new FlxSprite(0, 670).makeGraphic(FlxG.width, 50, FlxColor.BLACK);
		blackBlack.alpha = 0.6;
		add(blackBlack);

		var loadWeekButton:FlxButton = new FlxButton(0, 685, "Load Week", function() {
			WeekEditorState.loadWeek();
		});
		loadWeekButton.screenCenter(X);
		loadWeekButton.x -= 120;
		add(loadWeekButton);
		
		var storyModeButton:FlxButton = new FlxButton(0, 685, "Story Mode", function() {
			MusicBeatState.switchState(new WeekEditorState(weekFile));
			
		});
		storyModeButton.screenCenter(X);
		add(storyModeButton);
	
		var saveWeekButton:FlxButton = new FlxButton(0, 685, "Save Week", function() {
			WeekEditorState.saveWeek(weekFile);
		});
		saveWeekButton.screenCenter(X);
		saveWeekButton.x += 120;
		add(saveWeekButton);
	}
	
	override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>) {
		if(id == FlxUIInputText.CHANGE_EVENT && (sender is FlxUIInputText)) {
			weekFile.songs[curSelected][1] = iconInputText.text;
			iconArray[curSelected].changeIcon(iconInputText.text);
		} else if(id == FlxUINumericStepper.CHANGE_EVENT && (sender is FlxUINumericStepper)) {
			if(sender == bgColorStepperR || sender == bgColorStepperG || sender == bgColorStepperB) {
				updateBG();
			}
		}
	}

	var bgColorStepperR:FlxUINumericStepper;
	var bgColorStepperG:FlxUINumericStepper;
	var bgColorStepperB:FlxUINumericStepper;
	var iconInputText:FlxUIInputText;
	function addFreeplayUI() {
		var tab_group = new FlxUI(null, UI_box);
		tab_group.name = "Freeplay";

		bgColorStepperR = new FlxUINumericStepper(10, 40, 20, 255, 0, 255, 0);
		bgColorStepperG = new FlxUINumericStepper(80, 40, 20, 255, 0, 255, 0);
		bgColorStepperB = new FlxUINumericStepper(150, 40, 20, 255, 0, 255, 0);

		var copyColor:FlxButton = new FlxButton(10, bgColorStepperR.y + 25, "Copy Color", function() {
			Clipboard.text = bg.color.red + ',' + bg.color.green + ',' + bg.color.blue;
		});
		var pasteColor:FlxButton = new FlxButton(140, copyColor.y, "Paste Color", function() {
			if(Clipboard.text != null) {
				var leColor:Array<Int> = [];
				var splitted:Array<String> = Clipboard.text.trim().split(',');
				for (i in 0...splitted.length) {
					var toPush:Int = Std.parseInt(splitted[i]);
					if(!Math.isNaN(toPush)) {
						if(toPush > 255) toPush = 255;
						else if(toPush < 0) toPush *= -1;
						leColor.push(toPush);
					}
				}

				if(leColor.length > 2) {
					bgColorStepperR.value = leColor[0];
					bgColorStepperG.value = leColor[1];
					bgColorStepperB.value = leColor[2];
					updateBG();
				}
			}
		});
		var iconColor:FlxButton = new FlxButton(pasteColor.x, bgColorStepperR.y + 70, "Get Icon Color", function() {
				var leColor:Array<Int> = [];
				var coolColor = FlxColor.fromInt(CoolUtil.dominantColor(iconArray[curSelected]));
				leColor.push(coolColor.red);
				leColor.push(coolColor.green);
				leColor.push(coolColor.blue);

				if(leColor.length > 2) {
					bgColorStepperR.value = leColor[0];
					bgColorStepperG.value = leColor[1];
					bgColorStepperB.value = leColor[2];
					updateBG();
				}
		});

		iconInputText = new FlxUIInputText(10, bgColorStepperR.y + 70, 100, '', 8);

		var hideFreeplayCheckbox:FlxUICheckBox = new FlxUICheckBox(10, iconInputText.y + 30, null, null, "Hide Week from Freeplay?", 100);
		hideFreeplayCheckbox.checked = weekFile.hideFreeplay;
		hideFreeplayCheckbox.callback = function()
		{
			weekFile.hideFreeplay = hideFreeplayCheckbox.checked;
		};
		
		tab_group.add(new FlxText(10, bgColorStepperR.y - 18, 0, 'Selected background Color R/G/B:'));
		tab_group.add(new FlxText(10, iconInputText.y - 18, 0, 'Selected icon:'));
		tab_group.add(bgColorStepperR);
		tab_group.add(bgColorStepperG);
		tab_group.add(bgColorStepperB);
		tab_group.add(copyColor);
		tab_group.add(pasteColor);
		tab_group.add(iconColor);
		tab_group.add(iconInputText);
		tab_group.add(hideFreeplayCheckbox);
		UI_box.addGroup(tab_group);
	}

	function updateBG() {
		weekFile.songs[curSelected][2][0] = Math.round(bgColorStepperR.value);
		weekFile.songs[curSelected][2][1] = Math.round(bgColorStepperG.value);
		weekFile.songs[curSelected][2][2] = Math.round(bgColorStepperB.value);
		bg.color = FlxColor.fromRGB(weekFile.songs[curSelected][2][0], weekFile.songs[curSelected][2][1], weekFile.songs[curSelected][2][2]);
	}

	function changeSelection(change:Int = 0) {
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = weekFile.songs.length - 1;
		if (curSelected >= weekFile.songs.length)
			curSelected = 0;

		var bullShit:Int = 0;
		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.6;
		}

		iconArray[curSelected].alpha = 1;

		for (item in grpSongs.members)
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
		trace(weekFile.songs[curSelected]);
		iconInputText.text = weekFile.songs[curSelected][1];
		bgColorStepperR.value = Math.round(weekFile.songs[curSelected][2][0]);
		bgColorStepperG.value = Math.round(weekFile.songs[curSelected][2][1]);
		bgColorStepperB.value = Math.round(weekFile.songs[curSelected][2][2]);
		updateBG();
	}

	var canshowcolor:Bool = false;
	override function update(elapsed:Float) {
		checker.color = bg.color;

		if(FlxG.keys.justPressed.SPACE) canshowcolor = !canshowcolor;

		if (canshowcolor)
		{
			var coolColor = FlxColor.fromInt(CoolUtil.dominantColor(iconArray[curSelected]));
			grpSongs.members[curSelected].color = FlxColor.fromRGB(coolColor.red, coolColor.green, coolColor.blue);
		}
		else
		{
			grpSongs.members[curSelected].color = FlxColor.WHITE;
		}

		if(WeekEditorState.loadedWeek != null) {
			super.update(elapsed);
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			MusicBeatState.switchState(new WeekEditorFreeplayState(WeekEditorState.loadedWeek));
			WeekEditorState.loadedWeek = null;
			return;
		}
		
		if(iconInputText.hasFocus) {
			FlxG.sound.muteKeys = [];
			FlxG.sound.volumeDownKeys = [];
			FlxG.sound.volumeUpKeys = [];
			if(FlxG.keys.justPressed.ENTER) {
				iconInputText.hasFocus = false;
			}
		} else {
			FlxG.sound.muteKeys = TitleState.muteKeys;
			FlxG.sound.volumeDownKeys = TitleState.volumeDownKeys;
			FlxG.sound.volumeUpKeys = TitleState.volumeUpKeys;
			if(FlxG.keys.justPressed.ESCAPE) {
				MusicBeatState.switchState(new editors.MasterEditorMenu());
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
			}

			if(controls.UI_UP_P || FlxG.mouse.wheel == 1) changeSelection(-1);
			if(controls.UI_DOWN_P || FlxG.mouse.wheel == -1) changeSelection(1);
		}
		super.update(elapsed);
	}
}
