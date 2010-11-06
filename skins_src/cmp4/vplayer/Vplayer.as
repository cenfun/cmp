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
		//修正加载皮肤时找不到bitmapData属性报错的情况
		public var bitmapData:BitmapData;

		public function Vplayer() {
			//侦听api的发送
			root.loaderInfo.sharedEvents.addEventListener('api', apiHandler);
			root.loaderInfo.sharedEvents.addEventListener('api_remove', removeHandler);
		}
		override public function set width(v:Number):void {
		}
		override public function set height(v:Number):void {
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
			
			//隐藏时间提示框
			barOut();
			//
			//侦听控制台显示隐藏事件;
			api.cmp.addEventListener(MouseEvent.MOUSE_MOVE, cmpMove);
			api.cmp.addEventListener(MouseEvent.ROLL_OVER, cmpOver);
			api.cmp.addEventListener(MouseEvent.ROLL_OUT, cmpOut);
			//侦听进度条提示事件;
			api.win_list.console.progress.addEventListener(MouseEvent.MOUSE_MOVE, barMove);
			api.win_list.console.progress.addEventListener(MouseEvent.MOUSE_OVER, barOver);
			api.win_list.console.progress.addEventListener(MouseEvent.MOUSE_OUT, barOut);
			//控制台透明度侦听事件
			api.win_list.console.addEventListener(MouseEvent.ROLL_OVER, conOver);
			api.win_list.console.addEventListener(MouseEvent.ROLL_OUT, conOut);
			//初始位置尺寸
			resizeHandler();
			//初始化播放状态
			stateHandler();
		}
		
		private function removeHandler(e:Event):void {
			//移除所有事件，防止冲突
			clearTimeout(timeid);
			//
			api.cmp.removeEventListener(MouseEvent.MOUSE_MOVE, cmpMove);
			api.cmp.removeEventListener(MouseEvent.ROLL_OVER, cmpOver);
			api.cmp.removeEventListener(MouseEvent.ROLL_OUT, cmpOut);
			//
			api.win_list.console.progress.removeEventListener(MouseEvent.MOUSE_MOVE, barMove);
			api.win_list.console.progress.removeEventListener(MouseEvent.MOUSE_OVER, barOver);
			api.win_list.console.progress.removeEventListener(MouseEvent.MOUSE_OUT, barOut);
			//
			api.win_list.console.removeEventListener(MouseEvent.ROLL_OVER, conOver);
			api.win_list.console.removeEventListener(MouseEvent.ROLL_OUT, conOut);
		}
		

		//尺寸改变时调用
		private function resizeHandler(e:Event = null):void {
			//获取cmp的宽高
			var cw:Number = api.config.width;
			var ch:Number = api.config.height;
			//还原缩放，因为cmp会把背景大小改变，这样要还原，以免比例失调
			//并且设置背景框和cmp一样大小
			bg.width = cw;
			bg.height = ch;
			//控制台透明背景
			back.width = cw;
			back.y = ch - 50;
			//设置bar背景的位置
			bg_bar.y = ch - 10 - bg_bar.height;
			bg_bar.width = loading.width = cw - 150;
			//
			bg_sld.y = loading_mask.y = loading.y = bg_bar.y + 3;
			bg_sld.width = loading_mask.width = api.win_list.console.progress.width;
			//时间提示位置
			tip_time.y = ch - 43;
			cmpOut();
		}
		

		//cmp ==================================================
		private function cmpMove(e:MouseEvent):void {
			cmpOver();
			startHide();
		}

		private function cmpOver(e:MouseEvent = null):void {
			this.visible = true;
			api.win_list.console.visible = true;
			//
			Mouse.show();
		}

		private function cmpOut(e:MouseEvent = null):void {
			if (api.config.state == "playing") {
				this.visible = false;
				api.win_list.console.visible = false;
				Mouse.hide();
			}
		}

		private function startHide():void {
			clearTimeout(timeid);
			var sx:Number = api.cmp.stage.mouseX;
			var sy:Number = api.cmp.stage.mouseY;
			//api.tools.output("sx:"+sx + "|sy:"+sy);
			var test:Boolean = api.win_list.console.hitTestPoint(sx, sy, true);
			if (sx == 0 || sx == api.config.width || sy == 0 || sy == api.config.height || !test) {
				timeid = setTimeout(cmpOut, 2000);
			}
		}
		//播放状态改变时调用
		private function stateHandler(e:Event = null):void {
			loading_mask.visible = loading.visible = false;
			if (api.config.state == "buffering" || api.config.state == "connecting") {
				loading_mask.visible = loading.visible = true;
			}
			if (api.config.state == "playing") {
				startHide();
			} else {
				cmpOver();
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
		
		//con =================================================
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
		
		//functions ===========================================

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