package {

	import flash.events.*;
	import flash.net.*;
	
	public class P2P {
		public static const CMP:String = "CMP";
		public static const SERVER:String = "rtmfp://p2p.rtmfp.net";
		public static const DEVKEY:String = "96e7a8a95afb85faa7f67d81-e3d7b7edbb29";
		
		public static var peer_id:String;
		
		//组规格
		public static function createSpec(id:String):void {
			//创建组规格
			var spec:GroupSpecifier = new GroupSpecifier(id);
			//指定是否可以在 IP 多播套接字中交换有关组成员资格的信息。
			//IP 多播服务器可以发送组成员资格更新以帮助启动 P2P 网格或修复分区
			//这些更新可以提高 P2P 性能
			//创建局域网时，需要打开，以便自己内网手动更新ip邻居列表，如addIPMulticastAddress
			//详情：http://www.flashrealtime.com/local-flash-peer-to-peer-communication-over-lan-without-cirrus/
			spec.ipMulticastMemberUpdatesEnabled = true;
			
			//指定是否为 NetGroup 启用流
			//用于流的方法是 NetStream.publish()、NetStream.play() 和 NetStream.play2()
			//Multicast when you have fewer senders sending lots of data (Video, Chat)
			spec.multicastEnabled = true;
			
			//指定是否为 NetGroup 启用对象复制
			//文件复制功能
			spec.objectReplicationEnabled = true;
			
			//指定是否为 NetGroup 或 NetStream 禁用对等连接
			//默认就是flase 不禁用，如果禁用则只能在局域网广播，不能广域网
			//详情：http://www.flashrealtime.com/p2p-groupspecifier-explained-1/
			spec.peerToPeerDisabled = false;
			
			//指定是否为 NetGroup 启用发布
			//Posting should be used when you have lots of senders sending relatively little data (like Chat)
			spec.postingEnabled = true;
			
			//指定是否为 NetGroup 启用定向路由方法
			spec.routingEnabled = true;
			
			//指定 NetGroup 的成员是否可以打开到服务器的通道。
			//http://www.flashrealtime.com/p2p-groupspecifier-explained-1/
			spec.serverChannelEnabled = true;
			
			//保存多组id
			peer_id = spec.groupspecWithAuthorizations();
			
		}
		
	}

}