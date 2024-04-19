package editors;

import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.FlxSprite;

class NoteTypeEditorState extends MusicBeatState {
    public var defaultUIFont:String = 'vcr.ttf';
    var noModsTxt:FlxText;
    override function create() {
        var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
        bg.scrollFactor.set();
        bg.color = 0xFF353535;
        add(bg);
        switch(ClientPrefs.uifont.toLowerCase())
		{
			case 'vcr osd mono': defaultUIFont = 'vcr.ttf';
			case 'pixel arial 11 bold': defaultUIFont = 'pixel.otf';
			case 'comic sans ms': defaultUIFont = 'comicsans.ttf';
			case 'tf2 build': defaultUIFont = 'tf2build.ttf';
			default: defaultUIFont = 'vcr.ttf';
		}
        FlxG.sound.playMusic(Paths.music('offsetSong'), 1, true);
        noModsTxt = new FlxText(0, 0, FlxG.width, "not done yet\nmight take a while to make it", 48);
		noModsTxt.setFormat(Paths.font(defaultUIFont), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		noModsTxt.scrollFactor.set();
		noModsTxt.borderSize = 2;
		add(noModsTxt);
		noModsTxt.screenCenter();
        super.create();
    }
    var noModsSine:Float = 0;
    override function update(elapsed:Float)
    {
        if (FlxG.sound.music.volume < 0.5)
        {
            FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
        }
        if(noModsTxt.visible)
        {
            noModsSine += 180 * elapsed;
            noModsTxt.alpha = 1 - Math.sin((Math.PI * noModsSine) / 180);
        }
        if (controls.BACK)
        {
            FlxG.sound.music.fadeOut(0.45);
            new FlxTimer().start(0.5, function(no:FlxTimer){ FlxG.sound.music.stop(); });
            MusicBeatState.switchState(new MainMenuState());
        }
        super.update(elapsed);
    }
}