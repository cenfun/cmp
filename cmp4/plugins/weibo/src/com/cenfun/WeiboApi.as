package com.cenfun{
	
	import flash.net.*;

	public class WeiboApi {
		
		private static var API_URL:String = "http://api.t.sina.com.cn/";
		
		public static var request_token:Object = {
			url : API_URL + "oauth/request_token",
			method : URLRequestMethod.GET
		}
		public static var authorize:Object = {
			url : API_URL + "oauth/authorize",
			method : URLRequestMethod.POST
		};
		public static var access_token:Object = {
			url : API_URL + "oauth/access_token",
			method : URLRequestMethod.GET
		};
		
		//用户是否已经开通微博
		public static var user_info:Object = {
			url : API_URL + "account/verify_credentials.xml",
			method : URLRequestMethod.GET
		};
		
		
		//关注
		public static var friends_add:Object = {
			url : API_URL + "friendships/create.xml",
			method : URLRequestMethod.POST
		};
		
		
		public static var t_add:Object = {
			url : API_URL + "statuses/update.xml",
			method : URLRequestMethod.POST
		};
		
		public static var t_del:Object = {
			url : API_URL + "statuses/destroy/{id}.xml",
			method : URLRequestMethod.POST
		}
		
		
		//获取当前登录用户及其所关注用户的最新微博消息
		public static var home_timeline:Object = {
			url : API_URL + "statuses/friends_timeline.xml",
			method : URLRequestMethod.GET
		};
		
		public static var mentions_timeline:Object = {
			url : API_URL + "statuses/mentions.xml",
			method : URLRequestMethod.GET
		};

		
		//未读消息
		public static var info_update:Object = {
			url : API_URL + "statuses/unread.xml",
			method : URLRequestMethod.GET
		};
		//清0未读消息
		public static var info_reset:Object = {
			url : API_URL + "statuses/reset_count.xml",
			method : URLRequestMethod.POST
		};
		
		//话题时间线
		public static var ht_timeline:Object = {
			url : API_URL + "trends/statuses.xml",
			method : URLRequestMethod.GET
		};
		
		//转播
		public static var re_add:Object = {
			url : API_URL + "statuses/repost.xml",
			method : URLRequestMethod.POST
		};
		
		//回复
		public static var reply:Object = {
			url : API_URL + "statuses/comment.xml",
			method : URLRequestMethod.POST
		};
		
		
		
		
		public var url:String;
		public var method:String;
		public var params:Object = {};
		
		public function WeiboApi(api:Object):void {
			url = api.url;
			method = api.method;
		}
		
	}

}