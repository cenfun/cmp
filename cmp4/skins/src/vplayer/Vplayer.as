package {
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.ui.*;
	import flash.utils.*;
	
	public class Vplayer extends Sprite {

		//cmp的api接口
		private var api:Object;
		//延时id
		private var timeid:uint;

		public function Vplayer() {
			//侦听api的发送
			root.loaderInfo.sharedEvents.addEventListener('api', apiHandler);
			root.loaderInfo.sharedEvents.addEventListener('api_remove', removeHandler);
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
			
			api.win_list.console.progress.removeEventListener(MouseEvent.MOUSE_MOVE, barMove);
			api.win_list.console.progress.removeEventListener(MouseEvent.MOUSE_OVER, barOver);
			api.win_list.console.progress.removeEventListener(MouseEvent.MOUSE_OUT, barOut);
			
		}

		private function apiHandler(e):void {
			var apikey:Object = e.data;
			if (! apikey) {
				return;
			}
			api = apikey.api;
			api.addEventListener(apikey.key, 'resize', resizeHandler);
			api.addEventListener(apikey.key, 'model_state', stateHandler);
			//初始化
			if (api.config.state != "playing") {
				api.win_list.media.video.vi.ip.visible = true;
			}
			
			//鼠标移动和移除事件
			api.cmp.stage.addEventListener(MouseEvent.MOUSE_MOVE, moving);
			api.cmp.stage.addEventListener(Event.MOUSE_LEAVE, leave);
			//api.tools.output("tvlive");
			
			barOut();
			//侦听进度条提示事件;
			api.win_list.console.progress.addEventListener(MouseEvent.MOUSE_MOVE, barMove);
			api.win_list.console.progress.addEventListener(MouseEvent.MOUSE_OVER, barOver);
			api.win_list.console.progress.addEventListener(MouseEvent.MOUSE_OUT, barOut);
			
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
			//
			leave();
		}
		
		
		private function moving(e:MouseEvent = null):void {
			if (visible) {
				startHide();
			} else {
				visible = true;
				api.win_list.console.visible = true;
				Mouse.show();
			}
		}
		//鼠标离开flash舞台区域
		private function leave(e:Event = null):void {
			visible = false;
			api.win_list.console.visible = false;
			Mouse.hide();
		}
		

		//尺寸改变时调用
		private function resizeHandler(e:Event = null):void {
			//获取cmp的宽高
			var cw:Number = api.config.width;
			var ch:Number = api.config.height;
			//控制台透明背景
			back.width = cw - 10;
			back.y = ch - 45;
			//设置bar背景的位置
			bg_bar.y = ch - 10 - bg_bar.height;
			bg_bar.width = loading.width = cw - 150;
			//
			bg_sld.y = loading_mask.y = loading.y = bg_bar.y + 3;
			bg_sld.width = loading_mask.width = cw - 220;
			//时间提示位置
			tip_time.y = ch - 43;
			//
			visible = true;
			startHide();
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
			loading_mask.visible = loading.visible = false;
			if (api.config.state == "buffering" || api.config.state == "connecting") {
				loading_mask.visible = loading.visible = true;
			} else if (api.config.state == "stopped") {
				api.win_list.media.video.vi.ip.visible = true;
			}
		}
		
		//bar ==================================================
		private function barMove(e:MouseEvent):void {
			tip_time.x = api.win_list.console.progress.mouseX + api.win_list.console.progress.x;
			if (! tip_time.visible) {
				return;
			}
			var per:Number = api.win_list.console.progress.mouseX / api.win_list.console.progress.width;
			var str:String = sTime(Math.round(per * api.item.duration));
			tip_time.tip.text = String(str);
		}

		private function barOver(e:MouseEvent):void {
			if (api.item) {
				if (api.item.duration) {
					tip_time.visible = true;
				}
			}
		}

		private function barOut(e:MouseEvent = null):void {
			tip_time.visible = false;
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

		//转化成时间字符串
		private function sTime(p:Number):String {
			return zero(p/60) + ":" + zero(p%60);
		}
		//补0
		private function zero(n:Number):String {
			var str:String = String(int(n));
			if (str.length < 2) {
				str = "0" + str;
			}
			return str;
		}

	}

}