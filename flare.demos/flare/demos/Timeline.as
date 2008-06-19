package flare.demos
{
	import flare.analytics.optimization.AspectRatioBanker;
	import flare.animate.Transitioner;
	import flare.display.RectSprite;
	import flare.display.TextSprite;
	import flare.scale.ScaleType;
	import flare.util.Button;
	import flare.util.Maths;
	import flare.vis.Visualization;
	import flare.vis.controls.DragControl;
	import flare.vis.data.Data;
	import flare.vis.operator.encoder.ColorEncoder;
	import flare.vis.operator.layout.AxisLayout;
	import flare.vis.operator.layout.ForceDirectedLayout;
	import flare.vis.util.Filters;
	
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	public class Timeline extends Demo
	{
		public function Timeline() {
			name = "Timeline";
			
			var vis:Visualization = new Visualization(getTimeline(50,3));
			vis.operators.add(new AspectRatioBanker("data.count", true, 700, 300));
			vis.operators.add(new AxisLayout("data.date", "data.count"));
			vis.operators.add(new ColorEncoder(
				"data.series", Data.EDGES, "lineColor", ScaleType.CATEGORIES));
			vis.operators.add(new ColorEncoder(
				"data.series", Data.NODES, "fillColor", ScaleType.CATEGORIES));
			vis.data.nodes.setProperty("alpha", 0.5);
			
			vis.operators[1].xScale.flush = true;
			
			with (vis.xyAxes.xAxis) {
				horizontalAnchor = TextSprite.LEFT;
				verticalAnchor = TextSprite.MIDDLE;
				labelAngle = Math.PI / 2;
			}
			vis.update();
			addChild(vis);
			
			vis.data.edges.setProperty("lineWidth", 2);
			vis.data.nodes.setProperty("lineAlpha", 0);
			vis.data.nodes.setProperty("size", 0.5);
			
			vis.x = vis.y = 40;
			
			var btn:Button = new Button("Bad Idea!");
			btn.x = 10; btn.y = HEIGHT - 10 - btn.height;
			btn.addEventListener(MouseEvent.CLICK, function(evt:MouseEvent):void
			{
				// create new force-directed layout that enforces the bounds
				var r:Rectangle = new Rectangle(0, 0, vis.bounds.width, 460);
				var fdl:ForceDirectedLayout = new ForceDirectedLayout(true);
				fdl.simulation.nbodyForce.gravitation = -10;
				fdl.defaultSpringLength = 20;
				fdl.layoutBounds = r;
				vis.operators.clear();
				vis.operators.add(fdl);
				vis.continuousUpdates = true;
				
				// add a border around the layout bounds
				var b:RectSprite = new RectSprite(-5,-5,r.width+10,r.height+10);
				b.lineColor = 0xffcccccc;
				b.fillColor = 0;
				b.alpha = 0;
				vis.addChildAt(b, 0);
				
				var t:Transitioner = new Transitioner(1);
				vis.data.nodes.setProperties({buttonMode:true, scaleX:2, scaleY:2}, t);
				t.$(b).alpha = 1;
				fdl.hideAxes(t).play();
				
				vis.controls.add(new DragControl(Filters.isNodeSprite));
				removeChild(btn);
			});
			addChild(btn);
		}
		
		public static function getTimeline(N:int, M:int):Data
		{
			var MAX:Number = 60;
			var t0:Date = new Date(1979,5,15);
			var t1:Date = new Date(1982,2,19);
			var x:Number, f:Number;
			
			var data:Data = new Data();
			for (var j:uint=0; j<M; ++j) {
				for (var i:uint=0; i<N; ++i) {
					f = i/(N-1);
					x = t0.time + f*(t1.time - t0.time);
					data.addNode({
						series: int(j),
						date: new Date(x),
						count:int((j*MAX/M) + MAX/M * (1+Maths.noise(13*f,j)))
					});
				}
			}
			data.createEdges("data.date", "data.series");

			return data;
		}
	}
}