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
		//微博话题
		public static const WBHT:String = "wbht";
		//微博回复
		public static const WBHF:String = "wbhf";
		//微博转播
		public static const WBZB:String = "wbzb";
		//对话
		public static const TALK:String = "talk";
		//自己
		public static const HOME:String = "home";
		//提及
		public static const MENT:String = "ment";
		//========================================
		public var api:Object;
		public var tw:Number;
		public var th:Number;
		public var oauth:WeiboOauth;
		
		public var weibo_callback:String = "http://cmpweibo.sinaapp.com/plugins/weibocallback.htm";
		
		public var weibo_jscallback:String;
		public var weibo_js_token:String;
		public var weibo_js_token_secret:String;
		
		public static var win:Win;
		//当前微博帐户名，授权后获取
		public static var weibo_selfname:String;
		
		//收听微博帐户名，在cmp配置中自定义
		public var weibo_username:String = "cenfun";
		//当前需要的微博id
		public var tweet_id:String;

		public var page:Number = 1;
		public var count:Number = 20;
		public var hasnext:Boolean = true;
		
		public var weibo_topic:String = "CMP";
		public var current_list:String = WBHT;
		
		public var form_type:String = WBHT;
		public var total:Number = 140;
		
		public var xmlself:XML;
		public var xmlinfo:XML;

		public var nexting:Boolean = false;
		public var connected:Boolean = false;
		public var timeid:uint;
		public var interval:uint;

		//必须定义为public，否则无法返回数据
		public var conn:LocalConnection;
		public var conn_name:String = "_conn_name";

		public var sheet:StyleSheet = new StyleSheet();
		
		public function Win() {
			
			win = this;
			
			oauth = new WeiboOauth();
			oauth.addEventListener(WeiboOauth.LOADING, oauthLoading);
			oauth.addEventListener(WeiboOauth.COMPLETE, oauthComplete);
			
			sheet.parseCSS("a { color:#A5DD37; } a:hover { text-decoration:underline; }");

			win_title.autoSize = "left";
			win_title.styleSheet = sheet;
			win_title.addEventListener(TextEvent.LINK,linkClick);
			main.tweet_menu.addEventListener(TextEvent.LINK,linkClick);

			hideMsg();
			msg.bt_ok.addEventListener(MouseEvent.CLICK,okClick);
			
			hideForm();
			form.bt_form_send.addEventListener(MouseEvent.CLICK,formSendClick);
			form.bt_form_cancel.addEventListener(MouseEvent.CLICK,formCancelClick);
			form.txt.addEventListener(Event.CHANGE, updateNum);

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

			main.bt_tweet.addEventListener(MouseEvent.CLICK,tweetClick);
			main.tweet_list.addEventListener(Tlist.NEXT_PAGE,nextPage);

			//可以拖动;
			dragEnabled();

		}
		
		public function nextPage(e:Event):void {
			if (!nexting) {
				nexting = true;
				update();
			}
		}
		
		private function oauthLoading(e:Event):void {
			showLoading();
		}
		private function oauthComplete(e:Event):void {
			hideLoading();
		}
		
		public function formCancelClick(e:MouseEvent):void {
			hideForm();
		}
		
		public function tweetClick(e:MouseEvent):void {
			form_type = WBHT;
			showForm();
		}
		
		
		//==============================================================================
		public function formSendClick(e:MouseEvent):void {
			var str:String = form.txt.text;
			
			//必须过滤开头和结尾的换行符
			str = Tools.trim(str);
			//过滤中间换行符号
			str = Tools.rn(str);
			
			
			if (form_type != WBZB && ! str) {
				showMsg("请输入对话的内容");
				return;
			}
			if (form_type == WBHT) {
				str = "#" + weibo_topic + "# " + str;
				sendTweet(str);
			} else if (form_type == TALK) {
				str = "@" + weibo_username + " " + str;
				sendTweet(str);
			} else if (form_type == WBZB) {
				//转播
				reTweet(str, 0);
				
			} else if (form_type == WBHF) {
				//回复
				reTweet(str, 1);
			}
		}
		
		public function reTweet(str:String, is_comment:Number):void {
			var weiboapi:WeiboApi = new WeiboApi(WeiboApi.re_add);
				
			weiboapi.params.id = tweet_id;
			weiboapi.params.status = str;
			weiboapi.params.is_comment = is_comment;
				
			oauth.load(weiboapi, tweetComplete);
		}
		
		
		public function sendTweet(str:String):void {
			var weiboapi:WeiboApi = new WeiboApi(WeiboApi.t_add);
			weiboapi.params.status = str;
			oauth.load(weiboapi, tweetComplete);
		}

		public function tweetComplete(ba:ByteArray):void {
			if (!ba) {
				showMsg("发送失败!");
				return;
			}
			var xml:XML = oauth.parseXML(ba);
			if (xml.@ret == "0") {
				showMsg("恭喜！提交成功!", 2);
				hideForm();
				//刷新列表
				if (form_type == WBHT) {
					current_list = WBHT;
				} else if (form_type == WBHF || form_type == WBZB || form_type == TALK) {
					current_list = HOME;
				}
				update();   
			} else {
				showMsg(xml.error);
			}

		}
		
		//============================================================================================
		
		public function tweetDel(id:String):void {
			
			var theapi:Object = WeiboApi.t_del;
			
			theapi.url = theapi.url.replace("{id}", id);
			
			var weiboapi:WeiboApi = new WeiboApi(theapi);

			oauth.load(weiboapi, tweetDelDone);
		}
		
		public function tweetDelDone(ba:ByteArray):void {
			var xml:XML = oauth.parseXML(ba);
			if (xml.@ret == "0") {
				update();
			} else {
				showMsg(xml.error);
			}
		}
		
		//============================================================================================
		
		//转播
		public function tweetReAdd(id:String):void {
			tweet_id = id;
			form_type = WBZB;
			showForm();
		}
		
		//回复
		public function tweetReply(id:String):void {
			tweet_id = id;
			form_type = WBHF;
			showForm();
		}
		
		
		//============================================================================================
		public function userTalk(username:String):void {
			weibo_username = username;
			form_type = TALK;
			showForm();
		}

		public function userFollow(val:String):void {
			if (!val) {
				return;
			}
			var arr:Array = val.split(",");
			var un:String = arr[0];
			var id:String = arr[1];
			
			if (weibo_selfname == un) {
				showMsg("无法收听自己！", 2);
				return;
			}
			weibo_username = un;
			
			var weiboapi:WeiboApi = new WeiboApi(WeiboApi.friends_add);
			weiboapi.params.user_id = id;
			
			oauth.load(weiboapi, followDone);
		}
		
		public function followDone(ba:ByteArray):void {
			if (!ba) {
				showMsg("请求失败!");
				return;
			}
			var xml:XML = oauth.parseXML(ba);
			if (xml.@ret == "0") {
				showMsg("已经成功收听 @" + weibo_username, 1);
			} else {
				showMsg(xml.error);
			}
		}
		

		//=====================================================================================================

		public function connectClick(e:MouseEvent=null):void {
			conn_name = newConnName();
			var vars:Object = {cn:conn_name};
			var callback:String = oauth.addUrlParameters(weibo_callback, vars);
			
			var weiboapi:WeiboApi = new WeiboApi(WeiboApi.request_token);
			weiboapi.params.oauth_callback = callback;
			
			
			step1.visible = false;

			oauth.load(weiboapi, step1Complete);
		}
		
		public function step1Complete(ba:ByteArray):void {
			
			
			if (!ba) {
				showStep(1);
				showMsg("无法连接到微博，请重试!");
				return;
			}
			
			
			var vars:URLVariables = new URLVariables(ba.toString());
			//trace(vars);
			//trace(vars.oauth_callback_confirmed);
			//取得用户授权request_token

			var token:String = vars.oauth_token;
			var token_secret:String = vars.oauth_token_secret;

			if (token && token_secret) {
				var url:String = WeiboApi.authorize.url + "?oauth_token=" + token;
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

				//去微博官方进行授权
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

			var weibo_verifier:String = obj.oauth_verifier;

			if (! weibo_verifier) {
				showStep(1);
				showMsg("返回的授权码错误，请重试！");
				return;
			}
			
			var weiboapi:WeiboApi = new WeiboApi(WeiboApi.access_token);
			weiboapi.params.oauth_verifier = weibo_verifier;
			
			
			step2.visible = false;

			oauth.load(weiboapi, step2Complete);
		}
		
		public function step2Complete(ba:ByteArray):void {
			
			
			if (!ba) {
				showStep(1);
				showMsg("无法请求到微博，或者使用的授权码失效，请重试!");
				return;
			}
			
			var vars:URLVariables = new URLVariables(ba.toString());
			//Debug.show(vars);
			var token:String = vars.oauth_token;
			var token_secret:String = vars.oauth_token_secret;

			if (token && token_secret) {

				api.cookie("weibo_token", token);
				api.cookie("weibo_token_secret", token_secret);
				oauth.setToken(token, token_secret);
				
				api.config.weibo_token = token;
				api.config.weibo_token_secret = token_secret;
				
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
			if (weibo_jscallback) {
				if (vars) {
					if (vars.oauth_token != weibo_js_token && vars.oauth_token_secret != weibo_js_token_secret) {
						weibo_js_token = vars.oauth_token;
						weibo_js_token_secret = vars.oauth_token_secret;
						try {
							ExternalInterface.call(weibo_jscallback, vars);
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
				current_list = WBHT;
				update();
				return;
			}
			var weiboapi:WeiboApi = new WeiboApi(WeiboApi.user_info);
			oauth.load(weiboapi, selfInfoComplete);
		}
		
		public function selfInfoComplete(ba:ByteArray):void {
			if (!ba) {
				showMsg("无法获取用户@" + weibo_selfname + "的信息，请重试!");
				return;
			}
			
			var xml:XML = oauth.parseXML(ba);
			
			//Debug.show(xml.toXMLString());
			
			if (xml.@ret == "0") {
				xmlself = xml;
				showSelfInfo();
				main.visible = true;
				//更新数目
				checkInfoUpdate();
				interval = setInterval(checkInfoUpdate, 60 * 1000);
				//加载话题
				current_list = WBHT;
				update();
			} else {
				//取消授权后需要返回第一步
				showStep(1);
				showMsg(xml.error);
			}
		}

		public function showSelfInfo():void {
			var str:String = "";
			if (xmlself) {
				weibo_selfname = xmlself.name;
				var link:String = Tools.getLink(xmlself);
				str += '<a href="'+link+'" target="_blank"><b><font color="#ffffff">' + xmlself.screen_name + '</font></b></a>  ';
				str += '<font size="12px">'
				str += '<a href="'+link+'/follow" target="_blank">关注:<font size="11px">' + Tools.num_format(xmlself.friends_count) + '</font></a>  ';
				str += '<a href="'+link+'/fans" target="_blank">粉丝:<font size="11px">' + Tools.num_format(xmlself.followers_count) + '</font></a>  ';
				str += '<a href="'+link+'/profile" target="_blank">微博:<font size="11px">' + Tools.num_format(xmlself.statuses_count) + '</font></a>';
				str += '</font>';
				str += '   <a href="event:fullscreen"><b>全屏</b></a>';
				str += '   <a href="event:logout"><b>退出</b></a>';
				var avatar:Image = new Image(xmlself.profile_image_url, 20, 20, link);
				icon.avatar.addChild(avatar);
				showMenu();
			}
			
			showTitle(str);
			
		}
		
		public function showMenu():void {
			var ms:Array = [];
			var wbht:String = "#" + weibo_topic + "#";
			ms.push([wbht, WBHT]);
			
			var home:String = "我的首页";
			var ment:String = "提及我的";
			/*
			<new_status>1</new_status>
  			<followers>0</followers>
  			<dm>1</dm>
  			<mentions>1</mentions>
  			<comments>3</comments>
			*/
			if (xmlinfo) {
				var num:String = xmlinfo.new_status;
				if (num && "0" != num) {
					home += "(" + num + "新)";
				}
				num = xmlinfo.mentions;
				if (num && "0" != num) {
					ment += "(" + num + "新)";
				}
			}
			ms.push([home, HOME]);
			ms.push([ment, MENT]);
			
			var arr:Array = [];
			for each(var a:Array in ms) {
				var s:String = a[0];
				var e:String = a[1];
				if (e != current_list) {
					s = '<font color="#999999">' + s + '</font>';
				}
				s = '<a href="event:' + e + '"><b>' + s + '</b></a>';
				arr.push(s);
			}
			var menu:String = arr.join("  |  ");
			main.tweet_menu.autoSize = "left";
			main.tweet_menu.styleSheet = sheet;
			main.tweet_menu.htmlText = menu;
		}
		
		//============================================================================================
		
		
		public function updateAppToken():void {
			//app_key
			//app_secret
			var app_key:String = api.config.weibo_app_key;
			var app_secret:String = api.config.weibo_app_secret;
			if (app_key && app_secret) {
				oauth.setAppkey(app_key, app_secret);
			}
			//weibo_token
			//weibo_token_secret
			var token:String = api.config.weibo_token;
			var token_secret:String = api.config.weibo_token_secret;
			if (token && token_secret) {
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
			if (api.config.weibo_callback) {
				weibo_callback = api.config.weibo_callback;
			}
			
			if (api.config.weibo_jscallback) {
				weibo_jscallback = api.config.weibo_jscallback;
			}
			if (api.config.weibo_topic) {
				weibo_topic = api.config.weibo_topic;
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

			var arr:Array = [msg,form,step1,step2];

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
			
			var val:String = e.text;
			
			if (val == "logout") {
				logout();
			} else if (val == "fullscreen") {
				fullscreen();
			} else if (val == WBHT || val == HOME || val == MENT) {
				
				if (val != WBHT) {
					resetInfo(val);
				}
				
				current_list = val;
				update();
			}
		}
		
		
		public function update():void {
			//清除下一页标记
			if (!nexting) {
				hasnext = true;
			}
			
			if (current_list == WBHT) {
				loadHtTweets();
			} else if (current_list == HOME) {
				loadHomeTweets();
			} else if (current_list == MENT) {
				loadMentions();
			} else {
				loadHtTweets();
			}
		}
		
		public function logout():void {

			Tools.clear(icon.avatar);

			showStep(1);

		}
		
		public function showList(xml:XML):void {
			
			if (nexting) {
				main.tweet_list.show(xml, false);
				nexting = false;
			} else {
				main.tweet_list.show(xml);
			}
			
			showMenu();
		}
		
		public function fullscreen():void {
			//保存全屏最大化设置，并设置为空，使全屏后不进行视频或歌词的最大化
			var fm:String = api.config.fullscreen_max;
			api.config.fullscreen_max = "";
			var bm:String = api.skin_xml.console.bt_fullscreen.@fullscreen_max;
			api.skin_xml.console.bt_fullscreen.@fullscreen_max = "";
			//尝试全屏操作
			api.sendEvent("view_fullscreen");
			//恢复原有全屏最大化设置
			api.config.fullscreen_max = fm;
			api.skin_xml.console.bt_fullscreen.@fullscreen_max = bm
		}
		
		public function loadHtTweets():void {
			var weiboapi:WeiboApi = new WeiboApi(WeiboApi.ht_timeline);
			//分页标识
			if (nexting) {
				//不能往下翻
				if (!hasnext) {
					nexting = false;
					return;
				}
				page = page + 1;
			} else {
				page = 1;
			}
			
			weiboapi.params.page = page;
			//weiboapi.params.count = count;
			//
			weiboapi.params.trend_name = "#" + weibo_topic + "#";
			oauth.load(weiboapi, htTweetsComplete);
		}
		public function htTweetsComplete(ba:ByteArray):void {
			if (!ba) {
				showMsg("无法读取当前话题列表：" + weibo_topic);
				return;
			}
			var xml:XML = oauth.parseXML(ba);
			//Debug.show(xml);
			if (xml.@ret == "0") {
				var totalnum:Number = xml.children().length();
				hasnext = (totalnum > 0) ? true : false;
				showList(xml);
			} else {
				showMsg(xml.error);
			}
		}

		//=====================================================================
		public function loadHomeTweets():void {
			var weiboapi:WeiboApi = new WeiboApi(WeiboApi.home_timeline);
			//分页标识
			if (nexting) {
				//不能往下翻
				if (!hasnext) {
					nexting = false;
					return;
				}
				page = page + 1;
			} else {
				page = 1;
			}
			weiboapi.params.page = page;
			weiboapi.params.count = count;

			oauth.load(weiboapi, selfTweetsComplete);
		}
		public function selfTweetsComplete(ba:ByteArray):void {
			if (!ba) {
				showMsg("无法读取自己的微博列表");
				return;
			}
			var xml:XML = oauth.parseXML(ba);
			
			var str = xml.toXMLString();
			if (xml.@ret == "0") {
				var totalnum:Number = xml.children().length();
				hasnext = (totalnum == count) ? true : false;
				showList(xml);
			} else {
				showMsg(xml.error);
			}
		}
		
		public function loadMentions():void {
			var weiboapi:WeiboApi = new WeiboApi(WeiboApi.mentions_timeline);
			//分页标识
			if (nexting) {
				//不能往下翻
				if (!hasnext) {
					nexting = false;
					return;
				}
				page = page + 1;
			} else {
				page = 1;
			}
			weiboapi.params.page = page;
			weiboapi.params.count = count;
			oauth.load(weiboapi, mentionsComplete);
		}
		public function mentionsComplete(ba:ByteArray):void {
			if (!ba) {
				showMsg("请求提及列表时失败");
				return;
			}
			var xml:XML = oauth.parseXML(ba);
			if (xml.@ret == "0") {
				var totalnum:Number = xml.children().length();
				hasnext = (totalnum == count) ? true : false;
				showList(xml);
			} else {
				showMsg(xml.error);
			}
		}
		
		//============================================================================================
		public function resetInfo(type:String):void {
			var weiboapi:WeiboApi = new WeiboApi(WeiboApi.info_reset);
			//清零的计数类别有：1. 评论数，2. @me数，3. 私信数，4. 关注数 
			if (type == HOME) {
				weiboapi.params.type = 4;
			} else if (type == MENT) {
				weiboapi.params.type = 2;
			}
			oauth.load(weiboapi, resetInfoComplete);
		}
		public function resetInfoComplete(ba:ByteArray):void {
			if (!ba) {
				return;
			}
			var xml:XML = oauth.parseXML(ba);
			if (xml.@ret == "0") {
				var result:String = xml.result;
				if (result == "true") {
					checkInfoUpdate();
				}
			}
		}
		
		public function checkInfoUpdate():void {
			//仅显示时请求
			if (!main.visible) {
				return;
			}
			var weiboapi:WeiboApi = new WeiboApi(WeiboApi.info_update);
			oauth.load(weiboapi, infoUpdateComplete);
		}
		public function infoUpdateComplete(ba:ByteArray):void {
			if (!ba) {
				return;
			}
			var xml:XML = oauth.parseXML(ba);
			if (xml.@ret == "0") {
				xmlinfo = xml;
				showMenu();
			}
		}
		
		//============================================================================================
		
		public function showStep(num:Number):void {

			step1.visible = false;
			step2.visible = false;
			main.visible = false;

			if (num == 1) {
				
				api.cookie("weibo_token","");
				api.cookie("weibo_token_secret","");
				api.config.weibo_token = null;
				api.config.weibo_token_secret = null;
				oauth.setToken(null, null);
				xmlinfo = null;
				xmlself = null;
				connected = false;
				calljs({oauth_token:"", oauth_token_secret:""});
				
				step1.visible = true;
				showTitle("<b>连接到我的微博：</b>");
			} else if (num == 2) {
				step2.visible = true;
				showTitle("<b>进行我的微博授权：</b>");
			}

		}

		public function showMain():void {
			step1.visible = false;
			step2.visible = false;
			loadSelfInfo();
		}

		public function okClick(e:MouseEvent):void {
			hideMsg();
		}
		
		//=================================================================================


		public function showMsg(str:String="", time:Number = 0):void {
			if (str) {
				msg.visible = true;
				msg.content.htmlText = str;
			} else {
				hideMsg();
			}
			
			clearTimeout(timeid);
			if (time) {
				timeid = setTimeout(hideMsg, time * 1000);
			}
			
		}

		public function hideMsg():void {
			clearTimeout(timeid);
			msg.visible = false;
			msg.content.htmlText = "";
		}
		
		
		//=================================================================================

		public function showForm():void {
			var str:String = "发表广播：";
			if (form_type == WBHT) {
				str = '<b>在#' + weibo_topic + '#发表留言：</b>';
				total = 140 - weibo_topic.length - 3;
			} else if (form_type == TALK) {
				str = '<b>对@' + weibo_username + '说：</b>';
				total = 140 - weibo_username.length - 2;
			} else if (form_type == WBHF) {
				str = '<b>评论：</b>';
				total = 140;
			} else if (form_type == WBZB) {
				str = '<b>转播：</b>';
				total = 140;
			}
			
			form.title.htmlText = str;
			form.title.mouseEnabled = false;
			form.txt.htmlText = "";
			updateNum();
			
			if (!form.visible) {
				form.visible = true;
				form.alpha = 0;
			}
			TweenNano.to(form, 0.2, {alpha:1, onComplete:showFormDone});
		}
		
		private function showFormDone():void {
			stage.focus = form.txt;
		}

		public function hideForm():void {
			
			form.txt.htmlText = "";
			if (form.visible) {
				TweenNano.to(form, 0.2, {alpha:0, onComplete:hideFormDone});
			}
		}
		private function hideFormDone():void {
			form.visible = false;
		}
		
		private function updateNum(e:Event = null):void {
			
			var num:Number = total - form.txt.text.length;
			var str:String;
			if (num < 0) {
				str = '超出<font color="#ff0000"><b>' +  ( - num ) + '</b></font>字';
			} else {
				str = '还能输入<font color="#A5DD37"><b>' + num + '</b></font>字';
			}
			form.num.htmlText = str
			
		}
		
		//=================================================================================

		public function dragEnabled():void {
			msg.back.addEventListener(MouseEvent.MOUSE_DOWN, msgDown);
			form.back.addEventListener(MouseEvent.MOUSE_DOWN, formDown);
		}
		public function msgDown(e:MouseEvent):void {
			stage.addEventListener(MouseEvent.MOUSE_UP, msgUp);
			msg.startDrag();
		}
		public function formDown(e:MouseEvent):void {
			stage.addEventListener(MouseEvent.MOUSE_UP, formUp);
			form.startDrag();
		}
		public function msgUp(e:MouseEvent):void {
			stage.removeEventListener(MouseEvent.MOUSE_UP, msgUp);
			msg.stopDrag();
		}
		public function formUp(e:MouseEvent):void {
			stage.removeEventListener(MouseEvent.MOUSE_UP, formUp);
			form.stopDrag();
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
			return "_cmpweibo" + SHA1.hash(Math.random().toString()).substr(0,8).toUpperCase();
		}

	}

}