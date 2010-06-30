package src{
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.net.*;
	import flash.text.*;
	import flash.ui.*;
	import flash.utils.*;

	import org.papervision3d.lights.*;
	import org.papervision3d.objects.*;
	import org.papervision3d.objects.primitives.*
	import org.papervision3d.materials.*;
    import org.papervision3d.materials.utils.*;
	import org.papervision3d.materials.shadematerials.*;
	import org.papervision3d.core.geom.*;
	import org.papervision3d.core.geom.renderables.*;

	public final class Box extends DisplayObject3D {
		public var api:Object;
		public var ws:Array;
		public var ds:Array = [];
		public var ps:Array = [];
		public var ms:Array = [];
		public function Box(_api:Object):void {
			api = _api;
		}
		
		public function init():void {
			//自动关闭右键中窗口项
			var menus:Array = api.cmp.contextMenu.customItems;
			if (menus.length > 3) {
				var newMenu:ContextMenu = new ContextMenu();
				newMenu.hideBuiltInItems();
				newMenu.customItems = [menus[0], menus[1], menus[menus.length - 1]];
				api.cmp.contextMenu = newMenu;
			}
			//移除子对象
			for each (var child:DisplayObject3D in children) {
				removeChild(child);
			}
			//窗口列表
			var wins:Object = api.win_list;
			wins.option.display = true;
			wins.console.bt_option.visible = false;
			wins.console.bt_video.visible = false;
			wins.console.bt_lrc.visible = false;
			wins.console.bt_list.visible = false;
			//
			ws = [wins.console, wins.list, wins.lrc, wins.option, wins.media];
			for (var i:int = 0; i < ws.length; i ++) {
				var w:Object = ws[i];
				w.bt_close.visible = false;
				var xywh:String = w.xywh;
				var arr:Array = api.tools.strings.array(xywh);
				arr[0] = "100P";
				w.xywh = arr.join(",");
				w.lock = true;
			}
			//
			draw();
		}
		private function draw():void {
			//围绕的半径
			var r:uint = 450;
			//平均角度和弧度
			var d:Number = 360 / ws.length;
			var a:Number = d * Math.PI / 180;
			for (var i:int = 0; i < ws.length; i ++) {
				var w:DisplayObject = ws[i];
				var mm:MovieMaterial = new MovieMaterial(w, true, true, false);
				mm.doubleSided = true;
				ms[i] = mm;
				var p:Plane = new Plane(mm, w.width, w.height, 3, 3);
				p.x = Math.round(Math.sin(a * i) * r);
                p.z = - Math.round(Math.cos(a * i) * r);
				ds[i] = Math.round(d * i);
				p.rotationY = - ds[i];
				addChild(p);
				ps[i] = p;
			}
			showWin();
		}
		
		public function showWin(i:int = 0):void {
			var win:Object = ws[i];
			win.x = (api.config.width - win.width) * 0.5;
			win.y = (api.config.height - win.height) * 0.5;
			win.visible = true;
			//api.tools.output(win);
			//api.tools.output(win.visible);
			//api.tools.output(win.x + "|" + win.y);
			ms[i].animated = false;
			ps[i].visible = false;
		}
		public function hideWin(i:int = 0):void {
			var win:Object = ws[i];
			win.x = api.config.width;
			win.y = api.config.height;
			ms[i].animated = true;
			ps[i].visible = true;
		}

	}
}