package src{
	public class FreeBody extends Force {
		//弹力系数
		private var bounce:Number = 0.8;
		private var continuousForce:Force;

		public function FreeBody(fc:Force = null) {
			continuousForce = (fc == null) ? new Force(0, 0) : fc;
			super(fc.x, fc.y);
		}
		public function update():void {
			addForce(continuousForce);
		}
		public function addForce(fc:Force):void {
			_x += fc.x;
			_y += fc.y;
		}
		public function addNormal(num:Number):void {
			var _cos:Number = Math.cos(num);
			var _sin:Number = Math.sin(num);
			var _c:Number = _cos * _x + _sin * _y;
			var _d:Number = _cos * _y - _sin * _x;
			_c = Math.abs(_c) * bounce;
			_x = _cos * _c - _sin * _d;
			_y = _cos * _d + _sin * _c;
		}
	}
}