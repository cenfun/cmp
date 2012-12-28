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
	/**
	 * MappingNumberLinear interpolates(exponential) a normalized value
	 * into the given range(min/max): Number
	 * 
	 * @author Andre Michelle
	 */
	public class MappingNumberExponential
		implements IMapping
	{
		private var min: Number;
		private var max: Number;
		
		private var t0: Number;
		private var t1: Number;
		
		public function MappingNumberExponential( min: Number, max: Number )
		{
			this.min = min;
			this.max = max;
			
			t0 = Math.log( max / min );
			t1 = 1.0 / t0;
		}
		
		public function map( normalizedValue: Number ): *
		{
			return min * Math.exp( normalizedValue * t0 );
		}
		
		public function mapInverse( value: * ): Number
		{
			return Math.log( value / min ) * t1;
		}
	}
}