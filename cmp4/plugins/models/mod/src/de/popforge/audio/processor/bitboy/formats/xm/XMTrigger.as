package de.popforge.audio.processor.bitboy.formats.xm
{
	import flash.utils.ByteArray;
	
	public final class XMTrigger
	{
		private var instrumentIndex: uint;
		
		public var note: int;
		public var instrument: XMInstrument;
		
		public var volume: uint;
		public var volumeCommand: uint;
		public var hasVolume: Boolean;//is a volume command executed?
		
		public var effect: int;
		public var effectParam: int;
		public var hasEffect: Boolean;//is a effect command executed?
		
		public function XMTrigger( stream: ByteArray, instruments: Array )
		{
			parse( stream, instruments );
		}
		
		public function get period(): uint
		{//dirty hack for quick testing
			return note;
		}
		
		private function parse( stream: ByteArray, instruments: Array ): void
		{
			var type: int = stream.readUnsignedByte();
			
			volume = 0;
			volumeCommand = XMVolumeCommand.NO_COMMAND;
			
			if ( ( type & 0x80 ) != 0 )
			{
				if ( ( type & 0x01 ) != 0 ) note = stream.readUnsignedByte();
				if ( ( type & 0x02 ) != 0 ) instrumentIndex = stream.readUnsignedByte();
				if ( ( type & 0x04 ) != 0 )	volume = stream.readUnsignedByte();
				if ( ( type & 0x08 ) != 0 )	effect = stream.readUnsignedByte();
				if ( ( type & 0x10 ) != 0 )	effectParam = stream.readUnsignedByte();
			}
			else
			{
				note = type;
				instrumentIndex = stream.readUnsignedByte();
				volume = stream.readUnsignedByte();
				effect = stream.readUnsignedByte();
				effectParam = stream.readUnsignedByte();
			}
			
			if ( note == 97 )
			{
				// ModPlug displays these notes as == and sets
				// their value internal to 0xff
				note = 0xff;
			}
			else
			{
				if ( note > 0 && note < 97 )
				{
					note += 12;
					//do we need this?
				}
			}
			
			hasEffect = ( effect | effectParam ) != 0;
			
			if ( instrumentIndex == 0xff )
				instrumentIndex = 0;
				
			if ( instrumentIndex != 0 )
			{
				instrument = instruments[ int( instrumentIndex - 1 ) ];
			}
							
			if ( volume >= 0x10 && volume <= 0x50 )
			{
				volumeCommand = XMVolumeCommand.VOLUME;
				volume -= 0x10;
			}
			else if ( volume >= 0x60 )
			{
				volumeCommand = volume & 0xf0;
				volume &= 0x0f;
			}
			
			if ( volume == 0 && volumeCommand == XMVolumeCommand.NO_COMMAND )
			{
				hasVolume = false;
			}
			else
			{
				hasVolume = true;
			}
		}
		
		public function toString(): String
		{
			return '[XMTrigger instrument: ' + instrument + ', volume: ' + volume + ', effect: 0x' + effect.toString(0x10) + ', effectParam: 0x' + effectParam.toString(0x10) + ']';
		}
	}
}