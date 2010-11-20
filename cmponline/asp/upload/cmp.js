if(typeof window.CMP==="undefined") {
	var CMP=window.CMP=new (function(){
		var msie=/msie/.test(navigator.userAgent.toLowerCase());
		this.write=function(id, width, height, url, vars, params, attrs){
			document.write(this.create(id, width, height, url, vars, params, attrs));
		};
		this.get=function(id) {
			var o = document.getElementById(id);
			if (!o || o.nodeName.toLowerCase() != "object") {
				o = msie ? window[id] : document[id];
			}
			return o;
		};
		this.create=function(id, width, height, url, vars, params, attrs){
			var _attrs = {
				width : width,
				height : height,
				id : id
			};
			appendObj(_attrs, attrs);
			var _params = { allowfullscreen : "true", allowscriptaccess : "always" };
			appendObj(_params, params);
			var _vars = "";
			if (vars && typeof vars === "string") {
				_vars = vars;
			} else if (vars && typeof vars === "object") {
				var arr = [];
				for (var v in vars) {
					arr.push(v + "=" + encodeURIComponent(vars[v]));
				}
				_vars = arr.join("&");
			}
			if (_vars) {
				_params.flashvars = _vars;
			}
			var htm = '<object ';
			htm += msie? 'classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" ' : 'type="application/x-shockwave-flash" data="'+url+'" ';
			for (var a in _attrs) {
				htm += a + '="'+_attrs[a]+'" ';
			}
			htm += msie? '><param name="movie" value="'+url+'" />' : '>';
			for (var p in _params) {
				htm += '<param name="'+p+'" value="'+_params[p]+'" />';
			}
			htm += '</object>';
			return htm;
		};
		function appendObj(_obj, obj) {
			if (obj && typeof obj === "object") {
				for (var k in obj) {
					_obj[k] = obj[k];	
				}
			}
			return _obj;
		}
	})();
}

