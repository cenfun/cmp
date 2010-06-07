package src{
	import flash.events.*;
	import flash.geom.*;
	import flash.display.*;

	public class Screen extends Shape {

		private var newFloorPts:Array;
		private var rect:Rectangle;
		private var oldFloorPts:Array;
		private var spacing:Number;
		private var waveSampler:WaveformSampler;
		private var length:int;

		public static const GRAVITY:Number = 2;

		public function Screen(_rect:Rectangle) {
			newFloorPts = [new Point(0,0)];
			oldFloorPts = [new Point(0,0)];
			waveSampler = WaveformSampler.getInstance();
			rect = _rect;
			addEventListener(Event.ENTER_FRAME, enterframeHandler, false, 0, true);
		}
		private function enterframeHandler(e:Event):void {
			this.graphics.clear();
			this.graphics.lineStyle(1, 0);
			this.graphics.beginFill(0xFFFFFF, 0.5);
			this.graphics.moveTo(rect.left, rect.top);
			this.graphics.lineTo(rect.left, rect.bottom);
			
			var arr:Array = waveSampler.getSamples(WaveformSampler.MONO);
			length = arr.length;
			spacing = (rect.width / (length - 0.5));
			var i:int = 0;
			while (i < length) {
				oldFloorPts[i] = newFloorPts[i];
				newFloorPts[i] = new Point(((rect.left + (i * spacing)) + (spacing / 2)), ((arr[i] * 50) + rect.bottom));
				this.graphics.curveTo((rect.left + (i * spacing)), rect.bottom, newFloorPts[i].x, newFloorPts[i].y);
				i ++;
			}
			this.graphics.lineTo(rect.right, rect.top);
			this.graphics.lineTo(rect.left, rect.top);
			this.graphics.endFill();
		}
		public function applyForces(b:Ball):void {
			var fb:FreeBody;
			var i:int;
			var _local4:Number;
			var _local5:Number;
			var _local6:Number;
			var _local7:Number;
			fb = b.freebody;
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
				fb.addNormal((Math.PI / 2));
			} else {
				if ((b.y + b.r) > (rect.bottom - 50)) {
					i = Math.round((((b.x - rect.left) - (spacing / 2)) / spacing));
					if (i >= (newFloorPts.length - 1)) {
						i = (newFloorPts.length - 2);
					} else {
						if (i <= 0) {
							i = 1;
						}
					}
					_local4 = newFloorPts[(i - 1)].y;
					_local5 = newFloorPts[(i + 1)].y;
					_local6 = ((_local4 + _local5) / 2);
					if ((b.y + b.r) > _local6) {
						b.y = (_local6 - b.r);
						_local7 = (Math.atan2((_local5 - _local4), 3) - (Math.PI / 2));
						fb.addNormal(_local7);
						fb.addForce(new Force(0, Math.min(0, (newFloorPts[i].y - oldFloorPts[i].y))));
					}
				}
			}
		}

	}
}