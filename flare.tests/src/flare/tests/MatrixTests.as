package flare.tests
{
	import flare.util.matrix.DenseMatrix;
	import flare.util.matrix.IMatrix;
	import flare.util.matrix.SparseMatrix;
	
	import unitest.TestCase;

	public class MatrixTests extends TestCase
	{
		public function MatrixTests()
		{
			addTest("testDenseMatrix");
			addTest("testSparseMatrix");
		}
		
		private static function testMatrix(mat:IMatrix):void
		{
			var i:int, j:int, c:int = 7;
			
			// populate matrix
			for (i=0; i<mat.cols; ++i) mat.$(1,i,c);
			for (i=0; i<mat.rows; ++i) mat.$(i,1,c);
			for (i=0; i<mat.rows; ++i) mat.$(i,i,i+1);
			
			assertEquals(5, mat.rows);
			assertEquals(5, mat.cols);
			assertEquals(13, mat.nnz);
			
			// test matrix access
			var test:Function = function(i:int, j:int, v:Number):Number {
				if (i==j)              assertEquals(i+1, v);
				else if (i==1 || j==1) assertEquals(c, v);
				else                   assertEquals(0, v);
				return v;
			};
			var nonZero:Function = function(i:int, j:int, v:Number):Number {
				assertNotEquals(0, v);
				return v;
			};
			
			for (i=0; i<mat.rows; ++i) {
				for (j=0; j<mat.cols; ++j) test(i, j, mat._(i,j));
			}
			mat.visit(test);
			mat.visitNonZero(test);
			mat.visitNonZero(nonZero);
			
			for (i=0; i<mat.rows; ++i) {
				mat.$(i,i,0);
			}
			assertEquals(8, mat.nnz);
			mat.visitNonZero(nonZero);
		}
		
		public function testDenseMatrix():void
		{
			testMatrix(new DenseMatrix(5,5));
		}
		
		public function testSparseMatrix():void
		{
			testMatrix(new SparseMatrix(5,5));
		}
		
	} // end of class MatrixTests
}