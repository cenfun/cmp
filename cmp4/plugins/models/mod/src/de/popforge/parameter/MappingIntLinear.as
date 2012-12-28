/**
 * Copyright(C) 2007 Andre Michelle and Joa Ebert
 *
 * PopForge is an ActionScript3 code sandbox developed by Andre Michelle and Joa Ebert
 * http://sandbox.popforge.de
 * 
 * This file is part of PopforgeAS3Audio.
 * 
 * PopforgeAS3Audio is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 * 
 * PopforgeAS3Audio is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>
 */
 package de.popforge.parameter
{
	import de.popforge.math.rint;
	
	/**
	 * MappingIntLinear interpolates(linear) a normalized value
	 * into the given range(min/max): int
	 * 
	 * @author Andre Michelle
	 */
	public class MappingIntLinear
		implements IMapping
	{
		private var min: Number;
		private var max: Number;
		
		public function MappingIntLinear( min: int = 0, max: int = 1 )
		{
			this.min = min;
			this.max = max;
		}
		
		public function map( normalizedValue: Number ): *
		{
			return rint( min + normalizedValue * ( max - min ) );
		}
		
		public function mapInverse( value: * ): Number
		{
			return ( value - min ) / ( max - min );
		}
	}
}