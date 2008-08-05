package flare.util.matrix
{
	/**
	 * Interface for a matrix of real-valued numbers.
	 */
	public interface IMatrix
	{
		/** The number of rows. */
		function get rows():int;
		/** The number of columns. */
		function get cols():int;
		/** The number of non-zero values. */
		function get nnz():int;
		
		/** Creates a copy of this matrix. */
		function clone():IMatrix;
		
		/** Initializes the matrix to desired dimensions. This method also
		 *  resets all values in the matrix to zero. */
		function init(rows:int, cols:int):void;
		
		/**
		 * Returns the value at the given indices. 
		 * @param i the row index
		 * @param j the column index
		 * @return the value at position i,j
		 */
		function _(i:int, j:int):Number;
		
		/**
		 * Sets the value at the given indices. 
		 * @param i the row index
		 * @param j the column index
		 * @param v the value to set
		 * @return the input value v
		 */
		function $(i:int, j:int, v:Number):Number;
		
		/**
		 * Visit all non-zero values in the matrix.
		 * The input function is expected to take three arguments--the row
		 * index, the column index, and the cell value--and return a number
		 * which then becomes the new value for the cell.
		 * @param f the function to invoke for each non-zero value
		 */
		function visitNonZero(f:Function):void;
		
		/**
		 * Visit all values in the matrix.
		 * The input function is expected to take three arguments--the row
		 * index, the column index, and the cell value--and return a number
		 * which then becomes the new value for the cell.
		 * @param f the function to invoke for each value
		 */
		function visit(f:Function):void;
		
	} // end of interface IMatrix
}