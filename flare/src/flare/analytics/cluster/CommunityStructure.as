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
	 * Clusters a network based on inferred community structure. The result
	 * is a cluster tree in which each merge is chosen so as to maximize
	 * within-cluster linkage while minimizing between-cluster linkage. This
	 * class uses <a href="http://arxiv.org/abs/cond-mat/0309508">Newman's
	 * fast algorithm for detecting community structure</a>.
	 */
	public class CommunityStructure extends Operator
	{
		private var _idx:Property = Property.$("props.sequence");
		private var _com:Property = Property.$("props.community");
		
		private var _qvals:Array;
		private var _merges:Edge;
		private var _size:int;
		private var _tree:Tree;
		
		/** A function defining edge weights in the graph. */
		public var edgeWeights:Function = null;
		
		/** The property in which to store community indices. This property
		 *  is used to annotate nodes with the community they belong to
		 *  (indicated as an integer index). The default value
		 *  is "props.community". */
		public function get communityField():String { return _com.name; }
		public function set communityField(f:String):void { _com = Property.$(f); }
		
		/** The property in which to store sequence indices. This property
		 *  is used to annotate nodes with their sequence index along the
		 *  computed cluster tree. This value can be used to sort the nodes
		 *  in a way that best preserves community structure. The default value
		 *  is "props.sequence". */
		public function get sequenceField():String { return _idx.name; }
		public function set sequenceField(f:String):void { _idx = Property.$(f); }
		
		/** Computed criterion values for each merge in the cluster tree. */
		public function get criteria():Array { return _qvals; }
		
		/** The cluster tree of detected community structures. The leaf nodes
		 *  correspond to each of the nodes in the input graph, and include the
		 *  same <code>data</code> property. Non-leaf nodes indicate merges
		 *  made by the clustering algorithm, and have <code>data</code>
		 *  properties that include the <code>merge</code> number (1 for the
		 *  first merger, 2 for the second, etc), the <code>criterion</code>
		 *  value computed for that merge, and the <code>size</code> of the
		 *  cluster rooted at that node (the number of descendants in the
		 *  cluster tree).
		 */
		public function get clusterTree():Tree { return _tree; }
		
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
		
		/**
		 * Labels nodes with their cluster membership, determined by
		 * the given merge number. If the merge number is less than
		 * zero or unprovided, the merge number that maximizes the
		 * clustering criteria will be assumed.
		 * @param merge the merge number at which to compute the clusters
		 */
		public function labelNodes(merge:int=-1):void
		{
			if (merge < 0) merge = Arrays.maxIndex(_qvals);
			var com:int, idx:int;
			var helper:Function = function(n:NodeSprite):void
			{
				var nn:NodeSprite;
				if (n.childDegree && n.data.merge > merge)
				{
					for (var i:int=0; i<n.childDegree; ++i)
						helper(n.getChildNode(i));
				}
				else if (n.childDegree)
				{
					n.visitTreeDepthFirst(function(c:NodeSprite):void {
						if (c.childDegree==0) {
							nn = c.props.node;
							_com.setValue(nn, com);
							_idx.setValue(nn, idx++);
						}
					});
					com++;
				}
				else
				{
					nn = n.props.node;
					_com.setValue(nn, com++);
					_idx.setValue(nn, idx++);
				}
			}
			helper(_tree.root);
		}
		
		/** Computes the clustering */
		private function compute(G:IMatrix):void
		{
			_merges = new Edge(-1, -1); _qvals = [];
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
			var E:Edge = new Edge(-1,-1), e:Edge = E, m:Edge = _merges;
			var eMax:Edge=new Edge(0,0);
			var A:Array = new Array(N);
			
			for (i=0; i<N; ++i) {
				A[i] = 0;
				for (j=0; j<N; ++j) {
					if ((v=Z._(i,j)) != 0) {
						A[i] += v;
						e = e.add(new Edge(i,j));
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
				m = m.add(new Edge(i,j));
			}
		}
		
		// ------------------------------------------------------------
		
		/** Constructs the cluster tree from the cluster results */
		private function buildTree(data:Data):Tree
		{
			var tree:Tree = new Tree();
			
			var e:Edge, i:int, j:int, ii:int, map:Object = {};
			var l:NodeSprite, r:NodeSprite, p:NodeSprite;
			
			// populate the leaf notes
			for (i=0; i<_size; ++i) {
				map[i] = (p = new NodeSprite());
				p.data = data.nodes[i].data;
				p.props.node = data.nodes[i];
				p.props.size = 0;
			}
			
			// build up the tree
			for (ii=0, e=_merges.next; e!=null; ++ii, e=e.next) {
				i = e.i;
				j = e.j;
				l = map[i];
				r = map[j];
				map[i] = (p = new NodeSprite());
				if (l.props.size >= r.props.size) {
					p.addChildEdge(new EdgeSprite(p, l));
					p.addChildEdge(new EdgeSprite(p, r));
				} else {
					p.addChildEdge(new EdgeSprite(p, r));
					p.addChildEdge(new EdgeSprite(p, l));
				}
				p.data.merge = ii;
				p.data.criterion = _qvals[ii];
				p.props.size = 2 + l.props.size + r.props.size;
				delete map[j];
			}
			
			// build and sort array of cluster roots
			var roots:Array = [];
			for each (var n:NodeSprite in map) roots.push(n);
			new Sort(["props.size", false]).sort(roots);
			
			// merge cluster roots into final tree, if needed
			if (roots.length == 1) {
				p = NodeSprite(roots[0]);
			} else {
				p = new NodeSprite();
				p.data.merge = ii;
				for each (n in roots) {
					p.addChildEdge(new EdgeSprite(p, n));
				}
			}
			tree.root = p;
			return tree;
		}
	} // end of class CommunityStructure
}

/**
 * Auxiliary class that represents an edge in a graph
 */
class Edge {
	public var i:int;
	public var j:int;
	public var next:Edge = null;
	public var prev:Edge = null;
	
	public function Edge(i:int, j:int) {
		this.i = i;
		this.j = j;
	}
	public function update(i:int, j:int):void
	{
		this.i = i;
		this.j = j;
	}
	public function add(e:Edge):Edge {
		if (next) {
			e.next = next;
			next.prev = e;
		}
		next = e;
		e.prev = this;
		return e;
	}
	public function remove():void {
		if (prev) prev.next = next;
		if (next) next.prev = prev;
	}
}