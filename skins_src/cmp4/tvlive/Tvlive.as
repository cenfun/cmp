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
			//初始化====================================================================
			//api.tools.output("tvlive");
			//自动关闭右键中窗口项
			var menus:Array = api.cmp.contextMenu.customItems;
			if (menus.length > 1) {
				var newMenu:ContextMenu = new ContextMenu();
				newMenu.hideBuiltInItems();
				newMenu.customItems = [menus[0]];
				api.cmp.contextMenu = newMenu;
			}
			//
			api.win_list.console.bt_list.useHandCursor = true;
			
			//隐藏时间提示框和声音调节器
			hideVol();
			//侦听静音按钮鼠标事件
			api.win_list.console.bt_mute.addEventListener(MouseEvent.ROLL_OVER, btmuteOver);
			api.win_list.console.bt_mute.addEventListener(MouseEvent.ROLL_OUT, btmuteOut);
			//
			bg_vol.addEventListener(MouseEvent.ROLL_OUT, btmuteOut);
			//侦听控制台显示隐藏事件;
			api.cmp.addEventListener(MouseEvent.MOUSE_MOVE, cmpMove);
			api.cmp.addEventListener(MouseEvent.ROLL_OVER, cmpOver);
			api.cmp.addEventListener(MouseEvent.ROLL_OUT, cmpOut);
			//控制台透明度侦听事件
			api.win_list.console.addEventListener(MouseEvent.ROLL_OVER, conOver);
			api.win_list.console.addEventListener(MouseEvent.ROLL_OUT, conOut);
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
			api.win_list.console.bt_mute.removeEventListener(MouseEvent.ROLL_OVER, btmuteOver);
			api.win_list.console.bt_mute.removeEventListener(MouseEvent.ROLL_OUT, btmuteOut);
			//
			api.cmp.removeEventListener(MouseEvent.MOUSE_MOVE, cmpMove);
			api.cmp.removeEventListener(MouseEvent.ROLL_OVER, cmpOver);
			api.cmp.removeEventListener(MouseEvent.ROLL_OUT, cmpOut);
			//
			api.win_list.console.removeEventListener(MouseEvent.ROLL_OVER, conOver);
			api.win_list.console.removeEventListener(MouseEvent.ROLL_OUT, conOut);
			//还原CMP的内部元件
			showVol();
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
			bg_vol.x = Math.round(cw * 0.5) + 10;
			bg_vol.y = ch - 10;
			cmpOut();
			hideVol();
		}

		//vol ==================================================

		private function hideVol():void {
			bg_vol.visible = false;
			api.win_list.console.volume.visible = false;
		}
		private function showVol():void {
			bg_vol.visible = true;
			api.win_list.console.volume.visible = true;
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
			if (api.config.state == "playing") {
				startHide();
			} else {
				cmpOver();
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