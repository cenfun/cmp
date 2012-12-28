//cmp4 mouse wheel fix
(function(window, undefined) {
	var deltaDispatcher = function(event) {
		event = event || window.event;
		var target = event.target || event.srcElement;
		if (target && typeof (target.cmp_version) == "function") {
			var maxPos = target.skin("list.tree", "maxVerticalScrollPosition");
			if (maxPos > 0) {
				target.focus();
				if (event.preventDefault) {
					event.preventDefault();
				}
				return false;
			}
		}
	};
	if (window.addEventListener) {
		window.addEventListener("DOMMouseScroll", deltaDispatcher, false);
	}
	window.onmousewheel = document.onmousewheel = deltaDispatcher;
})(window);