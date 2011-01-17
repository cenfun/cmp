package {

	import flash.display.*;
	import flash.events.*;
	import flash.system.*;
	import flash.text.*;
	import flash.utils.*;
	import flash.geom.Rectangle;

	public class Category extends Sprite {
		private var api:Object;
		private var tw:Number;
		private var th:Number;

		private var xl:XMLList;
		
		private var auto_hide:Boolean = true;
		private var onleft:Boolean = true;

		private var category_width:int = 120;
		private var row_height:int = 35;
		private var row_format:TextFormat = new TextFormat();
		private var row_formatNow:TextFormat = new TextFormat();

		private var rowNow:Row;
		private var rowArr:Array = [];

		public function Category() {
			Security.allowDomain("*");
			root.loaderInfo.sharedEvents.addEventListener('api',apiHandler);
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
		}

		private function apiHandler(e):void {
			//取得cmp的api对象和侦听key，包含2个属性{api,key}
			var apikey:Object = e.data;
			//如果没有取到则直接返回
			if (! apikey) {
				return;
			}
			api = apikey.api;
			//
			api.addEventListener(apikey.key,"resize",resizeHandler);
			resizeHandler();
			//加载分类配置
			loadCategory();
		}

		private function resizeHandler(e:Event=null):void {
			tw = api.config.width || stage.stageWidth;
			th = api.config.height || stage.stageHeight;
			//播放器小于将不显示
			if (tw < category_width || th < main.list.height) {
				visible = false;
				return;
			} else if (! visible) {
				visible = true;
			}
			layout();
		}
		private function layout():void {
			main.bg.width = category_width;
			main.bg.height = th;
			main.list.y = (th - main.list.height) * 0.5;
			arrow.y = (th - arrow.height) * 0.5;
		}

		//===================================================================

		private function loadCategory():void {
			var category_config:String = api.config.category_config;
			if (! category_config) {
				return;
			}
			category_config = decodeURIComponent(category_config);
			//api.tools.output(category_config);
			try {
				xl = new XMLList(category_config);
			} catch (e:Error) {
				api.tools.output(e);
			}
			if (xl) {
				parseCategory();
			} else {
				api.tools.output("分类配置的xml格式错误");
			}
		}

		private function moving(e:MouseEvent):void {
			var sx:int = e.stageX;
			var ol:Boolean = false;
			if (sx < category_width + 10) {
				ol = true;
			}
			slideNow(ol);
			if (ol && arrow.visible) {
				arrow.visible = false;
			} else if (!ol) {
				arrow.visible = true;
			}
		}
		//鼠标离开flash舞台区域
		private function leave(e:Event):void {
			//api.tools.output(e);
			arrow.visible = false;
			slideNow(false);
		}
		
		private function slideNow(ol:Boolean):void {
			if (ol == onleft) {
				return;
			}
			onleft = ol;
			api.tools.effects.e(main);
			//api.tools.output(onleft);
			if (onleft) {
				api.tools.effects.m(main, "x", 0, tw);
			} else {
				api.tools.effects.m(main, "x", - category_width - 20, tw);
			}
		}
		
		//解析配置
		private function parseCategory():void {
			//解析配置===============================================
			//是否自动隐藏
			auto_hide = api.tools.strings.tof(gOP(xl,"auto_hide",true));
			if (auto_hide) {
				api.cmp.stage.addEventListener(MouseEvent.MOUSE_MOVE, moving);
				api.cmp.stage.addEventListener(Event.MOUSE_LEAVE, leave);
				slideNow(false);
			}
			//宽度
			category_width = parseInt(gOP(xl,"width",category_width));
			//行高
			row_height = parseInt(gOP(xl,"row_height",row_height));
			//格式
			row_format = api.tools.strings.format(xl,0);
			row_formatNow = api.tools.strings.format(xl,1);
			
			//清理列表==============================================
			var ls:MovieClip = main.list as MovieClip;
			//生成列表
			var i:int = 0;
			for each (var xml:XML in xl.children()) {
				var row:Row = new Row();
				row.xml = xml;
				row.back.width = category_width;
				row.back.height = row_height;
				row.y = i * row_height;
				//
				var tt:TextField = new TextField();
				tt.defaultTextFormat = row_format;
				tt.selectable = false;
				tt.multiline = false;
				tt.wordWrap = false;
				tt.autoSize = "left";
				tt.mouseEnabled = false;
				tt.htmlText = String(xml.@label);
				tt.setTextFormat(row_format);
				tt.y = (row_height - tt.height) * 0.5;
				tt.autoSize = "none";
				tt.width = category_width;
				row.addChild(tt);
				row.tt = tt;
				//
				row.buttonMode = true;
				row.addEventListener(MouseEvent.MOUSE_DOWN,rowHandler);
				row.addEventListener(MouseEvent.MOUSE_UP,rowHandler);
				row.addEventListener(MouseEvent.ROLL_OVER,rowHandler);
				row.addEventListener(MouseEvent.ROLL_OUT,rowHandler);
				row.addEventListener(MouseEvent.CLICK,rowHandler);
				ls.addChild(row);
				rowArr.push(row);
				i++;
			}
			//布局列表
			layout();
		}

		private function rowHandler(e:MouseEvent):void {
			var row:Row = e.currentTarget as Row;
			if (row) {
				switch (e.type) {
					case MouseEvent.MOUSE_DOWN :
						row.back.alpha = 0.8;
						break;
					case MouseEvent.MOUSE_UP :
						if (row.mouse_roll == "over") {
							row.back.alpha = 0.5;
						} else {
							row.back.alpha = 1;
						}
						break;
					case MouseEvent.ROLL_OVER :
						row.mouse_roll = "over";
						row.back.alpha = 0.5;
						break;
					case MouseEvent.ROLL_OUT :
						row.mouse_roll = "out";
						row.back.alpha = 1;
						break;
					case MouseEvent.CLICK :
						rowNow = row;
						rowClick();
						break;
					default :

				}

			}
		}

		private function rowClick():void {
			//更新列表当前选择项样式
			for each(var row:Row in rowArr) {
				var tf:TextFormat = row_format;
				if (row == rowNow) {
					tf = row_formatNow;
				}
				row.tt.setTextFormat(tf);
			}
			//加载当前项新的列表和皮肤
			var xml:XML = rowNow.xml;
			//新的列表地址
			var lists:String = gOP(xml,"lists",api.config.lists);
			//api.tools.output(lists);
			if (lists != api.config.lists) {
				api.config.lists = lists;
				api.list_xml = <list />;
				api.sendEvent("list_load");
			}
			//新的皮肤id
			var skin_id:int = parseInt(gOP(xml,"skin_id",api.config.skin_id));
			if (skin_id != api.config.skin_id) {
				api.config.skin_id = skin_id;
				api.sendEvent("skin_load");
			}
		}
		
		
		public function gOP(xl:Object, pn:String, dv:*):* {
			if (xl.hasOwnProperty("@" + pn)) {
				var v:String = xl.attribute(pn);
				if (v) {
					return v;
				}
			}
			return dv;
		}

	}

}