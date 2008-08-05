package flare.util.matrix
{
	/**
	 * A matrix of numbers implemented using an array of values.
	 */
	public class DenseMatrix implements IMatrix
	{
		private var _r:int;
		private var _c:int;
		private var _v:Array;
		
		/** The underlying array of values */
		public function get values():Array { return _v; }
		/** @inheritDoc */
		public function get rows():int { return _r; }
		/** @inheritDoc */
		public function get cols():int { return _c; }
		/** @inheritDoc */
		public function get nnz():int {
			var nz:int = 0;
			for (var i:int=0; i<_v.length; ++i) {
				if (_v[i] != 0) ++nz;
			}
			return nz;
		}
		
		// --------------------------------------------------------------------
		
		/**
		 * Creates a new DenseMatrix with the given size. 
		 * @param rows the number of rows
		 * @param cols the number of columns
		 */
		public function DenseMatrix(rows:int, cols:int) {
			init(rows, cols);
		}
		
		/** @inheritDoc */
		public function clone():IMatrix {
			var m:DenseMatrix = new DenseMatrix(_r, _c);
			var v:Array = m.values;
			for (var i:int=0; i<_v.length; ++i) {
				v[i] = _v[i];
			}
			return m;
		}
		
		/** @inheritDoc */
		public function init(rows:int, cols:int):void {
			_r = rows;
			_c = cols;
			_v = new Array(_r * _c);
			for (var i:int=0; i<_v.length; ++i) _v[i]=0;
		}
		
		/** @inheritDoc */
		public function _(i:int, j:int):Number {
			return _v[i*_c + j];
		}
		
		/** @inheritDoc */
		public function $(i:int, j:int, v:Number):Number {
			_v[i*_c + j] = v;
			return v;
		}
		
		/** @inheritDoc */
		public function visitNonZero(f:Function):void {
			var k0:int, k:int;
			for (var i:int=0; i<_r; ++i) {
				k0 = i*_c;
				for (var j:int=0; j<_c; ++j) {
					k = k0 + j;
					if (_v[k] != 0) _v[k] = f(i, j, _v[k]);
				}
			}
		}
		
		/** @inheritDoc */
		public function visit(f:Function):void {
			var k0:int, k:int;
			for (var i:int=0; i<_r; ++i) {
				k0 = i*_c;
				for (var j:int=0; j<_c; ++j) {
					k = k0 + j;
					_v[k] = f(i, j, _v[k]);
				}
			}
		}

	} // end of class DenseMatrix
}