package src{
	import flash.events.*;
	import flash.display.*;
	public class Ball extends Shape {
		//球半径
		public const r:Number = 5;
		public const FGRAV:Force = new Force(0, 1);
		private var screen:Screen;
		private var fb:FreeBody;
		public function Ball(sc:Screen) {
			screen = sc;
			fb = new FreeBody(FGRAV);
			with (graphics) {
				lineStyle(0.5, 0);
				beginFill((Math.random() * 0xFFFFFF));
				drawCircle(0, 0, r);
				endFill();
			}
			addEventListener(Event.ENTER_FRAME, updatePosition, false, 0, true);
		}
		private function updatePosition(e:Event):void {
			fb.update();
			screen.applyForces(this);
			x += fb.x;
			y += fb.y;
		}
		public function get freebody():FreeBody {
			return fb;
		}
	}
}