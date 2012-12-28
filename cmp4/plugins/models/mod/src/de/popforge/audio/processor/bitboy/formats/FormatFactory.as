package de.popforge.audio.processor.bitboy.formats
{
	import de.popforge.audio.processor.bitboy.formats.mod.ModFormat;
	import de.popforge.audio.processor.bitboy.formats.xm.XMFormat;
	
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	public final class FormatFactory
	{
		public static function createFormat( file: ByteArray ): FormatBase 
		{
			var id: String;
			
			//-- ROUND #1
			//-- MOD
			
			file.endian = Endian.LITTLE_ENDIAN;
			file.position = 0x438;
			id = file.readMultiByte( 4, 'us-ascii' );
			
			if ( id.toLowerCase() == 'm.k.' )
				return new ModFormat( file );
			
			//-- ROUND #2
			//-- XM
			
			file.endian = Endian.LITTLE_ENDIAN;
			file.position = 0;
			id = file.readMultiByte( 17, 'us-ascii' );
			
			if ( id.toLowerCase() == 'extended module: ' )
				return new XMFormat( file );
				
			//-- ROUND #3
			//-- IT
			
			
			//-- ROUND #4
			//-- S3M
			
			
			//-- ROUND #5
			//-- NO SUCCESS			
			
			throw new Error( 'Unsupported format.' );
			
			return null;
		}
	}
}