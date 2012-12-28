package com.cenfun{

	import flash.display.*;
	import flash.events.*;
	import flash.ui.*;
	import flash.net.*;
	import flash.utils.*;
	import flash.system.*;
	import flash.text.*;

	import com.adobe.crypto.*;

	public class TqqOauth extends EventDispatcher {
		
		public static var LOADING:String = "loading";
		public static var COMPLETE:String = "complete";

		public var tqq_app_key:String = "4d3bdc0ff4ac456e8df13ca92fa87a6f";
		public var tqq_app_secret:String = "a6e32cd939361e933381b096872e33f2";
		public var tqq_token:String;
		public var tqq_token_secret:String;
		
		public var loader:URLLoader;
		
		//队列
		public var queue:Array;
		public var item:Object;
		public var loading:Boolean;

		public function TqqOauth() {
			queue = [];
		}
		
		public function setAppkey(app_key:String, app_secret:String):void {
			tqq_app_key = app_key;
			tqq_app_secret = app_secret;
		}
		
		public function setToken(token:String, token_secret:String):void {
			tqq_token = token;
			tqq_token_secret = token_secret;
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

				xml.msg +=  "：" + getRetCode(xml.ret);

				return xml;
			} else {
				return <root><msg>wrong xml format</msg><ret>4</ret></root>;
			}
		}

		public function getErrorCode(code:String):String {

			var codes:Array = [];
			codes[0] = "表示成功";
			codes[4] = "表示有过多脏话";
			codes[5] = "禁止访问，如城市，uin黑名单限制等";
			codes[6] = "删除时：该记录不存在。发表时：父节点已不存在";
			codes[8] = "内容超过最大长度：420字节 （以进行短url处理后的长度计）";
			codes[9] = "包含垃圾信息：广告，恶意链接、黑名单号码等";
			codes[10] = "发表太快，被频率限制";
			codes[11] = "源消息已删除，如转播或回复时";
			codes[12] = "源消息审核中";
			codes[13] = "重复发表";

			var i:int = parseInt(code);
			return codes[i];

		}

		public function getRetCode(code:String):String {
			var codes:Array = [];
			codes[0] = "成功返回";
			codes[1] = "参数错误";
			codes[2] = "频率受限";
			codes[3] = "鉴权失败";
			codes[4] = "服务器内部错误";
			var i:int = parseInt(code);
			return codes[i];
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

			params["oauth_consumer_key"] = tqq_app_key;
			if (tqq_token && tqq_token.length > 0) {
				params["oauth_token"] = tqq_token;
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
			var secrectStr:String = tqq_app_secret + "&";
			if (tqq_token && tqq_token.length > 0 && tqq_token_secret && tqq_token_secret.length > 0) {
				secrectStr +=  tqq_token_secret;
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
		
		public function load(tqqapi:TqqApi, onComplete:Function):void {
			
			//加入队列
			queue.push({tqqapi:tqqapi,onComplete:onComplete});
			
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
			dispatchEvent(new Event(TqqOauth.LOADING));
			
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
			var req:URLRequest = signRequest(item.tqqapi.method, item.tqqapi.url, item.tqqapi.params);
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
			onComplete(null);
		}
		private function onLoaded(e:Event):void {
			onComplete(e.target.data);
		}
		
		private function onComplete(ba:ByteArray):void {
			loading = false;
			dispatchEvent(new Event(TqqOauth.COMPLETE));
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