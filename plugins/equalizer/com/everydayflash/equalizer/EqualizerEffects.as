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

 package com.everydayflash.equalizer {
	
	import flash.display.*;
	import flash.filters.BlurFilter;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Point;
	import com.gskinner.geom.ColorMatrix;
		
	/**
	  * This class is very basic, it is just to illustrate how different effect can be applied to the equalizer.
	  * The amount of possible effects (including most of the filters the AS3 offers) is almost infinite.
	  * For the sake of the demonstration I created four of them.
	  * 
	  * @author Bartek Drozdz (http://www.everydayflash.com)
	  * @version 1.0
	  */
	public class EqualizerEffects {
		
		private var equalizer:Equalizer;
		private var currentEffect:int;
		
		private var reflection:BitmapData;
		private var reflectionHolder:Bitmap;

		public function EqualizerEffects(eq:Equalizer) {
			equalizer = eq;
		}

		public function update(settings:EqualizerSettings):void {
			currentEffect = settings.effect;
			
			equalizer.filters = [new BlurFilter(0, 0, 1)];
			// Hack. Cleaning all the filters creates problems with refreshing the bitmap,
			// when changing the size of theequalizer. Normally, the size will not be
			// changed dynamically, so uncomment the line below and comment out the one above.
			// equalizer.filters = [];
			
			if (reflection != null && equalizer.contains(reflectionHolder)) {
				equalizer.removeChild(reflectionHolder);
				reflection.dispose();
				reflection == null;
			}
			
			switch(settings.effect) {
				case EqualizerSettings.FX_LIGHT_BLUR:
					equalizer.filters = [new BlurFilter(6, 6, 3)];
					break;
				case EqualizerSettings.FX_STRONG_BLUR:
					equalizer.filters = [new BlurFilter(12, 12, 3)];
					break;
				case EqualizerSettings.FX_REFLECTION:
					reflection = new BitmapData(settings.getWidth(), settings.height, true, 0x00000000);
					reflectionHolder = new Bitmap(reflection);
					reflectionHolder.y = settings.height * 1.6;
					reflectionHolder.x = 0;
					reflectionHolder.rotation = 180;
					reflectionHolder.scaleX = -1;
					reflectionHolder.scaleY = 0.6;
					var cm:ColorMatrix = new ColorMatrix();
					cm.adjustBrightness(-60);
					reflectionHolder.filters = [new ColorMatrixFilter(cm), new BlurFilter(6, 6, 3)];
					equalizer.addChild(reflectionHolder);
					reflectionHolder.alpha = 0.8;
					break;
				default:
					break;
			}
		}
		
		public function onRendered():void {
			if (currentEffect == EqualizerSettings.FX_REFLECTION) {
				reflection.copyPixels(equalizer.canvas, equalizer.canvas.rect, new Point(0, 0));
			}
		}
	}
}





