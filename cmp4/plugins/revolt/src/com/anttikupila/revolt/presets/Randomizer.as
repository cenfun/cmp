package com.anttikupila.revolt.presets {
	public class Randomizer {
		private var original:Array;
		private var todo:Array;
		private var done:Array;
		public function Randomizer(len:Number):void {
			original = new Array();
			todo = new Array();
			done = new Array();
			for (var i:Number = 0; i < len; i++) {
				original.push(i);
			}
		}
		public function pick():Number {
			if (todo.length == 0) {
				for (var k:Number = 0; k < original.length; k++) {
					todo.push(k);
				}
			}
			var ran:Number = Math.floor(Math.random() * todo.length);
			var idx:Number = todo[ran];
			done.push(todo.splice(ran,1)[0]);
			return idx;
		}
		public function get length():Number {
			return todo.length;
		}
		public function back():Number {
			if (done.length < 2) {
				return pick();
			} else {
				todo.push(done.pop());
				return done[done.length - 1];
			}
		}

	}
}