package flare.animate.interpolate
{
	import flash.geom.Point;
	
	/**
	 * Interpolator for <code>flash.geom.Point</code> values.
	 */
	public class PointInterpolator extends Interpolator
	{
		private var _startX:Number, _startY:Number;
		private var _rangeX:Number, _rangeY:Number;
		private var _cur:Point;
		
		/**
		 * Creates a new PointInterpolator.
		 * @param target the object whose property is being interpolated
		 * @param property the property to interpolate
		 * @param value the target point value to interpolate to
		 */
		public function PointInterpolator(target:Object, property:String, value:Object)
		{
			super(target, property, value);
		}
		
		/**
		 * Initializes this interpolator.
		 * @param value the target value of the interpolation
		 */
		protected override function init(value:Object) : void
		{
			var p:Point = Point(value);
			_cur = _prop.getValue(_target) as Point;
			if (_cur == null) _cur = p.clone();

			_startX = _cur.x;
			_startY = _cur.y;
			_rangeX = p.x - _startX;
			_rangeY = p.y - _startY;
		}
		
		/**
		 * Calculate and set an interpolated property value.
		 * @param f the interpolation fraction (typically between 0 and 1)
		 */
		public override function interpolate(f:Number) : void
		{
			_cur.x = _startX + f*_rangeX;
			_cur.y = _startY + f*_rangeY;
			_prop.setValue(_target, _cur);
		}
		
	} // end of class PointInterpolator
}