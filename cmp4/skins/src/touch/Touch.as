package  {
	
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	import flash.ui.*;
	import flash.utils.*;
	import flash.geom.*;
	
	
	public class Touch extends MovieClip {
		public static const LIST:String = "list";
		public static const LRC:String = "lrc";
		public static const MEDIA:String = "media";

		private var tw:Number;
		private var th:Number;
		private var api:Object;

		private var msg:TextField;
		//是否支持触摸
		private var touchSupport:Boolean = Multitouch.supportsTouchEvents;
		private var touchPointID:int = 0;

		//速度
		private var speed_evg:Number = 0;
		private var speed_now:Number = 0;
		//时间
		private var time_bgn:Number;
		private var time_end:Number;
		//接触位置
		private var touch_bgn:Number;
		private var touch_now:Number;

		private var on_moving:Boolean;

		//当前窗口名
		private var currentWin:String = LIST;
		//高度百分比
		private var ph:Number = 1;

		//竖向位置
		private var listy_bgn:Number = 0;
		private var listy_now:Number = 0;
		
		private var listy_pos:Number = 0;


		//窗口引用
		private var win_list:Object;
		private var win_lrc:Object;
		private var win_media:Object;
		private var list_tree:Object;
		private var list_index:Number;
		
		private var bts:Array;
		
		public function Touch():void {
			//msg调试信息
			
			msg = new TextField  ;
			msg.mouseEnabled = false;
			msg.selectable = false;
			msg.defaultTextFormat = new TextFormat(null,20,0xff0000);
			//msg.visible = false;
			addChild(msg);

			root.loaderInfo.sharedEvents.addEventListener('api',apiHandler);
			root.loaderInfo.sharedEvents.addEventListener('api_remove',removeHandler);
			
		}
		override public function set width(v:Number):void {
		}
		override public function set height(v:Number):void {
		}
		public function removeHandler(e):void {
			//api.tools.output("api remove");
			
		}
		
		private function apiHandler(e):void {
			
			//取得cmp的api对象和侦听key，包含2个属性{api,key}
			var apikey:Object = e.data;
			//如果没有取到则直接返回
			if (! apikey) {
				return;
			}
			api = apikey.api;
			
			if (!touchSupport) {
				output("当前设备不支持触摸输入");
			}
			
			
			//添加侦听事件，必须传入通信key
			//改变大小时调用
			api.addEventListener(apikey.key, 'resize', cmpResize);
			//状态改变时调用
			api.addEventListener(apikey.key, 'model_state', stateHandler);
			api.addEventListener(apikey.key, 'model_start', startHandler);
			//初始化====================================================================

			//触摸事件
			//output("touchSupport: " + touchSupport);

			//初始化触摸配置
			//触摸模式，单点触摸
			Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
				
			api.config.fullscreen_max = "video";

			win_list = api.win_list.list;
			win_list.mouseChildren = false;
			win_list.mouseEnabled = false;
				
			win_lrc = api.win_list.lrc;
			win_lrc.mouseChildren = false;
			win_lrc.mouseEnabled = false;
				
			win_media = api.win_list.media;
			win_media.mouseChildren = false;
			win_media.mouseEnabled = false;

			list_tree = win_list.tree;
				
			//按钮
			bts = ["bt_list", "bt_play", "bt_stop", "bt_fullscreen"];
			for (var i:int = 0; i < bts.length; i ++) {
				var bt:DisplayObject = this.getChildByName(bts[i]);
				
				
				if (bt) {
					//bt.mouseChildren = false;
					bt.addEventListener(TouchEvent.TOUCH_BEGIN, bt_begin);
					bt.addEventListener(TouchEvent.TOUCH_END, bt_end);
				}
			}

			//添加触摸事件
			pad.addEventListener(TouchEvent.TOUCH_BEGIN, touch_begin);
				
				
			//初始位置尺寸
			cmpResize();
			//初始化播放状态
			stateHandler();
			
		}
		
		private function bt_begin(e:TouchEvent):void {
			if ((touchPointID != 0)) {
				//已经有触摸id了返回
				return;
			}
			var mc:MovieClip = e.currentTarget as MovieClip;
			mc.gotoAndStop(2);
		}
		private function bt_end(e:TouchEvent):void {
			if (e.touchPointID != touchPointID) {
				return;
			}
			touchPointID = 0;
			var mc:MovieClip = e.currentTarget as MovieClip;
			mc.gotoAndStop(1);
			
			var name:String = mc.name;
			
			if (name == "bt_list") {
				showList();
			} else if (name == "bt_play") {
				api.sendEvent("view_play");
				
			} else if (name == "bt_stop") {
				api.sendEvent("view_stop");
				showList("true");
				
			} else if (name == "bt_fullscreen") {
				api.sendEvent("view_fullscreen");
			}
			
			//output(mc.name);
			
		}
		
		//触摸开始
		private function touch_begin(e:TouchEvent):void {
			//output(e);
			if ((touchPointID != 0)) {
				//已经有触摸id了返回
				return;
			}
			
			//output(e.currentTarget == pad);
			
			//if (e.stageY >= th * 0.8) {
				//return;
			//}
			
			
			time_bgn = getTimer();
			touch_bgn = touch_now = e.stageX;
			listy_bgn = listy_now = e.stageY;
			
			listy_pos = list_tree.verticalScrollPosition;
			
			on_moving = false;

			touchPointID = e.touchPointID;
			pad.addEventListener(TouchEvent.TOUCH_MOVE, touch_move);
			pad.addEventListener(TouchEvent.TOUCH_END, touch_end);

		}
		//拖动
		private function touch_move(e:TouchEvent):void {
			if (e.touchPointID != touchPointID) {
				return;
			}
			on_moving = true;
			
			listScroll(e.stageY);
			
		}
		
		//触摸结束
		private function touch_end(e:TouchEvent):void {
			//output(e);
			if (e.touchPointID != touchPointID) {
				return;
			}
			touchPointID = 0;

			pad.removeEventListener(TouchEvent.TOUCH_MOVE, touch_move);
			pad.removeEventListener(TouchEvent.TOUCH_END, touch_end);
			time_end = getTimer();
			if (on_moving) {
				
				listScroll(e.stageY);

			} else {
				touch_click(e);
			}
		}


		private function listScroll(ey:Number):void {
			var d:Number = ey - listy_now;
			
			list_tree.verticalScrollPosition = listy_pos - d;
			
		}



		private function touch_click(e:TouchEvent):void {

			//output(e);

			if (currentWin == LRC) {

			} else if (currentWin == MEDIA) {
				api.sendEvent("view_play");
			} else {
				var pt:Point = new Point(e.stageX, e.stageY);
				//this.graphics.clear();
				//this.graphics.beginFill(0xff0000);
				//this.graphics.drawEllipse(pt.x, pt.y, e.sizeX, e.sizeY);
				//this.graphics.endFill();
				var arr:Array = api.cmp.getObjectsUnderPoint(pt); 
				//output(arr.length);
				var len:int = arr.length;
				if (!len) {
					return;
				}
				var tn:Object;
				for (var i:int = 0; i < len; i ++) {
					var mc:Object = arr[i];
					var sp:Object = mc.parent;
					if (sp.hasOwnProperty("tn")) {
						tn = sp.tn;
						break;
					}
				}
				
				if (!tn) {
					return;
				}
				
				try {
					tn.play();
				} catch(e:Error) {
					return;
				}
			}

		}

		//尺寸改变时调用
		private function cmpResize(e:Event=null):void {
			//获取cmp的宽高
			tw = api.config.width;
			th = api.config.height;

			var h:Number = Math.round(th * 0.8);

			msg.width = tw;
			msg.height = h;
			
			pad.width = tw;
			pad.height = h;

			
			
			var bw:Number = Math.round((tw - 50) * 0.25);
			var bh:Number = bw;
			if (bh > th - h - 30) {
				bh = th - h - 30;
			}
			
			for (var i:int = 0; i < bts.length; i ++) {
				var bt:DisplayObject = this.getChildByName(bts[i]);
				if (bt) {
					bt.width = bw;
					bt.height = bh;
					bt.x = 10 + i * (bw + 10);
					bt.y = h + 10;
				}
			}
			
			//output(bt_list.visible + "|" +bt_list.y);
			
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
				case "completed" :
					showList("true");
				
					break;
				default :

			}
			bt_play.icon_play.visible = !playing;
			bt_play.icon_pause.visible = playing;

		}
		
		private function startHandler(e:Event=null):void {
			showList("false");
		}
		
		private function showList(v:String = null):void {
			if (v == null || (v == "true" && !win_list.visible) || (v == "false" && win_list.visible)) {
				api.sendEvent("view_list");
				if (win_list.visible) {
					bt_list.bt_list_icon.rotation = 0;
				} else {
					bt_list.bt_list_icon.rotation = 180;
				}
				
			}
			
			
			
		}

		private function output(s: * ):void {

			var t:String = msg.text;
			if (t.length > 6000) {
				t = t.substr(0,6000);
			}

			msg.text = s + "\n" + t;

		}
		
	}
	
}
