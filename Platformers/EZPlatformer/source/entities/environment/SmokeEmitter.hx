package entities.environment;

import entities.environment.SmokeEmitter.SmokeParticle;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.effects.particles.FlxEmitter.FlxEmitterMode;
import flixel.effects.particles.FlxEmitter.FlxTypedEmitter;
import flixel.effects.particles.FlxParticle;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxSpriteUtil.LineStyle;

/**
 * Copyright Sam Twidale (https://samcodes.co.uk) and Joe Williamson (https://joecreates.co.uk/)
 */
class SmokeParticle extends FlxParticle {
	
	public var deviationX:Float;
	public var baseScale:Float = 2;
	public var minScale:Float = 0.3;
	
	public function new() {
		super();
		initGraphic();
	}
	
	public function initGraphic() {
		generateGraphic("smoke", 0xff4c424e, 0xff38333c);
	}
	
	public function generateGraphic(name:String, lightColor:FlxColor, shadowColor:FlxColor):String {
		var r:Float = 16;
		var w:Float = r;
		var h:Float = r;
		
		if (FlxG.bitmap.checkCache(name)) {
			loadGraphic(name);
		} else {
			makeGraphic(Std.int(w), Std.int(h), 0, false, name);
			
			var gs:FlxSprite = new FlxSprite();
			gs.makeGraphic(Std.int(w), Std.int(h), 0, true);
			
			var mask:FlxSprite = new FlxSprite();
			mask.makeGraphic(Std.int(w), Std.int(h), 0, true);
			
			
			var lineStyle:LineStyle = {
				thickness: 0,
				color: 0,
				pixelHinting: false
			};
			
			FlxSpriteUtil.drawCircle(mask, -1, -1, w / 2, 0xff000000, lineStyle, {smoothing: false});
			FlxSpriteUtil.drawCircle(gs, -1, -1, w / 2, shadowColor, lineStyle, {smoothing: false});
			FlxSpriteUtil.drawCircle(gs, w * 0.2, w * 0.15, w / 2, lightColor, lineStyle, {smoothing: false});
			FlxSpriteUtil.alphaMaskFlxSprite(gs, mask, this);
		}
		
		return name;
	}
	
	override public function update(dt:Float):Void {
		super.update(dt);
		offset.x = deviationX * percent;
		var t = smokeEase(percent);
		var s = FlxMath.lerp(minScale, baseScale, t);
		scale.set(s, s);
	}
	
	public static function smokeEase(t:Float):Float {
		if (t < 0.7) {
			return FlxEase.quadOut(t / 0.7);
		} else {
			return FlxEase.quadIn(1 - (t - 0.7) / 0.3);
		}
	}
	
	private function sin(a:Float) {return Math.sin(a * FlxAngle.TO_RAD);}
	private function cos(a:Float) {return Math.cos(a * FlxAngle.TO_RAD);}
}

class SmokeEmitter extends FlxTypedEmitter<SmokeParticle> {
	public var minXDeviation:Float;
	public var maxXDeviation:Float;
	
	public var deviationX:Float;
	
	/* How quickly deviation changes in pixels per second */
	public var deviationRate:Float;
	public var deviationTweenX:FlxTween;
	
	private var tweens:FlxTweenManager;
	
	public function new() {
		super();
		
		tweens = new FlxTweenManager();
		
		launchMode = FlxEmitterMode.SQUARE;
		autoUpdateHitbox = true;
		solid = false;
		
		width = 15;
		height = 15;
		
		minXDeviation = -100;
		maxXDeviation = 100;
		
		deviationX = 0;
		
		deviationRate = 100;
		
		particleClass = SmokeParticle;
		
		for (i in 0...150) {
			add(new SmokeParticle());
		}
		
		lifespan.set(1.9, 2.4);
		velocity.set(15, -40, 35, -20);
	}
	
	override public function emitParticle():SmokeParticle {
		var p:SmokeParticle = super.emitParticle();
		
		p.offset.x = 0;
		p.deviationX = deviationX;
		p.scale.set();
		
		return p;
	}
	
	override public function start(explode:Bool = true, frequency:Float = 0.1, quantity:Int = 0):FlxTypedEmitter<SmokeParticle> {
		super.start(explode, frequency, quantity);
		
		deviateX();
		
		return this;
	}
	
	override public function update(dt:Float):Void {
		super.update(dt);
		tweens.update(dt);
	}
	
	override public function kill():Void {
		super.kill();
		tweens.completeAll();
	}
	
	private function deviateX():Void {
		if (deviationTweenX != null) deviationTweenX.cancel();
		var target:Float = FlxG.random.float(minXDeviation, maxXDeviation);
		var diff:Float = target - deviationX;
		deviationTweenX = tweens.tween(this, {deviationX: target}, Math.abs(diff) / deviationRate, {ease: FlxEase.quadInOut,
			onComplete: function(t:FlxTween):Void {
				if (emitting) deviateX();
			}
		});
	}
}

class StinkEmitter extends SmokeEmitter {
	public var maxScale:Float;
	
	public function new() {
		super();
		
		maxScale = 2;
		
		tweens = new FlxTweenManager();
		
		launchMode = FlxEmitterMode.SQUARE;
		autoUpdateHitbox = true;
		solid = false;
		
		width = 15;
		height = 15;
		
		minXDeviation = -30;
		maxXDeviation = 30;
		
		deviationX = 0;
		
		deviationRate = 70;
		
		particleClass = StinkParticle;
		
		for (i in 0...150) {
			add(new StinkParticle());
		}
		
		lifespan.set(1.9, 2.4);
		velocity.set(0, 0, 0, 0);
	}
	
	override public function emitParticle():SmokeParticle {
		var p = super.emitParticle();
		p.baseScale = maxScale;
		return p;
	}
}

class StinkParticle extends SmokeParticle {
	public function new() {
		super();
	}
	
	override public function initGraphic():Void {
		generateGraphic("stinkSmoke", 0xff76a564, 0xff4a8353);
	}
}