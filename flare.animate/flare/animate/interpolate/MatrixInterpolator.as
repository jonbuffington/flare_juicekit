package flare.animate.interpolate
{
	import flash.geom.Matrix;
	
	/**
	 * Interpolator for <code>flash.geom.Matrix</code> values.
	 */
	public class MatrixInterpolator extends Interpolator
	{
		private var _start:Matrix;
		private var _end:Matrix;
		private var _cur:Matrix;
		
		/**
		 * Creates a new MatrixInterpolator.
		 * @param target the object whose property is being interpolated
		 * @param property the property to interpolate
		 * @param value the target matrix value to interpolate to
		 */
		public function MatrixInterpolator(target:Object, property:String, value:Object)
		{
			super(target, property, value);
		}
		
		/**
		 * Initializes this interpolator.
		 * @param value the target value of the interpolation
		 */
		protected override function init(value:Object) : void
		{
			_end = Matrix(value);
			if (_cur == null) _cur = new Matrix();
			
			_start = _prop.getValue(_target) as Matrix;
			if (_start == null)
				throw new Error("Current value is not a Matrix.");
		}
		
		/**
		 * Calculate and set an interpolated property value.
		 * @param f the interpolation fraction (typically between 0 and 1)
		 */
		public override function interpolate(f:Number) : void
		{
			_cur.a  = _start.a  + f * (_end.a  - _start.a);
			_cur.b  = _start.b  + f * (_end.b  - _start.b);
			_cur.c  = _start.c  + f * (_end.c  - _start.c);
			_cur.d  = _start.d  + f * (_end.d  - _start.d);
			_cur.tx = _start.tx + f * (_end.tx - _start.tx);
			_cur.ty = _start.ty + f * (_end.ty - _start.ty);
			_prop.setValue(_target, _cur);
		}
		
	} // end of class MatrixInterpolator
}