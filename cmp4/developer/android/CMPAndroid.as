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

	public class CMPAndroid extends MovieClip {
		
		private var web:StageWebView;
		public function CMPAndroid() {
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = "TL";
			stage.addEventListener(Event.RESIZE, resizeHandler);
			//trace(Capabilities.version);
			//trace(NativeApplication.nativeApplication.runtimeVersion);
			web = new StageWebView();
			web.stage = stage;
			web.addEventListener(Event.COMPLETE, completeHandler);
			web.addEventListener(ErrorEvent.ERROR, errorHandler);
			resizeHandler();
			
			/*
			var htmlString:String = "<!DOCTYPE HTML>" +
                        "<html>" +
                            "<body>" +
                                "<h1>Example</h1>" +
                                "<p>King Phillip cut open five green snakes.</p>" +
                            "</body>" +
                        "</html>";

			web.loadString( htmlString, "text/html" );
			*/
			
			var url:String = "http://cmp.cenfun.com/cmp4/touch.htm";
			//url = "http://www.cenfun.com/";
			web.loadURL(url);
		}
		private function resizeHandler(e:Event = null):void {
			var sw:int = web.stage.stageWidth;
			var sh:int = web.stage.stageHeight;
			if (sw > 0 && sh > 0 && sw < 1920 && sh < 1920) {
				var rect:Rectangle = new Rectangle();
				rect.x = 0;
				rect.y = 0;
				rect.width = sw;
				rect.height = sh;
				trace(rect);
				web.viewPort = rect;
			}
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