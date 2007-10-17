package flare.vis.operator.layout
{
	import flare.animate.Transitioner;
	import flare.vis.data.NodeSprite;
	import flare.util.Property;
	import flare.vis.data.EdgeSprite;
	
	/**
	 * Layout that places items in a dendrogram for displaying the results of a
	 * hierarchical clustering. This class computes a dendrogram layout and sets
	 * edge control points to create "U" shaped dendrogram branches. It is
	 * common, though by no means required, to hide the node instances in a
	 * dendrogram display.
	 * 
	 * <p>To determine the height of dendrogram branches, a distance property
	 * can be provided. The values of this property will directly determine
	 * node heights by laying out the depth axis using a linear scale of
	 * distance values. The distance property should be set for all non-leaf
	 * nodes in the tree. Typically, leaf nodes have a distance of zero,
	 * resulting in an aligned list of leaf nodes.</p>
	 */
	public class DendrogramLayout extends Layout
	{
		// TODO: support axes, too
		
		private var _orient:uint = TOP_TO_BOTTOM; // the orientation of the tree
		private var _dp:Property;
		private var _t:Transitioner; // temp variable for transitioner access
		
		private var _leafCount:int;
		private var _leafIndex:int = 0;
		private var _maxDist:Number;
		private var _b1:Number;
		private var _db:Number;
		private var _d1:Number;
		private var _dd:Number;
		
		/** Data property to use as the distance field for
		 *  determining the height values of dendrogram branches. */
		public function get distanceProperty():String { return _dp.name; }
		public function set distanceProperty(dp:String):void {
			_dp = Property.$(dp);
		}
		
		/** The orientation of the dendrogram */
		public function get orientation():uint { return _orient; }
		public function set orientation(o:uint):void { _orient = o; }
		
		/**
		 * Creates a new DendrogramLayout.
		 * @param distField data property to use as the distance field for
		 *  determining the height values of dendrogram branches
		 * @param orientation the orientation of the dendrogram
		 */
		public function DendrogramLayout(distField:String=null,
			orientation:uint=TOP_TO_BOTTOM)
		{
			_dp = distField==null ? null : Property.$(distField);
			_orient = orientation;
		}
		
		/** @inheritDoc */
		public override function operate(t:Transitioner=null):void
		{
			_t = (t == null ? Transitioner.DEFAULT : t);
			init();
			layout(visualization.tree.root);
		}
		
		/**
		 * Initialize the layout.
		 */
		private function init():void
		{
			var root:NodeSprite = visualization.tree.root;
			_leafCount = (visualization.tree.numNodes+1) / 2;
			_leafIndex = 0;
			_maxDist = _dp!=null ? _dp.getValue(root) : computeHeights(root);
			
			switch (_orient) {
				case TOP_TO_BOTTOM:
					_b1 = layoutBounds.left;
					_db = layoutBounds.width;
					_d1 = layoutBounds.bottom;
					_dd = -layoutBounds.height;
					break;
				case BOTTOM_TO_TOP:
					_b1 = layoutBounds.left;
					_db = layoutBounds.width;
					_d1 = layoutBounds.top;
					_dd = layoutBounds.height;
					break;
				case LEFT_TO_RIGHT:
					_b1 = layoutBounds.top;
					_db = layoutBounds.height;
					_d1 = layoutBounds.right;
					_dd = -layoutBounds.width;
					break;
				case RIGHT_TO_LEFT:
					_b1 = layoutBounds.top;
					_db = layoutBounds.height;
					_d1 = layoutBounds.left;
					_dd = layoutBounds.width;
					break;
			}
		}
		
		private function computeHeights(n:NodeSprite):int
		{
			n.u = 0;
			for (var i:int=0; i<n.childDegree; ++i) {
				n.u = Math.max(n.u, 1 + computeHeights(n.getChildNode(i)));
			}
			return n.u;
		}
		
		private function layout(n:NodeSprite):Number
		{
			var d:Number = _dp!=null ? _dp.getValue(n) : n.u;
			d = _d1 + _dd * (d / _maxDist);
			
			if (n.childDegree > 0) {
				var b:Number = 0, bc:Number;
				for (var i:int=0; i<n.childDegree; ++i) {
					var c:NodeSprite = n.getChildNode(i);
					b += (bc=layout(c));
					layoutEdge(c.parentEdge, bc, d);
				}
				b /= n.childDegree;
			} else {
				var step:Number = 1.0 / _leafCount;
				b = _b1 + _db * (step/2 + step*_leafIndex++);
			}
			layoutNode(n, b, d);
			return b;
		}
		
		private function layoutNode(n:NodeSprite, b:Number, d:Number):void
		{
			var o:Object = _t.$(n);
			if (_orient==TOP_TO_BOTTOM || _orient==BOTTOM_TO_TOP) {
				o.x = b; o.y = d;
			} else {
				o.x = d; o.y = b;
			}
		}
		
		private function layoutEdge(e:EdgeSprite, b:Number, d:Number):void
		{
			var vert:Boolean = _orient==TOP_TO_BOTTOM || _orient==BOTTOM_TO_TOP;
			if (e.points == null) {
				e.points = vert ? [e.source.x, e.target.y] : [e.target.x, e.source.y];
			}
			_t.$(e).points = vert ? [b, d] : [d, b];
		}
		
	} // end of class DendrogramLayout
}