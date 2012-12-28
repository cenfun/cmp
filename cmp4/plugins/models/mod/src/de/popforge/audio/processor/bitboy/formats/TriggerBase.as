package de.popforge.audio.processor.bitboy.formats
{
	/**
	 * 
	 * @author Joa Ebert
	 */
	public class TriggerBase
	{
		/**
		* The effect that is initialized with this trigger.
		*/		
		public var effect: uint;
		
		/**
		* The parameter for the effect.
		*/	
		public var effectParam: uint;
		
		/**
		* If the trigger has any impact on effects or not.
		*/		
		public var hasEffect: Boolean;
		
		/**
		* The period for the trigger.
		*/		
		public var period: uint;


		/**
		 * Creates a new TriggerBase object.
		 * 
		 * Each property of the TriggerBase will be set to its default value.
		 */	
		public function TriggerBase()
		{
			effect = 0;
			effectParam = 0;
			
			hasEffect = false;
			
			period = 0;
		}
		
		/**
		 * Creates and returns the string representation of the object.
		 * @return The string represenation of the object.
		 */	
		public function toString(): String
		{
			return '[TriggerBase]';
		}
	}
}