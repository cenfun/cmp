package src{
	import flash.display.*;
	import flash.text.*;
	public class BitmapText extends Sprite {
		public var bmp:Bitmap;
		public function BitmapText(str:String, format:TextFormat, maxsize:Number = 120):void {
			var size:Object = format.size;
			//原始效果文本
			var tfs:TextField = new TextField();
			tfs.autoSize = "left";
			tfs.defaultTextFormat = format
			tfs.text = String(str);
			//取得原始宽高
			var tw:Number = tfs.width;
			var th:Number = tfs.height;
			//为消除锯齿，设置大尺寸去克隆
			format.size = maxsize;
			//绘图样本
			var tfd:TextField = new TextField();
			tfd.autoSize = "left";
			tfd.defaultTextFormat = format
			tfd.text = String(str);
			//还原尺寸
			format.size = size;
			//打散到位图
			var bd:BitmapData = new BitmapData(tfd.width, tfd.height, true, 0);
			bd.draw(tfd);
			bmp = new Bitmap(bd);
			bmp.smoothing = true;
			bmp.cacheAsBitmap = true;
			bmp.width = tw;
			bmp.height = th;
			addChild(bmp);
		}

	}

}