package flare.analytics.cluster
{
	import flare.analytics.util.IMatrix;
	import flare.analytics.util.MatrixUtil;
	import flare.animate.Transitioner;
	import flare.util.Arrays;
	import flare.util.Property;
	import flare.util.Sort;
	import flare.vis.data.Data;
	import flare.vis.data.EdgeSprite;
	import flare.vis.data.NodeSprite;
	import flare.vis.data.Tree;
	import flare.vis.operator.Operator;
	
	/**
	 * Hierarchically clusters a network based on inferred community structure.
	 * The result is a cluster tree in which each merge is chosen so as to
	 * maximize within-cluster linkage while minimizing between-cluster linkage.
	 * This class uses <a href="http://arxiv.org/abs/cond-mat/0309508">Newman's
	 * fast algorithm for detecting community structure</a>. Optionally allows
	 * clients to provide an edge weight function indicating the strength of
	 * ties within the network.
	 */
	public class CommunityStructure extends HierarchicalCluster
	{
		/** A function defining edge weights in the graph. */
		public var edgeWeights:Function = null;
		
		// --------------------------------------------------------------------
		
		/**
		 * Creates a new community structure instance
		 */
		public function CommunityStructure()
		{
		}
		
		/** @inheritDoc */
		public override function operate(t:Transitioner=null):void
		{
			calculate(visualization.data, edgeWeights);
		}
		
		/**
		 * Calculates the community structure clustering. As a result of this
		 * method, a cluster tree will be computed and graph nodes will be
		 * annotated with both community and sequence indices.
		 * @param data the graph to cluster
		 * @param w an edge weighting function. If null, each edge will be
		 *  given weight one.
		 */
		public function calculate(data:Data, w:Function=null):void
		{
			compute(MatrixUtil.adjacencyMatrix(data, w));
			_tree = buildTree(data);
			labelNodes();
		}
		
		/** Computes the clustering */
		private function compute(G:IMatrix):void
		{
			_merges = new MergeEdge(-1, -1); _qvals = [];
			_size = G.rows;
			var i:int, j:int, k:int, s:int, t:int, v:Number, sum:Number=0;
			var Q:Number=0, Qmax:Number=0, dQ:Number, dQmax:Number=0, imax:int;
			
			// initialize normalized matrix
			var N:int = G.rows, Z:IMatrix = G.clone();// z:Array = Z.values;
			for (i=0; i<N; ++i) Z.$(i,i,0);
			Z.visitNonZero(function(i:int, j:int, v:Number):Number {
				sum += v; return v;
			});
			Z.visitNonZero(function(i:int, j:int, v:Number):Number {
				return v / sum;
			});
			
			// initialize column sums and edge list
			var E:MergeEdge = new MergeEdge(-1,-1);
			var e:MergeEdge = E, m:MergeEdge = _merges;
			var eMax:MergeEdge = new MergeEdge(0,0);
			var A:Array = new Array(N);
			
			for (i=0; i<N; ++i) {
				A[i] = 0;
				for (j=0; j<N; ++j) {
					if ((v=Z._(i,j)) != 0) {
						A[i] += v;
						e = e.add(new MergeEdge(i,j));
					}
				}
			}
			
			// run the clustering algorithm
			for (var ii:int=0; ii<N-1 && E.next; ++ii) {
				dQmax = Number.NEGATIVE_INFINITY;
				eMax.update(0,0);
				
				// find the edge to merge
				for (e=E.next; e!=null; e=e.next) {
					i = e.i; j = e.j;
					if (i==j) continue;
					dQ = Z._(i,j) + Z._(j,i) - 2*A[i]*A[j];
					if (dQ > dQmax) {
						dQmax = dQ; eMax.update(i,j);
					}
				}
				
				// perform merge on graph
				i = eMax.i; j = eMax.j; if (j<i) { i=eMax.j; j=eMax.i; }
				var na:Number = 0;
				for (k=0; k<N; ++k) {
					v = Z._(i,k) + Z._(j,k);
					if (v != 0) {
						na += v; Z.$(i,k,v); Z.$(j,k,0);
					}
				}
				for (k=0; k<N; ++k) {
					v = Z._(k,i) + Z._(k,j);
					if (v != 0) {
						Z.$(k,i,v); Z.$(k,j,0);
					}
				}
				A[i] = na;
				A[j] = 0;
				for (e=E.next; e!=null; e=e.next) {
					s = e.i; t = e.j;
					if ((i==s && j==t) || (i==t && j==s)) {
						e.remove();
					} else if (s==j) {
						e.i = i;
					} else if (t==j) {
						e.j = i;
					}
				}
				
				Q += dQmax;
				if (Q > Qmax) {
					Qmax = Q;
					imax = ii;
				}
				_qvals.push(Q);
				m = m.add(new MergeEdge(i,j));
			}
		}
		
	} // end of class CommunityStructure
}