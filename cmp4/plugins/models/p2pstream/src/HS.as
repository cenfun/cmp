package {
	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;
	
	public class HS extends Sprite {
		
		public var value:String = "";
		
		private var target:ByteArray;
		
		//每次bit的数量
		private var bitper:int = 50000;
		private var bitlen:int = 0;
		private var bitpos:int = 0;
		
		private var blocks:Array;
		
		private var h0:int = 0;
		private var h1:int = 0;
		private var h2:int = 0;
		private var h3:int = 0;
		private var h4:int = 0;
		
		private var blockper:int = 1000;
		private var blocklen:int = 0;
		private var blockpos:int = 0;
		
		private var w:Array;
		private var p:int;
		
		public function HS(data:Object):void {
			if (data is ByteArray) {
				target = data as ByteArray;
			} else {
				var str:String = String(data);
				if (str) {
					target = new ByteArray();
					target.writeUTFBytes(str);
					target.position = 0;
				}
			}
		}
		
		public function hash():void {
			if (!target) {
				dispatchEvent(new CE(CE.HS_ERROR, "Invalid ByteArray"));
				return;
			}
			//
			target.position = 0;
			//
			bitlen = target.length * 8;
			bitpos = 0;
			blocks = [];
			//
			addEventListener(Event.ENTER_FRAME, createBlocks);
		}
		
		private function running(step:int, pos:int, len:int):void {
			var obj:Object = {
				step : step,
				pos : pos,
				len : len
			};
			dispatchEvent(new CE(CE.HS_PROGRESS, obj));
		}
		
		private function createBlocks(e:Event):void {
			running(1, bitpos, bitlen);
			var end:Boolean = false;
			for (var i:int = 0; i < bitper; i ++) {
				if (bitpos < bitlen) {
					blocks[ bitpos >> 5 ] |= ( target.readByte() & 0xFF ) << ( 24 - bitpos % 32 );
					bitpos += 8;
				} else {
					end = true;
					break;
				}
			}
			if (!end) {
				return;
			}
			
			//done
			removeEventListener(Event.ENTER_FRAME, createBlocks);
			// append padding and length
			blocks[ bitlen >> 5 ] |= 0x80 << ( 24 - bitlen % 32 );
			blocks[ ( ( ( bitlen + 64 ) >> 9 ) << 4 ) + 15 ] = bitlen;
			target.position = 0;
				
			h0 = 0x67452301;
			h1 = 0xefcdab89;
			h2 = 0x98badcfe;
			h3 = 0x10325476;
			h4 = 0xc3d2e1f0;
			
			blocklen = blocks.length;
			blockpos = 0;
			
			w = new Array(80);
			p = 0;
			//
			addEventListener(Event.ENTER_FRAME, hashBlocks);
			
		}

		private function hashBlocks(e:Event):void {
			running(2, blockpos, blocklen);
			var end:Boolean = false;
			for (var i:int = 0; i < blockper; i ++) {
				if (blockpos < blocklen) {
					process();
					blockpos += 16;
				} else {
					end = true;
					break;
				}
			}
			if (!end) {
				return;
			}
			
			//done
			removeEventListener(Event.ENTER_FRAME, hashBlocks);
			
			var ba:ByteArray = new ByteArray();
			ba.writeInt(h0);
			ba.writeInt(h1);
			ba.writeInt(h2);
			ba.writeInt(h3);
			ba.writeInt(h4);
			ba.position = 0;
			
			var digest:ByteArray = new ByteArray();
			digest.writeBytes(ba);
			digest.position = 0;
			
			var str:String = "";
			
			str += toHex(digest.readInt(), true);
			str += toHex(digest.readInt(), true);
			str += toHex(digest.readInt(), true);
			str += toHex(digest.readInt(), true);
			str += toHex(digest.readInt(), true);
			
			value = str.toUpperCase();
			
			dispatchEvent(new CE(CE.HS_COMPLETE, value));
			
		}
		
		private function process():void {
			// 6.1.c
			var a:int = h0;
			var b:int = h1;
			var c:int = h2;
			var d:int = h3;
			var e:int = h4;
				
			var i:int = blockpos;
				
			// 80 steps to process each block
			var t:int;
			for ( t = 0; t < 20; t++ ) {
					
				if ( t < 16 ) {
					// 6.1.a
					w[ t ] = blocks[ i + t ];
				} else {
					// 6.1.b
					p = w[ t - 3 ] ^ w[ t - 8 ] ^ w[ t - 14 ] ^ w[ t - 16 ];
					w[ t ] = ( p << 1 ) | ( p >>> 31 )
				}

				// 6.1.d
				p = ( ( a << 5 ) | ( a >>> 27 ) ) + ( ( b & c ) | ( ~b & d ) ) + e + int( w[ t ] ) + 0x5a827999;

				e = d;
				d = c;
				c = ( b << 30 ) | ( b >>> 2 );
				b = a;
				a = p;
			}
				
			for ( ; t < 40; t++ ) {
				// 6.1.b
				p = w[ t - 3 ] ^ w[ t - 8 ] ^ w[ t - 14 ] ^ w[ t - 16 ];
				w[ t ] = ( p << 1 ) | ( p >>> 31 )

				// 6.1.d
				p = ( ( a << 5 ) | ( a >>> 27 ) ) + ( b ^ c ^ d ) + e + int( w[ t ] ) + 0x6ed9eba1;

				e = d;
				d = c;
				c = ( b << 30 ) | ( b >>> 2 );
				b = a;
				a = p;
			}
				
			for ( ; t < 60; t++ ) {
				// 6.1.b
				p = w[ t - 3 ] ^ w[ t - 8 ] ^ w[ t - 14 ] ^ w[ t - 16 ];
				w[ t ] = ( p << 1 ) | ( p >>> 31 )
					
				// 6.1.d
				p = ( ( a << 5 ) | ( a >>> 27 ) ) + ( ( b & c ) | ( b & d ) | ( c & d ) ) + e + int( w[ t ] ) + 0x8f1bbcdc;
					
				e = d;
				d = c;
				c = ( b << 30 ) | ( b >>> 2 );
				b = a;
				a = p;
			}
				
			for ( ; t < 80; t++ ) {
				// 6.1.b
				p = w[ t - 3 ] ^ w[ t - 8 ] ^ w[ t - 14 ] ^ w[ t - 16 ];
				w[ t ] = ( p << 1 ) | ( p >>> 31 )

				// 6.1.d
				p = ( ( a << 5 ) | ( a >>> 27 ) ) + ( b ^ c ^ d ) + e + int( w[ t ] ) + 0xca62c1d6;

				e = d;
				d = c;
				c = ( b << 30 ) | ( b >>> 2 );
				b = a;
				a = p;
			}
				
			// 6.1.e
			h0 += a;
			h1 += b;
			h2 += c;
			h3 += d;
			h4 += e;
			
		}
		
		public function toHex( n:int, bigEndian:Boolean = false ):String {
			var s:String = "";
			var hexChars:String = "0123456789abcdef";
			if ( bigEndian ) {
				for ( var i:int = 0; i < 4; i++ ) {
					s += hexChars.charAt( ( n >> ( ( 3 - i ) * 8 + 4 ) ) & 0xF ) + hexChars.charAt( ( n >> ( ( 3 - i ) * 8 ) ) & 0xF );
				}
			} else {
				for ( var x:int = 0; x < 4; x++ ) {
					s += hexChars.charAt( ( n >> ( x * 8 + 4 ) ) & 0xF )+ hexChars.charAt( ( n >> ( x * 8 ) ) & 0xF );
				}
			}
			
			return s;
		}
		
	}
}
