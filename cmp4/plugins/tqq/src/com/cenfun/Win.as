package com.cenfun{
	import flash.external.*;
	import flash.display.*;
	import flash.events.*;
	import flash.ui.*;
	import flash.net.*;
	import flash.utils.*;
	import flash.system.*;
	import flash.text.*;

	import com.adobe.crypto.*;

	public class Win extends MovieClip {
		public var api:Object;
		public var tw:Number;
		public var th:Number;
		public var oauth:TqqOauth;
		
		public var tqq_callback:String;
		
		public var tqq_jscallback:String;
		public var tqq_js_token:String;
		public var tqq_js_token_secret:String;

		//当前微博帐户名，授权后获取
		public var tqq_selfname:String;
		//收听微博帐户名，在cmp配置中自定义
		public var tqq_username:String = "cenfun";
		public var tqq_message:String;
		public var tqq_message_filter:String;
		
		public var xmlself:XML;
		public var xmluser:XML;

		public var connected:Boolean = false;

		//必须定义为public，否则无法返回数据
		public var conn:LocalConnection;
		public var conn_name:String = "_conn_name";

		public var sheet:StyleSheet = new StyleSheet();
		public function Win() {
			oauth = new TqqOauth();
			oauth.addEventListener(TqqOauth.LOADING, oauthLoading);
			oauth.addEventListener(TqqOauth.COMPLETE, oauthComplete);
			
			sheet.parseCSS("a { color:#A5DD37; } a:hover { text-decoration:underline; }");

			win_title.autoSize = "left";
			win_title.styleSheet = sheet;
			win_title.addEventListener(TextEvent.LINK,linkClick);
			main.tweet_menu.addEventListener(TextEvent.LINK,linkClick);

			hideMsg();
			msg.bt_ok.addEventListener(MouseEvent.CLICK,okClick);
			
			hideTalk();
			talk.bt_talk_send.addEventListener(MouseEvent.CLICK,talkSendClick);
			talk.bt_talk_cancel.addEventListener(MouseEvent.CLICK,talkCancelClick);

			hide();
			bt_close.addEventListener(MouseEvent.CLICK,closeClick);

			hideLoading();
			step1.visible = false;
			step2.visible = false;
			main.visible = false;


			step1.bt_connect.addEventListener(MouseEvent.CLICK,connectClick);

			step2.bt_copy.addEventListener(MouseEvent.CLICK,copyClick);
			step2.token_url.addEventListener(MouseEvent.CLICK,copyClick);
			step2.bt_cancel.addEventListener(MouseEvent.CLICK,cancelClick);

			main.bt_follow.addEventListener(MouseEvent.CLICK,followClick);
			main.bt_talk.addEventListener(MouseEvent.CLICK,talkClick);
			main.bt_tweet.addEventListener(MouseEvent.CLICK,tweetClick);
			
			main.is_follow.visible = false;
			main.bt_follow.visible = false;

			//可以拖动;
			dragEnabled();

		}
		
		private function oauthLoading(e:Event):void {
			showLoading();
		}
		private function oauthComplete(e:Event):void {
			hideLoading();
		}
		
		public function talkSendClick(e:MouseEvent):void {
			var str:String = talk.txt.text;
			
			//必须过滤开头和结尾的换行符
			str = Tools.trim(str);
			//过滤中间换行符号
			str = Tools.rn(str);
			
			if (! str) {
				showMsg("请输入对话的内容");
				return;
			}
			
			str = "@" + tqq_username + " " + str;
			
			sendTweets(str);
			
		}
		public function talkCancelClick(e:MouseEvent):void {
			hideTalk();
		}
		
		public function talkClick(e:MouseEvent):void {
			showTalk();
		}

		//============================================================================================
		public function tweetClick(e:MouseEvent):void {
			var str:String = main.tweet_text.text
			
			//必须过滤开头和结尾的换行符
			str = Tools.trim(str);
			//过滤中间换行符号
			str = Tools.rn(str);
			
			sendTweets(str);
		}
		
		public function sendTweets(str:String):void {
			if (! str) {
				showMsg("请输入要发送的内容");
				return;
			}
			
			
			var clientip:String = "127.0.0.1";
			if (api.config.clientip) {
				clientip = api.config.clientip;
			}
			
			var tqqapi:TqqApi = new TqqApi(TqqApi.t_add);
			tqqapi.params.format = "xml";
			tqqapi.params.clientip = clientip;
			tqqapi.params.content = str;
			tqqapi.params.jing = "";
			tqqapi.params.wei = "";
			
			oauth.load(tqqapi, tweetComplete);
		}

		public function tweetComplete(ba:ByteArray):void {
			if (!ba) {
				showMsg("发送失败!");
				return;
			}
			var xml:XML = oauth.parseXML(ba);
			if (xml.ret == "0") {
				showMsg("恭喜！发送成功!");
				hideTalk();
				update();
			} else {
				var str:String = xml.msg;
				var code:String = xml.errcode;
				if (code) {
					str +=  "：" + oauth.getErrorCode(code);
				}
				showMsg(str);
			}

		}
		
		//============================================================================================
		
		public function tweetDel(id:String):void {
			var tqqapi:TqqApi = new TqqApi(TqqApi.t_del);
			tqqapi.params.format = "xml";
			tqqapi.params.id = id;
			
			
			oauth.load(tqqapi, tweetDed);
			
		}
		
		public function tweetDed(ba:ByteArray):void {
			

			var xml:XML = oauth.parseXML(ba);

			if (xml.ret == "0") {
				
				update();
				
			} else {
				showMsg(xml.msg);
			}

		}
		
		//============================================================================================

		public function followClick(e:MouseEvent):void {

			if (tqq_selfname == tqq_username) {
				showMsg("无法收听自己！");
				return;
			}
			
			var tqqapi:TqqApi = new TqqApi(TqqApi.friends_add);
			tqqapi.params.format = "xml";
			tqqapi.params.name = tqq_username;

			
			oauth.load(tqqapi, followLed);
		}
		
		public function followLed(ba:ByteArray):void {
			
			
			if (!ba) {
				showMsg("请求失败!");
				return;
			}

			var xml:XML = oauth.parseXML(ba);

			if (xml.ret == "0") {
				showMsg("已经成功收听 @" + tqq_username);
				
				main.is_follow.visible = true;
				main.bt_follow.visible = false;
				
			} else {
				showMsg(xml.msg);
			}

		}
		

		//=====================================================================================================

		public function connectClick(e:MouseEvent=null):void {
			conn_name = newConnName();
			var vars:Object = {cn:conn_name};
			var callback:String = oauth.addUrlParameters(tqq_callback, vars);
			
			var tqqapi:TqqApi = new TqqApi(TqqApi.request_token);
			tqqapi.params.oauth_callback = callback;
			
			
			step1.visible = false;

			oauth.load(tqqapi, step1Complete);
		}
		
		public function step1Complete(ba:ByteArray):void {
			
			
			if (!ba) {
				showStep(1);
				showMsg("无法连接到腾讯微博，请重试!");
				return;
			}
			
			
			var vars:URLVariables = new URLVariables(ba.toString());
			//trace(vars);
			//trace(vars.oauth_callback_confirmed);
			//取得用户授权request_token

			var token:String = vars.oauth_token;
			var token_secret:String = vars.oauth_token_secret;

			if (token && token.length == 32 && token_secret && token_secret.length == 32) {
				var url:String = TqqApi.authorize.url + "?oauth_token=" + token;
				oauth.setToken(token, token_secret);
				step2.token_url.text = url;
				showStep(2);

				//等待连接程序
				if (conn) {
					conn.close();
					conn = null;
				}
				conn = new LocalConnection();
				conn.allowDomain("*");
				conn.client = this;
				conn.addEventListener(AsyncErrorEvent.ASYNC_ERROR,connError);
				conn.addEventListener(SecurityErrorEvent.SECURITY_ERROR,connError);
				try {
					conn.connect(conn_name);
				} catch (e:ArgumentError) {
					connError();
				}

				//去腾讯微博官方进行授权
				var ok:Boolean = api.tools.strings.open(url);

			} else {
				showStep(1);
				showMsg("没有获取到正确的验证数据，请重试!");
			}
		}

		public function connError(e:Event=null):void {
			showMsg("无法建立等待连接!");
		}


		//=====================================================================================================

		//必须使用callback函数名
		public function callback(obj:Object):void {
			if (! obj) {
				showStep(1);
				showMsg("返回的参数组错误，请重试！");
				return;
			}

			var tqq_verifier:String = obj.oauth_verifier;

			if (! tqq_verifier) {
				showStep(1);
				showMsg("返回的授权码错误，请重试！");
				return;
			}
			
			var tqqapi:TqqApi = new TqqApi(TqqApi.access_token);
			tqqapi.params.oauth_verifier = tqq_verifier;
			
			
			step2.visible = false;

			oauth.load(tqqapi, step2Complete);
		}
		
		public function step2Complete(ba:ByteArray):void {
			
			
			if (!ba) {
				showStep(1);
				showMsg("无法请求到腾讯微博，或者使用的授权码失效，请重试!");
				return;
			}
			
			var vars:URLVariables = new URLVariables(ba.toString());

			//trace(vars);
			tqq_selfname = vars.name;
			var token:String = vars.oauth_token;
			var token_secret:String = vars.oauth_token_secret;

			if (token && token.length == 32 && token_secret && token_secret.length == 32) {

				api.cookie("tqq_token", token);
				api.cookie("tqq_token_secret", token_secret);
				oauth.setToken(token, token_secret);
				
				api.config.tqq_token = token;
				api.config.tqq_token_secret = token_secret;
				
				connected = true;
				
				calljs(vars);
				//
				showMain();

			} else {
				showStep(1);
				showMsg("没有获取到正确的验证数据，请重试！");
			}

		}

		
		private function calljs(vars:Object):void {
			if (tqq_jscallback) {
				if (vars) {
					if (vars.oauth_token != tqq_js_token && vars.oauth_token_secret != tqq_js_token_secret) {
						tqq_js_token = vars.oauth_token;
						tqq_js_token_secret = vars.oauth_token_secret;
						try {
							ExternalInterface.call(tqq_jscallback, vars);
						} catch (e:Error) {
						}
					}
				}
			}
		}


		//=====================================================================================================
		
		
		public function loadSelfInfo():void {

			if (xmlself) {
				showSelfInfo();
				return;
			}
			
			var tqqapi:TqqApi = new TqqApi(TqqApi.user_info);
			tqqapi.params.format = "xml";

			
			oauth.load(tqqapi, selfInfoComplete);
		}
		
		public function selfInfoComplete(ba:ByteArray):void {
			if (!ba) {
				showMsg("无法获取用户@" + tqq_selfname + "的信息，请重试!");
				return;
			}
			
			var xml:XML = oauth.parseXML(ba);
			if (xml.ret == "0") {
				xmlself = xml;
				showSelfInfo();
			} else {
				//取消授权后需要返回第一步
				showStep(1);
				showMsg(xml.msg);
			}
		}

		public function showSelfInfo():void {
			var str:String = "";
			if (xmlself) {
				tqq_selfname = xmlself.data.name;
				var link:String = "http://t.qq.com/" + tqq_selfname;
				str += "<b>" + xmlself.data.nick + " @" + tqq_selfname + "</b>";
				str += ' <font color="#cccccc" size="12px">听众:' + Tools.num_format(xmlself.data.fansnum);
				str += ' 广播:' + Tools.num_format(xmlself.data.tweetnum) + '</font>';
				str += '   <a href="event:update"><b>刷新列表</b></a>';
				str += '   <a href="event:fullscreen"><b>全屏</b></a>';
				str += '   <a href="event:logout"><b>退出</b></a>';
				var avatar:Image = new Image(xmlself.data.head + "/20",20,20,link);
				icon.avatar.addChild(avatar);
				
				//更新menu
				
				var menu:String = '<a href="event:self">全部广播</a>';
				menu += ' | <a href="event:mention">提及我的</a>';
				main.tweet_menu.autoSize = "left";
				main.tweet_menu.styleSheet = sheet;
				main.tweet_menu.htmlText = menu;
				
			}
			
			showTitle(str);
			
		}


		//=====================================================================================================
		public function loadUserInfo():void {

			if (xmluser) {
				showUserInfo();
				return;
			}
			
			var tqqapi:TqqApi = new TqqApi(TqqApi.other_info);
			tqqapi.params.format = "xml";
			tqqapi.params.name = tqq_username;

			
			oauth.load(tqqapi, userinfoComplete);
		}

		
		public function userinfoComplete(ba:ByteArray):void {
			
			
			if (!ba) {
				showMsg("无法获取用户@" + tqq_username + "的信息，请重试!");
				return;
			}

			var xml:XML = oauth.parseXML(ba);
			if (xml.ret == "0") {
				xmluser = xml;
				checkFollow();
				showUserInfo();
			} else {
				showStep(1);
				showMsg(xml.msg);
			}
		}


		public function showUserInfo():void {
			if (! xmluser) {
				return;
			}

			var link:String = "http://t.qq.com/" + xmluser.data.name;

			var avatar:Image = new Image(xmluser.data.head + "/50",50,50,link);
			main.avatar.addChild(avatar);

			var str:String = "<b>" + xmluser.data.nick + "</b> ";
			str +=  '<a href="' + link + '" target="_blank"><b>@' + xmluser.data.name + '</b></a>';
			main.username.htmlText = str;
			main.username.styleSheet = sheet;

			str = "听众：" + Tools.num_format(xmluser.data.fansnum);
			str +=  "    广播：" + Tools.num_format(xmluser.data.tweetnum);
			main.userinfo.htmlText = str;

			str = '<a href="' + link + '" target="_blank">' + link + '</a>';
			main.userlink.styleSheet = sheet;
			main.userlink.htmlText = str;


			var txt:String = tqq_message;
			if (! txt) {
				txt = getPageInfo();
			}
			
			if (! txt) {
				txt =  api.config.name + ' ' + (api.config.link || api.config.share_url);
			}
			if (tqq_message_filter) {
				var arr:Array = api.tools.strings.array(tqq_message_filter);
				for each(var s:String in arr) {
					txt = txt.split(s).join("");
				}
			}
			main.tweet_text.text = txt;
			
			main.tweet_text.addEventListener(Event.CHANGE, updateNum);
			updateNum();

			main.layout();

			main.visible = true;
			
			update();
		}
		
		private function getPageInfo():String {
			if (!ExternalInterface.available) {
				return '';
			}
			if (Capabilities.playerType == "ActiveX" && !ExternalInterface.objectID) {
				return '';
			}
			var arr:Array;
			try {
				arr = ExternalInterface.call("function(){return [document.title,location.href];}");
			} catch (e:Error) {
				return '';
			}
			if (arr is Array) {
				if (arr.length == 2) {
					
					var codepage:Boolean = false
					if (!System.useCodePage) {
						codepage = true;
						System.useCodePage = true;
					}
					var str:String = arr.join(' ');
					
					if (codepage) {
						System.useCodePage = false;
					}
					
					return str;
				}
			}
			return '';
		}
		
		private function updateNum(e:Event = null):void {
			
			var num:Number = 140 - main.tweet_text.text.length;
			var str:String;
			if (num < 0) {
				str = '超出<font color="#ff0000" size="14px"><b>' +  ( - num ) + '</b></font>字';
			} else {
				str = '还能输入<font color="#A5DD37" size="14px"><b>' + num + '</b></font>字';
			}
			main.tweet_num.htmlText = str
			
		}
		
		//============================================================================================
		
		public function loadSelfTweets():void {
			var tqqapi:TqqApi = new TqqApi(TqqApi.home_timeline);
			tqqapi.params.format = "xml";
			//分页标识（0：第一页，1：向下翻页，2向上翻页）
			tqqapi.params.pageflag = 0;
			//本页起始时间（第一页 0，继续：根据返回记录时间决定）
			tqqapi.params.pagetime = 0;
			//每次请求记录的条数（1-20条）
			tqqapi.params.reqnum = 20;

			
			oauth.load(tqqapi, selfTweetsComplete);
			
		}
		public function selfTweetsComplete(ba:ByteArray):void {
			if (!ba) {
				showMsg("无法读取自己的微博列表");
				return;
			}
			var xml:XML = oauth.parseXML(ba);
			if (xml.ret == "0") {
				main.tweet_list_lt.show(xml);
			} else {
				showMsg(xml.msg);
			}
		}
		
		public function loadUserTweets():void {
			var tqqapi:TqqApi = new TqqApi(TqqApi.user_timeline);
			tqqapi.params.format = "xml";
			//分页标识（0：第一页，1：向下翻页，2向上翻页）
			tqqapi.params.pageflag = 0;
			//本页起始时间（第一页 0，继续：根据返回记录时间决定）
			tqqapi.params.pagetime = 0;
			//每次请求记录的条数（1-20条）
			tqqapi.params.reqnum = 20;
			tqqapi.params.name = tqq_username;
			oauth.load(tqqapi, userTweetsComplete);
		}
		public function userTweetsComplete(ba:ByteArray):void {
			if (!ba) {
				showMsg("无法读取推荐用户的微博列表");
				return;
			}
			var xml:XML = oauth.parseXML(ba);
			if (xml.ret == "0") {
				main.tweet_list_rt.show(xml);
			} else {
				showMsg(xml.msg);
			}
		}
		
		
		public function loadMentions():void {
			var tqqapi:TqqApi = new TqqApi(TqqApi.mentions_timeline);
			tqqapi.params.format = "xml";
			tqqapi.params.pageflag = 0;
			tqqapi.params.pagetime = 0;
			tqqapi.params.reqnum = 20;
			tqqapi.params.lastid = 0;
			
			oauth.load(tqqapi, mentionsComplete);
		}
		public function mentionsComplete(ba:ByteArray):void {
			if (!ba) {
				showMsg("请求提及列表时失败");
				return;
			}
			var xml:XML = oauth.parseXML(ba);
			if (xml.ret == "0") {
				main.tweet_list_lt.show(xml);
			} else {
				showMsg(xml.msg);
			}
		}
		
		//============================================================================================
		
		public function checkFollow():void {
			
			var tqqapi:TqqApi = new TqqApi(TqqApi.friends_check);
			tqqapi.params.format = "xml";
			tqqapi.params.names = tqq_username;
			tqqapi.params.flag = 1;

			//
			oauth.load(tqqapi, followCheckComplete);
			
		}
		public function followCheckComplete(ba:ByteArray):void {
			//
			
			if (!ba) {
				main.bt_follow.visible = true;
				return;
			}

			var xml:XML = oauth.parseXML(ba);
			if (xml.ret == "0") {
				
				main.is_follow.visible = false;
				main.bt_follow.visible = false;
				
				var tof:String = xml.data.elements(tqq_username);
				if (tof == "true") {
					main.is_follow.visible = true;
				} else {
					main.bt_follow.visible = true;
				}
				
				
			} else {
				showMsg(xml.msg);
			}
		}
		
		
		//============================================================================================

		public function updateAppToken():void {
			//app_key
			//app_secret
			var app_key:String = api.config.tqq_app_key;
			var app_secret:String = api.config.tqq_app_secret;
			if (app_key && app_key.length == 32 && app_secret && app_secret.length == 32) {
				oauth.setAppkey(app_key, app_secret);
			}
			//tqq_token
			//tqq_token_secret
			var token:String = api.config.tqq_token;
			var token_secret:String = api.config.tqq_token_secret;
			if (token && token.length == 32 && token_secret && token_secret.length == 32) {
				oauth.setToken(token, token_secret);
				calljs({oauth_token:token, oauth_token_secret:token_secret});
				
				connected = true;
				return;
			}
			//
			connected = false;
			calljs({oauth_token:"", oauth_token_secret:""});
		}

		public function apiHandler(_api:Object):void {

			api = _api;
			//读取app和token
			updateAppToken();
			//读取回调通讯地址
			if (api.config.tqq_callback) {
				tqq_callback = api.config.tqq_callback;
			} else {
				showMsg("请为CMP腾讯微博插件配置好正确的tqq_callback参数，否则本插件无法工作");
				return;
			}
			
			if (api.config.tqq_jscallback) {
				tqq_jscallback = api.config.tqq_jscallback;
			}

			if (api.config.tqq_username) {
				tqq_username = api.config.tqq_username;
			}

			if (api.config.tqq_message) {
				tqq_message = api.config.tqq_message;
			}
			if (api.config.tqq_message_filter) {
				tqq_message_filter = api.config.tqq_message_filter;
			}
		}


		public function resizeHandler(_tw:Number,_th:Number):void {

			tw = _tw;
			th = _th;


			bt_close.x = tw - bt_close.width;


			back.width = tw;
			back.height = th;

			loading.x = Math.round(tw * 0.5);
			loading.y = Math.round(th * 0.5);

			var arr:Array = [msg,talk,step1,step2];

			for (var i:int = 0; i < arr.length; i++) {
				var mc:MovieClip = arr[i] as MovieClip;
				mc.x = Math.round(tw * 0.5 - mc.width * 0.5);
				mc.y = Math.round(th * 0.5 - mc.height * 0.5);
			}

			main.resizeHandler(tw - 20, th - 50);
			
		}
		
		
		
		//============================================================================================
		public function cancelClick(e:MouseEvent=null):void {
			oauth.setToken(null, null);
			showStep(1);
		}
		
		public function linkClick(e:TextEvent):void {
			if (e.text == "logout") {
				logout();
			} else if (e.text == "fullscreen") {
				fullscreen();
			} else if (e.text == "update") {
				update();
			} else if (e.text == "self") {
				loadSelfTweets();
			} else if (e.text == "mention") {
				loadMentions();
			}
		}
		
		public function logout():void {

			Tools.clear(icon.avatar);

			showStep(1);

		}
		
		public function fullscreen():void {
			var fm:String = api.config.fullscreen_max;
			api.config.fullscreen_max = "";
			//全屏状态
			var ds:String;
			if (stage.displayState != StageDisplayState.NORMAL) {
				ds = StageDisplayState.NORMAL;
			} else {
				ds = StageDisplayState.FULL_SCREEN;
			}
			try {
				stage.displayState = ds;
			} catch(e:Error) {
				showMsg("无法进入全屏，请检查在网页中是否设置flash的allowfullscreen为true");
			}
			
			api.config.fullscreen_max = fm;
		}
		
		public function update():void {
			
			loadSelfTweets();
			loadUserTweets();
			
			
			//checkInfoUpdate();
		}
		
		
		public function checkInfoUpdate():void {
			
			var tqqapi:TqqApi = new TqqApi(TqqApi.info_update);
			tqqapi.params.format = "xml";
			tqqapi.params.op = 0;
			//
			oauth.load(tqqapi, infoUpdateComplete);
			
		}
		public function infoUpdateComplete(ba:ByteArray):void {
			if (!ba) {
				showMsg("网络错误");
				return;
			}

			var xml:XML = oauth.parseXML(ba);
			if (xml.ret == "0") {
				
				showMsg(xml.toXMLString());
				
			} else {
				showMsg(xml.msg);
			}
		}
		
		//============================================================================================
		
		public function showStep(num:Number):void {

			step1.visible = false;
			step2.visible = false;
			main.visible = false;

			if (num == 1) {
				
				api.cookie("tqq_token","");
				api.cookie("tqq_token_secret","");
				api.config.tqq_token = null;
				api.config.tqq_token_secret = null;
				oauth.setToken(null, null);
				xmluser = null;
				xmlself = null;
				connected = false;
				calljs({oauth_token:"", oauth_token_secret:""});
				
				step1.visible = true;
				showTitle("<b>连接到我的腾讯微博：</b>");
			} else if (num == 2) {
				step2.visible = true;
				showTitle("<b>进行我的微博授权：</b>");
			}

		}

		public function showMain():void {
			step1.visible = false;
			step2.visible = false;
			loadSelfInfo();
			loadUserInfo();
		}

		public function okClick(e:MouseEvent):void {
			hideMsg();
		}

		public function showMsg(str:String=""):void {
			if (str) {
				msg.visible = true;
				msg.content.htmlText = str;
			} else {
				hideMsg();
			}
		}

		public function hideMsg():void {
			msg.visible = false;
			msg.content.htmlText = "";
		}
		
		public function showTalk():void {
			talk.visible = true;
			talk.title.htmlText = "对@" + tqq_username + "说点什么：";
			talk.title.mouseEnabled = false;
			talk.txt.htmlText = "";
			stage.focus = talk.txt;
		}

		public function hideTalk():void {
			talk.visible = false;
			talk.txt.htmlText = "";
		}

		public function dragEnabled():void {
			msg.back.addEventListener(MouseEvent.MOUSE_DOWN, msgDown);
			talk.back.addEventListener(MouseEvent.MOUSE_DOWN, talkDown);
		}
		public function msgDown(e:MouseEvent):void {
			stage.addEventListener(MouseEvent.MOUSE_UP, msgUp);
			msg.startDrag();
		}
		public function talkDown(e:MouseEvent):void {
			stage.addEventListener(MouseEvent.MOUSE_UP, talkUp);
			talk.startDrag();
		}
		public function msgUp(e:MouseEvent):void {
			stage.removeEventListener(MouseEvent.MOUSE_UP, msgUp);
			msg.stopDrag();
		}
		public function talkUp(e:MouseEvent):void {
			stage.removeEventListener(MouseEvent.MOUSE_UP, talkUp);
			talk.stopDrag();
		}

		public function selectAllText(tf:TextField):void {
			if (! tf) {
				return;
			}
			if (stage) {
				stage.focus = tf;
			}
			tf.setSelection(0,tf.length);
			tf.scrollH = 0;
		}
		public function closeClick(e:MouseEvent):void {
			hide();
			
			if (stage.displayState == StageDisplayState.FULL_SCREEN) {
				fullscreen();
			}
			
		}
		public function show():void {
			visible = true;
			//
			updateAppToken();
			//是否连接
			if (connected) {
				showMain();
			} else {
				showStep(1);
			}
		}
		public function hide():void {
			visible = false;
		}

		public function showTitle(str:String):void {
			if (! str) {
				str = "";
			}
			win_title.htmlText = str;
		}

		public function showLoading():void {
			loading.visible = true;
		}

		public function hideLoading():void {
			loading.visible = false;
		}

		public function copyClick(e:MouseEvent=null):void {
			var tf:TextField = step2.token_url;
			if (tf) {
				var url:String = tf.text;
				if (url) {
					api.tools.strings.copy(url);
					selectAllText(tf);
				}
			}
		}
		
		public function newConnName():String {
			return "_cmptqq" + SHA1.hash(Math.random().toString()).substr(0,8).toUpperCase();
		}

	}

}