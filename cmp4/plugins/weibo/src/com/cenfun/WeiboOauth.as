package com.cenfun{

	import flash.display.*;
	import flash.events.*;
	import flash.ui.*;
	import flash.net.*;
	import flash.utils.*;
	import flash.system.*;
	import flash.text.*;

	import com.adobe.crypto.*;

	public class WeiboOauth extends EventDispatcher {
		
		public static var LOADING:String = "loading";
		public static var COMPLETE:String = "complete";

		public var weibo_app_key:String = "3833153772";
		public var weibo_app_secret:String = "e6a5df243c2acfc1e757f76634dd3ddf";
		public var weibo_token:String;
		public var weibo_token_secret:String;
		
		public var loader:URLLoader;
		
		//队列
		public var queue:Array;
		public var item:Object;
		public var loading:Boolean;

		public function WeiboOauth() {
			queue = [];
		}
		
		public function setAppkey(app_key:String, app_secret:String):void {
			weibo_app_key = app_key;
			weibo_app_secret = app_secret;
		}
		
		public function setToken(token:String, token_secret:String):void {
			weibo_token = token;
			weibo_token_secret = token_secret;
		}
		
		public function addUrlParameters(url:String, obj:Object):String {
			if (! url) {
				return "";
			}
			if (url.indexOf("?") == -1) {
				url +=  "?";
			} else {
				url +=  "&";
			}
			if (obj) {
				var arr:Array = [];
				for (var i:String in obj) {
					arr.push(i + "=" + encodeURIComponent(obj[i]));
				}
				url +=  arr.join("&");
			}
			return url;
		}
		private function parseUtf8Xml(ba:ByteArray):XML {
			var str:String = "";
			if (ba is ByteArray) {
				var a:ByteArray = new ByteArray();
				a.writeByte(239);
				a.writeByte(187);
				a.writeByte(191);
				a.writeBytes(ba);
				str = a.toString();
			} else if (ba) {
				str = ba.toString();
			}
			var xml:XML;
			try {
				xml = new XML(str);
			} catch (e:Error) {
			}
			return xml;
		}
		
		public function parseXML(ba:ByteArray):XML {
			var xml:XML = parseUtf8Xml(ba);
			if (xml) {
				var error_code:String = xml.error_code;
				
				if (error_code) {
					xml.@ret = error_code;
				} else {
					xml.@ret = "0";
				}
				return xml;
			} else {
				return <root ret="4"><error>wrong xml format</error></root>;
			}
		}

		private function nonce():String {
			var now:Date = new Date();
			var p1:String = now.getTime().toString();
			var p2:String = Math.random().toString().substr(2);
			var p3:String = Capabilities.serverString;
			var id:String = SHA1.hash(p1 + p3 + p2).substr(0,32);
			return id;
		}

		private function timestamp():String {
			return new Date().getTime().toString().substr(0,10);
		}

		private function getOAuthParams():Object {
			var params:Object = {};

			params["oauth_consumer_key"] = weibo_app_key;
			if (weibo_token && weibo_token.length > 0) {
				params["oauth_token"] = weibo_token;
			}
			params["oauth_signature_method"] = "HMAC-SHA1";
			params["oauth_timestamp"] = timestamp();
			params["oauth_nonce"] = nonce();
			params["oauth_version"] = "1.0";

			return params;
		}

		private function makeSignableParamStr(params:Object):String {
			var retParams:Array = [];

			for (var param:String in params) {
				if (param != "oauth_signature") {
					retParams.push(param + "=" + URLEncoding.encode(params[param].toString()));
				}
			}
			retParams.sort();

			return retParams.join("&");
		}

		private function signRequest(requestMethod:String, url:String, requestParams:Object):URLRequest {
			
			//请求方法
			var method:String = requestMethod.toUpperCase();
			
			//请求参数
			var params:Object = {};
			
			//oauth参数
			var oauthParams:Object = getOAuthParams();
			for (var key:String in oauthParams) {
				params[key] = oauthParams[key];
			}
			
			//自定义传递参数
			for (var key1:String in requestParams) {
				params[key1] = requestParams[key1];
			}
			
			//参数串
			var paramsStr:String = makeSignableParamStr(params);
			
			//签名串
			var msgStr:String = URLEncoding.encode(method);
			msgStr +=  "&";
			msgStr +=  URLEncoding.encode(url);
			msgStr +=  "&";
			msgStr +=  URLEncoding.encode(paramsStr);
			
			//密匙
			var secrectStr:String = weibo_app_secret + "&";
			if (weibo_token && weibo_token.length > 0 && weibo_token_secret && weibo_token_secret.length > 0) {
				secrectStr +=  weibo_token_secret;
			}

			//签名
			var str:String = HMAC.hash(secrectStr,msgStr,SHA1);
			str = hex(str);
			var sig:String = Base64.encode(str);
			
			//设置请求
			var req:URLRequest = new URLRequest();
			req.method = method;

			if (method == URLRequestMethod.GET) {
				
				//GET url需要编码一下
				sig = encodeURIComponent(sig);
				req.url = url + "?" + paramsStr + "&oauth_signature=" + sig;

			} else if (requestMethod == URLRequestMethod.POST) {
				
				req.url = url;
				var vars:URLVariables = new URLVariables(paramsStr);
				vars.oauth_signature = sig;
				req.data = vars;
				
			}
			
			return req;
		}
		
		public function load(weiboapi:WeiboApi, onComplete:Function):void {
			
			//加入队列
			queue.push({weiboapi:weiboapi,onComplete:onComplete});
			
			start();
			
		}
		
		
		private function start():void {
			
			if (!queue.length || loading) {
				return;
			}
			
			item = queue.shift();
			
			if (!item) {
				return;
			}
			
			loading = true;
			dispatchEvent(new Event(WeiboOauth.LOADING));
			
			//关闭之前的
			if (loader) {
				try {
					loader.close();
				} catch(e:Error) {
				}
				loader = null;
			}
			
			//中文乱码问题
			var codepage:Boolean = false
			if (System.useCodePage) {
				codepage = true;
				System.useCodePage = false;
			}
			var req:URLRequest = signRequest(item.weiboapi.method, item.weiboapi.url, item.weiboapi.params);
			loader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.BINARY;
			loader.addEventListener(IOErrorEvent.IO_ERROR, onError);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
			loader.addEventListener(Event.COMPLETE, onLoaded);
			try {
				loader.load(req);
			} catch (e:Error) {
				onError();
			}
			//恢复编码
			if (codepage) {
				System.useCodePage = true;
			}
		}
		
		private function onError(e:Event = null):void {
			onComplete(e.target.data);
		}
		private function onLoaded(e:Event):void {
			onComplete(e.target.data);
		}
		
		private function onComplete(ba:ByteArray):void {
			loading = false;
			dispatchEvent(new Event(WeiboOauth.COMPLETE));
			if (item) {
				if (item.onComplete is Function) {
					item.onComplete(ba);
				}
			}
			start();
		}
		
		
		private function hex(str:String):String {
			var c:String = "";
			var arr:Array = str.split("");
			while (arr.length) {
				c +=  String.fromCharCode(parseInt(arr.shift() + arr.shift(), 16));
			}
			return c;
		}
		

	}

}