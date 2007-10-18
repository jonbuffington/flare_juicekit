package flare.tests
{
	import flare.vis.data.Data;
	import flare.vis.data.EdgeSprite;
	import flare.vis.data.NodeSprite;
	import unitest.TestCase;
	
	public class DataTests extends TestCase
	{
		public function DataTests()
		{
			addTest("createNodes");
			addTest("createEdges");
			addTest("containsNodes");
			addTest("containsEdges");
			addTest("removeNodes");
			addTest("removeEdges");
			addTest("createWithDefaults");
		}
		
		// --------------------------------------------------------------------
		
		private static const N:int = 100;
		private var data:Data;
		
		public function createNodes():void
		{
			data = new Data();
			for (var i:uint=0; i<N; ++i) {
				data.addNode();
				assertEquals(data.numNodes, i+1);
			}
		}
		
		public function createEdges():void
		{
			data = new Data();
			for (var i:uint=0; i<N; ++i) {
				data.addNode();
				assertEquals(data.numNodes, i+1);
					
				if (i > 0) {
					var s:NodeSprite = data.getNodeAt(i-1);
					var t:NodeSprite = data.getNodeAt(i);
					var e:EdgeSprite = data.addEdgeFor(s, t);
					assertEquals(data.numEdges, i);
					assertEquals(e.source, s);
					assertEquals(e.target, t);
				}
			}
		}
		
		public function createWithDefaults():void
		{
			var _x:Number = 10, _y:Number = 20, _lw:Number = 3;
			var _na:Number = 1, _ea:Number = 0, _t:String = "hello";
			data = new Data();
			data.setDefaults({x:_x, y:_y}, Data.NODES);
			data.setDefaults({lineWidth: _lw}, Data.EDGES);
			data.setDefault("alpha", _na, Data.NODES);
			data.setDefault("props.temp", _t, Data.NODES);
			data.setDefault("alpha", _ea, Data.EDGES);

			
			var prev:NodeSprite = null, curr:NodeSprite;
			for (var i:uint=0; i<10; ++i) {
				curr = data.addNode();
				if (prev != null) data.addEdgeFor(prev, curr);
				prev = curr;
			}
			
			for (i=0; i<data.numNodes; ++i) {
				curr = data.getNodeAt(i);
				assertEquals(_x, curr.x);
				assertEquals(_y, curr.y);
				assertEquals(_t, curr.props.temp);
				assertEquals(_na, curr.alpha);
			}
			for (i=0; i<data.numEdges; ++i) {
				var e:EdgeSprite = data.getEdgeAt(i);
				assertEquals(_lw, e.lineWidth);
				assertEquals(_ea, e.alpha);
			}
			
			// test default removal
			data.removeDefault("props.temp", Data.NODES);
			data.removeDefault("alpha", Data.EDGES);
			curr = data.addNode();
			e = data.addEdgeFor(prev, curr);
			assertNotEquals(_t, curr.props.temp);
			assertNotEquals(_ea, e.alpha);
		}
		
		public function containsNodes():void
		{
			createNodes();
			for (var i:uint=0; i<N; ++i) {
				assertTrue(data.contains(data.getNodeAt(i)));
				assertTrue(data.containsNode(data.getNodeAt(i)));
			}
			data.visitNodes(function(n:NodeSprite):Boolean {
				assertTrue(data.contains(n));
				assertTrue(data.containsNode(n));
				return true;
			});
		}
		
		public function containsEdges():void
		{
			createEdges();
			for (var i:uint=0; i<data.numEdges; ++i) {
				assertTrue(data.contains(data.getEdgeAt(i)));
				assertTrue(data.containsEdge(data.getEdgeAt(i)));
			}
			data.visitEdges(function(e:EdgeSprite):Boolean {
				assertTrue(data.contains(e));
				assertTrue(data.containsEdge(e));
				return true;
			});
		}
		
		public function removeNodes():void
		{
			var n:NodeSprite;
			
			createNodes();
			for (var i:uint=N; --i>=0;) {
				n = data.getNodeAt(i);
				data.removeNode(n);
				assertEquals(i, data.numNodes);
				assertFalse(data.containsNode(n));
			}
			
			createNodes(); i=N;
			data.visitNodes(function(n:NodeSprite):Boolean {
				data.removeNode(n); --i;
				assertEquals(data.numNodes, i);
				return true;
			});
			assertEquals(0, i);
			
			createEdges(); i=N;
			data.visitNodes(function(n:NodeSprite):Boolean {
				data.removeNode(n); --i;
				assertEquals(data.numNodes, i);
				return true;
			});
			assertEquals(0, i);
			assertEquals(0, data.numEdges);
		}
		
		public function removeEdges():void
		{
			var e:EdgeSprite;
						
			createEdges();
			for (var i:uint=N-1; --i>=0;) {
				e = data.getEdgeAt(i);
				data.removeEdge(e);
				assertEquals(i, data.numEdges);
				assertFalse(data.containsEdge(e));
			}
			assertEquals(N, data.numNodes);
			
			createEdges(); i=N-1;
			data.visitEdges(function(e:EdgeSprite):Boolean {
				data.removeEdge(e); --i;
				assertEquals(data.numEdges, i);
				return true;
			});
			assertEquals(0, i);
			assertEquals(0, data.numEdges);
			assertEquals(N, data.numNodes);
		}
		
	} // end of class DataTests
}