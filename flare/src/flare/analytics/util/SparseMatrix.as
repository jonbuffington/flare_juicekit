package flare.analytics.util
{
	import flash.utils.Dictionary;
	
	/**
	 * A matrix of numbers implemented using a hashtable of values.
	 */
	public class SparseMatrix implements IMatrix
	{
		private var _r:int;
		private var _c:int;
		private var _nnz:int;
		private var _v:Dictionary;
		
		/** @inheritDoc */
		public function get rows():int { return _r; }
		/** @inheritDoc */
		public function get cols():int { return _c; }
		/** @inheritDoc */
		public function get nnz():int {
			var count:int = 0;
			for (var name:String in _v)
				++count;
			return count;
		}
		
		// --------------------------------------------------------------------
		
		/**
		 * Creates a new SparseMatrix with the given size. 
		 * @param rows the number of rows
		 * @param cols the number of columns
		 */
		public function SparseMatrix(rows:int, cols:int) {
			_r = rows;
			_c = cols;
			_nnz = 0;
			_v = new Dictionary();
		}
		
		/** @inheritDoc */
		public function clone():IMatrix {
			var m:SparseMatrix = new SparseMatrix(_r, _c);
			for each (var key:Object in _v) {
				m._v[key] = _v[key];
			}
			return m;
		}
		
		/** @inheritDoc */
		public function _(i:int, j:int):Number {
			var v:* = _v[i*_c + j];
			return (v ? Number(v) : 0);
		}
		
		/** @inheritDoc */
		public function $(i:int, j:int, v:Number):Number {
			var key:int = i*_c + j;
			if (v==0) {
				delete _v[key];
			} else {
				_v[key] = v;
			}
			return v;
		}
		
		/** @inheritDoc */
		public function visitNonZero(f:Function):void {
			var i:int, j:int, k:int, v:Number;
			for (var key:String in _v) {
				k = int(key);
				i = k / _c;
				j = k % _c;
				v = _v[k];
				v = f(i,j,v);
				if (v==0) {
					delete _v[k];
				} else {
					_v[k] = v;
				}
			}
		}
		
		/** @inheritDoc */
		public function visit(f:Function):void {
			var k0:int, k:int, u:*, v:Number;
			for (var i:int=0; i<_r; ++i) {
				k0 = i*_c;
				for (var j:int=0; j<_c; ++j) {
					k = k0 + j;
					u = _v[k];
					v = u ? Number(u) : 0;
					v = f(i,j,v);
					if (v==0) {
						delete _v[k];
					} else {
						_v[k] = v;
					}
				}
			}
		}

	} // end of class SparseMatrix
}