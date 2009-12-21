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

package com.everydayflash.equalizer.util
{
	
	import flash.utils.ByteArray;
	import flash.media.SoundMixer;
	
	/**
	  * @author Bartek Drozdz (http://www.everydayflash.com)
	  * @version 1.0
	  */
	public class SpectrumReader {
		
		private var bytes:ByteArray;
		private var reduction:int;
		private var size:int;
		private var resultTemplate:Array;
		
		private var SPECTRUM_LENGTH:Number = 512;
		
		private var ARITHMETIC_MEAN:int = 0;
		private var GEOMTRIC_MEAN:int = 0;
		private var MEDIAN:int = 0;
		private var CM_ARITHMETIC_MEAN:int = 0;
		
		/**
		 * This utility class read the byets from the SoundMixer.computeSpectrum byte array
		 * and transform it into an Array of numbers renging from 0 to 1 of the given size.
		 * 
		 * It has several different methods to reduce to 512 values from  the spectrum to the size expected, 
		 * including arithmetic and geometric means and a median. 
		 * 
		 * @param _size Size of the result array - corrseponds to the number of bars in the Equalizer.
		 * 
		 * It is strongly recommeded that size is a value that is a power of 2. It was not tested on any other
		 * values.
		 */
		public function SpectrumReader(_size:int) {
			size = _size;

			reduction = Math.round(SPECTRUM_LENGTH / size);
			bytes = new ByteArray();
			resultTemplate = new Array();
			for (var i:int = 0; i < size; i++) resultTemplate.push(0);
		}

		public function getSpectrum():Array {
			var result:Array;
			
			try {
				SoundMixer.computeSpectrum(bytes, true, 0);
				result = byMaximumValues(bytes);
			} catch (e:Error) {
				// the computeSpectrum() throws a "Security violation" error occurs sometimes. Ignore it.
			}
			
			// Optionally the results can by multiplied (no need if byMaximumValues() is used)
			// result = multiply(result, 1.4);
			
			return reverseLeftChannel(result);
		}
		
		/**
		 * This and the following methods reduce the data from the spectrum bytearray to an array of Numbers of the correct size 
		 * (= value of the 'size' property). 
		 * 
		 * This method returns the maximum value from each group. 
		 */
		private function byMaximumValues(spectrum:ByteArray):Array {
			var byMax:Array = resultTemplate.concat();
			
			for (var i:uint = 0; i < SPECTRUM_LENGTH; i++) 
				byMax[Math.floor(i / reduction)] = Math.max(spectrum.readFloat(), byMax[Math.floor(i / reduction)]);
				
			return byMax;
		}
		
		/**
		 * This method returns the common average value ('arithmetic mean') from each group.
		 */
		private function byArithmeticMean(spectrum:ByteArray):Array {
			var byArMean:Array = resultTemplate.concat();
			
			for (var i:int = 0; i < SPECTRUM_LENGTH; i++) 
				byArMean[Math.floor(i / reduction)] += spectrum.readFloat();
				
			for (i = 0; i < size; i++) 
				byArMean[i] = byArMean[i] / reduction;
				
			return byArMean;
		}
		
		/**
		 * This method returns the geometric mean from each group.
		 * (Anybody has any idea how to deal with 0 values when calculating geometric means?)
		 */
		private function byGeometricMean(spectrum:ByteArray):Array {
			var byGeomMean:Array = resultTemplate.concat();
			
			for (var i:int = 0; i < SPECTRUM_LENGTH; i++) {
				var float:Number = spectrum.readFloat();
				var pos:Number = Math.floor(i / reduction);
				
				if(byGeomMean[pos] == 0) byGeomMean[pos] = float;
				else if (float > 0) byGeomMean[Math.floor(i / reduction)] *= float;
			}
				
			for (i = 0; i < size; i++) 
				byGeomMean[i] = Math.pow(byGeomMean[i], 1 / reduction);
				
			return byGeomMean;
		}
		
		/**
		 * This method returns the median value from each group.
		 * 
		 * NOTE. The method always assumes that the value 'reduction' is even. If, as recommeded, the size 
		 * is a power of 2 that it is even all the time indeed. 
		 */
		private function byMedian(spectrum:ByteArray):Array {
			var floats:Array = new Array;
			var byMed:Array = resultTemplate.concat();
			
			for (var i:int = 0; i < SPECTRUM_LENGTH; i++) 
				floats.push(spectrum.readFloat());
			
			for (i = 0; i < SPECTRUM_LENGTH; i += reduction) 
				byMed[Math.floor(i / reduction)] = (floats[i + reduction/2] + floats[(i + reduction/2) + 1])/2;
				
			return byMed;
		}
		
		/**
		 * ++ EXPERIMENTAL ++ 
		 * This method returns the median value from each group, except the situation if the median is 0.
		 * In this case it will look for the first non-zero value in the set and return it. If all values
		 * in the set are 0, only then 0 will be returned.
		 * 
		 * NOTE. The method always assumes that the value 'reduction' is even. If, as recommeded, the size 
		 * is a power of 2 that it is even all the time indeed. 
		 */
		private function byMedianNoZero(spectrum:ByteArray):Array {
			var floats:Array = new Array;
			var byMed:Array = resultTemplate.concat();
			
			for (var i:int = 0; i < SPECTRUM_LENGTH; i++) 
				floats.push(spectrum.readFloat());
			
			for (i = 0; i < SPECTRUM_LENGTH; i += reduction) {
				if (floats[i + reduction / 2] != 0) {
					byMed[Math.floor(i / reduction)] = (floats[i + reduction/2] + floats[(i + reduction/2) + 1])/2;
				} else {
					for (var j:int = 0; j < reduction; j++) {
						byMed[Math.floor(i / reduction)] = floats[i + j];
						if (byMed[Math.floor(i / reduction)] > 0) break;
					}
					
				}
			}
				
			return byMed;
		}
		
		/**
		 * Multiplies each value by factor but forces it to be < 1.
		 */
		private function multiply(result:Array, factor:Number):Array {
			var multiplied:Array = new Array()
			for (var i:int = 0; i < size; i++) 
				multiplied.push( Math.min((result[i] * factor), 1) );
			
			return multiplied;
		}
		
		/**
		 * Reverses the left half of the result values so that Equalizer 
		 * has the form of a pyramid '/\' rather than of two triangles '|\|\'
		 */
		private function reverseLeftChannel(result:Array):Array {
			var reversed:Array = new Array();
			for (var i:int = 0; i < size; i++) {
				var si:uint = (i < (size / 2)) ? (size / 2) - i -1 : i;
				reversed[si] = result[i];
			}
			return reversed;
		}

		public function getSize():int {
			return size;
		}
		
	}

}















