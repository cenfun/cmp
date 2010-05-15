package {
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.ui.*;
	import flash.utils.*;
	
	public class Vplayer extends Sprite {

		//cmp的api接口
		private var api:Object;
		//
		private var timeid:uint;
		//音量引用
		private var vol:DisplayObject;
		private var vol_parent:DisplayObjectContainer;
		//进度条引用
		private var bar:DisplayObject;
		//静音按钮引用
		private var bt_mute:DisplayObject;
		//控制台引用
		private var console:Object;
		//修正加载皮肤时找不到bitmapData属性报错的情况
		public var bitmapData:BitmapData;

		public function Vplayer() {
			//侦听api的发送
			this.loaderInfo.sharedEvents.addEventListener('api', apiHandler);
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
			//初始化
			init();
		}

		private function init():void {
			console = api.win_list.console;
			vol = console.volume;
			vol_parent = vol.parent;
			//隐藏时间提示框和声音调节器
			barOut();
			hideVol();
			//侦听静音按钮鼠标事件
			bt_mute = console.bt_mute as DisplayObject;
			bt_mute.addEventListener(MouseEvent.ROLL_OVER, btmuteOver);
			bt_mute.addEventListener(MouseEvent.ROLL_OUT, btmuteOut);
			//
			bg_vol.addEventListener(MouseEvent.ROLL_OUT, btmuteOut);
			//侦听控制台显示隐藏事件;
			api.cmp.addEventListener(MouseEvent.MOUSE_MOVE, cmpMove);
			api.cmp.addEventListener(MouseEvent.ROLL_OVER, cmpOver);
			api.cmp.addEventListener(MouseEvent.ROLL_OUT, cmpOut);
			//侦听进度条提示事件;
			bar = console.progress;
			bar.addEventListener(MouseEvent.MOUSE_MOVE, barMove);
			bar.addEventListener(MouseEvent.MOUSE_OVER, barOver);
			bar.addEventListener(MouseEvent.MOUSE_OUT, barOut);
			//控制台透明度侦听事件
			console.addEventListener(MouseEvent.ROLL_OVER, conOver);
			console.addEventListener(MouseEvent.ROLL_OUT, conOut);
			//退出皮肤时调用，用于清理上面的侦听，以免应该到其他皮肤里，冲突
			this.addEventListener(Event.REMOVED_FROM_STAGE, removeHandler);
			//初始位置尺寸
			resizeHandler();
			//初始化播放状态
			stateHandler();
		}
		
		private function removeHandler(e:Event):void {
			//移除所有事件，防止冲突
			clearTimeout(timeid);
			bt_mute.removeEventListener(MouseEvent.ROLL_OVER, btmuteOver);
			bt_mute.removeEventListener(MouseEvent.ROLL_OUT, btmuteOut);
			//
			api.cmp.removeEventListener(MouseEvent.MOUSE_MOVE, cmpMove);
			api.cmp.removeEventListener(MouseEvent.ROLL_OVER, cmpOver);
			api.cmp.removeEventListener(MouseEvent.ROLL_OUT, cmpOut);
			//
			bar.removeEventListener(MouseEvent.MOUSE_MOVE, barMove);
			bar.removeEventListener(MouseEvent.MOUSE_OVER, barOver);
			bar.removeEventListener(MouseEvent.MOUSE_OUT, barOut);
			//
			console.removeEventListener(MouseEvent.ROLL_OVER, conOver);
			console.removeEventListener(MouseEvent.ROLL_OUT, conOut);
			//还原CMP的内部元件
			showVol();
			//清楚引用，释放内存
			vol_parent = null;
			vol = null;
			bt_mute = null;
			bar = null;
			console = null;
		}
		
		//调试信息发送程序
		private function o(str:*):void {
			if (str == undefined) {
				str = "undefined";
			}
			var lc:LocalConnection = new LocalConnection();
			lc.addEventListener(StatusEvent.STATUS, function(e:Event):void{});
			var s:String = str.toString();
			trace(s);
			lc.send("_cenfun_lc", "cenfunTrace", s);
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
			back.width = cw;
			back.y = ch - 50;
			//设置bar背景的位置
			bg_bar.y = ch - 10 - bg_bar.height;
			bg_bar.width = cw - 150;
			//设置音量背景位置
			bg_vol.x = cw - 80;
			bg_vol.y = ch - 10;
			//时间提示位置
			tip_time.y = ch - 43;
			cmpOut();
		}

		//vol ==================================================

		private function hideVol():void {
			bg_vol.visible = false;
			if (vol_parent.contains(vol)) {
				vol_parent.removeChild(vol);
			}
		}
		private function showVol():void {
			bg_vol.visible = true;
			if (! vol_parent.contains(vol)) {
				vol_parent.addChild(vol);
			}
		}
		private function btmuteOver(e:MouseEvent):void {
			showVol();
		}

		private function btmuteOut(e:MouseEvent):void {
			var sx:Number = bg_vol.stage.mouseX;
			var sy:Number = bg_vol.stage.mouseY;
			var test:Boolean = bg_vol.hitTestPoint(sx,sy,true);
			if (! test) {
				hideVol();
			}
		}

		//cmp ==================================================
		private function cmpMove(e:MouseEvent):void {
			cmpOver();
			startHide();
		}

		private function cmpOver(e:MouseEvent = null):void {
			this.visible = true;
			console.visible = true;
			//
			
			
			Mouse.show();
		}

		private function cmpOut(e:MouseEvent = null):void {
			if (api.config.state == "playing") {
				this.visible = false;
				console.visible = false;
				Mouse.hide();
			}
		}

		private function startHide():void {
			clearTimeout(timeid);
			timeid = setTimeout(cmpOut,2000);
		}
		//播放状态改变时调用
		private function stateHandler(e:Event = null):void {
			startHide();
		}


		//bar ==================================================
		private function barMove(e:MouseEvent):void {
			tip_time.x = bar.mouseX + bar.x;
			if (! tip_time.visible) {
				return;
			}
			var per:Number = bar.mouseX / bar.width;
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
			this.alpha = console.alpha = 1;
			
		}

		private function conOut(e:MouseEvent = null):void {
			this.alpha = console.alpha = 0.8;
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