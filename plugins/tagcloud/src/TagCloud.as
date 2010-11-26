package src{
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.text.*;
	import flash.system.*;

	public class TagCloud extends MovieClip {
		// private vars

		private var mcList:Array = [];

		private var radius:Number = 150;
		private var dtr:Number = Math.PI / 180;
		private var d:Number = 300;
		private var sa:Number;
		private var ca:Number;
		private var sb:Number;
		private var cb:Number;
		private var sc:Number;
		private var cc:Number;

		private var distr:Boolean;
		private var lasta:Number = 1;
		private var lastb:Number = 1;
		private var active:Boolean = false;

		private var holder:MovieClip;

		private var api:Object;

		private var tw:Number;
		private var th:Number;
		
		private var length:int = 30;
		//播放或缓存视频类型时，是否自动隐藏
		private var autohide:Boolean = true;
		//随机颜色组
		private var colors:String = "#ff0000|#ffffff,#ffff00|#ffffff,#ff00ff|#ffffff,#0000ff|#ffffff,#00ff00|#ffffff";
		//随机文本尺寸范围，最小尺寸和最大尺寸
		private var sizes:String = "12,24";
		//旋转速度
		private var speed:Number = 1;
		
		public function TagCloud():void {
			Security.allowDomain("*");
			root.loaderInfo.sharedEvents.addEventListener('api',apiHandler);
			root.loaderInfo.sharedEvents.addEventListener('api_remove',removeHandler);
			sineCosine(0,0,0);
			holder = new MovieClip();
			addChild(holder);
		}
		override public function set width(v:Number):void {
		}
		override public function set height(v:Number):void {
		}
		public function removeHandler(e):void {
			removeEventListener(Event.ENTER_FRAME, updateTags);
			api.cmp.stage.removeEventListener(Event.MOUSE_LEAVE, mouseExitHandler);
			api.cmp.stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
		}

		private function apiHandler(e):void {
			var apikey:Object = e.data;
			if (! apikey) {
				return;
			}
			api = apikey.api;
			api.addEventListener(apikey.key,"resize",resizeHandler);
			api.addEventListener(apikey.key,"control_load",itemHandler);
			api.addEventListener(apikey.key,"model_state",stateHandler);
			stateHandler();
			resizeHandler();
			//api.tools.output("tagcloud");
			
			var ah:String = api.config.tagcloud_autohide;
			if (ah == "0" || ah == "false" || ah == "null") {
				autohide = false;
			}
			if (api.config.tagcloud_length) {
				length = parseInt(api.config.tagcloud_length);
			}
			if (api.config.tagcloud_speed) {
				speed = parseInt(api.config.tagcloud_speed);
			}
			if (api.config.tagcloud_sizes) {
				sizes = api.config.tagcloud_sizes;
			}
			if (api.config.tagcloud_colors) {
				colors = api.config.tagcloud_colors;
			}
			//
			if (api.list_xml.children().length()) {
				init();
			} else {
				api.addEventListener(apikey.key,"list_change", init);
			}
		}

		private function stateHandler(e:Event = null):void {
			//播放视频时隐藏
			if (autohide && api.item && api.item.type == "video" && (api.config.state == "buffering" || api.config.state == "playing")) {
				visible = false;
			} else if (!visible) {
				visible = true;
			}
		}
		private function itemHandler(e:Event = null):void {
			if (api.item) {
				for (var i:Number = 0; i < mcList.length; i ++) {
					mcList[i].checkItem(api.item);
				}
			}
		}
		
		private function resizeHandler(e:Event=null):void {
			tw = api.config.width || stage.stageWidth;
			th = api.config.height || stage.stageHeight;

			holder.x = tw * 0.5;
			holder.y = th * 0.5;
		}

		private function init(e = null):void {

			var td:Object = api.win_list.list.tree.data;
			//api.tools.output(td.length);
			if (td) {
				//清理原有的
				while (holder.numChildren) {
					holder.removeChildAt(0);
				}
				mcList = [];
				
				//尺寸范围
				var arr:Array = array(sizes);
				var size_min:int = parseInt(arr[0]);
				var size_max:int = size_min;
				if (arr[1]) {
					size_max = parseInt(arr[1]);
				}
				var size_len:int = size_max - size_min;
				//颜色范围
				var color_list:Array = [];
				if (colors) {
					var list:Array = array(colors);
					for (var c:Number = 0; c < list.length; c ++) {
						var str:String = list[c];
						var cs:Array = str.split("|");
						var cup:uint = color(cs[0]);
						var con:uint = cup;
						if (cs[1]) {
							con = color(cs[1]);
						}
						color_list.push([cup, con]);
					}
				}
				var color_up:uint;
				var color_on:uint;
				for (var i:int = 0; i < td.length; i ++) {
					if (i > length) {
						break;
					}
					var tn:Object = td.getItemAt(i);
					if (tn.node_type == "node_item") {
						if (color_list.length) {
							var ti:uint = Math.floor(color_list.length * Math.random());
							color_up = color_list[ti][0];
							color_on = color_list[ti][1];
						} else {
							color_up = 0xffffff * Math.random();
							color_on = 0xffffff * Math.random();
						}
						var size:uint = Math.round(size_min + size_len * Math.random());
						var mc:Tag = new Tag(tn, color_up, color_on, size);
						holder.addChild(mc);
						mcList.push(mc);
					}
				}
			}
			//api.tools.output("TagCloud Length: " + mcList.length);
			if (! mcList.length) {
				return;
			}

			// distribute the tags on the sphere
			positionAll();
			// add event listeners
			addEventListener(Event.ENTER_FRAME, updateTags);
			api.cmp.stage.addEventListener(Event.MOUSE_LEAVE, mouseExitHandler);
			api.cmp.stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
		}

		private function updateTags( e:Event ):void {
			var a:Number;
			var b:Number;
			if (active) {
				a = (-Math.min( Math.max( holder.mouseY, -250 ), 250 ) / 150 ) * speed;
				b = (Math.min( Math.max( holder.mouseX, -250 ), 250 ) /150 ) * speed;
			} else {
				a = lasta * 0.98;
				b = lastb * 0.98;
			}
			lasta = a;
			lastb = b;
			// if a and b under threshold, skip motion calculations to free up the processor
			if (Math.abs(a) > 0.01 || Math.abs(b) > 0.01) {
				var c:Number = 0;
				sineCosine( a, b, c );
				// bewegen van de punten
				for (var j:Number=0; j<mcList.length; j++) {
					// multiply positions by a x-rotation matrix
					var rx1:Number = mcList[j].cx;
					var ry1:Number = mcList[j].cy * ca + mcList[j].cz *  -  sa;
					var rz1:Number = mcList[j].cy * sa + mcList[j].cz * ca;
					// multiply new positions by a y-rotation matrix
					var rx2:Number = rx1 * cb + rz1 * sb;
					var ry2:Number = ry1;
					var rz2:Number = rx1 *  -  sb + rz1 * cb;
					// multiply new positions by a z-rotation matrix
					var rx3:Number = rx2 * cc + ry2 *  -  sc;
					var ry3:Number = rx2 * sc + ry2 * cc;
					var rz3:Number = rz2;
					// set arrays to new positions
					mcList[j].cx = rx3;
					mcList[j].cy = ry3;
					mcList[j].cz = rz3;
					// add perspective
					var per:Number = d / (d+rz3);
					// setmc position, scale, alpha
					mcList[j].x = rx3 * per;
					mcList[j].y = ry3 * per;
					mcList[j].scaleX = mcList[j].scaleY = per;
					mcList[j].alpha = per / 2;
				}
				depthSort();
			}
		}

		private function depthSort():void {
			//mcList.sortOn();
			var current:Number = 0;
			for (var i:Number=0; i<mcList.length; i++) {
				holder.setChildIndex( mcList[i], i );
				if (mcList[i].active) {
					current = i;
				}
			}
			holder.setChildIndex( mcList[current], mcList.length-1 );
		}

		/* See http://blog.massivecube.com/?p=9 */
		private function positionAll():void {
			var phi:Number = 0;
			var theta:Number = 0;
			var max:Number = mcList.length;
			// mix up the list so not all a' live on the north pole
			mcList.sort(sortWay);
			// distibute
			for (var i:Number=1; i<max+1; i++) {
				if (distr) {
					phi = Math.acos(-1+(2*i-1)/max);
					theta = Math.sqrt(max * Math.PI) * phi;
				} else {
					phi = Math.random()*(Math.PI);
					theta = Math.random()*(2*Math.PI);
				}
				// Coordinate conversion
				mcList[i - 1].cx = radius * Math.cos(theta) * Math.sin(phi);
				mcList[i - 1].cy = radius * Math.sin(theta) * Math.sin(phi);
				mcList[i - 1].cz = radius * Math.cos(phi);
			}
		}

		public function sortWay(a, b):Number {
			if (Math.random() < 0.5) {
				return 1;
			} else {
				return -1;
			}
		}


		private function mouseExitHandler( e:Event ):void {
			active = false;
		}
		private function mouseMoveHandler( e:MouseEvent ):void {
			active = true;
		}


		private function sineCosine( a:Number, b:Number, c:Number ):void {
			sa = Math.sin(a * dtr);
			ca = Math.cos(a * dtr);
			sb = Math.sin(b * dtr);
			cb = Math.cos(b * dtr);
			sc = Math.sin(c * dtr);
			cc = Math.cos(c * dtr);
		}
		
		public function color(input:String):uint {
			input = String(input);
			//过滤#
			input = input.replace("#", "");
			//返回16进制数字
 			return parseInt(input, 16);
		}
		public const COMMA:RegExp = /\s*\,\s*/;
		public function array(input:String):Array {
			input = String(input);
			var arr:Array = input.split(COMMA);
			var out:Array = [];
			for each(var str:String in arr) {
				if (str) {
					out.push(str);
				}
			}
			return out;
		}
	}

}