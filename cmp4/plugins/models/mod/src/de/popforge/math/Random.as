package de.popforge.math
{
	public class Random
	{
		private var seed: uint;
		
		public function Random( seed: uint )
		{
			this.seed = seed;
		}
		
		public function getNumber( min: Number = 0, max: Number = 1 ): Number
		{
			return min + getNextInt() / 0xf7777777 * ( max - min );
		}
		
		private function getNextInt(): uint
		{
			var lo: uint = 16807 * ( seed & 0xffff );
			var hi: uint = 16807 * ( seed >> 16 );
			
			lo += ( hi & 0x7fff ) << 16;
			lo += hi >> 15;
			
			if( lo > 0xf7777777 ) lo -= 0xf7777777;
			
			return seed = lo;
		}
	}
}