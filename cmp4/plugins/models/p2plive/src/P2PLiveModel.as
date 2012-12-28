package {
	import flash.display.*;
	import flash.events.*;
	import flash.filters.*;
	import flash.geom.*;
	import flash.media.*;
	import flash.net.*;
	import flash.ui.*;
	import flash.utils.*;

	public final class P2PLiveModel extends Object {
		public var position:Number = 0;
		//时间控制者
		public var timer:Sprite = new Sprite();
		public var transform:SoundTransform;
		public var nc:NetConnection;
		public var ns:NetStream;
		public var vv:Video;
		public var isBuffering:Boolean = false;
		public var isFlush:Boolean = false;
		
		//====================================================================================
		public var CMP:Object;
		public var apikey:Object;
		public var api:Object;
		
		public static const SERVER:String = "rtmfp://p2p.rtmfp.net";
		public static const DEVKEY:String = "96e7a8a95afb85faa7f67d81-e3d7b7edbb29";
		
		public var src:String;
		public var groupid:String;
		public var streamname:String = "cchat";
		public var peerid:String;
		public var spec:GroupSpecifier;
		public var gp:NetGroup;
		public var connected:Boolean = false;
		public var maxtimes:Number = 10;
		public var timeid:uint;
		
		//缓冲超时
		public var bf_timemax:Number = 60;
		public var bf_timenow:Number = 0;

		public function P2PLiveModel(_apikey:Object):void {
			apikey = _apikey;
			api = apikey.api;
			//取得cmp构造函数
			CMP = api.cmp.constructor;
			
			//模块初始定义
			transform = new SoundTransform();
			CMP.addEventListener("video_effect", effectHandler);
			CMP.addEventListener("video_smoothing", smoothingHandler);
		}
		
		//=============================================================================================================
		
		public function load():void {
			api.sendState("connecting");
			src = api.item.src;
			if (!src) {
				api.sendEvent("model_error", "src不存在");
				return;
			}
			var arr:Array = src.split(".");
			var str:String = arr[0];
			arr = str.split(":");
			
			groupid = arr[0];
			if (arr[1]) {
				streamname = arr[1];
			}
			
			if (!groupid) {
				api.sendEvent("model_error", "p2plive的地址参数不正确");
				return;
			}
			
			maxtimes = 10
			bf_timenow = 0;
			
			init();
		}
		
		public function init():void {
			if (!connected) {
				loadNet();
				return;
			}
			setGroup();
		}
		
		public function loadNet():void {
			if (nc) {
				nc.removeEventListener(NetStatusEvent.NET_STATUS, statusHandler);
				nc.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
				nc.removeEventListener(IOErrorEvent.IO_ERROR, errorHandler);
				nc.removeEventListener(AsyncErrorEvent.ASYNC_ERROR, errorHandler);
				try {
					nc.close();
				} catch (e:Error) {
				}
				nc = null;
			}
			nc = new NetConnection();
			nc.addEventListener(NetStatusEvent.NET_STATUS, statusHandler);
			nc.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
			nc.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			nc.addEventListener(AsyncErrorEvent.ASYNC_ERROR, errorHandler);
			nc.client = new NetClient(this);
			nc.connect(SERVER, DEVKEY);
		}
		
		public function setGroup():void {
			
			createSpec(groupid);
			
			loadGroup();
			
		}
		
		public function loadGroup():void {
			
			gp = new NetGroup(nc, peerid);
			gp.addEventListener(NetStatusEvent.NET_STATUS, statusHandler);

			clearTimeout(timeid);

			if (maxtimes > 0) {
				maxtimes --;
				timeid = setTimeout(checkConnect, 3000);
			}
			
		}
		
		public function checkConnect():void {
			clearTimeout(timeid);
			if (! connected) {
				loadGroup();
			}
		}
		
		public function loadStream():void {
			//新建流
			ns = new NetStream(nc, peerid);
			ns.bufferTime = api.config.buffer_time;
			ns.client = new NetClient(this);
			ns.addEventListener(AsyncErrorEvent.ASYNC_ERROR, errorHandler);
			ns.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			ns.addEventListener(NetStatusEvent.NET_STATUS, statusHandler);
			vv = new Video();
			vv.attachNetStream(ns);
			//开始播放流
			api.item.url = streamname;
			ns.play(streamname);
		}
		
		public function play():void {
			//直播不支持
		}
		public function pause():void {
			//直播不支持
		}
		public function stop():void {
			interval("del", [timeHandler]);
			clearTimeout(timeid);
			connected = false;
			bf_timenow = 0;
			//需要开启一个新的video，清除之前的宽高，以及平滑层
			if (vv) {
				vv.clear();
				vv.visible = false;
				vv = null;
			}
			if (ns) {
				//关闭流
				ns.removeEventListener(AsyncErrorEvent.ASYNC_ERROR, errorHandler);
				ns.removeEventListener(IOErrorEvent.IO_ERROR, errorHandler);
				ns.removeEventListener(NetStatusEvent.NET_STATUS, statusHandler);
				//必须关闭，不能暂停，否则mp3的频谱不显示
				try {
					ns.close();
				} catch (e:Error) {
				}
				ns = null;
			}
			
		}
		
		public function volume():void {
			transform.volume = api.config.volume;
			transform.pan = api.config.panning;
			ns.soundTransform = transform;
		}
		public function seek(val:Number):void {
			
		}
		//=========================================================================================
		public function statusHandler(e:NetStatusEvent):void {
			var s:String = e.info.code;
			//api.tools.output(s);
			switch (s) {
				case "NetConnection.Connect.Success":
					//已经连接Net，开始连接流媒体
					setGroup();
					break;
				case "NetStream.Play.Start" :
					//播放已开始
					start();
					break;
				case "NetStream.Buffer.Empty" :
					//数据的接收速度不足以填充缓冲区
					if (!isFlush) {
						isBuffering = true;
					}
					break;
				case "NetStream.Buffer.Full" :
					//缓冲区已满并且流将开始播放
					isBuffering = false;
					break;
				case "NetStream.Buffer.Flush" :
					//数据已完成流式处理，剩余的缓冲区将被清空，修正无总时间视频长度,和纵横比
					isFlush = true;
					isBuffering = false;
					break;
				case "NetStream.Seek.Notify" :
					//搜寻操作完成
					isBuffering = false;
					break;
				case "NetStream.Play.Stop" :
					//播放已结束
					completeHandler();
					break;
				
				case "NetGroup.Connect.Success" :
					connected = true;
					loadStream();
					break;
					//NetGroup 连接尝试失败。
					//info.group 属性指示哪些 NetGroup 已失败。
				case "NetGroup.Connect.Failed" :
					connected = false;
					nsError('连接多播地址失败');
					break;
					//NetGroup 没有使用函数的权限。
					//info.group 属性指示哪些 NetGroup 被拒绝。
				case "NetGroup.Connect.Rejected" :
					connected = false;
					nsError('连接多播地址被拒绝，需要允许对等协助网络(P2P)才能进入 (请添加并允许本域的P2P对等协助网络，完成后再刷新)');
					break;
					
				case "NetConnection.Connect.NetworkChange" :
				case "NetConnection.Connect.Rejected" :
				case "NetConnection.Connect.InvalidApp" :
				case "NetConnection.Connect.AppShutdown" :
				case "NetConnection.Connect.Closed" :
				case "NetConnection.Connect.Failed" :
				case "NetStream.Play.StreamNotFound" :
				case "NetStream.Play.Failed" :
				case "NetStream.Failed" :
				case "NetStream.Play.FileStructureInvalid" :
				case "NetStream.Play.NoSupportedTrackFound" :
					connected = false;
					//视频流错误
					nsError(s);
					break;
				default :
			}
		}
		//播放流开始
		public function start():void {
			//状态
			isBuffering = true;
			isFlush = false;
			api.item.data = true;
			//无需在第一次播放时使用resume，尤其是rtmp类型
			volume();
			//
			vv.width = 320;
			vv.height = 240;
			api.showMedia(vv);
			//初始化效果处理
			effectHandler();
			smoothingHandler();
			
			//获取时间和宽高
			interval("add", [timeHandler]);
		}
		//时间控制
		public function timeHandler(e:Event):void {
			//当前段的时间修正
			position = ns.time;
			//发送时间变更事件
			if (position != api.item.position && api.config.state == "playing") {
				api.item.position = position;
				api.sendEvent("model_time");
			}
			//检测缓冲状态
			if (isBuffering) {
				if (bf_timenow == 0) {
					bf_timenow = getTimer();
				}
				
				var now:Number = getTimer();
				
				//api.tools.output(now - bf_timenow);
				
				//bf_timemax = 10;
				
				if ((now - bf_timenow) > bf_timemax * 1000) {
					stop();
					nsError("缓冲数据1分钟超时，可能是直播源已停止");
					return;
				}
				
				var bper:Number = Math.floor(ns.bufferLength * 100 / api.config.buffer_time);
				//trace(bper);
				if (bper < 100) {
					api.config.buffer_percent = bper;
					api.sendState("buffering");
				}
			} else if(api.config.state != "playing") {
				api.sendState("playing");
				bf_timenow = 0;
			}
			
		}
		//是否平滑处理
		public function smoothingHandler(e:Object = null):void {
			if (!vv) {
				return;
			}
			if (e) {
				//有数据才改值，否则有事件才反转值
				if (e.data != null) {
					api.config.video_smoothing = api.tools.strings.tof(e.data.toString());
				} else {
					api.config.video_smoothing = !api.config.video_smoothing;
				}
			}
			vv.smoothing = api.config.video_smoothing;
		}
		//视频效果
		public function effectHandler(e:Object = null):void {
			if (!vv) {
				return;
			}
			//黑白高亮效果
			var cmf:BitmapFilter;
			if (e && e.data != null) {
				var arr:Array = api.tools.strings.array(e.data.toString());
				cmf = new ColorMatrixFilter(arr);
			} else if (api.config.video_blackwhite && api.config.video_highlight) {
				cmf = new ColorMatrixFilter([1.5, 0, 0, 0, 0, 1.5, 0, 0, 0, 0, 1.5, 0, 0, 0, 0, 0, 0, 0, 1, 0]);
			} else if (api.config.video_blackwhite) {
				cmf = new ColorMatrixFilter([1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0]);
			} else if (api.config.video_highlight) {
				cmf = new ColorMatrixFilter([1.5, 0, 0, 0, 0, 0, 1.5, 0, 0, 0, 0, 0, 1.5, 0, 0, 0, 0, 0, 1, 0]);
			}
			if (cmf) {
				vv.filters = [cmf];
			} else {
				vv.filters = null;
			}
		}
		public function errorHandler(e:Event):void {
			nsError(e);
		}
		//视频流错误
		public function nsError(dat:Object):void {
			clearTimeout(timeid);
			//不重连
			api.item.reload = true;
			api.sendEvent("model_error", dat);
		}
		//段播放完成
		public function completeHandler():void {
			//整体完成
			finish();
		}
		
		//整体完成
		public function finish():void {
			//先停止当前模块
			stop();
			api.sendState("completed");
		}
		//取得媒体资料
		public function metaHandler(info:Object):void {
			if (info.type == "cuepoint") {
				CMP.wc.showStatus("来源：" + info.username);
			}
			
			//trace(info.type);
			//for (var i:String in info) {
			//trace(i + ": " + info[i]);
			//}
			
			api.sendEvent("model_meta", info);
		}


		//组规格
		public function createSpec(id:String):void {
			spec = new GroupSpecifier(id);
			spec.ipMulticastMemberUpdatesEnabled = true;
			spec.multicastEnabled = true;
			spec.objectReplicationEnabled = true;
			spec.peerToPeerDisabled = false;
			spec.postingEnabled = true;
			spec.routingEnabled = true;
			spec.serverChannelEnabled = true;
			peerid = spec.groupspecWithAuthorizations();
		}
		
		//批量处理侦听==================================================================
		
		public function interval(type:String, arr:Array):void {
			var f:Function;
			for (var i:int = 0; i < arr.length; i ++) {
				f = arr[i];
				if (f is Function) {
					timer.removeEventListener(Event.ENTER_FRAME, f);
					if (type == "add") {
						timer.addEventListener(Event.ENTER_FRAME, f);
					}
				}
			}
		}

	}
}