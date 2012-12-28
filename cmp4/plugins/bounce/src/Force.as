package src{
	public class Force {
		protected var _x:Number = 0;
		protected var _y:Number = 0;
		public function Force(tx:Number, ty:Number) {
			_x = tx;
			_y = ty;
		}
		public function get y():Number {
			return _y;
		}
		public function get x():Number {
			return _x;
		}
	}
}