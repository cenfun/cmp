package com.anttikupila.revolt.drawers {
	import flash.display.Sprite;
	import flash.display.BitmapData;
	import com.anttikupila.revolt.drawers.Drawer;
	
	public class SimpleLine extends Drawer {
		private var lineSprite:Sprite;
		private var color:String;
		function SimpleLine(col:String=undefined) {
			if(col == undefined) {
				color = 0xEEEEEE;
			} else {
				color = uint('0x'+col);
			}
			super();
			fourier = false;
			lineSprite = new Sprite();
		}
		
		override public function drawGFX(gfx:BitmapData, soundArray:Array):void {
			lineSprite.graphics.clear();
			lineSprite.graphics.moveTo(0, gfx.height/2);
			for (var i:uint = 0; i < soundArray.length; i+=2) {
				var a:uint = i;
				if (i >= soundArray.length/2) a -= soundArray.length/2;
				if (i == soundArray.length/2) lineSprite.graphics.moveTo(0, gfx.height/2);
				lineSprite.graphics.lineStyle(1,color);
				var xPos:Number = (a/(soundArray.length))*(gfx.width*4+2);
				var yPos:Number = -soundArray[i]*gfx.height/2;
				xPos -= 2; // to prevent black line to the left
				if (i >= soundArray.length/2) yPos *= -1;
				lineSprite.graphics.lineTo(xPos, yPos + gfx.height/2);
			}
			gfx.draw(lineSprite);
		}
	}
}