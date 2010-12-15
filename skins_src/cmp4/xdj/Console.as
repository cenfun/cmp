package {
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.ui.*;
	import flash.utils.*;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flashx.textLayout.elements.InlineGraphicElement;

	public class Console extends Sprite {
		public var api:Object;
		public var bitmapData:BitmapData;
		
		//选择角度
		private var round_rotation:Number = 0;
		//频谱缓存
		private var mixer_l:Number = 0;
		private var mixer_r:Number = 0;
		private var mixer_a:Array = [0, 0, 0, 0, 0, 0, 0];
		private var mixer_m:Array = [];
		
		//是否已经停止
		private var stopped:Boolean = true;
		
		//拖动按钮
		private var thumb:DisplayObject;
		
		public function Console() {
			for (var i:int = 0; i < 7; i ++) {
				var mc:DisplayObject = lt_mask.getChildByName("mixer_" + i);
				mixer_m.push(mc);
			}
			root.loaderInfo.sharedEvents.addEventListener('api', apiHandler);
			root.loaderInfo.sharedEvents.addEventListener('api_remove',removeHandler);
		}
		override public function set width(v:Number):void {
		}
		override public function set height(v:Number):void {
		}
		public function removeHandler(e):void {
		}

		private function apiHandler(e):void {
			var apikey:Object = e.data;
			if (! apikey) {
				return;
			}
			api = apikey.api;
			//版本检测
			var ver:int = parseInt(api.config.version.substr(-6));
			//
			if (ver < 101215) {
				api.tools.output(ver);
				return;
			} else {
				version.visible = false;
				removeChild(version);
			}
			//自动启用取样播放
			api.config.sound_sample = true;
			//并去掉均衡参数
			api.config.sound_eq = null;
			//
			api.addEventListener(apikey.key, 'resize', resizeHandler);
			api.addEventListener(apikey.key, 'model_state', stateHandler);
			api.addEventListener(apikey.key, 'control_mute', muteHandler);
			api.addEventListener(apikey.key, 'control_volume', volumeHandler);
			resizeHandler();
			stateHandler();
			muteHandler();
			volumeHandler();
			
			for each(var tb:MovieClip in [lt_thumb, rt_thumb, l_thumb, r_thumb]) {
				tb.addEventListener(MouseEvent.MOUSE_DOWN, downHandler);
				tb.addEventListener(MouseEvent.ROLL_OVER, overHandler);
				tb.addEventListener(MouseEvent.ROLL_OUT, outHandler);
			}
			
			bt_reset_l.addEventListener(MouseEvent.CLICK, resetHandler);
			bt_reset_r.addEventListener(MouseEvent.CLICK, resetHandler);
		}
		private function overHandler(e:MouseEvent):void {
			e.currentTarget.gotoAndStop(2);
		}
		private function outHandler(e:MouseEvent):void {
			e.currentTarget.gotoAndStop(1);
		}
		
		private function resetHandler(e:MouseEvent):void {
			api.config.panning = 0;
			api.sendEvent("view_volume");
		}
		
		private function downHandler(e:MouseEvent):void {
			thumb = e.currentTarget as DisplayObject;
			stage.addEventListener(MouseEvent.MOUSE_MOVE, moveHandler);
			stage.addEventListener(MouseEvent.MOUSE_UP, upHandler);
		}
		
		private function moveHandler(e:MouseEvent):void {
			if (thumb) {
				var tp:Number = api.config.panning;
				var ty:Number = this.mouseY;
				var track:DisplayObject = getChildByName(thumb.name.replace("thumb", "track"));
				if (track) {
					var th:Number = track.height;
					ty = api.tools.strings.clamp(ty, track.y, track.y + th);
					tp = (ty - track.y - th * 0.5) / (th * 0.5);
					if (thumb == rt_thumb || thumb == r_thumb) {
						tp = tp * -1;
					}
					//api.tools.output(tp);
				}
				thumb.y = ty;
				//左右平衡
				api.config.panning = tp;
				api.sendEvent("view_volume");
			}
		}
		
		private function upHandler(e:MouseEvent):void {
			stage.removeEventListener(MouseEvent.MOUSE_UP, upHandler);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, moveHandler);
			thumb = null;
		}
		
		
		private function resizeHandler(e:Event = null):void {
			var cw:Number = api.config.width;
			var ch:Number = api.config.height;
			
		}
		private function stateHandler(e:Event = null):void {
			if (api.config.state == "playing") {
				stopped = false;
				play_xdj();
			} else {
				stopped = true;
				if (e == null) {
					stop_xdj();
				}
			}
		}
		private function muteHandler(e:Event = null):void {
			if (api.config.mute) {
				lr_led.visible = false;
			} else {
				lr_led.visible = true;
			}
		}
		private function volumeHandler(e:Event = null):void {
			var pan:Number = api.config.panning;
			l_led.visible = true;
			r_led.visible = true;
			if (pan == -1) {
				r_led.visible = false;
			} else if (pan == 1) {
				l_led.visible = false;
			}
			
			var ty:Number = 0;
			var th:Number = 0;
			if (thumb != lt_thumb) {
				th = lt_track.height;
				ty = pan * th * 0.5;
				lt_thumb.y = Math.round(lt_track.y + th * 0.5 + ty);
			}
			if (thumb != rt_thumb) {
				th = rt_track.height;
				ty = pan * th * 0.5 * -1;
				rt_thumb.y = Math.round(rt_track.y + th * 0.5 + ty);
			}
			if (thumb != l_thumb) {
				th = l_track.height;
				ty = pan * th * 0.5;
				l_thumb.y = Math.round(l_track.y + th * 0.5 + ty);
			}
			if (thumb != r_thumb) {
				th = r_track.height;
				ty = pan * th * 0.5 * -1;
				r_thumb.y = Math.round(r_track.y + th * 0.5 + ty);
			}
		}
		
		
		
		//round
		private function play_xdj():void {
			if (!this.hasEventListener(Event.ENTER_FRAME)) {
				this.addEventListener(Event.ENTER_FRAME, running);
			}
		}
		private function stop_xdj():void {
			this.removeEventListener(Event.ENTER_FRAME, running);
			mixer_l = 0;
			mixer_r = 0;
			mixer_a = [0, 0, 0, 0, 0, 0, 0];
			for (var i:int = 0; i < 7; i ++) {
				mixer_m[i].height = 0;
			}
			l_vu8_mask.height = 0;
			r_vu8_mask.height = 0;
				
			l_vu10_mask.height = 0;
			r_vu10_mask.height = 0;
			
		}

		private function running(e:Event):void {
			
			round_rotation += 6;
			round_rotation = round_rotation % 360;
			lt_round.rotation = round_rotation;
			rt_round.rotation = round_rotation;
			
			//
			var rot:Number = 0;
			if (api.item.duration) {
				var per:Number = api.tools.strings.per(api.item.position / api.item.duration);
				rot = Math.round(16 * per);
			}
			rt_passthrough.rotation = rot;
			
			//
			//左右最大值
			var ml:Number = 0;
			var mr:Number = 0;
			//
			var ba:ByteArray = api.win_list.media.video.mx.gb(true);
			//如果读取到数据
			if (ba.bytesAvailable) {
				//取出右边组
				ba.position = 0;
				var br:ByteArray = new ByteArray();
				ba.position = 1024;
				ba.readBytes(br);
				
				//分别计算两边的最大值
				var i:Number = 0;
				var l:Number = 0;
				var r:Number = 0;
				var v:Number = 0;
				ba.position = 0;
				br.position = 0;
				while (br.bytesAvailable) {
					l = ba.readFloat();
					if (ml < l) {
						ml = l;
					}
					r = br.readFloat();
					if (mr < r) {
						mr = r;
					}
					if (i < 7) {
						v = (l + r) * 0.5;
						mixer_a[i] -= 0.1;
						if (mixer_a[i] < v) {
							mixer_a[i] = v;
						}
						
						mixer_m[i].height = 35 * mixer_a[i];
						i ++;
					}
				}
				ml = ml * 0.8;
				mr = mr * 0.8;
				//api.tools.output(ml, mr);
				
			}
			
			
			//更新频谱
			mixer_l -= 0.1;
			if (mixer_l < ml) {
				mixer_l = ml;
			}
			mixer_r -= 0.1;
			if (mixer_r < mr) {
				mixer_r = mr;
			}
			
			if (mixer_l <= 0 && mixer_r <= 0) {
				mixer_l = mixer_r = 0;
				if (stopped) {
					stop_xdj();
				}
			}
			
			l_vu8_mask.height = 45 * mixer_l;
			r_vu8_mask.height = 45 * mixer_r;
				
			l_vu10_mask.height = 55 * mixer_l;
			r_vu10_mask.height = 55 * mixer_r;

		}

		
		

	}

}