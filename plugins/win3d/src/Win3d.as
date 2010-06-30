package src{
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.net.*;
	import flash.text.*;
	import flash.ui.*;
	import flash.utils.*;
	import flash.system.*;
	
	import org.papervision3d.objects.*;
	import org.papervision3d.view.*;
	import org.papervision3d.lights.*;
	import org.papervision3d.render.*;

	public final class Win3d extends Sprite {
		public var view:BasicView;
		//主体
		public var main:DisplayObject3D;
		//盒子
		public var box:Box;
		//拖动背景
		public var bg:Sprite;
		//cmp的api接口
		private var api:Object;
		
		public function Win3d():void {
			Security.allowDomain("*");
			loaderInfo.sharedEvents.addEventListener('api', apiHandler);
			bg = new Sprite();
			bg.graphics.beginFill(0xffffff, 0);
			bg.graphics.drawRect(0, 0, 100, 100);
			bg.graphics.endFill();
			bg.buttonMode = true;
			addChild(bg);
		}
		
		private function apiHandler(e):void {
			//取得cmp的api对象和侦听key，包含2个属性{api,key}
			var apikey:Object = e.data;
			//如果没有取到则直接返回
			if (! apikey) {
				return;
			}
			api = apikey.api;
			//添加侦听事件
			api.addEventListener(apikey.key, 'skin_complete', boxInit);
			api.addEventListener(apikey.key, 'resize', resize);
			resize();
			//
			init();
		}
		private function resize(e = null):void {
			bg.width = api.config.width;
			bg.height = api.config.height;
			if (box) {
				box.showWin(win_idx);
			}
		}
		
		private function boxInit(e = null):void {
			box.init();
			win_idx = 0;
			main.rotationY = 0;
		}
		
		private function init():void {
			//
			main = new DisplayObject3D();
			box = new Box(api, this);
			box.init();
			main.addChild(box);
			//
			view = new BasicView();
			view.buttonMode = true;
			view.scene.addChild(main);
			view.camera.y = 0;
            view.camera.z = - 800;
			view.viewport.interactive = true;
			view.startRendering();
  			addChild(view);
			
			//光影，必须光影材质，否则无效
			//var pl3d:PointLight3D = new PointLight3D(true);
			//pl3d.y = 500;
			//view.scene.addChild(pl3d);
			
			//
			bg.addEventListener(MouseEvent.MOUSE_DOWN, downHandler);
		}

		//============================================================================================
		private var is_down:Boolean = false;
		private var is_move:Boolean = false;
		private var time_bgn:Number;
		private var time_end:Number;
		
		private var speed_evg:Number = 0;
		private var speed_now:Number = 0;
		private var mouse_bgn:Point;
		private var mouse_now:Point;
		
		private var pos_end:int;
		private var pos_spd:int;
		private var win_idx:int = 0;
		private function downHandler(e:MouseEvent):void {
			time_bgn = getTimer();
			mouse_bgn = new Point(stage.mouseX, stage.mouseY);
			mouse_now = mouse_bgn;
			//
			stopHandler();
			is_down = true;
			is_move = false;
			//
			stage.addEventListener(MouseEvent.MOUSE_MOVE, moveHandler);
			stage.addEventListener(MouseEvent.MOUSE_UP, upHandler);
		}
		private function moveHandler(e:MouseEvent):void {
			box.hideWin(win_idx);
			is_move = true;
			speed_now = stage.mouseX - mouse_now.x;
			rotateHandler(speed_now);
			mouse_now = new Point(stage.mouseX, stage.mouseY);
			//
			var time_now:Number = getTimer();
			if (time_now - time_bgn > 500) {
				time_bgn = time_now;
				mouse_bgn = mouse_now;
			}
		}
		
		private function upHandler(e:MouseEvent):void {
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, moveHandler);
			stage.removeEventListener(MouseEvent.MOUSE_UP, upHandler);
			if (!is_down) {
				return;
			}
			is_down = false;
			//惯性
			time_end = getTimer();
			if (is_move) {
				if (Math.abs(speed_now) > 1) {
					speed_evg = (mouse_now.x - mouse_bgn.x) / (time_end - time_bgn);
					speed_evg = Math.round(speed_evg * 100);
				}
				addEventListener(Event.ENTER_FRAME, autoHandler);
			} else {
				box.showWin(win_idx);
			}
		}
		private function autoHandler(e:Event):void {
			var val:int = speed_evg > 0 ? 1 : -1;
			speed_evg = Math.round(speed_evg * 0.9 - val);
			if (speed_evg != 0 && Math.abs(speed_evg) > 20) {
				//api.tools.output(speed_evg);
				rotateHandler(speed_evg);
			} else {
				fixPos();
			}
		}
		
		private function rotateHandler(speed:Number):void {
			main.rotationY -= speed;
		}
		private function stopHandler():void {
			removeEventListener(Event.ENTER_FRAME, autoHandler);
		}
		
		private function fixPos():void {
			stopHandler();
			//
			var ry:int = getRY();
			win_idx = 0;
			if (ry in box.ds) {
				box.showWin(win_idx);
				return;
			}
			var val:int = speed_now > 0 ? 1 : -1;
			//
			if (val < 0) {
				pos_end = 360;
				for (var i:int = 0; i < box.ds.length; i++) {
					if (box.ds[i] > ry) {
						pos_end = box.ds[i];
						win_idx = i;
						break;
					}
				}
			} else {
				pos_end = 0;
				for (var j:int = box.ds.length - 1; j >= 0; j--) {
					if (box.ds[j] < ry) {
						pos_end = box.ds[j];
						win_idx = j;
						break;
					}
				}
			}
			pos_spd = (ry - pos_end) * 0.2;
			//
			//api.tools.output(win_idx);
			//api.tools.output(val);
			//api.tools.output(ry);
			//api.tools.output(pos_end);
			addEventListener(Event.ENTER_FRAME, endHandler);
		}
		private function endHandler(e:Event):void {
			//api.tools.output("end");
			main.rotationY -= pos_spd;
			if ((pos_spd > 0 && main.rotationY <= pos_end) || (pos_spd < 0 && main.rotationY >= pos_end)) {
				fixed();
			}
		}
		private function fixed():void {
			removeEventListener(Event.ENTER_FRAME, endHandler);
			main.rotationY = pos_end;
			box.showWin(win_idx);
			//api.tools.output("fixed");
		}
		
		public function goto(i:int):void {
			box.hideWin(win_idx);
			win_idx = i;
			pos_end = box.ds[i];
			var ry:int = getRY();
			pos_spd = (ry - pos_end) * 0.2;
			addEventListener(Event.ENTER_FRAME, endHandler);
		}
		
		private function getRY():int {
			var ry:int = Math.round(main.rotationY % 360);
			if (ry < 0) {
				ry += 360;
			}
			main.rotationY = ry;
			return ry;
		}
		
	}
}