package de.popforge.audio.processor.bitboy.formats.xm
{
	import flash.geom.Point;
	import flash.utils.ByteArray;
	
	public final class XMSampleHeader
	{
		public var size: uint;
		
		public var sampleNumber: Array;
		
		public var volumeEnvelope: Array;
		public var panningEnvelope: Array;
		
		public var numVolumePoints: uint;
		public var numPanningPoints: uint;
		
		public var volumeSustainPoint: uint;
		public var volumeLoopStartPoint: uint;
		public var volumeLoopEndPoint: uint;
			
		public var panningSustainPoint: uint;
		public var panningLoopStartPoint: uint;
		public var panningLoopEndPoint: uint;
		
		public var volumeType: uint;
		public var panningType: uint;
			
		public var vibratoType: uint;
		public var vibratoSweep: uint;
		public var vibratoDepth: uint;
		public var vibratoRate: uint;
			
		public var volumeFadeOut: uint;
		
		public function XMSampleHeader( stream: ByteArray )
		{
			parse( stream );
		}
		
		private function parse( stream: ByteArray ): void
		{
			var i: int;
			var x: int;
			var y: int;
			
			size = stream.readUnsignedInt();
			sampleNumber = new Array( 96 );
			
			for ( i = 0; i < 96; ++i )
			{
				sampleNumber[ i ] = stream.readUnsignedByte();
			}
			
			volumeEnvelope = new Array( 12 );
			
			for ( i = 0; i < 12; ++i )
			{
				x = stream.readUnsignedShort();
				y = stream.readUnsignedShort();
				
				volumeEnvelope[ i ] = new Point( x, y );
			}
			
			panningEnvelope = new Array( 12 );
			
			for ( i = 0; i < 12; ++i )
			{
				x = stream.readUnsignedShort();
				y = stream.readUnsignedShort();
				
				panningEnvelope[ i ] = new Point( x, y );
			}
			
			numVolumePoints = stream.readUnsignedByte();
			
			if ( numVolumePoints > 12 )
			{
				trace( 'Waning: numVolumePoints is greater than 12 which should be the maximum.' );
				numVolumePoints = 12;
			}
			
			numPanningPoints = stream.readUnsignedByte();
			
			if ( numPanningPoints > 12 )
			{
				trace( 'Waning: numPanningPoints is greater than 12 which should be the maximum.' );
				numPanningPoints = 12;
			}
			
			volumeSustainPoint = stream.readUnsignedByte();
			volumeLoopStartPoint = stream.readUnsignedByte();
			volumeLoopEndPoint = stream.readUnsignedByte();
			
			panningSustainPoint = stream.readUnsignedByte();
			panningLoopStartPoint = stream.readUnsignedByte();
			panningLoopEndPoint = stream.readUnsignedByte();
			
			//TODO: implement this bitflag
			// Volume type: bit 0: On; 1: Sustain; 2: Loop
			volumeType = stream.readUnsignedByte();

			//TODO: implement this bitflag
			// Panning type: bit 0: On; 1: Sustain; 2: Loop
			panningType = stream.readUnsignedByte();
		
			vibratoType = stream.readUnsignedByte();
			vibratoSweep = stream.readUnsignedByte();
			vibratoDepth = stream.readUnsignedByte();
			vibratoRate = stream.readUnsignedByte();
			
			volumeFadeOut = stream.readUnsignedShort();
			
			//-- unused
			stream.readMultiByte( 11, XMFormat.ENCODING );
		}
		
		public function toString(): String
		{
			const ENUM: Array = ['size',
				'sampleNumber',
				'volumeEnvelope',
				'panningEnvelope',
				'numVolumePoints',
				'numPanningPoints',
				'volumeSustainPoint',
				'volumeLoopStartPoint',
				'volumeLoopEndPoint',
				'panningSustainPoint',
				'panningLoopStartPoint',
				'panningLoopEndPoint',
				'volumeType',
				'panningType',
				'vibratoType',
				'vibratoSweep',
				'vibratoDepth',
				'vibratoRate',
				'volumeFadeOut'];
			
			var result: String = '[XMSampleHeader';
			
			for ( var i: int = 0; i < ENUM.length; i++ )
			{
				result += ( i == 0 ? ' ' : ', ' ) + ENUM[ i ] + ': ' + this[ENUM[i]];
			}
			
			return result + ']';
		}
	}
}