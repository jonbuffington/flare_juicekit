package flare.animate.interpolate
{
	/**
	 * Interpolator for arbitrary <code>Object</code> values. Simply swaps the
	 * initial value for the end value for interpolation fractions greater
	 * than or equal to 0.5.
	 */
	public class ObjectInterpolator extends Interpolator
	{
		private var _start:Object;
		private var _end:Object;
		
		/**
		 * Creates a new ObjectInterpolator.
		 * @param target the object whose property is being interpolated
		 * @param property the property to interpolate
		 * @param value the target object value to interpolate to
		 */
		public function ObjectInterpolator(target:Object, property:String, value:Object)
		{
			super(target, property, value);
		}
		
		/**
		 * Initializes this interpolator.
		 * @param value the target value of the interpolation
		 */
		protected override function init(value:Object) : void
		{
			_end = value;
			_start = _prop.getValue(_target);
		}
		
		/**
		 * Calculate and set an interpolated property value. This method sets
		 * the target object's property to the starting value if the
		 * interpolation fraction is less than 0.5 and to the ending value if
		 * the fraction is greather than or equal to 0.5.
		 * @param f the interpolation fraction (typically between 0 and 1)
		 */
		public override function interpolate(f:Number) : void
		{
			_prop.setValue(_target, f < 0.5 ? _start : _end);
		}
		
	} // end of class ObjectInterpolator
}