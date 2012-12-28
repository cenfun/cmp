package com.cenfun{
	
	import flash.net.*;

	public class TqqApi {
		
		public static var request_token:Object = {
			url : "https://open.t.qq.com/cgi-bin/request_token",
			method : URLRequestMethod.GET
		}
		public static var authorize:Object = {
			url : "https://open.t.qq.com/cgi-bin/authorize",
			method : URLRequestMethod.POST
		};
		public static var access_token:Object = {
			url : "https://open.t.qq.com/cgi-bin/access_token",
			method : URLRequestMethod.GET
		};

		public static var user_info:Object = {
			url : "http://open.t.qq.com/api/user/info",
			method : URLRequestMethod.GET
		};
		public static var other_info:Object = {
			url : "http://open.t.qq.com/api/user/other_info",
			method : URLRequestMethod.GET
		};
		
		public static var friends_add:Object = {
			url : "http://open.t.qq.com/api/friends/add",
			method : URLRequestMethod.POST
		};
		
		
		public static var friends_check:Object = {
			url : "http://open.t.qq.com/api/friends/check",
			method : URLRequestMethod.GET
		};
		
		
		public static var t_add:Object = {
			url : "http://open.t.qq.com/api/t/add",
			method : URLRequestMethod.POST
		};
		
		public static var t_del:Object = {
			url : "http://open.t.qq.com/api/t/del",
			method : URLRequestMethod.POST
		}
		
		
		public static var home_timeline:Object = {
			url : "http://open.t.qq.com/api/statuses/home_timeline",
			method : URLRequestMethod.GET
		};
		
		public static var user_timeline:Object = {
			url : "http://open.t.qq.com/api/statuses/user_timeline",
			method : URLRequestMethod.GET
		};
		
		public static var mentions_timeline:Object = {
			url : "http://open.t.qq.com/api/statuses/mentions_timeline",
			method : URLRequestMethod.GET
		};

		
		public static var info_update:Object = {
			url : "http://open.t.qq.com/api/info/update",
			method : URLRequestMethod.GET
		};
		
		
		
		public var url:String;
		public var method:String;
		public var params:Object = {};
		
		public function TqqApi(api:Object):void {
			url = api.url;
			method = api.method;
		}
		
	}

}