package de.popforge.audio.processor.bitboy.formats.mod
{
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	/**
	 * @private
	 */
	
	public final class ModSample
	{
		public var title: String;
		public var length: int;
		public var tone: int;
		public var volume: int;
		public var repeatStart: int;
		public var repeatLength: int;
		public var waveform: ByteArray;
		public var wave: Array;
		
		public function ModSample( stream: ByteArray )
		{
			if( stream )
				parse( stream );
		}
		
		public function loadWaveform( stream: ByteArray ): void
		{
			if ( length == 0 )
				return;

			waveform = new ByteArray();
			
			wave = new Array();
			
			var value: Number;
			var min: Number = 1;
			var max: Number = -1;
			
			var i: int;
			
			for( i = 0 ; i < length ; i++ )
			{
				value = ( stream.readByte() + .5 ) / 127.5;
				
				if( value < min ) min = value;
				if( value > max ) max = value;
				
				wave.push( value );
			}
			
			var base: Number = ( min + max ) / 2;
			
			for( i = 0 ; i < length ; i++ )
				wave[i] -= base;
		}
		
		private function parse( stream: ByteArray ): void
		{
			stream.position = 0;			
			title = '';
			
			//-- read 22 chars into the title
			//   we dont break if we reach the NUL char cause this would turn
			//   the stream.position wrong
			for ( var i: int = 0; i < 22; i++ )
			{
				var char: uint = uint( stream.readByte() );
				if ( char != 0 )
					title += String.fromCharCode( char );
			}
			
			length = stream.readUnsignedShort();
			tone = stream.readUnsignedByte(); //everytime 0
			volume = stream.readUnsignedByte();
			repeatStart = stream.readUnsignedShort();
			repeatLength = stream.readUnsignedShort();

			//-- turn it into bytes
			length <<= 1;
			repeatStart <<= 1;
			repeatLength <<= 1;
		}
		
		public function clone(): ModSample
		{
			var sample: ModSample = new ModSample( null );
			
			sample.title = title;
			sample.length = length;
			sample.tone = tone;
			sample.volume = volume;
			sample.repeatStart = repeatStart;
			sample.repeatLength = repeatLength;
			sample.waveform = waveform;
			sample.wave = wave;
			
			return sample;
		}
		
		public function toString(): String
		{
			return '[MOD Sample'
				+ ' title: '+ title
				+ ', length: ' + length
				+ ', tone: ' + tone
				+ ', volume: ' + volume
				+ ', repeatStart: ' + repeatStart
				+ ', repeatLength: ' + repeatLength
				+ ']';
		}
	}
}