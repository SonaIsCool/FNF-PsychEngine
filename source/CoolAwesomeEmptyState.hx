package;
import flixel.util.FlxTimer;
import flixel.FlxG;

//because putting save data related shit wont work in FlxSplashCustom
class CoolAwesomeEmptyState extends MusicBeatState {
    override public function create()
    {
        super.create();
        new FlxTimer().start(0.5, function(no:FlxTimer){
            FlxG.save.bind('funkin', 'ninjamuffin99');
            trace('loaded save');
            PlayerSettings.init();
            trace('loaded init what the fuck is that');
            ClientPrefs.loadPrefs();
            trace('loaded prefs');
			/*options.GraphicsSettingsSubState.onChangeRes();
            trace('resolution');*/
			Highscore.load();
            trace('loaded highscore');
            FlxG.switchState(new FlxSplashCustom());
        });
    }
}