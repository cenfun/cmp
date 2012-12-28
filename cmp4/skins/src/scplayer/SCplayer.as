package {
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.ui.*;
	import flash.utils.*;
	
	public class SCplayer extends MovieClip {
		private var api:Object;
		private var timeid:uint;
		public function SCplayer() {
			root.loaderInfo.sharedEvents.addEventListener('api', apiHandler);
			root.loaderInfo.sharedEvents.addEventListener('api_remove', removeHandler);
		}
		override public function set width(v:Number):void {
		}
		override public function set height(v:Number):void {
		}
		public function removeHandler(e):void {
			//api.tools.output("api remove");
			
		}

		private function apiHandler(e):void {
			var apikey:Object = e.data;
			if (! apikey) {
				return;
			}
			api = apikey.api;
			api.addEventListener(apikey.key, 'model_start', startHandler);
			api.addEventListener(apikey.key, 'model_state', stateHandler);
			api.addEventListener(apikey.key, 'model_time', timeHandler);
			api.addEventListener(apikey.key, 'model_loading', loadingHandler);
			api.addEventListener(apikey.key, 'model_loaded', loadedHandler);
			//初始化
			api.config.volume = 1;
			//初始化按钮
			bt_mute.loading.visible = false;
			bt_play.buttonMode = true;
			bt_play.addEventListener(MouseEvent.ROLL_OVER, btplayOver);
			bt_play.addEventListener(MouseEvent.ROLL_OUT, btplayOut);
			bt_play.addEventListener(MouseEvent.CLICK, btplayClick);
			msg.selectable = false;
			time.selectable = false;
			//初始化进度条
			bar.bar_track.buttonMode = true;
			bar.bar_track.addEventListener(MouseEvent.CLICK, barClick);
			
			//初始化播放状态
			stateHandler();
		}
		
		//点击播放按钮
		private function btplayClick(e:MouseEvent):void {
			//发送播放按钮事件，通知cmp是否播放还是暂停
			api.sendEvent("view_play");
			mainOpen();
		}
		//打开
		private function mainOpen():void {
			clearTimeout(timeid);
			if (currentFrame == 1) {
				play();
			}
		}
		//关闭
		private function mainClose():void {
			clearTimeout(timeid);
			if (currentFrame == 15) {
				play();
			}
		}
		
		//鼠标移入播放按钮
		private function btplayOver(e:MouseEvent):void {
			if (api.config.state == "playing") {
				bt_play.gotoAndStop(4);
			} else {
				bt_play.gotoAndStop(2);
			}
		}
		//鼠标移出播放按钮
		private function btplayOut(e:MouseEvent):void {
			if (api.config.state == "playing") {
				bt_play.gotoAndStop(3);
			} else {
				bt_play.gotoAndStop(1);
			}
		}
		
		//进度条点击事件
		private function barClick(e:MouseEvent):void {
			var per:Number = bar.bar_track.mouseX / bar.bar_track.width;
			//发送新的进度百分比，通知cmp跳转到新的地方
			api.sendEvent("view_progress", per);
		}
		
		//时间变化时调用
		private function timeHandler(e:Event):void {
			var str:String = "00:00 / 00:00";
			//取得当前项的时间和总时间
			if (api.item) {
				if (api.item.duration) {
					str = sTime(api.item.position, api.item.duration);
				}
			}
			time.text = str;
			//根据2个时间得出播放百分比
			var per:Number = per(api.item.position / api.item.duration);
			//设置播放位置
			var bw:Number = 200 * per;
			bar.bar_played.width = bw;
		}
		//正在加载时调用
		private function loadingHandler(e:Object):void {
			var per:Number = per(e.data);
			bar.bar_mask.width = 200 * per;
		}
		//加载完成时调用
		private function loadedHandler(e:Event):void {
			bar.bar_mask.width = 0;
		}
		
		//模块开始时调用
		private function startHandler(e:Event):void {
			mainOpen();
		}
		
		//播放状态改变时调用
		private function stateHandler(e:Event = null):void {
			var str:String = "";
			var is_play:Boolean = false;
			switch (api.config.state) {
				//连接中
				case "connecting" :
					str = "connecting ...";
					if (api.item.reload) {
						//重连
						str = "reconnecting ...";
					}
					break;
				//加载中
				case "buffering" :
					str = "loading ..." + api.config.buffer_percent + "%";
					break;
				//播放中
				case "playing" :
					str = "playing";
					is_play = true;
					break;
				//已经暂停
				case "paused" :
					str = "paused";
					break;
				case "completed" :
					str = "completed";
					bar.bar_played.width = 200;
					break;
				//已停止
				case "stopped" :
					str = "stopped";
					bar.bar_mask.width = 0;
					bar.bar_played.width = 0;
					time.text = "00:00 / 00:00";
					timeid = setTimeout(mainClose, 500);;
					break;
				default :
					break;
			}
			//显示状态字符
			msg.htmlText = str;
			//根据状态显示或隐藏声音动画，以及播放还是暂停图标
			bt_mute.loading.visible = false;
			if (is_play) {
				bt_play.gotoAndStop(3);
				if (!api.config.mute) {
					bt_mute.loading.visible = true;
				}
			} else {
				bt_play.gotoAndStop(1);
			}
		}
		
		//==================================================================================================================
		//转换时间格式
		private function sTime(position:Number, duration:Number):String{
			return zero(position / 60) + ":" + zero(position % 60) + " / " + zero(duration / 60) + ":" + zero(duration % 60);
		}
		//生成补零数字
		private function zero(num:Number):String{
			var str:String = String(int(num));
			if (str.length < 2) {
				str = "0" + str;
			}
			return str;
		}
		//百分比校正
		private function per(input:*):Number{
			input = Number(input);
			if (isNaN(input)){
				return 0;
			}
			if (input > 1){
				return 1;
			}
			if (input < 0){
				return 0;
			}
			return input;
		}
		

	}

}