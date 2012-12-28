/*
 * CMP extends interface
 * http://bbs.cenfun.com/
 *
 * file: http://cenfunmusicplayer.googlecode.com/svn/trunk/developer/wmp/wmp.js
 */
(function(window) {
	var document = window.document;
	var msie = /msie/.test(navigator.userAgent.toLowerCase());
	// QVOD interface
	if (typeof window.QVOD === "undefined") {
		var QVOD = function(key, parent) {
			this.id = "QVOD_" + key;
			this.parent = parent;
		};
		QVOD.prototype = {
			ec : 0,
			ts : "stopped",
			t1 : 0,
			t2 : 0,
			bp : 0,
			dp : 0,
			qvod : null,
			QVO : null,
			ready : false,
			finish : false,
			init : function() {
				if (!this.qvod) {
					this.qvod = document.createElement("object");
					this.qvod.id = this.id;
					if (msie) {
						this.qvod.classid = "clsid:F3D0D36F-23F8-4682-A195-74C92B03D4AF";
					} else {
						this.qvod.type = "'application/qvod-plugin";
					}
					this.parent.appendChild(this.qvod);
				}
				this.ready = false;
				this.QVO = document.getElementById(this.id);
				if (this.QVO) {
					try {
						this.QVO.Showcontrol = 0;
						this.QVO.QvodAdUrl = "blank.htm";
						this.QVO.QvodTextAdUrl = "blank.htm";
						this.QVO.EnableTextAd = false;
						this.QVO.NextWebPage = "blank.htm";
						this.QVO.NumLoop = 0;
						this.ready = true;
					} catch (e) {
					}
				}
				// URL|Autoplay|Mute|Showcontrol|Full|Volume|Duration|Downrate|Canseek|Currentpos|NumLoop|
				// Version|PlayState|hWnd|MainInfo|ViewFrame|SoundTrack|DownPercent|BufferPercent|ParentWnd|
				// NextWebPage|QvodAdUrl|QvodTextAdUrl|EnableTextAd
				// var str = "";
				// for ( var k in this.QVO) {
				// str += k + "|";
				// }
				// var div = document.createElement("div");
				// div.innerHTML = str;
				// document.body.appendChild(div);
			},
			load : function(url) {
				if (!this.ready) {
					this.init();
				}
				if (this.ready) {
					this.finish = false;
					this.QVO.URL = url;
					this.play();
				} else {
					this.finish = true;
				}
			},
			play : function() {
				if (this.ready) {
					this.QVO.Play();
				}
			},
			pause : function() {
				if (this.ready) {
					this.QVO.Pause();
				}
			},
			stop : function() {
				if (this.ready) {
					this.QVO.Stop();
				}
			},
			seek : function(p) {
				if (this.ready) {
					this.QVO.Currentpos = p;
				}
			},
			volume : function(a) {
				if (this.ready) {
					this.QVO.Volume = a[0];
				}
			},
			status : function() {
				if (this.ready) {
					this.ec = 0;
					this.ts = this.getState(this.QVO.PlayState);
					this.t1 = this.QVO.Currentpos;
					this.t2 = this.QVO.Duration;
					this.bp = this.QVO.BufferPercent;
					this.dp = Math.round(this.QVO.get_CurTaskProcess() * 0.1);
				}
				if (this.t2 > 0 && this.dp == 100 && this.t1 > this.t2 - 1) {
					this.finish = true;
				}
				// if (this.bp > 0 && this.bp < 100) {
				// this.ts = "buffering";
				// }
				var arr = [this.ec, this.ts, this.t1, this.t2, this.bp, this.dp, this.finish];
				// document.title = "" + arr;
				return arr;
			},
			getState : function(n) {
				switch (n) {
				case 1:
					return "stopped";
					break;
				case 2:
					return "paused";
					break;
				case 3:
					return "playing";
					break;
				case 4:
					return "buffering";
					break;
				case 7:
					return "completed";
					break;
				default:
					return "connecting";
				}
			},
			error : function() {
				return null;
			},
			info : function() {
				if (this.ready) {
					var info = {
						filename : this.QVO.get_MainInfo()
					};
					return info;
				}
				return null;
			}
		};
		//
		var CMPEI = function() {
		};
		CMPEI.prototype = {
			key : null,
			cmpo : null,
			CMPO : null,
			wmpo : null,
			qvod : null,
			player : null,
			tx : 0,
			ty : 0,
			tw : 0,
			th : 0,
			display : null,
			playing : null,
			init : function(key, cmpo) {
				if (!this.cmpo) {
					// 添加QVOD支持类型
					this.CMPO = window[key];
					this.CMPO.qvod = new QVOD(key, this.CMPO.DIV);
					// CMP事件
					this.key = key;
					this.cmpo = cmpo;
					this.cmpo.addEventListener("model_start", "CMPEI.update");
					this.cmpo.addEventListener("model_state", "CMPEI.update");
					this.cmpo.addEventListener("resize", "CMPEI.update");
					this.cmpo.addEventListener("control_fullscreen", "CMPEI.fullscreen");
				}
			},
			update : function(data) {
				this.display = false;
				this.playing = false;
				var item = this.cmpo.item();
				if (item) {
					if (item.type == "wmp") {
						// 将WMP视频可见
						if (!this.wmpo) {
							this.wmpo = document.getElementById("WMP_" + this.key);
							if (this.wmpo) {
								this.wmpo.uiMode = "None";
								this.wmpo.fullScreen = false;
								this.wmpo.stretchToFit = true;
								this.wmpo.enableContextMenu = true;
								this.wmpo.style.top = "0px";
								this.wmpo.style.left = "0px";
								this.wmpo.style.position = "absolute";
								this.cmpo.parentNode.appendChild(this.wmpo);
							}
						}
						if (!this.qvod) {
							this.qvod = document.getElementById("QVOD_" + this.key);
							if (this.qvod) {
								this.qvod.style.top = "0px";
								this.qvod.style.left = "0px";
								this.qvod.style.position = "absolute";
								this.cmpo.parentNode.appendChild(this.qvod);
							}
						}
						// 根据地址前缀自动判断是否是QVOD
						var prefix = item.url.substr(0, 7);
						if (prefix.toLowerCase() == "qvod://") {
							this.CMPO.player = this.CMPO.qvod;
							this.player = this.qvod;
							if (this.wmpo) {
								this.wmpo.style.display = "none";
							}
						} else {
							this.CMPO.player = this.CMPO.wmp;
							this.player = this.wmpo;
							if (this.qvod) {
								this.qvod.style.display = "none";
							}
						}
						var state = this.cmpo.config("state");
						if (state == "playing") {
							this.playing = true;
							var is_show = this.cmpo.skin("media", "display");
							if (is_show) {
								this.display = true;
							}
						}
					}
				}
				if (this.display) {
					this.tx = 0;
					this.ty = 0;
					if (!this.cmpo.config("video_max")) {
						this.tx = parseInt(this.cmpo.skin("media", "x")) + parseInt(this.cmpo.skin("media.video", "x"));
						this.ty = parseInt(this.cmpo.skin("media", "y")) + parseInt(this.cmpo.skin("media.video", "y"));
					}
					this.tw = this.cmpo.config("video_width");
					this.th = this.cmpo.config("video_height");
					//
					this.player.width = this.tw;
					this.player.height = this.th;
					this.player.style.left = this.tx + "px";
					this.player.style.top = this.ty + "px";
					this.player.style.display = "block";
				} else {
					this.player.style.display = "none";
				}
			},
			fullscreen : function(data) {
				var item = this.cmpo.item();
				if (item.type == "wmp" && this.playing) {
					var fullscreen = this.cmpo.config("fullscreen");
					if (fullscreen) {
						this.cmpo.sendEvent("view_fullscreen");
						if (this.CMPO.player == this.CMPO.qvod) {
							this.player.Full = true;
						} else {
							this.player.fullScreen = true;
						}
					}
				}
			}
		};
		window.CMPEI = new CMPEI();
	}
})(window);