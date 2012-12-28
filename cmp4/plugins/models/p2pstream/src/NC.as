package {
	public dynamic class NC {
		private var callback:Object;
		public function NC(cbk:Object):void {
			callback = cbk;
		}
		private function close(... rest):void {
			ncs({close:true},'close');
		}

		private function ncs(dat:Object, typ:String):void {
			var out:Object = {};
			for (var i:Object in dat) {
				out[i] = dat[i];
			}
			out['type'] = typ;
			callback.metaHandler(out);
		}
		//on functions ===============================================================
		//带宽监测，发送给服务器测试数据，即使是0
		public function onBWCheck(... rest):Number {
			return 0;
		}
		//返回带宽测试结果
		public function onBWDone(... rest):void {
			if (rest.length > 0) {
				ncs({bandwidth:rest[0]},'bandwidth');
			}
		}

		public function onCaption(cps:String, spk:Number, ...rest):void {
			ncs({captions:cps,speaker:spk},'caption');
		}

		public function onCaptionInfo(obj:Object, ...rest):void {
			ncs(obj,'captioninfo');
		}

		public function onCuePoint(obj:Object, ...rest):void {
			ncs(obj,'cuepoint');
		}

		public function onFCSubscribe(obj:Object, ...rest):void {
			ncs(obj,'fcsubscribe');
		}

		public function onHeaderData(obj:Object, ...rest):void {
			var dat:Object = new Object();
			var pat:String = "-";
			var rep:String = "_";
			for (var i:String in obj) {
				var j:String = i.replace("-","_");
				dat[j] = obj[i];
			}
			ncs(dat,'headerdata');
		}

		public function onID3(... rest):void {
			ncs(rest[0],'id3');
		}

		public function onImageData(obj:Object, ...rest):void {
			ncs(obj,'imagedata');
		}

		public function onLastSecond(obj:Object, ...rest):void {
			ncs(obj,'lastsecond');
		}

		public function onMetaData(obj:Object, ...rest):void {
			if (rest && rest.length > 0) {
				rest.splice(0, 0, obj);
				ncs({ arguments: rest }, 'metadata');
			} else {
				ncs(obj, 'metadata');
			}
		}

		public function onPlayStatus(...rest):void {
			for each (var dat:Object in rest) {
				if (dat && dat.hasOwnProperty('code')) {
					if (dat.code == "NetStream.Play.Complete") {
						ncs(dat, 'complete');
					} else {
						ncs(dat, 'playstatus');
					}
				}
			}
		}

		public function onSDES(... rest):void {
			ncs(rest[0],'sdes');
		}

		public function onXMPData(... rest):void {
			ncs(rest[0],'xmp');
		}
		
		public function onXMP(... rest):void {
			onXMPData(rest);
		}

		public function RtmpSampleAccess(... rest):void {
			ncs(rest[0],'rtmpsampleaccess');
		}

		public function onTextData(obj:Object, ...rest):void {
			ncs(obj,'textdata');
		}
		public function onFI(obj:Object, ...rest):void {
			ncs(obj, 'timecode');
		}

	}
}