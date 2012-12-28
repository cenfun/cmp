package {

	import flash.display.*;
	import flash.events.*;
	import flash.external.*;
	import flash.text.*;
	import flash.net.*;
	import flash.utils.*;
	import flash.geom.*;
	import flash.system.*;


	import com.google.ads.instream.api.Ad;
	import com.google.ads.instream.api.AdErrorEvent;
	import com.google.ads.instream.api.AdEvent;
	import com.google.ads.instream.api.AdLoadedEvent;
	import com.google.ads.instream.api.AdSizeChangedEvent;
	import com.google.ads.instream.api.AdTypes;
	import com.google.ads.instream.api.AdsLoadedEvent;
	import com.google.ads.instream.api.AdsLoader;
	import com.google.ads.instream.api.AdsManager;
	import com.google.ads.instream.api.AdsManagerTypes;
	import com.google.ads.instream.api.AdsRequest;
	import com.google.ads.instream.api.AdsRequestType;
	import com.google.ads.instream.api.CustomContentAd;
	import com.google.ads.instream.api.FlashAd;
	import com.google.ads.instream.api.FlashAdCustomEvent;
	import com.google.ads.instream.api.FlashAdsManager;
	import com.google.ads.instream.api.VastVideoAd;
	import com.google.ads.instream.api.VastWrapper;
	import com.google.ads.instream.api.VideoAd;
	import com.google.ads.instream.api.VideoAdsManager;
	import com.google.ads.instream.api.FlashAsset;


	public class GoogleAds extends MovieClip {
		private var api:Object;
		//

		private var adsManager:AdsManager;
		private var adsLoader:AdsLoader;

		private var currentNetStream:NetStream;
		private var contentNetStream:NetStream;

		private var adShown:Boolean = false;

		private var tw:Number;
		private var th:Number;

		private var req_vars:Object = {};

		public function GoogleAds():void {
			
			root.loaderInfo.sharedEvents.addEventListener('api', apiHandler);

			var req:AdsRequest = new AdsRequest();
			var des:XML = describeType(AdsRequest);
			var vas:XMLList = des..variable;
			for each (var va:XML in vas) {
				var vn:String = va. @ name;
				req_vars[vn] = req[vn];
			}
			
			//default
			//video, text_overlay, text_or_graphical, text_full_slot, overlay, graphical_overlay, graphical_full_slot, graphical, full_slot
			req_vars.adType = "overlay";
			
		}
		
		private function apiHandler(e):void {
			//取得cmp的api对象和侦听key，包含2个属性{api,key}
			var apikey:Object = e.data;
			//如果没有取到则直接返回
			if (! apikey) {
				return;
			}
			api = apikey.api;
			api.addEventListener(apikey.key, "resize", resizeHandler);
			api.addEventListener(apikey.key, "model_state", stateHandler);
			//
			resizeHandler();
			stateHandler();
			
			log("publisherId:" + api.config["publisherId"]);
			
			
			startHandler();
		}
		
		private function resizeHandler(e:Event = null):void {
			
			tw = api.config.width;
			th = api.config.height;

			req_vars.adSlotWidth = tw;
			req_vars.adSlotHeight = th;
			
			if(adsManager) {
				adsManager.adSlotWidth = tw;
				adsManager.adSlotHeight = th;
			}
			
			log("size: " + tw + "x" + th);
		}

		
		private function startHandler():void {
			if (adShown) {
				return;
			}
			adShown = true;
			setTimeout(loadAd, 500);
		}
		private function stateHandler(e:Event = null):void {
			switch (api.config.state) {
				case "playing" :
					break;
				case "buffering" :
					break;
				case "paused" :
					break;
				case "completed" :
					break;
				default :
			}
		}
		
		
		private function showPlugin():void {
			visible = true;
		}
		private function hidePlugin():void {
			visible = false;
		}
		private function resumeVideo():void {
			log("resume");
			if (api.config.state == "paused") {
				api.sendEvent("view_play");
			}
		}
		private function pauseVideo():void {
			log("pause");
			if (api.config.state == "playing") {
				api.sendEvent("view_play");
			}
		}

		private function initAd():void {
			unloadAd();
			clearVideo();
		}

		private function loadAd():void {
			if (! adsLoader) {
				adsLoader = new AdsLoader();
				addChild(adsLoader);
				adsLoader.addEventListener(AdsLoadedEvent.ADS_LOADED, onAdsLoaded);
				adsLoader.addEventListener(AdErrorEvent.AD_ERROR, onAdError);
			}

			adsLoader.requestAds(createAdsRequest());

			log("Ad requested");
		}


		private function createAdsRequest():AdsRequest {
			var req:AdsRequest = new AdsRequest();
			for (var k:String in req_vars) {
				var v:Object = api.config[k];
				if (v) {
					try {
						req[k] = v;
					}catch(e:Error) {
					}
				} else {
					req[k] = req_vars[k];
				}
				log(k + "=" + req[k]);
			}

			return req;
		}

		private function displayAdsInformation(adsManager:Object):void {
			log("AdsManager type: " + adsManager.type);
			var ads:Array = adsManager.ads;
			if (ads) {
				log(ads.length + " ads loaded");
				for each (var ad:Ad in ads) {
					try {
						// APIs defined on Ad
						log("type: " + ad.type);
						log("id: " + ad.id);
						log("traffickingParameters: " + ad.traffickingParameters);
						log("surveyUrl: " + ad.surveyUrl);
						if (ad.type == AdTypes.VIDEO) {
							// APIs defined on all video ads
							var videoAd:VideoAd = ad as VideoAd;
							log("author: " + videoAd.author);
							log("title: " + videoAd.title);
							log("ISCI: " + videoAd.ISCI);
							log("deliveryType: " + videoAd.deliveryType);
							log("mediaUrl: " + videoAd.mediaUrl);
							if (ad.type == AdTypes.VAST) {
								// APIs only defined on VastVideoAd (derived class of VideoAd)
								var vastAd:VastVideoAd = ad as VastVideoAd;
								log("description: " + vastAd.description);
								log("adSystem: " + vastAd.adSystem);
								log("customClicks: " + vastAd.customClicks);
								if (vastAd.wrappers) {
									for each (var wrapper:VastWrapper in vastAd.wrappers) {
										log("wrapper found");
										log("wrapper adSystem: " + wrapper.adSystem);
										log("wrapper customClicks: " + wrapper.customClicks);
									}
								}
							} else {
								log("getCompanionAdUrl: " + ad.getCompanionAdUrl("flash"));
								// will throw error for VAST ads
							}
						} else if (ad.type == AdTypes.FLASH) {
							// API defined on FlashAd
							var flashAd:FlashAd = ad as FlashAd;
							log("asset: " + flashAd.asset);
						}
					} catch (error:Error) {
						log("Error type:" + error + " message:" + error.message);
					}
				}
			}
		}


		private function onAdsLoaded(adsLoadedEvent:AdsLoadedEvent):void {
			log("Ads Loaded");
			adsManager = adsLoadedEvent.adsManager;
			adsManager.addEventListener(AdErrorEvent.AD_ERROR, onAdError);
			adsManager.addEventListener(AdEvent.CONTENT_PAUSE_REQUESTED, onContentPauseRequested);
			adsManager.addEventListener(AdEvent.CONTENT_RESUME_REQUESTED, onContentResumeRequested);
			adsManager.addEventListener(AdLoadedEvent.LOADED, onAdLoaded);
			adsManager.addEventListener(AdEvent.STARTED, onAdStarted);
			adsManager.addEventListener(AdEvent.CLICK, onAdClicked);


			displayAdsInformation(adsManager);
			
			showPlugin();
			
			
			if (adsManager.type == AdsManagerTypes.FLASH) {
				
				var flashAdsManager:FlashAdsManager = adsManager as FlashAdsManager;
				flashAdsManager.addEventListener(AdSizeChangedEvent.SIZE_CHANGED, onFlashAdSizeChanged);
				flashAdsManager.addEventListener(FlashAdCustomEvent.CUSTOM_EVENT, onFlashAdCustomEvent);

				// For some reason calling video.localToGlobal(point) produced an;
				// incorrect location.
				flashAdsManager.x = 0;
				flashAdsManager.y = 0;

				log("Calling load, then play");
				flashAdsManager.load();
				flashAdsManager.play();
			} else if (adsManager.type == AdsManagerTypes.VIDEO) {
				
				log("ad is type 'video', do not show");
				
				
			} else if (adsManager.type == AdsManagerTypes.CUSTOM_CONTENT) {
				// Cannot call play() since it is custom content.
				// You can get the content string from the ad and further process it as
				// required.
				log(adsManager.type);
				
				//for each (var ad:CustomContentAd in adsManager.ads) {
					//log(ad.content);
				//}
			}
		}

		//video ad =======================================================================================================
		private function onVideoAdComplete(e:AdEvent):void {
			logEvent(e.type);
			removeListeners();
			// Remove clickTrackingElement before playing content or a different ad.
			if (adsManager.type == AdsManagerTypes.VIDEO) {
				(adsManager as VideoAdsManager).clickTrackingElement = null;
			}
		}
		private function onVideoAdStopped(e:AdEvent):void {
			logEvent(e.type);
		}

		private function onVideoAdPaused(e:AdEvent):void {
			logEvent(e.type);
		}

		private function onVideoAdMidpoint(e:AdEvent):void {
			logEvent(e.type);
		}

		private function onVideoAdFirstQuartile(e:AdEvent):void {
			logEvent(e.type);
		}

		private function onVideoAdThirdQuartile(e:AdEvent):void {
			logEvent(e.type);
		}

		private function onVideoAdClicked(e:AdEvent):void {
			logEvent(e.type);
		}

		private function onVideoAdRestarted(e:AdEvent):void {
			logEvent(e.type);
		}

		private function onVideoAdVolumeMuted(e:AdEvent):void {
			logEvent(e.type);
		}


		private function removeListeners():void {
			adsManager.removeEventListener(AdLoadedEvent.LOADED, onAdLoaded);
			adsManager.removeEventListener(AdEvent.STARTED, onAdStarted);

			if (adsManager.type == AdsManagerTypes.VIDEO) {
				var videoAdsManager:VideoAdsManager = adsManager as VideoAdsManager;
				videoAdsManager.removeEventListener(AdEvent.STOPPED, onVideoAdStopped);
				videoAdsManager.removeEventListener(AdEvent.PAUSED, onVideoAdPaused);
				videoAdsManager.removeEventListener(AdEvent.COMPLETE, onVideoAdComplete);
				videoAdsManager.removeEventListener(AdEvent.MIDPOINT, onVideoAdMidpoint);
				videoAdsManager.removeEventListener(AdEvent.FIRST_QUARTILE, onVideoAdFirstQuartile);
				videoAdsManager.removeEventListener(AdEvent.THIRD_QUARTILE, onVideoAdThirdQuartile);
				videoAdsManager.removeEventListener(AdEvent.RESTARTED, onVideoAdRestarted);
				videoAdsManager.removeEventListener(AdEvent.VOLUME_MUTED, onVideoAdVolumeMuted);
			} else if (adsManager.type == AdsManagerTypes.FLASH) {
				var flashAdsManager:FlashAdsManager = adsManager as FlashAdsManager;
				flashAdsManager.removeEventListener(AdSizeChangedEvent.SIZE_CHANGED, onFlashAdSizeChanged);
				flashAdsManager.removeEventListener(FlashAdCustomEvent.CUSTOM_EVENT, onFlashAdCustomEvent);
			}
		}



		private function unloadAd():void {
			try {
				if (adsManager) {
					removeListeners();
					removeAdsManagerListeners();
					adsManager.unload();
					adsManager = null;
					log("Ad unloaded");
				}
			} catch (e:Error) {
				log("Error occured during unload : " + e.message);
			}
		}

		private function clearVideo():void {
			if (currentNetStream) {
				currentNetStream.close();
			}
		}

		private function removeAdsManagerListeners():void {
			adsManager.removeEventListener(AdErrorEvent.AD_ERROR, onAdError);
			adsManager.removeEventListener(AdEvent.CONTENT_PAUSE_REQUESTED, onContentPauseRequested);
			adsManager.removeEventListener(AdEvent.CONTENT_RESUME_REQUESTED, onContentResumeRequested);
			adsManager.removeEventListener(AdEvent.CLICK, onAdClicked);
		}
		
		
		
		//ad events ========================================================================================
		

		private function onContentPauseRequested(e:AdEvent):void {
			logEvent(e.type);
			pauseVideo();
		}

		private function onContentResumeRequested(e:AdEvent):void {
			logEvent(e.type);
			resumeVideo();
		}

		private function onAdStarted(e:AdEvent):void {
			logEvent(e.type);
		}

		private function onAdClicked(e:AdEvent):void {
			logEvent(e.type);
		}

		private function onAdLoaded(e:AdLoadedEvent):void {
			logEvent(e.type);
			if (e.netStream) {
				currentNetStream = e.netStream;
			}
		}



		//flash ad =====================================================================================
		private function onFlashAdSizeChanged(e:AdSizeChangedEvent):void {
			logEvent(e.type);
			
			log("new size:" + e.width + "x" + e.height);
			
		}

		private function onFlashAdCustomEvent(e:FlashAdCustomEvent):void {
			logEvent(e.type);
		}


		private function onAdError(adErrorEvent:AdErrorEvent):void {
			log("Ad error: " + adErrorEvent.error.errorMessage);
		}



		private function logEvent(eventType:String):void {
			log(eventType + " event raised");
		}
		private function log(msg:Object):void {
			if(api) {
				api.tools.output(msg);
			}
		}

		private function openUrl(url:String):void {
			var request:URLRequest = new URLRequest(url);
			try {
				navigateToURL(request, "_self");
			} catch (e:Error) {
			}
		}
		private function clear(clip:DisplayObjectContainer):void {
			while (clip.numChildren) {
				clip.removeChildAt(0);
			}
		}


	}
}