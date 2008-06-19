package flare.demos
{
	import flare.util.GraphUtil;
	import flare.vis.Visualization;
	import flare.vis.controls.HoverControl;
	import flare.vis.data.EdgeSprite;
	import flare.vis.data.NodeSprite;
	import flare.vis.data.Tree;
	import flare.vis.events.SelectionEvent;
	import flare.vis.operator.layout.TreeMapLayout;
	import flare.vis.util.Filters;
	import flare.vis.util.Shapes;
	
	import flash.display.StageQuality;
	import flash.geom.Rectangle;
	
	public class TreeMap extends Demo
	{
		public function TreeMap() {
			name = "TreeMap";
			var tree:Tree = GraphUtil.balancedTree(4,5);
			var e:EdgeSprite, n:NodeSprite;
			
			var vis:Visualization = new Visualization(tree);
			vis.tree.nodes.visit(function(n:NodeSprite):void {
				n.size = Math.random();
				n.shape = Shapes.BLOCK;
				n.fillColor = 0xff8888FF; n.lineColor = 0;
				n.fillAlpha = n.lineAlpha = n.depth / 25;
			});
			vis.data.edges.setProperty("visible", false);
			vis.operators.add(new TreeMapLayout());
			vis.bounds = new Rectangle(0, 0, WIDTH, HEIGHT);		
			vis.update();
			addChild(vis);
			
			var hc:HoverControl = new HoverControl(
				Filters.isNodeSprite, HoverControl.MOVE_AND_RETURN);
			hc.addEventListener(SelectionEvent.SELECT, rollOver);
			hc.addEventListener(SelectionEvent.DESELECT, rollOut);
			vis.controls.add(hc);
		}
		
		private function rollOver(evt:SelectionEvent):void {
			var n:NodeSprite = evt.node;
			n.lineColor = 0xffFF0000; n.lineWidth = 2;
			n.fillColor = 0xffFFFFAAAA;
		}
		
		private function rollOut(evt:SelectionEvent):void {
			var n:NodeSprite = evt.node;
			n.lineColor = 0; n.lineWidth = 0;
			n.fillColor = 0xff8888FF;
			n.fillAlpha = n.lineAlpha = n.depth / 25;
		}
		
		public override function play():void
		{
			stage.quality = StageQuality.LOW;
		}
		
		public override function stop():void
		{
			stage.quality = StageQuality.HIGH;
		}
	}
}