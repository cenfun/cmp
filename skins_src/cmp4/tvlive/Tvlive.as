package {
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.ui.*;
	import flash.utils.*;
	public class Tvlive extends Sprite {
		//cmp的api接口
		private var api:Object;
		//延时id
		private var timeid:uint;
		//修正加载皮肤时找不到bitmapData属性报错的情况
		public var bitmapData:BitmapData;

		public function Tvlive() {
			//侦听api的发送
			root.loaderInfo.sharedEvents.addEventListener('api', apiHandler);
			root.loaderInfo.sharedEvents.addEventListener('api_remove',removeHandler);
		}
		override public function set width(v:Number):void {
		}
		override public function set height(v:Number):void {
		}
		public function removeHandler(e):void {
			//api.tools.output("api remove");
			api.cmp.stage.removeEventListener(MouseEvent.MOUSE_MOVE, moving);
			api.cmp.stage.removeEventListener(Event.MOUSE_LEAVE, leave);
			//移除所有事件，防止冲突
			clearTimeout(timeid);
			//
			api.win_list.console.removeEventListener(MouseEvent.ROLL_OVER, conOver);
			api.win_list.console.removeEventListener(MouseEvent.ROLL_OUT, conOut);
			
		}

		private function apiHandler(e):void {
			//取得cmp的api对象和侦听key，包含2个属性{api,key}
			var apikey:Object = e.data;
			//如果没有取到则直接返回
			if (! apikey) {
				return;
			}
			api = apikey.api;
			//添加侦听事件，必须传入通信key
			//改变大小时调用
			api.addEventListener(apikey.key, 'resize', resizeHandler);
			//状态改变时调用
			api.addEventListener(apikey.key, 'model_state', stateHandler);
			//初始化====================================================================
			//鼠标移动和移除事件
			api.cmp.stage.addEventListener(MouseEvent.MOUSE_MOVE, moving);
			api.cmp.stage.addEventListener(Event.MOUSE_LEAVE, leave);
			//api.tools.output("tvlive");
			
			//初始化
			conOut();
			//
			//控制台透明度侦听事件
			api.win_list.console.addEventListener(MouseEvent.ROLL_OVER, conOver);
			api.win_list.console.addEventListener(MouseEvent.ROLL_OUT, conOut);
			//初始位置尺寸
			resizeHandler();
			//初始化播放状态
			stateHandler();
		}
		
		private function moving(e:MouseEvent = null):void {
			if (!visible) {
				visible = true;
				api.win_list.console.visible = true;
				Mouse.show();
			} else {
				startHide();
			}
		}
		//鼠标离开flash舞台区域
		private function leave(e:Event = null):void {
			if (api.config.state == "playing") {
				visible = false;
				api.win_list.console.visible = false;
				Mouse.hide();
			}
		}
		

		//尺寸改变时调用
		private function resizeHandler(e:Event = null):void {
			//获取cmp的宽高
			var cw:Number = api.config.width;
			var ch:Number = api.config.height;
			//还原缩放，因为cmp会把背景大小改变，这样要还原，以免比例失调
			//并且设置背景框和cmp一样大小
			this.scaleX = this.scaleY = 1;
			bg.width = cw;
			bg.height = ch;
			//控制台透明背景
			back.x = (cw - 200) * 0.5;
			back.y = ch - 50;
			//设置音量背景位置
			leave();
		}
		
		//cmp ==================================================
		private function startHide():void {
			clearTimeout(timeid);
			var sx:Number = api.cmp.stage.mouseX;
			var sy:Number = api.cmp.stage.mouseY;
			//api.tools.output("sx:"+sx + "|sy:"+sy);
			var test:Boolean = api.win_list.console.hitTestPoint(sx, sy, true);
			if (!test) {
				timeid = setTimeout(leave, 2000);
			}
		}
		//播放状态改变时调用
		private function stateHandler(e:Event = null):void {
			if (api.config.state == "playing") {
				startHide();
			} else {
				moving();
			}
		}
		
		private function conOver(e:MouseEvent):void {
			if (api.win_list.console) {
				this.alpha = api.win_list.console.alpha = 1;
			}
		}

		private function conOut(e:MouseEvent = null):void {
			if (api.win_list.console) {
				this.alpha = api.win_list.console.alpha = 0.8;
			}
		}


	}

}