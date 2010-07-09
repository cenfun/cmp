package {
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.ui.*;
	import flash.utils.*;

	public class Manila extends Sprite {
		private var cw:Number;
		private var ch:Number;
		//cmp的api接口
		private var api:Object;
		//延时id
		private var timeid:uint;
		//修正加载皮肤时找不到bitmapData属性报错的情况
		public var bitmapData:BitmapData;

		public function Manila() {
			//侦听api的发送
			root.loaderInfo.sharedEvents.addEventListener('api',apiHandler);
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
			api.addEventListener(apikey.key,'resize',resizeHandler);
			//状态改变时调用
			api.addEventListener(apikey.key,'model_state',stateHandler);
			//
			api.addEventListener(apikey.key,'model_time',timeHandler);
			//初始化====================================================================
			//api.tools.output("vplayer");
			//自动关闭右键中窗口项
			var menus:Array = api.cmp.contextMenu.customItems;
			if (menus.length > 1) {
				var newMenu:ContextMenu = new ContextMenu  ;
				newMenu.hideBuiltInItems();
				newMenu.customItems = [menus[0]];
				api.cmp.contextMenu = newMenu;
			}
			
			var bg_url:String = api.config.manila_bg;
			if (bg_url) {
				var loader:Loader = new Loader();
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, bgComplete);
				loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, bgError);
				var request:URLRequest = new URLRequest(bg_url);
				loader.load(request);
			} else {
				bg_url = api.skin_xml.console.@bg
				//api.tools.output(bg_url);
				api.tools.zip.gZ(bg_url, bgComplete, bgError);
			}
			//初始位置尺寸
			resizeHandler();
			//初始化播放状态
			stateHandler();
			timeHandler();
		}

		private function bgError(e:Event):void {
			//api.tools.output(e);
		}
		private function bgComplete(e:Event):void {
			bg_back.addChild(e.target.loader);
			resizeHandler();
		}

		//尺寸改变时调用
		private function resizeHandler(e:Event=null):void {
			//获取cmp的宽高
			cw = api.config.width;
			ch = api.config.height;
			//还原缩放，因为cmp会把背景大小改变，这样要还原，以免比例失调
			//并且设置背景框和cmp一样大小
			this.scaleX = this.scaleY = 1;
			bg_head.width = cw;
			//
			bg_main.y = ch - bg_main.height;
			bg_main.width = cw;
			//
			bg_video.width = cw;
			bg_video.height = ch - 120;
			//
			bg_back.width = cw;
			bg_back.height = ch;
			//
			time_pos.y = time_dua.y = bg_main.y + 25;
			time_pos.x = cw * 0.5 - 115;
			time_dua.x = cw * 0.5 + 115 - time_dua.width
		}

		//播放状态改变时调用
		private function stateHandler(e:Event=null):void {
			var playing:Boolean = false;
			switch (api.config.state) {
				case "connecting" :
				case "buffering" :
				case "playing" :
				case "paused" :
					playing = true;
					break;
				default :
					time_pos.text = time_dua.text = "00:00";
			}
			if (playing && api.item.type == "video") {
				bg_video.visible = true;
			} else {
				bg_video.visible = false;
			}
			//
			if (api.win_list.list.visible == playing) {
				api.win_list.list.display = ! playing;
				api.win_list.media.display = playing;
				if (playing) {
					api.win_list.media.x = cw;
					api.tools.effects.m(api.win_list.media, "x", 0, cw + 10);
				} else {
					api.win_list.list.x = - cw;
					api.tools.effects.m(api.win_list.list, "x", 0, cw + 10);
				}
			}
			//
		}

		private function timeHandler(e:Event=null):void {
			var str_pos:String = "00:00";
			var str_dua:String = "00:00";
			//取得当前项的时间和总时间
			if (api.item) {
				str_pos = sTime(api.item.position);
				if (api.item.duration) {
					str_dua = sTime(api.item.duration);
				}
			}
			time_pos.text = str_pos;
			time_dua.text = str_dua;

		}
		//==================================================================================================================
		//转换时间格式
		private function sTime(n:Number):String {
			return zero(n / 60) + ":" + zero(n % 60);
		}
		//生成补零数字
		private function zero(num:Number):String {
			var str:String = String(int(num));
			if (str.length < 2) {
				str = "0" + str;
			} else if (str.length > 3) {
				str = str.substr(str.length - 3);
			}
			return str;
		}
		//百分比校正
		private function per(input: * ):Number {
			input = Number(input);
			if (isNaN(input)) {
				return 0;
			}
			if (input > 1) {
				return 1;
			}
			if (input < 0) {
				return 0;
			}
			return input;
		}



	}

}