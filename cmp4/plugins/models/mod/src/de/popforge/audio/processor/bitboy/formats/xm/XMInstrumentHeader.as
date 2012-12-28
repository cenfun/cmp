package de.popforge.audio.processor.bitboy.formats.xm
{
	import flash.utils.ByteArray;

	public final class XMInstrumentHeader
	{
		public var size: uint;
		public var name: String;
		public var type: uint;
		public var numSamples: uint;
		
		public function XMInstrumentHeader( stream: ByteArray )
		{
			parse( stream );
		}
		
		private function parse( stream: ByteArray ): void
		{
			size = stream.readUnsignedInt();
			name = stream.readMultiByte( 22, XMFormat.ENCODING );
			type = stream.readUnsignedByte();
			numSamples = stream.readUnsignedShort();
		}
		
		public function toString(): String
		{
			return '[XMInstrumentHeader size: ' + size + ', name: ' + name + ', type: ' + type.toString(2) + ', numSamples: ' + numSamples + ']';
		}
	}
}