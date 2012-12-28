package de.popforge.audio.processor.bitboy.formats.xm
{
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import de.popforge.audio.processor.bitboy.formats.FormatBase;
	
	public final class XMFormat extends FormatBase
	{
		internal static const ENCODING: String = 'us-ascii';
		
		private static const MAX_CHANNELS: uint = 0x20;
		private static const MAX_INSTRUMENTS: uint = 0x80;
		private static const MAX_PATTERNS: uint = 0x100;
		private static const MAX_LENGTH: uint = 0x100;
		
		//public var patterns: Array;
		
		//public var sequence: Array; //pattern order
		//public var length: uint; //sequence length
		//public var restartPosition: uint;
		
		//public var title: String;
		
		//public var numChannels: uint;
		//public var numPatterns: uint;
		public var numInstruments: uint;
		
		public var useLinearSlides: Boolean;
		
		public var defaultTempo: uint;
		public var defaultBPM: uint;
		
		private var instruments: Array;
		
		static public function decode( stream: ByteArray ): XMFormat
		{
			return new XMFormat( stream );
		}
		
		public function XMFormat( stream: ByteArray )
		{
			super( stream );
			
			instruments = new Array;
			
			parse( stream );
		}
		
		override protected function parse( stream: ByteArray ): void
		{
			var i: int;
			
			stream.position = 0;
			stream.endian = Endian.LITTLE_ENDIAN;
			
			var idText: String = stream.readMultiByte( 17, ENCODING );
			title = stream.readMultiByte( 20, ENCODING );

			if ( idText.toLowerCase() != 'extended module: ' )
				throw new XMFormatError( XMFormatError.FILE_CORRUPT );
				
			if ( stream.readUnsignedByte() != 0x1a )
				throw new XMFormatError( XMFormatError.FILE_CORRUPT );
				
			var trackerName: String = stream.readMultiByte( 20, ENCODING );
			
			var version: uint = stream.readUnsignedShort();
	
			if ( version > 0x0104 )//01 = major, 04 = minor
				throw new XMFormatError( XMFormatError.NOT_IMPLEMENTED );
			
			var headerSize: uint = stream.readUnsignedInt();
			
			length = stream.readUnsignedShort();//songLength in patterns
			
			if ( length > MAX_LENGTH )
				throw new XMFormatError( XMFormatError.MAX_LENGTH );
			
			restartPosition = stream.readUnsignedShort();
			
			numChannels = stream.readUnsignedShort();
			
			if ( numChannels > MAX_CHANNELS )
				throw new XMFormatError( XMFormatError.MAX_CHANNELS );
			
			numPatterns = stream.readUnsignedShort();
			
			if ( numPatterns > MAX_PATTERNS )
				throw new XMFormatError( XMFormatError.MAX_PATTERNS );
			
			numInstruments = stream.readUnsignedShort();
			
			if ( numInstruments > MAX_INSTRUMENTS )
				throw new XMFormatError( XMFormatError.MAX_INSTRUMENTS );
			
			var flags: uint = stream.readUnsignedShort();
			
			useLinearSlides = ( ( flags & 1 ) == 1 );
			
			defaultTempo = stream.readUnsignedShort();
			
			defaultBPM = stream.readUnsignedShort();
			
			sequence = new Array( length );
			
			for ( i = 0; i < length; ++i )
			{
				sequence[ i ] = stream.readUnsignedByte();
			}
			
			stream.position += 0x100 - length;
			
			//-- seek to instruments by getting pattern headers
			for ( i = 0; i < numPatterns; ++i )
			{
				patterns.push( new XMPattern( stream ) );
			}
			
			//-- parse instruments
			for ( i = 0; i < numInstruments; ++i )
			{
				instruments.push( new XMInstrument( stream, i + 1 ) );
			}
			
			//-- parse pattern data now
			for ( i = 0; i < numPatterns; ++i )
			{
				XMPattern( patterns[ i ] ).parseData( stream, numChannels, instruments );
			}
			
			// access a trigger:
			// patternId = id of pattern
			// rowNumber = number of row in pattern
			// channelNumber = desired channel
			//
			// XMTrigger( XMPattern( patterns[ patternId ] ).rows[ rowNumber ][ channelNumber ] )
		}
	}
}