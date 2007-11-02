package flare.animate.interpolate
{
	import flash.geom.Rectangle;
	
	/**
	 * Interpolator for <code>flash.geom.Rectangle</code> values.
	 */
	public class RectangleInterpolator extends Interpolator
	{
		private var _startX:Number, _startY:Number;
		private var _startW:Number, _startH:Number;
		private var _rangeX:Number, _rangeY:Number;
		private var _rangeW:Number, _rangeH:Number;

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
			var r:Rectangle = value as Rectangle;
			_cur = _prop.getValue(_target) as Rectangle;
			if (_cur == null) _cur = r.clone();
			
			_startX = _cur.x;
			_startY = _cur.y;
			_startW = _cur.width;
			_startH = _cur.height;
			_rangeX = r.x - _startX;
			_rangeY = r.y - _startY;
			_rangeW = r.width - _startW;
			_rangeH = r.height - _startH;
		}
		
		/**
		 * Calculate and set an interpolated property value.
		 * @param f the interpolation fraction (typically between 0 and 1)
		 */
		public override function interpolate(f:Number) : void
		{
			_cur.x      = _startX + f * _rangeX;
			_cur.y      = _startY + f * _rangeY;
			_cur.width  = _startW + f * _rangeW;
			_cur.height = _startH + f * _rangeH;
			_prop.setValue(_target, _cur);
		}
		
	} // end of class RectangleInterpolator
}