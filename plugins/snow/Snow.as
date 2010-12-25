package {

	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;
	import flash.system.*;

	public class Snow extends MovieClip {
		public var api:Object;
		
		public var tw:Number;
		public var th:Number;
		
		//每100px面积雪花的数量
		public var num_100px:Number = 1;
		//当前面积的雪花总数
		public var num_total:Number = 100;
		//左右风速
		public var speed_x:Number = 0;
		//飘落速度
		public var speed_y:Number = 5;
		
		public var timer:Timer;
		
		public var index:int;
		
		public function Snow():void {
			Security.allowDomain("*");
			root.loaderInfo.sharedEvents.addEventListener('api',apiHandler);
			root.loaderInfo.sharedEvents.addEventListener('api_remove',removeHandler);
		}
		
		override public function set width(v:Number):void {
		}
		override public function set height(v:Number):void {
		}
		public function removeHandler(e):void {
			timer.stop();
		}
		
		private function apiHandler(e):void {
			var apikey:Object = e.data;
			if (! apikey) {
				return;
			}
			api = apikey.api;
			api.addEventListener(apikey.key, "resize", resizeHandler);
			resizeHandler();
			//
			timer = new Timer(200);
			timer.start();
			timer.addEventListener(TimerEvent.TIMER, update);
		}
		public function resizeHandler(e:Event = null):void {
			tw = api.config.width;
			th = api.config.height;
			
			num_total = Math.round(tw * th * num_100px * 0.0001);
			
			//api.tools.output(num_total);
			
		}
		
		public function update(e:TimerEvent):void {
			if (num_total <= 0) {
				return;
			}
			
			//api.tools.output(numChildren, num_total, timer.currentCount);
			
			//
			if (numChildren < num_total) {
				addChild(new Flake(this));
			} else {
				
				//改变风吹速度和方向
				var rd:Number = Math.random();
				if (rd < 0.1 && timer.currentCount - index > 100) {
					speed_x = 5 * Math.random();
					
					//api.tools.output(speed_x, rd);
					
					if (rd < 0.03) {
						speed_x = - speed_x;
					}
					
					index = timer.currentCount;
				}
				
			}
		}

	}

}