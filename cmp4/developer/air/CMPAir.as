package  {
	
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.html.*;
	import flash.desktop.*;
	
	public class CMPAir extends MovieClip {
		private var url:String = "http://cmp.cenfun.com/cmp4/";
		private var html:HTMLLoader;
		public function CMPAir() {
			
			//任务栏图标支持
			NativeApplication.nativeApplication.autoExit = false;
			
			var iconMenu:NativeMenu = new NativeMenu();
			//打开退出菜单
			var openCommand:NativeMenuItem = iconMenu.addItem(new NativeMenuItem("打开CMP"));
			openCommand.addEventListener(Event.SELECT, openHandler);
			
			//分隔符
			iconMenu.addItem(new NativeMenuItem("", true));
			var aboutCommand:NativeMenuItem = iconMenu.addItem(new NativeMenuItem("关于"));
			aboutCommand.addEventListener(Event.SELECT, aboutHandler);
			
			//分隔符
			iconMenu.addItem(new NativeMenuItem("", true));
			var exitCommand:NativeMenuItem = iconMenu.addItem(new NativeMenuItem("退出"));
			exitCommand.addEventListener(Event.SELECT, exitHandler);
			
			//图标加载
			var icon:Loader = new Loader();
			icon.contentLoaderInfo.addEventListener(Event.COMPLETE, iconLoadComplete);
			
			if (NativeApplication.supportsSystemTrayIcon) {
				icon.load(new URLRequest("icons/16x16.png"));
				var systray:SystemTrayIcon = NativeApplication.nativeApplication.icon as SystemTrayIcon;
				systray.tooltip = "CMP";
				systray.menu = iconMenu;
				systray.addEventListener(MouseEvent.CLICK, showWindow);
			}
			if (NativeApplication.supportsDockIcon){
				icon.load(new URLRequest("icons/128x128.png"));
				var dock:DockIcon = NativeApplication.nativeApplication.icon as DockIcon;
				dock.menu = iconMenu;
				dock.addEventListener(MouseEvent.CLICK, showWindow);
			}
			
			stage.nativeWindow.addEventListener(Event.CLOSING, closingHandler);
			//
			stage.align = StageAlign.TOP_LEFT; 
			stage.scaleMode = StageScaleMode.NO_SCALE; 
			stage.addEventListener(Event.RESIZE, resize);
			
			var req:URLRequest = new URLRequest(url);
			html = new HTMLLoader();
			html.load(req);
			stage.addChild(html);
			
			resize();
		}
		
		public function closingHandler(e:Event):void {
			//点击关闭时不退出，而是最小化
			e.preventDefault();
			stage.nativeWindow.minimize();
			stage.nativeWindow.visible = false;
		}
		
		public function showWindow(e:ScreenMouseEvent):void {
			//已经最小化就还原窗口
		   	if (stage.nativeWindow.displayState == NativeWindowDisplayState.MINIMIZED) {
				stage.nativeWindow.visible = true;
				stage.nativeWindow.restore();
			} else {
				//否则最小化
				stage.nativeWindow.minimize();
				stage.nativeWindow.visible = false;
			}
        }
		
		private function iconLoadComplete(e:Event):void{
			NativeApplication.nativeApplication.icon.bitmaps = [e.target.content.bitmapData];
		}
		
		public function openHandler(e:Event):void {
			stage.nativeWindow.visible = true;
			if (stage.nativeWindow.displayState == NativeWindowDisplayState.MINIMIZED) {
				stage.nativeWindow.restore();
			} else {
				stage.nativeWindow.activate();
			}
		}
		public function aboutHandler(e:Event):void {
			try {
				navigateToURL(new URLRequest("http://www.cenfun.com"), "_blank");
			} catch (e:Error) {
			}
		}
		public function exitHandler(e:Event):void {
			NativeApplication.nativeApplication.icon.bitmaps = [];
			NativeApplication.nativeApplication.exit();
		}
		
		function resize(e:Event = null):void {
			html.width = stage.stageWidth;
			html.height = stage.stageHeight;
		}
		
	}
	
}
