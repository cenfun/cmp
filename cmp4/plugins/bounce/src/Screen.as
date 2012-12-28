package src{
	import flash.events.*;
	import flash.geom.*;
	import flash.display.*;

	public class Screen extends Shape {
		public static const GRAVITY:Number = 2;
		
		public var rect:Rectangle;
		public var color:uint = 0xffffff;
		
		private var newFloorPts:Array;
		private var oldFloorPts:Array;
		private var spacing:Number;
		private var waveSampler:WaveformSampler;
		private var length:int;
		private var bh:uint = 50;
		
		public function Screen() {
			newFloorPts = [new Point(0,0)];
			oldFloorPts = [new Point(0,0)];
			waveSampler = WaveformSampler.getInstance();
		}
		public function update():void {
			graphics.clear();
			graphics.lineStyle(1, color);
			graphics.beginFill(color, 0.1);
			graphics.moveTo(rect.left, rect.bottom);
			var arr:Array = waveSampler.getSamples(WaveformSampler.MONO);
			length = arr.length;
			spacing = (rect.width / (length - 0.5));
			var i:int = 0;
			while (i < length) {
				oldFloorPts[i] = newFloorPts[i];
				newFloorPts[i] = new Point(((rect.left + (i * spacing)) + (spacing * 0.5)), ((arr[i] * bh) + rect.bottom));
				graphics.curveTo((rect.left + (i * spacing)), rect.bottom, newFloorPts[i].x, newFloorPts[i].y);
				i ++;
			}
			graphics.lineStyle(1, color, 0);
			graphics.lineTo(rect.right, rect.bottom + bh);
			graphics.lineTo(rect.left, rect.bottom + bh);
			graphics.endFill();
		}
		public function applyForces(b:Ball):void {
			var fb:FreeBody = b.freebody;
			if ((b.x - b.r) < rect.left) {
				b.x = (rect.left + b.r);
				fb.addNormal(0);
			} else {
				if ((b.x + b.r) > rect.right) {
					b.x = (rect.right - b.r);
					fb.addNormal(Math.PI);
				}
			}
			if ((b.y - b.r) < rect.top) {
				b.y = (rect.top + b.r);
				fb.addNormal((Math.PI * 0.5));
			} else {
				if ((b.y + b.r) > (rect.bottom - bh)) {
					var i:int = Math.round((((b.x - rect.left) - (spacing * 0.5)) / spacing));
					if (i >= (newFloorPts.length - 1)) {
						i = (newFloorPts.length - 2);
					} else {
						if (i <= 0) {
							i = 1;
						}
					}
					var py:Number = newFloorPts[(i - 1)].y;
					var ny:Number = newFloorPts[(i + 1)].y;
					var ty:Number = ((py + ny) * 0.5);
					if ((b.y + b.r) > ty) {
						b.y = (ty - b.r);
						var p:Number = (Math.atan2((ny - py), 3) - (Math.PI * 0.5));
						fb.addNormal(p);
						fb.addForce(new Force(0, Math.min(0, (newFloorPts[i].y - oldFloorPts[i].y))));
					}
				}
			}
		}
	}
}