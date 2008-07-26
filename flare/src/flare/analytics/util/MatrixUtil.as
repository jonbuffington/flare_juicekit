package flare.analytics.util
{
	import flare.vis.data.Data;
	import flare.vis.data.DataList;
	import flare.vis.data.EdgeSprite;
	
	import flash.utils.Dictionary;
	
	/**
	 * Utility methods for working with matrices. 
	 */
	public class MatrixUtil
	{
		public function MatrixUtil() {
			throw new Error("This is an abstract class.");
		}

		/**
		 * Creates a new adjacency matrix representing the input data set,
		 * using an optional input function to determine edge weights.
		 * @param data the flare data set
		 * @param w the edge weight function. This function should take an
		 *  EdgeSprite as input and return a Number.
		 * @return the adjacency matrix as a DenseMatrix
		 */
		public static function adjacencyMatrix(data:Data, w:Function=null):DenseMatrix
		{
			var N:int = data.nodes.length, i:int=0, j:int=0, k:int = 0;
			
			var idx:Dictionary = new Dictionary();
			for (k=0; k<N; ++k) idx[data.nodes[k]] = k;
			
			var m:DenseMatrix = new DenseMatrix(N, N);
			for each (var e:EdgeSprite in data.edges) {
				i = idx[e.source]; j = idx[e.target];
				var v:Number = w==null ? 1 : w(e);
				m.$(i,j,v); m.$(j,i,v);
			}
			return m;
		}
		
		/**
		 * Creates a new distance or similarity matrix based on the provided
		 * distance function
		 * @param list a data list (for example, <code>data.nodes</code>)
		 * @param d the distance function. This should take two
		 *  <code>DataSprite</code> instances and return a <code>Number</code>
		 * @return the distance matrix as a DenseMatrix
		 */
		public static function distanceMatrix(list:DataList, d:Function):DenseMatrix
		{
			var N:int = list.length, i:uint, j:uint;
			
			var m:DenseMatrix = new DenseMatrix(N, N);
			for (i=0; i<N; ++i) {
				for (j=i+1; j<N; ++j) {
					var v:Number = d(list[i], list[j]);
					m.$(i,j,v); m.$(j,i,v);
				}
			}
			return m;
		}

	} // end of class MatrixUtil
}