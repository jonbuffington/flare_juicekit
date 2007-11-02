package flare.animate.interpolate
{
	import flash.geom.Matrix;
	
	/**
	 * Interpolator for <code>flash.geom.Matrix</code> values.
	 */
	public class MatrixInterpolator extends Interpolator
	{
		private var _startA:Number, _startB:Number, _startC:Number;
		private var _startD:Number, _startX:Number, _startY:Number;
		private var _rangeA:Number, _rangeB:Number, _rangeC:Number;
		private var _rangeD:Number, _rangeX:Number, _rangeY:Number;
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
			var m:Matrix = Matrix(value);
			_cur = _prop.getValue(_target) as Matrix;
			if (_cur == null) _cur = m.clone();
			
			_startA = _cur.a;
			_startB = _cur.b;
			_startC = _cur.c;
			_startD = _cur.d;
			_startX = _cur.tx;
			_startY = _cur.ty;
			_rangeA = m.a  - _startA;
			_rangeB = m.b  - _startB;
			_rangeC = m.c  - _startC;
			_rangeD = m.d  - _startD;
			_rangeX = m.tx - _startX;
			_rangeY = m.ty - _startY;
		}
		
		/**
		 * Calculate and set an interpolated property value.
		 * @param f the interpolation fraction (typically between 0 and 1)
		 */
		public override function interpolate(f:Number) : void
		{
			_cur.a  = _startA + f * _rangeA;
			_cur.b  = _startB + f * _rangeB;
			_cur.c  = _startC + f * _rangeC;
			_cur.d  = _startD + f * _rangeD;
			_cur.tx = _startX + f * _rangeX;
			_cur.ty = _startY + f * _rangeY;
			_prop.setValue(_target, _cur);
		}
		
	} // end of class MatrixInterpolator
}