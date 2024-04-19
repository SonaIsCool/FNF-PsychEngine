package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

class CheckboxThingie extends FlxSprite
{
	public var sprTracker:FlxSprite;
	public var daValue(default, set):Bool;
	public var copyAlpha:Bool = true;
	public var offsetX:Float = 0;
	public var offsetY:Float = 0;
	public var hueshiftenabled:Bool = false;
	public var huetouse:Int = 0;
	public function new(x:Float = 0, y:Float = 0, ?checked = false, ?canbehued:Bool = false, ?randomhue:Bool = true) {
		super(x, y);

		if (canbehued) frames = Paths.getSparrowAtlas('checkbox but red');
		else frames = Paths.getSparrowAtlas('checkboxanim');
		animation.addByPrefix("unchecked", "checkbox0", 24, false);
		animation.addByPrefix("unchecking", "checkbox anim reverse", 24, false);
		animation.addByPrefix("checking", "checkbox anim0", 24, false);
		animation.addByPrefix("checked", "checkbox finish", 24, false);

		antialiasing = ClientPrefs.globalAntialiasing;
		setGraphicSize(Std.int(0.9 * width));
		updateHitbox();
		this.hueshiftenabled = canbehued;
		animationFinished(checked ? 'checking' : 'unchecking');
		animation.finishCallback = animationFinished;
		daValue = checked;

		if(canbehued)
		{
			var newShader:ColorSwap = new ColorSwap();
			if (!randomhue) newShader.hue = huetouse / 360;
			else newShader.hue = FlxG.random.int(-180, 180) / 360;
			this.shader = newShader.shader;
		}
	}

	override function update(elapsed:Float) {
		if (sprTracker != null) {
			setPosition(sprTracker.x - 130 + offsetX, sprTracker.y + 30 + offsetY);
			if(copyAlpha) {
				alpha = sprTracker.alpha;
			}
		}
		super.update(elapsed);
	}

	private function set_daValue(check:Bool):Bool {
		if(check) {
			if(animation.curAnim.name != 'checked' && animation.curAnim.name != 'checking') {
				animation.play('checking', true);
				offset.set(34, 25);
			}
		} else if(animation.curAnim.name != 'unchecked' && animation.curAnim.name != 'unchecking') {
			animation.play("unchecking", true);
			offset.set(25, 28);
		}
		return check;
	}

	private function animationFinished(name:String)
	{
		switch(name)
		{
			case 'checking':
				animation.play('checked', true);
				offset.set(3, 12);

			case 'unchecking':
				animation.play('unchecked', true);
				offset.set(0, 2);
		}
	}
}