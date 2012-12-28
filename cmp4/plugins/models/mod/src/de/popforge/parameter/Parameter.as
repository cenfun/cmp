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
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	import flash.utils.IExternalizable;
	import flash.net.registerClassAlias;
	
	/**
	 * class Parameter stores an untyped value
	 * Depending on its mapping it can handle different types of values
	 * as Number, Boolean, Array
	 * 
	 * It also informs listeners if the value has changed.
	 * 
	 * @author Andre Michelle
	 */
	public class Parameter
		implements IExternalizable
	{
		{
			registerClassAlias( 'Parameter', Parameter );
		}
		
		private var value: *;
		private var mapping: IMapping;

		private var defaultValue: *;

		private var changedCallbacks: Array;
		
		/**
		 * Creates a Parameter instance
		 * 
		 * @param mapping The mapping used to map/mapInverse the normalized value
		 * @param value The default values
		 */
		public function Parameter( mapping: IMapping = null, value: * = null )
		{
			this.mapping = mapping;
			this.value = defaultValue = value;
			
			changedCallbacks = new Array();
		}
		
		public function writeExternal( output: IDataOutput ): void
		{
			output.writeObject( value );
			output.writeObject( defaultValue );
		}
		
		public function readExternal( input: IDataInput ): void
		{
			setValue( input.readObject() );
			defaultValue = input.readObject();
		}

		/**
		 * Sets the current value of the parameter
		 * 
		 * if changed, inform all callbacks
		 */
		public function setValue( value: * ): void
		{
			var oldValue: * = this.value;
			
			this.value = value;
			
			valueChanged( oldValue );
		}
		
		/**
		 * Returns the current value of the parameter
		 */
		public function getValue(): *
		{
			return value;
		}
		
		/**
		 * Sets the current value of the parameter
		 * by passing a normalized value between 0 and 1
		 * 
		 * if changed, inform all callbacks
		 * 
		 * @param normalizedValue A normalized value between 0 and 1
		 */
		public function setValueNormalized( normalizedValue: Number ): void
		{
			var oldValue: * = value;
			
			value = mapping.map( normalizedValue );
			
			valueChanged( oldValue );
		}

		/**
		 * Returns the current normalized value of the parameter
		 * between 0 and 1
		 */
		public function getValueNormalized(): Number
		{
			return mapping.mapInverse( value );
		}
		
		/**
		 * Reset value to its initial default value
		 */
		public function reset(): void
		{
			setValue( defaultValue );
		}
		
		/**
		 * adds a callback function, invoked on value changed
		 * 
		 * @param callback The function, that will be invoked on value changed
		 */
		public function addChangedCallbacks( callback: Function ): void
		{
			changedCallbacks.push( callback );
		}

		/**
		 * removes a callback function
		 * 
		 * @param callback The function, that will be removed
		 */
		public function removeChangedCallbacks( callback: Function ): void
		{
			var index: int = changedCallbacks.indexOf( callback );
			
			if( index > -1 )
				changedCallbacks.splice( index, 1 );
		}
		
		private function valueChanged( oldValue: * ): void
		{
			if( oldValue == value )
				return;
			
			try
			{
				for each( var callback: Function in changedCallbacks )
					callback( this, oldValue, value );
			}
			catch( e: ArgumentError )
			{
				throw new ArgumentError( 'Make sure callbacks have the following signature: (parameter: Parameter, oldValue: *, newValue: *)' );
			}
		}
	}
}