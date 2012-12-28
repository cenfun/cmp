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
	import org.papervision3d.events.*;

	public final class Box extends DisplayObject3D {
		public var api:Object;
		public var w3d:Win3d;
		public var ws:Array;
		public var ds:Array = [];
		public var ps:Array = [];
		public var ms:Array = [];
		public function Box(_api:Object, _w3d:Win3d):void {
			api = _api;
			w3d = _w3d;
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
			var logo:Logo = new Logo();
			var ml:MovieMaterial = new MovieMaterial(logo, true, false, false);
			ml.smooth = true;
			ml.doubleSided = true;
			var pl:Plane = new Plane(ml, logo.width * 2, logo.height * 2, 3, 3);
			pl.x = 0;
            pl.z = 0;
			addChild(pl);
			
			//围绕的半径
			var r:uint = 450;
			//平均角度和弧度
			var d:Number = 360 / ws.length;
			var a:Number = d * Math.PI / 180;
			for (var i:int = 0; i < ws.length; i ++) {
				var w:DisplayObject = ws[i];
				var mm:MovieMaterial = new MovieMaterial(w, true, true, false);
				mm.smooth = true;
				mm.doubleSided = true;
				mm.interactive = true;
				ms[i] = mm;
				var p:Plane = new Plane(mm, w.width, w.height, 3, 3);
				p.x = Math.round(Math.sin(a * i) * r);
                p.z = - Math.round(Math.cos(a * i) * r);
				ds[i] = Math.round(d * i);
				p.rotationY = - ds[i];
				p.addEventListener(InteractiveScene3DEvent.OBJECT_CLICK, winClick);
				addChild(p);
				ps[i] = p;
			}
			showWin();
		}

		
		private function winClick(e:InteractiveScene3DEvent):void {
			for (var i:int = 0; i < ps.length; i ++) {
				if (e.displayObject3D == ps[i]) {
					w3d.goto(i);
					break;
				}
			}
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