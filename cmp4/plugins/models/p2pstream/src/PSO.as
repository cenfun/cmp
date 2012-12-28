package {
	
	public class PSO {
		//头信息
		public var info:Object = {
			//file
			filename : "",
			filesize : 0,
			filehash : "",
			
			//video
			duration : 0,
			width : 320,
			height : 240,
			
			//p2p
			packetsize : 64000,
			length : 0,
			p2phash : ""
			
		};
		//区块
		public var chunks:Object = {};
		
		public function PSO():void {
			
		}
		
		//获取包
		public function appendPacket(index:int, data:Object):void {
			
			chunks[index] = data;
			
			//解包头信息
			if (index == 0) {
				for (var k:String in data) {
					info[k] = data[k];
				}
			}
			
			
		}
		

	}
}