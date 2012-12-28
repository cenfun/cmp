(function(window, undefined) {
	window.CMP = window.CMP || {};
	CMP.cookie = new (function() {
		this.path = "";
		this.domain = "";
		this.secure = "";
		this.get = function(name) {
			var str = document.cookie;
			var cookieName = name + "=";
			var valueBegin = str.indexOf(cookieName);
			if (valueBegin == -1) {
				return "";
			}
			var valueEnd = str.indexOf(";", valueBegin);
			if (valueEnd == -1) {
				valueEnd = str.length;
			}
			var value = str.substring(valueBegin + cookieName.length, valueEnd);
			if (value) {
				value = decodeURIComponent(value);
			}
			return value;
		};
		this.set = function(name, value, seconds) {
			var key = name + "=" + encodeURIComponent(value);
			var expires = '';
			if (seconds) {
				var date = new Date();
				date.setTime(date.getTime() + seconds * 1000);
				expires = "; expires=" + date.toGMTString();
			}
			var path = this.path ? '; path=' + this.path : '';
			var domain = this.domain ? '; domain=' + this.domain : '';
			var secure = this.secure ? '; secure=' + this.secure : '';
			document.cookie = [key, expires, path, domain, secure].join('');
		};
		this.del = function(name) {
			this.set(name, "", -1);
		};
	})();
})(window);
