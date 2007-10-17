package flare.animate.interpolate
{
	import flash.geom.Point;
	
	/**
	 * Interpolator for <code>flash.geom.Point</code> values.
	 */
	public class PointInterpolator extends Interpolator
	{
		private var _startX:Number;
		private var _startY:Number;
		private var _endX:Number;
		private var _endY:Number;
		private var _end:Point;
		
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
			_end = Point(value);
			
			var p:Point = _prop.getValue(_target);
			_startX = p.x;
			_startY = p.y;
			_endX = _end.x - _startX;
			_endY = _end.y - _startY;
		}
		
		/**
		 * Calculate and set an interpolated property value.
		 * @param f the interpolation fraction (typically between 0 and 1)
		 */
		public override function interpolate(f:Number) : void
		{
			_end.x = _startX + f*_endX;
			_end.y = _startY + f*_endY;
			_prop.setValue(_target, _end);
		}
		
	} // end of class PointInterpolator
}