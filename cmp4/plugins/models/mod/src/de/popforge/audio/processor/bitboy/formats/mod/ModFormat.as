package de.popforge.audio.processor.bitboy.formats.mod
{
	import de.popforge.audio.processor.bitboy.BitBoy;
	import de.popforge.audio.processor.bitboy.channels.ModChannel;
	import de.popforge.audio.processor.bitboy.formats.FormatBase;
	
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	/**
	 * @private
	 */

	public final class ModFormat extends FormatBase
	{
		static public function decode( stream: ByteArray ): ModFormat
		{
			return new ModFormat( stream );
		}
		
		// ModFormat specific
		public var modSamples: Array;

		//-- MOD format
		public var format: String;
			
		//-- define some positions in the file
		private const P_FORMAT: uint = 0x438;
		private const P_LENGTH: uint = 0x3b6;
		private const P_SEQUENCE: uint = 0x3b8;
		private const P_PATTERNS: uint = 0x43c;
		
		public function ModFormat( stream: ByteArray )
		{
			super( stream );
			
			modSamples = new Array( 32 );
			format = '';

			numChannels = 4;
					
			restartPosition = 0;

			defaultBpm = 125;
			defaultSpeed = 6;
					
			parse( stream );
		}
		
		override public function getChannels( bitboy: BitBoy ):Array
		{
			return [
					new ModChannel( bitboy, 0, -1 ),
					new ModChannel( bitboy, 1,  1 ),
					new ModChannel( bitboy, 2,  1 ),
					new ModChannel( bitboy, 3, -1 )
				];
		}
		
		override protected function parse( stream: ByteArray ): void
		{
			stream.endian = Endian.LITTLE_ENDIAN;
			stream.position = P_FORMAT;
			
			var patternNum: int = 0;
			
			//-- mod format
			format = String.fromCharCode( stream.readByte() ) + String.fromCharCode( stream.readByte() ) +
  					 String.fromCharCode( stream.readByte() ) + String.fromCharCode( stream.readByte() );
			
			if ( format.toLocaleLowerCase() != 'm.k.' )
				throw new Error( 'Unsupported MOD format' );
			
			 var i: int;
			
			//-- title
			title = '';
			stream.position = 0;
			for ( i = 0; i < 20; i++ )
			{
				var char: uint = stream.readUnsignedByte();			
				if ( char == 0 )
					break;	
				title += String.fromCharCode( char );
			}
			
			//-- sequence length
			stream.position = P_LENGTH;
			length = stream.readUnsignedByte();
			
			//-- samples
			var bytes: ByteArray = new ByteArray();
        	for ( i = 1; i <= 31; i++ )
        	{  		
            	stream.position = ( i - 1 ) * 0x1e + 0x14;
				bytes.position = 0;
				
				stream.readBytes( bytes, 0, 30 );	

				modSamples[ i ] = new ModSample( bytes );
	        }
	        
	        //-- sequence
	        stream.position = P_SEQUENCE;
			sequence = new Array( length );
				
			for ( i = 0; i < length; i++ )
			{
				sequence[ i ] = stream.readUnsignedByte();
				
				if ( sequence[ i ] > patternNum ) 
					patternNum = sequence[ i ];
			}
			
			
			numPatterns = patternNum;
		
			//-- patterns
			for ( i = 0; i < patternNum + 1; i++ )
			{
				//-- 4bytes * 4channels * 64rows = 0x400bytes
				stream.position = P_PATTERNS + i * 0x400;
				
				patterns[ i ] = new Array( 64 );
				
				for ( var j: int = 0; j < 64; j++ )
				{
					patterns[ i ][ j ] = new Array( 4 );
					for ( var k: int = 0; k < 4; k++ )
					{
						patterns[ i ][ j ][ k ] = new ModTrigger( stream, modSamples );
						
						//if( k == 0 )
						//{
						//	trace( j, patterns[ i ][ j ][ k ] );
						//}
					}
				}
			}
			
			//-- waveforms
			var sample: ModSample;
			for ( i = 1; i <= 31; i++ )
			{
				sample = ModSample( modSamples[ i ] );
				sample.loadWaveform( stream );	
			}
			
			//-- credits
			var modSample: ModSample;

			for( i = 1; i < modSamples.length; i++ )
			{
				modSample = modSamples[i];
				
				if( modSample.title != '' )
				{
					credits.push( modSample.title );
				}
			}
		}
	}
}