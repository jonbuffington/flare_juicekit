package flare.animate.interpolate
{
	import flare.util.Arrays;
	
	/**
	 * Interpolator for numeric <code>Array</code> values. Each value
	 * contained in the array should be a numeric (<code>Number</code> or
	 * <code>int</code>) value.
	 */
	public class ArrayInterpolator extends Interpolator
	{
		private var _start:Array;
		private var _end:Array;
		private var _cur:Array;
		
		/**
		 * Creates a new ArrayInterpolator.
		 * @param target the object whose property is being interpolated
		 * @param property the property to interpolate
		 * @param value the target array to interpolate to. This should be an
		 *  array of numerical values.
		 */
		public function ArrayInterpolator(target:Object, property:String, value:Object)
		{
			super(target, property, value);
		}
		
		/**
		 * Initializes this interpolator.
		 * @param value the target value of the interpolation
		 */
		protected override function init(value:Object) : void
		{
			_end = value as Array;
			if (_cur == null || _cur.length != _end.length)
				_cur = new Array(_end.length);
			
			_start = _prop.getValue(_target) as Array;
			if (_start == null)
				throw new Error("Current value is not an array.");
			if (_start.length < _end.length)
				throw new Error("Array dimensions don't match");
		}
		
		/**
		 * Calculate and set an interpolated property value.
		 * @param f the interpolation fraction (typically between 0 and 1)
		 */
		public override function interpolate(f:Number) : void
		{
			for (var i:uint=0; i<_cur.length; ++i) {
				_cur[i] = _start[i] + f*(_end[i] - _start[i]);
			}
			_prop.setValue(_target, _cur);
		}
		
	} // end of class ArrayInterpolator
}