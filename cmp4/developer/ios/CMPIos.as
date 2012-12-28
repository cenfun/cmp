package {

	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.html.*;
	import flash.system.*;
	import flash.desktop.*;
	import flash.geom.*;
	import flash.media.*;
	import flash.text.*;

	public class CMPIos extends MovieClip {
		private var url:String = "http://cmp.cenfun.com/cmp4/touch.htm";
		private var web:StageWebView;
		public function CMPIos() {
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = "TL";
			stage.addEventListener(Event.RESIZE, resizeHandler);
			//trace(Capabilities.version);
			//trace(NativeApplication.nativeApplication.runtimeVersion);
			web = new StageWebView();
			web.stage = stage;
			web.addEventListener(Event.COMPLETE, completeHandler);
			web.addEventListener(ErrorEvent.ERROR, errorHandler);
			web.loadURL(url);
			resizeHandler();
		}
		private function resizeHandler(e:Event = null):void {
			var rect:Rectangle = new Rectangle();
			rect.width = web.stage.stageWidth;
			rect.height = web.stage.stageHeight;
			web.viewPort = rect;
		}
		
		private function completeHandler(e:Event):void {
			//trace(e);
		}
		private function errorHandler(e:ErrorEvent):void {
			//trace(e);
			var msg:TextField = new TextField();
			msg.mouseEnabled = false;
			msg.selectable = false;
			msg.defaultTextFormat = new TextFormat(null, 20, 0xff0000);
			msg.text = e.toString();
			addChild(msg);
		}
	}
}