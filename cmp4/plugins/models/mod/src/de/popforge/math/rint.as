package de.popforge.math
{
	/**
	 * Rounds a Number to an Integer with respect to its sign
	 */
	public function rint( value: Number ): int
	{
		if( value > 0 )
			return value + .5;
		if( value < 0 )
			return -int( -value + .5 );
		else
			return 0;
	}
}