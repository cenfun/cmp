package de.popforge.audio.processor.bitboy.formats.xm
{
	import flash.utils.ByteArray;
	
	public final class XMInstrument
	{
		private static var INSTRUMENT_INDEX_ID: int = 0;
		
		public var header: XMInstrumentHeader;
		public var sampleHeader: XMSampleHeader;
		public var sample: XMSample;
		
		//debugging
		public var index: int;
		
		public function XMInstrument( stream: ByteArray, index: int )
		{
			this.index = index;
			parse( stream );
		}
		
		private function parse( stream: ByteArray ): void
		{
			var p: uint = stream.position;
			
			header = new XMInstrumentHeader( stream );
			
			if ( header.numSamples == 0 )
			{
				stream.position = p + header.size;
				return;
			}
			else
			{
				if ( header.numSamples > 1 )
				{
					throw new XMFormatError( XMFormatError.NOT_IMPLEMENTED );
				}
			}

			sampleHeader = new XMSampleHeader( stream );
				
			stream.position = p + header.size;
				
			sample = new XMSample( stream, sampleHeader.size );
		}
		
		public function toString(): String
		{
			return '[XMInstrument header: ' + header.toString() + ', sampleHeader: ' + ( sampleHeader == null ? 'null' : sampleHeader.toString() ) + ', sample: ' + ( sample == null ? 'null' : sample.toString() ) + ']';
		}
	}
}
