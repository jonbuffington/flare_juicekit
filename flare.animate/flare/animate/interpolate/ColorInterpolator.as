package flare.animate.interpolate
{
	import flare.util.Colors;
	
	/**
	 * Interpolator for color (<code>uint</code>) values.
	 */ 
	public class ColorInterpolator extends Interpolator
	{
		private var _start:uint;
		private var _end:uint;
		
		/**
		 * Creates a new ColorInterpolator.
		 * @param target the object whose property is being interpolated
		 * @param property the property to interpolate
		 * @param value the color value to interpolate to
		 */
		public function ColorInterpolator(target:Object, property:String, value:Object)
		{
			super(target, property, value);
		}
		
		/**
		 * Initializes this interpolator.
		 * @param value the target value of the interpolation
		 */
		protected override function init(value:Object) : void
		{
			_end = uint(value);
			_start = uint(_prop.getValue(_target));
		}
		
		/**
		 * Calculate and set an interpolated property value.
		 * @param f the interpolation fraction (typically between 0 and 1)
		 */
		public override function interpolate(f:Number) : void
		{
			_prop.setValue(_target, Colors.interpolate(_start, _end, f));
		}
		
	} // end of class ColorInterpolator
}