package de.popforge.math
{
	/**
	 * The RMS class represents the root-mean-square of a set of
	 * values (window) with a given width.
	 * 
	 * @author Joa Ebert
	 */
	public class RMS
	{
		private static const sqrt: Function = Math.sqrt;
		
		private var $width: uint;
		private var $sum: Number;
		private var $value: Number;
		
		private var window: Array;
		
		/**
		 * Creates a new RMS object.
		 * 
		 * @param windowTime The width of the window.
		 * 
		 */	
		public function RMS( width: uint )
		{
			$width = width;
			window = new Array( $width );
			
			reset();
		}
		
		/**
		 * Resets the sum and window.
		 */	
		public function reset(): void
		{
			var i: int = 0;
			var n: int = $width;
			
			$sum = 0;
			
			for (;i<n;++i)
				window[i] = 0;
		}
		
		/**
		 * The width of the window.
		 */	
		public function get width(): uint { return $width; }
		
		/**
		 * The sum of all values.
		 */	
		public function get sum(): Number { return $sum; }
		
		/**
		 * The root-mean-squared value of the sum.
		 */	
		public function get value(): Number { return $value; }
	
		/**
		 * Updates the sum of the values based on the window width.
		 * 
		 * @param sample The new sample to insert.
		 * 
		 */
		public function update( value: Number ): void
		{
			var squaredValue: Number = value * value;
	
			window.push( squaredValue );
			
			$sum -= window.shift();
			$sum += squaredValue;
			
			$value = sqrt( $sum / $width );
		}
	}
}