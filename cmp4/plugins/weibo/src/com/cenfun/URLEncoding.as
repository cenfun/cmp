package com.cenfun
{
	/**
	 * Encodes and decodes strings into URL format.
	 * 
	 * Code ported from the javascript code at:
	 * http://cass-hacks.com/articles/code/js_url_encode_decode/
	 * 
	 * UTF-8 bug fixed by Denis Borisenko:
	 * http://blog.dborisenko.com/en/2009/09/05/extended-utf-8-in-oauth-actionscript-library/
	*/
	import flash.utils.*;
	
	public class URLEncoding
	{
		public function URLEncoding()
		{
		}
		
		/**
		 * Does proper UTF-8 encoding
		 */
		public static function utf8Encode(string:String):String {
			string = string.replace(/\r\n/g, '\n');
			string = string.replace(/\r/g, '\n');
		 
			var utfString:String = '';
		 
			for (var i:int = 0 ; i < string.length ; i++)
			{
				var chr:Number = string.charCodeAt(i);
				if (chr < 128)
				{
					utfString += String.fromCharCode(chr);
				}
				else if ((chr > 127) && (chr < 2048))
				{
					utfString += String.fromCharCode((chr >> 6) | 192);
					utfString += String.fromCharCode((chr & 63) | 128);
				}
				else
				{
					utfString += String.fromCharCode((chr >> 12) | 224);
					utfString += String.fromCharCode(((chr >> 6) & 63) | 128);
					utfString += String.fromCharCode((chr & 63) | 128);
				}
			}
		 
			return utfString;
		}

		
		/**
		 * Does the URL encoding
		 */

		public static function urlEncode(string:String):String {
			var urlString:String = '';
		 
			for (var i:int = 0 ; i < string.length ; i++)
			{
				var chr:Number = string.charCodeAt(i);
		 
				if ((chr >= 48 && chr <= 57) || // 09
					(chr >= 65 && chr <= 90) || // AZ
					(chr >= 97 && chr <= 122) || // az
					chr == 45 || // -
					chr == 95 || // _
					chr == 46 || // .
					chr == 126) // ~
				{
					urlString += String.fromCharCode(chr);
				}
				else
				{
					urlString += '%' + chr.toString(16).toUpperCase();
				}
			}
			
			return urlString;
		}

		
		/**
		 * Properly URL encodes a string, taking into account UTF-8
		 */

		public static function encode(string:String):String {
			
			var s:String = string;
			
			s = urlEncode(utf8Encode(string));
			
			//s = encodeURIComponent(string);
			
			
			return s;
		}
		
		
	}
}