package {

	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;
	import flash.system.*;

	public class Flake extends Sprite {
		//父容器
		public var snow:Snow;
		//幅度
		public var tb:Number = 0;
		//
		public var tx:Number = 0;
		public var ty:Number = 0;
		public var ts:Number = 1;
		
		public function Flake(_snow:Snow):void {
			snow = _snow;
			draw();
			//初始化属性
			tb = 100 * Math.random();
			tx = x = snow.tw * Math.random();
			ty = y = -50 * Math.random();
			ts = 0.1 + Math.random();
			scaleX = scaleY = ts;
			alpha = ts - 0.1;
			addEventListener(Event.ENTER_FRAME, update);
		}
		public function update(e:Event):void {
			tx +=  Math.sin(tb ++ * 0.05) + ts * snow.speed_x;
			if (tx < 0) {
				tx += snow.tw;
			} else if (tx > snow.tw) {
				tx -= snow.tw;
			}
			//
			ty +=  ts * snow.speed_y + ts * Math.abs(snow.speed_x);
			if (ty > snow.th) {
				remove();
				if (snow.timer.delay != 30) {
					snow.timer.delay = 30;
				}
			}
			//
			x = tx;
			y = ty;
		}
		
		public function remove():void {
			removeEventListener(Event.ENTER_FRAME, update);
			snow.removeChild(this);
		}
		//画一个雪花
		public function draw():void {
			this.graphics.beginFill(0xffffff, 0.5);
			this.graphics.drawCircle(0, 0, 3);
			this.graphics.endFill();
			this.graphics.beginFill(0xffffff, 1);
			this.graphics.drawCircle(0, 0, 2);
			this.graphics.endFill();
		}
		

	}

}