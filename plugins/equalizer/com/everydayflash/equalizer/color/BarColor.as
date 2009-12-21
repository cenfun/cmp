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

 /**
  *  This interface can be implemented and supplied to the EqualizerSettings.
  *  It will be used to get the color for the equalizer bars. See the method 
  *  level comments and the three implementations in this package for details. 
  */
 package com.everydayflash.equalizer.color {
	
	import com.everydayflash.equalizer.EqualizerSettings;
	
	/**
	  * @author Bartek Drozdz (http://www.everydayflash.com)
	  * @version 1.0
	  */
	public interface BarColor {
		
		/**
		 * The Equalizer class will call this method. If you need the settings info
		 * to generate the colors keep it as a private field, otherwise you don't need
		 * to implement this method.
		 * 
		 * @param	settings EqualizerSettings
		 */
		function setSettings(settings:EqualizerSettings):void;
		
		/**
		 * Basic function to get the color. 
		 * 
		 * @param	x the x coordinate of the pixel inside the equalizer canvas
		 * @param	y the y coordinate of the pixel inside the equalizer canvas
		 * @return  an ARGB value
		 */
		function getColor(x:int, y:int):uint;
		
		/**
		 * Invoked by the Equalizer class after the equalizer has finished rendering 
		 * in EnterFrame event. Can be used to modify color parameters or can 
		 * be just left empty.
		 */
		function onRendered():void;
	}
	
}