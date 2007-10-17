package flare.animate.interpolate
{
	import flash.geom.Rectangle;
	
	/**
	 * Interpolator for <code>flash.geom.Rectangle</code> values.
	 */
	public class RectangleInterpolator extends Interpolator
	{
		private var _start:Rectangle;
		private var _end:Rectangle;
		private var _cur:Rectangle;
		
		/**
		 * Creates a new RectangleInterpolator.
		 * @param target the object whose property is being interpolated
		 * @param property the property to interpolate
		 * @param value the target rectangle value to interpolate to
		 */
		public function RectangleInterpolator(target:Object, property:String, value:Object)
		{
			super(target, property, value);
		}
		
		/**
		 * Initializes this interpolator.
		 * @param value the target value of the interpolation
		 */
		protected override function init(value:Object) : void
		{
			_end = Rectangle(value);
			if (_cur == null) _cur = new Rectangle();
			
			_start = _prop.getValue(_target) as Rectangle;
			if (_start == null)
				throw new Error("Current value is not a Rectangle.");
		}
		
		/**
		 * Calculate and set an interpolated property value.
		 * @param f the interpolation fraction (typically between 0 and 1)
		 */
		public override function interpolate(f:Number) : void
		{
			_cur.x      = _start.x      + f * (_end.x - _start.x);
			_cur.y      = _start.y      + f * (_end.y - _start.y);
			_cur.width  = _start.width  + f * (_end.width - _start.width);
			_cur.height = _start.height + f * (_end.height - _start.height);
			_prop.setValue(_target, _cur);
		}
		
	} // end of class RectangleInterpolator
}