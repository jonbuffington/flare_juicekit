package flare.demos
{
	import flare.animate.TransitionEvent;
	import flare.animate.Transitioner;
	import flare.util.Button;
	import flare.util.Colors;
	import flare.vis.Visualization;
	import flare.vis.data.Data;
	import flare.vis.data.DataSprite;
	import flare.vis.operator.layout.StackedAreaLayout;
	import flare.vis.util.Shapes;
	
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class Stacks extends Demo
	{
		private var vis:Visualization;
		private var t:Transitioner;
		private var thresh:Number;
		
		public function Stacks() {
			name = "Stacks";
			
			var dataset:Object = getData(500);
			
			vis = new Visualization(dataset.data);
			vis.bounds.width = WIDTH-100;
			vis.bounds.height = HEIGHT-90;
			vis.operators.add(new StackedAreaLayout(dataset.columns));
			vis.data.nodes.visit(function(d:DataSprite):void {
				d.fillColor = Colors.rgba(0xAA,0xAA,100 + uint(155*Math.random()));
				d.fillAlpha = 1;
				d.lineAlpha = 0;
				d.shape = Shapes.POLYGON;
			});
			vis.update();
			addChild(vis);
			
			vis.x = 60;
			vis.y = 15;
			
			// random filter button
			var b:Button = new Button("Filter");
			b.addEventListener(MouseEvent.CLICK, function(evt:MouseEvent):void
			{
				t = new Transitioner(1.5);
				thresh = 0.25 + 0.75 * Math.random();
				vis.data.nodes.visit(filter);
				
				t.addEventListener(TransitionEvent.START,
					function(e:Event):void {stage.quality = StageQuality.LOW});
				t.addEventListener(TransitionEvent.END,
					function(e:Event):void {stage.quality = StageQuality.HIGH});
				
				vis.update(t).play();
			});
			b.x = 10; b.y = HEIGHT - 10 - b.height;
			addChild(b);
		}
		
		public function filter(d:DataSprite):void
		{
			t.$(d).visible = Math.random() < thresh;
		}
	
		public static function getData(N:int):Object
		{
			var cols:Array = [-3,1,3,4,5,6,7,8,9,10];
			var i:uint, col:String;
			
			var data:Data = new Data();
			for (i=0; i<N; ++i) {
				var d:DataSprite = data.addNode();
				var j:uint = 0, s:Number;
				for each (col in cols) {
					s = 1 + int((j++)/2);
					d.data[col] = s*Math.random();
				}
			}
			
			return { data:data, columns:cols };
		}
		
		public override function play():void
		{
			//stage.quality = StageQuality.LOW;
		}
		
		public override function stop():void
		{
			//stage.quality = StageQuality.HIGH;
		}
	}
}