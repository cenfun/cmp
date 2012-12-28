package {
	import flash.display.*;
	import flash.events.*;
	import flash.filters.*;
	import flash.geom.*;
	import flash.media.*;
	import flash.net.*;
	import flash.ui.*;
	import flash.utils.*;

	public final class P2PStreamModel extends Object {
		public var position:Number = 0;
		//时间控制者
		public var timer:Sprite = new Sprite();
		public var transform:SoundTransform;
		public var nc:NetConnection;
		public var ns:NetStream;
		public var vv:Video;
		public var isBuffering:Boolean = false;
		public var keyframes:Object;
		public var meta:Boolean;
		public var mp4:Boolean;
		//====================================================================================
		public var apikey:Object;
		public var api:Object;
		
		public var src:String;
		
		public var pso:PSO;
		public var streamIndex:int;
		public var p2p_nc:NetConnection;
		public var groupid:String;
		public var ng:NetGroup;
		public var connected:Boolean = false;
		public var maxtimes:Number = 10;
		public var timeid:uint;
		
		//缓冲超时
		public var bf_timemax:Number = 60;
		public var bf_timenow:Number = 0;
		
		//是否已经开始播放
		public var started:Boolean = false;
		//是否加载完成
		public var loaded:Boolean = false;
		
		public function P2PStreamModel(_apikey:Object):void {
			apikey = _apikey;
			api = apikey.api;
			
			//模块初始定义
			transform = new SoundTransform();
			nc = new NetConnection();
			nc.connect(null);
			
			api.addEventListener(apikey.key, "video_effect", effectHandler);
			api.addEventListener(apikey.key, "video_smoothing", smoothingHandler);
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
			groupid = arr[0];

			if (!groupid) {
				api.sendEvent("model_error", "p2pstream的地址参数不正确");
				return;
			}
			//统一大写
			groupid = groupid.toUpperCase();	

			maxtimes = 10
			bf_timenow = 0;
			
			started = false;
			loaded = false;
			//=======================
			loadNet();
		}
		
		public function loadNet():void {
			p2p_nc = new NetConnection();
			p2p_nc.addEventListener(NetStatusEvent.NET_STATUS, statusHandler);
			p2p_nc.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
			p2p_nc.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			p2p_nc.addEventListener(AsyncErrorEvent.ASYNC_ERROR, errorHandler);
			p2p_nc.client = new NC(this);
			p2p_nc.connect(P2P.SERVER, P2P.DEVKEY);
		}
		
		public function setGroup():void {
			
			//api.tools.output(groupid);
			
			P2P.createSpec(groupid);
			ng = new NetGroup(p2p_nc, P2P.peer_id);
			ng.addEventListener(NetStatusEvent.NET_STATUS, statusHandler);
			
			clearTimeout(timeid);
			if (maxtimes > 0) {
				maxtimes --;
				timeid = setTimeout(checkConnect, 3000);
			}
			
		}
		
		public function checkConnect():void {
			clearTimeout(timeid);
			if (! connected) {
				setGroup();
			}
		}
		
		public function groupConnected():void {
			//新建流
			ns = new NetStream(nc);
			ns.bufferTime = api.config.buffer_time;
			ns.client = new NC(this);
			ns.addEventListener(AsyncErrorEvent.ASYNC_ERROR, errorHandler);
			ns.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			ns.addEventListener(NetStatusEvent.NET_STATUS, statusHandler);
			
			ns.play(null);
			ns.appendBytesAction(NetStreamAppendBytesAction.RESET_BEGIN);
			
			vv = new Video();
			vv.attachNetStream(ns);
			
			streamIndex = 1;
			
			pso = new PSO();
			
			ng.replicationStrategy = NetGroupReplicationStrategy.LOWEST_FIRST;
			ng.addWantObjects(0, 0);
			
			api.sendState("buffering");
			
			//跳过15秒超时，用缓冲1分钟超时
			api.item.data = true;
			
		}
		
		//==========================================================================================
		
		//下载数据
		public function p2p_down(e:NetStatusEvent):void {
			var index:int = e.info.index;
			var data:Object = e.info.object;
			
			if (!data) {
				return;
			}
			
			//api.tools.output(index, pso.info.length);
			
			pso.appendPacket(index, data);
			//share
			ng.addHaveObjects(index, index);
			
			//下载进度 位置+1和总长度
			progressHandler(index + 1, pso.info.length);
				
			if (index == 0) {
				
				//取到头信息后，开始从1开始获取视频数据
				ng.addWantObjects(1, pso.info.length - 1);
				
			} else {
				
				//先添加
				while (pso.chunks[streamIndex] is ByteArray) {
					var ba:ByteArray = pso.chunks[streamIndex] as ByteArray;
					//api.tools.output(ba.length);
					ns.appendBytes(ba);
					streamIndex ++;
				}
			
				//第一开始播放
				if (!started) {
					started = true;
					start();
				}
				
			}
			
		}
		
		//发送数据
		public function p2p_send(e:NetStatusEvent):void {
			//给请求的标识符(requestID)写入指定index的数据
			ng.writeRequestedObject(e.info.requestID, pso.chunks[e.info.index]);
		}
		
		//==================================================================================
		
		
		public function play():void {
			ns.resume();
			volume();
			interval("add", [timeHandler]);
		}
		public function pause():void {
			interval("del", [timeHandler]);
			ns.pause();
			api.sendState("paused");
		}
		
		public function stop():void {
			interval("del", [timeHandler]);
			clearTimeout(timeid);
			connected = false;
			bf_timenow = 0;
			started = false;
			loaded = false;
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
			
			if (ng) {
				ng.removeEventListener(NetStatusEvent.NET_STATUS, statusHandler);
				try {
					ng.close();
				} catch (e:Error) {
				}
				ng = null;
			}
			
			if (p2p_nc) {
				p2p_nc.removeEventListener(NetStatusEvent.NET_STATUS, statusHandler);
				p2p_nc.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
				p2p_nc.removeEventListener(IOErrorEvent.IO_ERROR, errorHandler);
				p2p_nc.removeEventListener(AsyncErrorEvent.ASYNC_ERROR, errorHandler);
				try {
					p2p_nc.close();
				} catch (e:Error) {
				}
				p2p_nc = null;
			}
			
		}
		
		public function volume():void {
			transform.volume = api.config.volume;
			transform.pan = api.config.panning;
			if (ns) {
				ns.soundTransform = transform;
			}
		}
		public function seek(val:Number):void {
			var pos:Number;
			if (val < 0 || val > 1) {
				pos = ns.time + val;
			} else if (api.item.duration) {
				pos = api.item.duration * val;
			} else {
				return;
			}
			
			/*
			
			var ss:Number = 0;
			var sb:Number = 0;
			if(keyframes) {
				for (var i:int = 0; i < keyframes.times.length - 1; i ++) {
					if(keyframes.times[i] <= pos && keyframes.times[i + 1] >= pos) {
						break;
					}
				}
				ss = keyframes.times[i];
				sb = keyframes.filepositions[i];
			}
			
			//普通逐渐式下载跳进
			if(keyframes) {
				ns.seek(ss);
			} else {
				ns.seek(pos);
			}
			*/
			
			//如果暂停则恢复播放
			//if (api.config.state == "paused") {
			//play();
			//}
			
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
					
				case "NetStream.Buffer.Empty" :
					//数据的接收速度不足以填充缓冲区
					isBuffering = true;
					break;
				case "NetStream.Buffer.Full" :
					//缓冲区已满并且流将开始播放
					isBuffering = false;
					break;
				case "NetStream.Seek.Notify" :
				
					//ns.appendBytesAction(NetStreamAppendBytesAction.RESET_BEGIN);
					//搜寻操作完成
					isBuffering = false;
					break;
				
				case "NetGroup.Connect.Success" :
					connected = true;
					groupConnected();
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
				
				
				
					//当 Object Replication 系统即将向邻域发送对象请求时发送
					//info.index:Number 属性是请求的对象的索引
				case "NetGroup.Replication.Fetch.SendNotify" :
					break;
					//当提取对象请求（之前已使用 NetGroup.Replication.Fetch.SendNotify 进行通知）失败或被拒绝时发送。
					//info.index:Number 属性是已请求的对象的索引
				case "NetGroup.Replication.Fetch.Failed" :
					break;
					//当邻域满足了提取请求时发送。
					//info.index:Number 属性是此结果的对象索引。
					//info.object:Object 属性是此对象的值。
					//此索引将自动从 Want 集中删除。
					//如果此对象无效，可使用 NetGroup.addWantObjects() 将此索引重新添加到 Want 集。
				case "NetGroup.Replication.Fetch.Result" :
					p2p_down(e);
					break;
					//当邻域已请求此节点已使用 NetGroup.addHaveObjects() 进行通知的对象时发送。
					//最终必须使用 NetGroup.writeRequestedObject() 或 NetGroup.denyRequestedObject() 应答此请求。请注意答复可能会不同。
					//info.index:Number 属性是已请求的对象的索引。
					//info.requestID:int 属性是此请求的 ID，由 NetGroup.writeRequestedObject() 或 NetGroup.denyRequestedObject() 使用
				case "NetGroup.Replication.Request" :
					p2p_send(e);
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
			api.item.data = true;
			//
			volume();
			
			whHandler();
			
			//获取时间
			interval("add", [timeHandler]);
		}
		//大小控制
		public function whHandler():void {
			var iw:Number = parseInt(api.item.width);
			var ih:Number = parseInt(api.item.height);
			if (iw && ih) {
				size(iw, ih);
			} else {
				size(pso.info.width, pso.info.height);
			}
		}
		//设置尺寸
		public function size(vw:Number, vh:Number):void {
			vv.width = vw;
			vv.height = vh;
			api.showMedia(vv);
			//初始化效果处理
			effectHandler();
			smoothingHandler();
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
			if (isBuffering && !loaded) {
				
				if (bf_timenow == 0) {
					bf_timenow = getTimer();
				}
				
				var now:Number = getTimer();
				if ((now - bf_timenow) > bf_timemax * 1000) {
					stop();
					nsError("缓冲数据1分钟超时，可能是种子数据源不完整或已经关闭");
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
			
			//完成前判断
			if (isBuffering && loaded) {
				interval("del", [timeHandler]);
				//整体完成
				timeid = setTimeout(finish, ns.bufferLength * 1000);
			}
			
			
		}
		//下载管理
		public function progressHandler(pos:int, len:int):void {
			if(pos < len) {
				api.sendEvent("model_loading", pos / len);
			} else {
				api.sendEvent("model_loaded");
				loaded = true;
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
		
		//整体完成
		public function finish():void {
			//先停止当前模块
			stop();
			api.sendState("completed");
		}
		//取得媒体资料
		public function metaHandler(info:Object):void {
			
			//trace(info.type);
			//for (var i:String in info) {
			//api.tools.output(i + ": " + info[i]);
			//}
			
			if (info.duration) {
				api.item.xml.@duration = api.item.duration = info.duration;
			}
			
			//重新修正宽高比
			if (info.width && info.height) {
				size(info.width, info.height);
			}
			if(info['type'] == 'metadata' && !meta) {
				meta = true;
				if(info.seekpoints) {
					mp4 = true;
					keyframes = skf(info.seekpoints);
				} else if(info.keyframes) {
					mp4 = false;
					keyframes = info.keyframes;
				}
			}
			
			api.sendEvent("model_meta", info);
		}
		
		public function skf(dat:Object):Object {
			var kfr:Object = new Object();
			kfr.times = new Array();
			kfr.filepositions = new Array();
			for (var i:String in dat) {
				kfr.times[i] = Number(dat[i]['time']);
				kfr.filepositions[i] = Number(dat[i]['offset']);
			}
			return kfr;
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