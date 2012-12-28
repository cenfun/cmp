package {

	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.media.*;
	import flash.utils.*;
	import flash.text.*;
	
	import fl.managers.*;
	
	public class PSP extends Sprite {
		
		private var nc:NetConnection;
		private var ns:NetStream;
		private var vv:Video;
		private var xywh:Array = [10, 24, 320, 240];
		//==================================
		
		private var file:FileReference;
		private var pso:PSO;
		
		//==================================
		
		public var connected:Boolean = false;

		public var p2p_nc:NetConnection;
		public var p2p_ng:NetGroup;
		//重连
		private var timeid:uint;
		private var maxtimes:int = 20;
		
		//==================================
		private var hold:Boolean = false;
		private var text:String = "";
		
		private var ready:Boolean = false;
		
		public function PSP() {
			
			StyleManager.setStyle("textFormat",new TextFormat(null, 12));
			
			nc = new NetConnection();
			nc.addEventListener(NetStatusEvent.NET_STATUS, netStatus);
			nc.addEventListener(SecurityErrorEvent.SECURITY_ERROR, netError);
			nc.addEventListener(IOErrorEvent.IO_ERROR, netError);
			nc.addEventListener(AsyncErrorEvent.ASYNC_ERROR, netError);
			nc.client = new NC(this);
			nc.connect(null);
			//
			bt_load.addEventListener(MouseEvent.CLICK, loadClick);
			bt_play.addEventListener(MouseEvent.CLICK, playClick);
			bt_publish.addEventListener(MouseEvent.CLICK, publishClick);
			drawVideoBack();
		}
		
		public function netError(e:Event):void {
			showMsg(e.toString());
		}
		private function netStatus(e:NetStatusEvent):void {
			//showMsg(e.info.code);
			
			if (e.info.code == "NetStream.Buffer.Full") {
				
				videoReady();
				
			}
			
		}
		public function metaHandler(info:Object):void {
			//showMsg("duration: "+info.duration);
			if (info.duration) {
				pso.info.duration = info.duration;
			}
			if (info.width) {
				pso.info.width = info.width;
			}
			if (info.height) {
				pso.info.height = info.height;
			}
		}
		
		private function videoReady():void {
			//only ready once
			if (ready) {
				return;
			}
			ready = true;
			
			showMsg("Video is ready");
			
			bt_load.enabled = false;
			bt_play.enabled = true;
			bt_publish.enabled = true;
		}
		
		
		//========================================================================
		private function loadClick(e:MouseEvent):void {
			
			file = new FileReference();
			file.addEventListener(Event.SELECT, selectHandler);
			file.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			file.addEventListener(ProgressEvent.PROGRESS, progressHandler);
			file.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			file.addEventListener(Event.COMPLETE, completeHandler);
			file.browse();
			
		}

		private function selectHandler(e:Event):void {
			
			hold = false;
			output.text = "";
			
			var filesize:int = 0;
			try {
				filesize = file.size;
			} catch (e:Error) {
			}
			if (filesize) {
				showMsg("File name: " + file.name);
				showMsg("File size: " + filesize);
				file.load();
			} else {
				showMsg("Invalid file or too large file");
			}
		}

		private function ioErrorHandler(e:IOErrorEvent):void {
			showMsg(e.text);
		}

		private function securityErrorHandler(e:SecurityErrorEvent):void {
			showMsg(e.text);
		}

		private function progressHandler(e:ProgressEvent):void {
			var per:Number = 0;
			if (e.bytesTotal) {
				per = e.bytesLoaded / e.bytesTotal;
			}
			
			var str:String = "File loading ... " + Math.round(per * 100) + "%";
			
			if (hold) {
				showMsg(str);
			} else {
				showMsg(str, 1);
			}
		}

		private function completeHandler(event:Event):void {
			
			showMsg("File loaded");
			
			showMsg("Try to play the video ...", 1);
			
			pso = new PSO();
			pso.info.filename = file.name;
			pso.info.filesize = file.size;
			
			videoPlay();
			
		}
		
		//=========================================================================
		public function playClick(e:MouseEvent):void {
			if (bt_play.label == "Stop") {
				videoStop();
			} else {
				videoPlay();
			}
		}
		
		public function videoStop():void {
			bt_play.label = "Play";
			// create video
			if (vv) {
				removeChild(vv);
				vv.clear();
				vv.visible = false;
				vv = null;
			}
			// create netstream
			if (ns) {
				ns.removeEventListener(AsyncErrorEvent.ASYNC_ERROR, netError);
				ns.removeEventListener(IOErrorEvent.IO_ERROR, netError);
				ns.removeEventListener(NetStatusEvent.NET_STATUS, netStatus);
				try {
					ns.close();
				} catch (e) {
				}
				ns = null;
			}
		}
		
		public function videoPlay():void {
			videoStop();
			bt_play.label = "Stop";
			
			//
			vv = new Video(xywh[2], xywh[3]);
			vv.x = xywh[0];
			vv.y = xywh[1];
			addChild(vv);
			
			ns = new NetStream(nc);
			ns.client = new NC(this);
			ns.addEventListener(AsyncErrorEvent.ASYNC_ERROR, netError);
			ns.addEventListener(IOErrorEvent.IO_ERROR, netError);
			ns.addEventListener(NetStatusEvent.NET_STATUS, netStatus);
			
			// play video
			ns.play(null);
			ns.appendBytesAction(NetStreamAppendBytesAction.RESET_BEGIN);
			vv.attachNetStream(ns);
			ns.appendBytes(file.data);
		}
		
		//=========================================================================
		
		public function publishClick(e:MouseEvent):void {
			videoStop();
			
			showMsg("Generate the P2P hash code:", -1);
			
			var hs:HS = new HS(file.data);
			hs.addEventListener(CE.HS_ERROR, hsError);
			hs.addEventListener(CE.HS_PROGRESS, hsProgress);
			hs.addEventListener(CE.HS_COMPLETE, hsComplete);
			hs.hash();
		}
		public function hsError(e:CE):void {
			showMsg(String(e.data));
		}
		public function hsProgress(e:CE):void {
			var str:String = "";
			var info:Object = e.data;
			if (info.step == 1) {
				str += "Step 1";
			} else {
				str += "Step 2";
			}
			str += " processing ... ";
			
			var per:Number = 0;
			if (info.len) {
				per = info.pos / info.len;
			}
			
			str += Math.round(per * 100) + "%";
			
			if (hold) {
				showMsg(str);
			} else {
				showMsg(str, 1);
			}
			
		}
		public function hsComplete(e:CE):void {
			var hash:String = String(e.data);
			if (!hash) {
				showMsg("Invalid file hash code");
				return;
			}
			pso.info.filehash = hash;
			//
			var p2pstr:String = P2P.CMP + hash + P2P.CMP;
			var hs:HS = new HS(p2pstr);
			hs.addEventListener(CE.HS_ERROR, hsError);
			hs.addEventListener(CE.HS_COMPLETE, p2pHashComplete);
			hs.hash();
		}
		
		public function p2pHashComplete(e:CE):void {
			var hash:String = String(e.data);
			if (!hash) {
				showMsg("Invalid p2p hash code");
				return;
			}
			pso.info.p2phash = hash;
			showMsg(hash);
			
			//==================================================================
			//创建P2P区块
			showMsg("Create P2P chunks:", -1);
			
			//包大小
			var packetsize:int = pso.info.packetsize;
			showMsg("Packet size: " + packetsize);
			
			//包的长度，取最大集
			var packetlen:int = Math.floor(file.size / packetsize) + 1;
			showMsg("Packets lenght: " + packetlen);
			
			//添加到从1开始的位置
			for (var i:int = 1; i <= packetlen; i ++) {
				pso.chunks[i] = new ByteArray();
				if (i == packetlen) {
					//最后一个包
					file.data.readBytes(pso.chunks[i], 0, file.data.bytesAvailable);
				} else {
					file.data.readBytes(pso.chunks[i], 0, packetsize);
				}
			}
			
			//p2p的长度，加上头信息，占一个长度
			pso.info.length = packetlen + 1;
			showMsg("Chunks lenght: " + pso.info.length);
			
			//设置头信息到区块头的位置
			pso.chunks[0] = pso.info;
			//==================================================================
			
			//连接p2p
			connect();
			
		}
		
		//==========================================================================
		private function connect():void {
			showMsg("Network connecting ... ", 1);
			
			p2p_nc = new NetConnection();
			p2p_nc.addEventListener(NetStatusEvent.NET_STATUS, p2pStatus);
			p2p_nc.connect(P2P.SERVER, P2P.DEVKEY);
			
		}
		
		private function setupGroup():void {
			
			p2p_ng = new NetGroup(p2p_nc, P2P.peer_id);
			p2p_ng.addEventListener(NetStatusEvent.NET_STATUS, p2pStatus);
			clearTimeout(timeid);

			if (maxtimes > 0) {
				maxtimes --;
				timeid = setTimeout(checkConnect,3000);
			}
			
		}
		public function checkConnect():void {
			clearTimeout(timeid);
			if (! connected) {
				setupGroup();
			}
		}

		private function groupConnected():void {
			
			//拥有所有长度，做种无需按顺序优先级
			//p2p_ng.replicationStrategy = NetGroupReplicationStrategy.LOWEST_FIRST;
			//id是从0开始，长度-1结束
			p2p_ng.addHaveObjects(0, pso.info.length - 1);
			
			showMsg("P2P stream is ready", -1);
			
			showMsg("CMP src:");
			
			showMsg(pso.info.p2phash + ".p2pstream");
			
			bt_publish.enabled = false;
			
		}
		
		private function p2pStatus(e:NetStatusEvent):void {
			//showMsg(e.info.code);
			
			switch (e.info.code) {
				case "NetConnection.Connect.Success" :
					P2P.createSpec(pso.info.p2phash);
					showMsg("P2P connecting ... ");
					setupGroup();
					break;

				case "NetGroup.Connect.Success" :
					connected = true;
					showMsg("P2P connected");
					groupConnected();
					break;

				case "NetGroup.Replication.Request" :
				
					//showMsg("RequestID:" + e.info.requestID + " Index:" + e.info.index);
					//任意位置直接发送
					p2p_ng.writeRequestedObject(e.info.requestID, pso.chunks[e.info.index]);
					break;
					
			}
			
		}
		
		
		//==========================================================================
		
		public function showMsg(str:String, save:int = 0):void {
			
			if (save == 1) {
				hold = true;
				text = output.text;
			} else if (save == -1) {
				hold = false;
			}
			
			//trace(str);
			
			str += "\n";
			
			if (hold) {
				output.text = text + str;
			} else {
				output.appendText(str);
			}
			
			output.verticalScrollPosition = output.maxVerticalScrollPosition;
		}
		
		public function drawVideoBack():void {
			var tg:Graphics = this.graphics;
			tg.clear();
			tg.beginFill(0x000000);
			tg.drawRect(xywh[0], xywh[1], xywh[2], xywh[3]);
			tg.endFill();
		}
		
		
	}

}