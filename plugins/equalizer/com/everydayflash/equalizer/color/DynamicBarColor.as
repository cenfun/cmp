/**
 * Copyright (c) 2008 Bartek Drozdz (http://www.everydayflash.com)
 * 
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 * 
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */

 package com.everydayflash.equalizer.color {
	
	import com.everydayflash.equalizer.EqualizerSettings;
	
	/**
	  * @author Bartek Drozdz (http://www.everydayflash.com)
	  * @version 1.0
	  */
	public class DynamicBarColor implements BarColor {
		
		private var r:uint;
		private var g:uint;
		private var b:uint;
		private var turn:int;

		private var colorRange:int = 210;
		
		public function DynamicBarColor() {
			turn = 0;
			r = 0;
			g = 0;
			b = 0;
		}
		
		public function setSettings(settings:EqualizerSettings):void {
			// Dynamic color does not need the settings
		}
		
		public function getColor(x:int, y:int):uint {
			var rc:int = Math.abs(colorRange - (r%(colorRange*2))) + ((255-colorRange));
			var gc:int = Math.abs(colorRange - (g%(colorRange*2))) + ((255-colorRange));
			var bc:int = Math.abs(colorRange - (b%(colorRange*2))) + ((255-colorRange));
				
			return (255 << 24) + (rc << 16) + (gc << 8) + (bc);
		}
		
		public function onRendered():void {
			switch(turn) {
				case 0:
					r++;
					if (r % colorRange == 0) turn = 1;
					break;
				case 1:
					r++;
					if (g % colorRange == 0) turn = 2;
					break;
				case 2:
					r++;
					if (b % colorRange == 0) turn = 0;
					break;
			}
		}
	}
}















