package  {
	
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	import flash.system.*;
	import flash.net.*;
	import com.bit101.components.*;
	import flash.geom.Rectangle;
	
	public class CMPList extends MovieClip {
		public var api:Object;
		public var cb_mode:ComboBox;
		public var bt_scale:TextField;
		public function CMPList() {
			Security.allowDomain("*");
			root.loaderInfo.sharedEvents.addEventListener('api', apiHandler);
			root.loaderInfo.sharedEvents.addEventListener('api_remove', removeHandler);
			scrollRect = new Rectangle(0, 0, 242, 305);
		}
		
		private function modeChange(e:Event):void {
			if (!api) {
				return;
			}
			cb_mode.visible = true;
			api.config.play_mode = cb_mode.selectedItem.value;
		}
		
		private function random(e:Event):void {
			if (!api) {
				return;
			}
			var xml:XML = api.list_xml as XML;
			if (xml) {
				var len:int = xml.children().length();
				if (len && len > 1) {
					
					api.list_xml = sortXMLByAttribute(xml, "label");
					
					api.sendEvent("list_loaded");
				}
			}
		}
		
		private function output(e:Event):void {
			if (!api) {
				return;
			}
			var file:FileReference = new FileReference();  
			var xml:XML = api.list_xml as XML;
			var str:String = "";
			if (xml) {
				str = xml.toXMLString();
			}
			var rd:String = Math.random().toString().substr(2, 4);
			file.save(str, "cmp_list_" + rd + ".xml");
		}
		
		private function onLink(e:TextEvent):void {
			if (!api) {
				return;
			}
			if (e.text == "clear") {
				api.sendEvent("view_stop");
				api.list_xml = <list/>;
				api.sendEvent("list_loaded");
			}
		}
		
		private function onScale(e:TextEvent):void {
			if (e.text == "scale") {
				api.win_list.media.xywh = "-125C, 128, 322, 262";
				bt_scale.htmlText = '<a href="event:reset">[还原]</a>';
			} else {
				api.win_list.media.xywh = "-125C, 128, 242, 202";
				bt_scale.htmlText = '<a href="event:scale">[放大]</a>';
			}
		}
		
		public function removeHandler(e):void {
			api.win_list.media.removeChild(bt_scale);
		}
		public function apiHandler(e):void {
			var apikey:Object = e.data;
			if (! apikey) {
				return;
			}
			api = apikey.api;
			
			
			var sheet:StyleSheet = new StyleSheet();
			sheet.parseCSS("a { color:#666666; } a:hover { text-decoration:underline; }");
			
			
			//清空按钮
			var bc:TextField = new TextField();
			bc.autoSize = "left";
			bc.htmlText = '<a href="event:clear">[清空]</a>';
			bc.selectable = false;
			bc.x = 40;
			bc.y = 1;
			bc.styleSheet = sheet;
			bc.addEventListener(TextEvent.LINK, onLink)
			addChild(bc);
			
			//窗口放大按钮
			
			bt_scale = new TextField();
			bt_scale.autoSize = "left";
			bt_scale.htmlText = '<a href="event:scale">[放大]</a>';
			bt_scale.selectable = false;
			bt_scale.x = 40;
			bt_scale.y = 1;
			bt_scale.styleSheet = sheet;
			bt_scale.addEventListener(TextEvent.LINK, onScale)
			api.win_list.media.addChild(bt_scale);
			
			//
			var ty:Number = bg.height - 25;
			
			var bl:PushButton = new PushButton(this, 5, ty, "名称排序", random);
			bl.width = 60;
			
			
			var bo:PushButton = new PushButton(this, 70, ty, "导出列表", output);
			bo.width = 60;
			
			cb_mode = new ComboBox(this, 156, ty);
			cb_mode.visible = false;
			cb_mode.setSize(80, 20);
			cb_mode.addEventListener(Event.CHANGE, modeChange);
			var mds:Array = [];
			mds.push({ label : "默认顺序", value : "normal" });
			mds.push({ label : "顺序播放", value : "normal" });
			mds.push({ label : "重复播放", value : "repeat" });
			mds.push({ label : "随机播放", value : "random" });
			mds.push({ label : "向上播放", value : "upward" });
			mds.push({ label : "单个播放", value : "single" });
			cb_mode.items = mds;
			cb_mode.selectedIndex = 0;
			
		}
		override public function set width(v:Number):void {
		}
		override public function set height(v:Number):void {
		}
		
		//1 or <code>Array.CASEINSENSITIVE</code></li>
		//2 or <code>Array.DESCENDING</code></li>
		//4 or <code>Array.UNIQUESORT</code></li>
		//8 or <code>Array.RETURNINDEXEDARRAY</code></li>
		//16 or <code>Array.NUMERIC</code></li>
		
		public function sortXMLByAttribute($xml:XML, $attribute:String, $options:Object=null, $copy:Boolean=false):XML {
			//store in array to sort on
			var xmlArray:Array	= new Array();

			var item:XML;
			for each(item in $xml.children()) {
				var object:Object = {data: item, order: item.attribute($attribute)};
				xmlArray.push(object);
			}
			xmlArray.sortOn('order', $options);

			var sortedXmlList:XMLList = new XMLList();
			var xmlObject:Object;
			for each(xmlObject in xmlArray ) {
				sortedXmlList += xmlObject.data;
			}

			if($copy) {
				return	$xml.copy().setChildren(sortedXmlList);
			} else {
				return $xml.setChildren(sortedXmlList);
			}
		 }
		
	}
	
}
