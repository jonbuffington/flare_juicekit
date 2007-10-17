package flare.animate.interpolate
{
	/**
	 * Interpolator for <code>Number</code> and <code>int</code> values.
	 */
	public class NumberInterpolator extends Interpolator
	{
		private var _start:Number;
		private var _end:Number;
		
		/**
		 * Creates a new NumberInterpolator.
		 * @param target the object whose property is being interpolated
		 * @param property the property to interpolate
		 * @param value the target number to interpolate to
		 */
		public function NumberInterpolator(target:Object, property:String, value:Object)
		{
			super(target, property, value);
		}
		
		/**
		 * Initializes this interpolator.
		 * @param value the target value of the interpolation
		 */
		protected override function init(value:Object) : void
		{
			_end = Number(value);
			_start = _prop.getValue(_target);
			if (isNaN(_start)) _start = _end;
			_end = _end - _start;
		}
		
		/**
		 * Calculate and set an interpolated property value.
		 * @param f the interpolation fraction (typically between 0 and 1)
		 */
		public override function interpolate(f:Number) : void
		{
			_prop.setValue(_target, _start + f*_end);
		}
		
	} // end of class NumberInterpolator
}