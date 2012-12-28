package de.popforge.audio.processor.bitboy.formats.mod
{
	import flash.utils.ByteArray;
	import de.popforge.audio.processor.bitboy.formats.TriggerBase;
	
	/**
	 * @private
	 */	
	
	public final class ModTrigger extends TriggerBase
	{
		//public var effect: uint;
		//public var effectParam: uint;
		//public var period: uint;
		public var modSample: ModSample;
		
		public function ModTrigger( stream: ByteArray, modSamples: Array )
		{
			parse( stream, modSamples );
		}
		
		private function parse( stream: ByteArray, modSamples: Array ): void
		{
			/*
			 Byte 0    Byte 1   Byte 2   Byte 3
			 aaaaBBBB CCCCCCCCC DDDDeeee FFFFFFFFF
			
			 aaaaDDDD     = sample number
			 BBBBCCCCCCCC = sample period value
			 eeee         = effect number
			 FFFFFFFF     = effect parameters
			*/
			
			var b0: int = stream.readUnsignedByte();
			var b1: int = stream.readUnsignedByte();
			var b2: int = stream.readUnsignedByte();
			var b3: int = stream.readUnsignedByte();
			
			modSample = modSamples[ ( b0 & 0xf0 ) | ( b2 >> 4 ) ];
			period = ( ( b0 & 0x0f ) << 8 ) | b1;
			effect = b2 & 0x0F;
			effectParam = b3;
		}
		
		override public function toString(): String
		{
			return '[MOD Trigger'
				+ ' modSample: '+ modSample
				+ ', period: ' + period
				+ ', effect: ' + effect
				+ ', effectParam: ' + effectParam
				+ ']';
		}
	}
}