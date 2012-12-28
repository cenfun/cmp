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
	 * MappingValues maps a normalized value
	 * to a value inside the passed Array
	 * 
	 * @author Andre Michelle
	 */
	public class MappingValues
		implements IMapping
	{
		private var values: Array;
		
		public function MappingValues( values: Array )
		{
			this.values = values;
		}
		
		public function map( normalizedValue: Number ): *
		{
			if( normalizedValue == 1 )
				return values[ values.length - 1 ];
			
			return values[ int( normalizedValue * values.length ) ];
		}
		
		public function mapInverse( value: * ): Number
		{
			return values.indexOf( value ) / ( values.length - 1 );
		}
	}
}