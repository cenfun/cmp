package de.popforge.audio.processor.bitboy.formats.xm
{
	import flash.utils.ByteArray;
	
	public final class XMPattern
	{
		private var numRows: uint;		

		private var headerLength: uint;
		private var packingType: uint;

		private var packedDataSize: uint;
		private var dataOffset: uint;
		
		public var rows: Array;
		
		public function XMPattern( stream: ByteArray )
		{
			parse( stream );
		}
		
		public function row( index: int ): Array
		{
			return rows[ index ];
		}

		private function parse( stream: ByteArray ): void
		{
			headerLength = stream.readUnsignedInt();
			packingType = stream.readUnsignedByte();
			
			numRows = stream.readUnsignedShort();
			rows = new Array( numRows );
						
			packedDataSize = stream.readUnsignedShort();
			dataOffset = stream.position;
			
			//-- skip data for now
			stream.position += packedDataSize;
		}
		
		internal function parseData( stream: ByteArray, numChannels: uint, instruments: Array ): void
		{
			var i: int, j: int;
			
			stream.position = dataOffset;
			
			if ( packedDataSize <= 0 )
			{
				var emptyElement: ByteArray = new ByteArray;
				
				emptyElement.writeByte( 0x81 );//use packed note to read 0x80
				emptyElement.writeByte( 0x80 );

				for ( i = 0; i < numRows; i++ )
				{
					rows[ i ] = new Array( numChannels );
					
					for ( j = 0; j < numChannels; j++ )
					{
						emptyElement.position = 0;
						rows[ i ][ j ] = new XMTrigger( emptyElement, instruments );
					}
				}
			}
			else
			{
				for ( i = 0; i < numRows; i++ )
				{
					rows[ i ] = new Array( numChannels );
					
					for ( j = 0; j < numChannels; j++ )
					{
						rows[ i ][ j ] = new XMTrigger( stream, instruments );
					}
				}
			}
		}
		
		public function toString(): String
		{
			return '[XMPattern headerLength: ' + headerLength + ', packingType: ' + packingType + ', numRows: ' + numRows + ', packedDataSize: ' + packedDataSize + ']';
		}
		
		public function toASCII(): String
		{
			if ( packedDataSize == 0 )
				return '(empty)\n';
				
			var patternString: String = '';
			var numChannels: uint = rows[0].length;
			var row: Array;
			var line: String;
			
			for ( var i: int = 0; i < numRows; ++i )
			{
				row = rows[ i ];
				
				line = pad( i.toString() ) + ': ';
				
				for ( var j: int = 0; j < numChannels; ++j )
				{
					if ( j != 0 ) line += ' | ';
					
					var trigger: XMTrigger = row[ j ];
					
					if ( trigger.note == 0xff )
						line += '==';
					else
						line += ( trigger.note == 0 ? '..' : pad( trigger.note.toString() ) );
					
					line += ' ' + pad( ( trigger.instrument == null ? '..' : trigger.instrument.index.toString() ) );
					
					
					if ( !trigger.hasVolume )
					{
						line += ' ...';
					}
					else
					{
						line += ' ';
						
						switch ( trigger.volumeCommand )
						{
							case XMVolumeCommand.PANNING:				line += 'p'; break;
							case XMVolumeCommand.PANNING_SLIDE_LEFT:	line += 'l'; break;
							case XMVolumeCommand.PANNING_SLIDE_RIGHT:	line += 'r'; break;
							case XMVolumeCommand.TONE_PORTAMENTO:		line += 'g'; break;
							case XMVolumeCommand.VIBRATO:				line += 'v'; break;
							case XMVolumeCommand.VIBRATO_SPEED:			line += 'h'; break;
							case XMVolumeCommand.VOLUME:				line += 'v'; break;
							case XMVolumeCommand.VOLUME_FINE_DOWN:		line += 'b'; break;
							case XMVolumeCommand.VOLUME_FINE_UP:		line += 'a'; break;
							case XMVolumeCommand.VOLUME_SLIDE_DOWN:		line += 'd'; break;
							case XMVolumeCommand.VOLUME_SLIDE_UP:		line += 'c'; break;
							
							case XMVolumeCommand.NO_COMMAND:
							default:									line += '.'; break;
						}
						
						line += pad( trigger.volume.toString() );
					}
					
					if ( trigger.hasEffect )
					{
						line += ' ' + ( trigger.effect.toString(16).toUpperCase() );
						line += pad( ( trigger.effectParam.toString(16).toUpperCase() ) );
					}
					else
						line += ' ...';
				}
				
				patternString += line + '\n';
			}
			
			return patternString;
		}
		
		private function pad( input: String, toLength: uint = 2, paddingChar: String = '0' ): String
		{
			while ( input.length < toLength )
				input = paddingChar + input;
			
			return input;
		}
	}
}