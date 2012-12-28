package de.popforge.audio.processor.bitboy.formats.xm
{
	import flash.utils.ByteArray;
	
	public final class XMSample
	{
		public var length: uint;
		
		public var loopStart: uint;
		public var loopLength: uint;
		
		public var loop: Boolean;
		public var pingPong: Boolean;
		
		public var volume: uint;
		public var fineTone: int;
		
		public var type: uint;
		
		public var panning: uint;
		
		public var relativeNote: int;
		
		public var wave: Array;
		public var name: String;
		
		//-- quick&dirty bitboy compatibility
		public var repeatStart: uint;
		public var repeatEnd: uint;
		
		public function XMSample( stream: ByteArray, sampleHeaderSize: uint = 0x28 )
		{
			parse( stream, sampleHeaderSize );
		}
		
		private function parse( stream: ByteArray, sampleHeaderSize: uint ): void
		{
			var i: int;
			var p: int = stream.position;
			
			length = stream.readUnsignedInt();
			
			loopStart = repeatStart = stream.readUnsignedInt();
			loopLength = stream.readUnsignedInt(); repeatEnd = loopStart + loopLength;
			
			//NOTE: if sampleLoopLength == 0 then sample is NOT looping (even if sampleType or smth has it set)
			
			volume = stream.readUnsignedByte();
			fineTone = stream.readByte();
			
			type = stream.readUnsignedByte();
			panning = stream.readUnsignedByte();
			
			if ( ( type & 0x10 ) != 0 )
			{
				trace( 'Error! Found a 16b sample' );
				throw new XMFormatError( XMFormatError.NOT_IMPLEMENTED );
			}
			
			if ( ( type & 0x20 ) != 0 )
			{
				trace( 'Error! Found a stereo sample' );
				throw new XMFormatError( XMFormatError.NOT_IMPLEMENTED );
				
				if ( ( type & 0x10 ) != 0 )
				{
					// stereo 16b
				}
				else
				{
					// stereo 8b
				}
			}
			
			if ( ( type & 2 ) != 0 )
			{
				pingPong = true;
			}
			
			if ( ( type & 3 ) != 0 )
			{
				loop = true;
			}

			if ( loopLength == 0 )
				loop = false;
				
			relativeNote = stream.readByte();
			
			//-- unused
			stream.readByte();
			
			name = stream.readMultiByte( 22, XMFormat.ENCODING );


			stream.position = p + sampleHeaderSize;
					
			//-- decode delta-encoded sample
			var delta: int = 0;	
			
			wave = new Array( length );
			
			for ( i = 0; i < length; ++i )
			{
				delta += stream.readByte();
				wave[ i ] = delta;
			}
		}
		
		public function toString(): String
		{
			const ENUM: Array = ['length',
				'loopStart',
				'loopLength',
				'loop',
				'pingPong',
				'volume',
				'fineTone',
				'type',
				'panning',
				'relativeNote',
				'wave',
				'name'];
			
			var result: String = '[XMSample';
			
			for ( var i: int = 0; i < ENUM.length; i++ )
			{
				result += ( i == 0 ? ' ' : ', ' ) + ENUM[ i ] + ': ' + this[ENUM[i]];
			}
			
			return result + ']';
		}
	}
}