package de.popforge.audio.processor.bitboy.formats.xm
{
	public final class XMFormatError extends Error
	{
		public static const FILE_CORRUPT: String = 'Invalid XM file';
		public static const NOT_IMPLEMENTED: String = 'A feature has not been implemented yet';
		
		public static const MAX_CHANNELS: String = 'Maximum number of channels reached';
		public static const MAX_INSTRUMENTS: String = 'Maximum number of instruments reached';
		public static const MAX_PATTERNS: String = 'Maximum number of patterns reached';
		public static const MAX_LENGTH: String = 'Maximum song length is reached';
		
		public function XMFormatError( message: String = '', id: int = 0 )
		{
			super( message, id );
		}
	}
}