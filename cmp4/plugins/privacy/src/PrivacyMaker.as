package {

	import flash.display.*;
	import flash.text.*;
	import flash.events.*;
	import flash.utils.*;
	import fl.managers.*;
	import fl.controls.*;
	public class PrivacyMaker extends MovieClip {

		public function PrivacyMaker() {
			stage.scaleMode = "noScale";
			StyleManager.setStyle("textFormat", new TextFormat(null, 12));
			bt_encrypt.addEventListener(MouseEvent.CLICK, make);
		}


		public function make(e:MouseEvent):void {
			var str_xml:String = xml.text;
			if (! str_xml) {
				xml.setFocus();
				return;
			}
			var str_key:String = key.text;
			if (! str_key) {
				key.setFocus();
				return;
			}
			
			var md5:String = MD5.hash("CMP" + str_key);
			md5 = MD5.hash(md5.toUpperCase()).toUpperCase();
			out.text = encrypt(str_xml, md5);
			out.setFocus();
			selectAllText(out.textField);
		}

		public function encrypt(s:String, k:String):String {
			var keyBytes:ByteArray = new ByteArray();
			keyBytes.writeUTFBytes(k);
			keyBytes.position = 0;
			var bytes:ByteArray = new ByteArray();
			bytes.writeUTFBytes(s);
			bytes.position = 0;
			var newBytes:ByteArray = XXTEA.encrypt(bytes,keyBytes);
			newBytes.position = 0;
			var strOut:String = Base64.encode(newBytes);
			return strOut;
		}

		public function selectAllText(tf:TextField):void {
			stage.focus = tf;
			tf.setSelection(0, tf.length);
			tf.scrollH = 0;
		}




	}

}