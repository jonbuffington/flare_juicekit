package flare.demos
{
	import flash.events.MouseEvent;
	import flare.vis.operator.distortion.FisheyeDistortion;
	import flash.geom.Point;
	import flare.vis.Visualization;
	import flare.util.GraphUtil;
	import flare.vis.operator.layout.NodeLinkTreeLayout;
	import flash.geom.Rectangle;
	import flare.vis.operator.layout.Layout;
	import flash.events.Event;
	import flare.vis.operator.distortion.BifocalDistortion;
	import flare.vis.operator.OperatorSwitch;
	import flash.display.Sprite;
	import flash.display.DisplayObject;
	import flare.vis.operator.encoder.PropertyEncoder;
	import flare.util.Button;
	
	public class Distortion extends Demo
	{
		private var vis:Visualization;
		private var layout:Layout;
		private var distort:Layout;
		private var oswitch:OperatorSwitch;
		
		public function Distortion() {
			name = "Distortion";
			
			// create visualization
			addChild(vis = new Visualization(GraphUtil.diamondTree(4, 6, 6)));
			vis.bounds = new Rectangle(0, 0, WIDTH, HEIGHT-40);
			vis.operators.add(new PropertyEncoder({scaleX:1, scaleY:1}));
			vis.operators.add(layout=new NodeLinkTreeLayout());
			layout.layoutAnchor = new Point(20, vis.bounds.height/2);
			oswitch = new OperatorSwitch(
				new FisheyeDistortion(4,0,2),
				new FisheyeDistortion(0,4,2),
				new FisheyeDistortion(4,4,2),
				new BifocalDistortion(0.1, 3.0, 0.1, 1.0),
				new BifocalDistortion(0.1, 1.0, 0.1, 3.0),
				new BifocalDistortion(0.1, 3.0, 0.1, 3.0)
			);
			vis.operators.add(oswitch);
			setDistortion(0);
			vis.update();
			
			// create buttons
			var btnSprite:Sprite = new Sprite();
			var btns:Array = ["Fisheye X","Fisheye Y","Fisheye XY",
							  "Bifocal X","Bifocal Y","Bifocal XY"];
			var w:Number = 0;
			for (var i:uint=0; i<btns.length; ++i) {
				var btn:Button = new Button(btns[i]);
				btn.addEventListener(MouseEvent.CLICK, function(e:Event):void {
					setDistortion(btnSprite.getChildIndex(e.target as DisplayObject));
				});
				btn.x = 10 + w;
				w += 10 + btn.width;
				btnSprite.addChild(btn);
			}
			btnSprite.y = HEIGHT - 10 - btnSprite.height;
			addChild(btnSprite);
		}
		
		private function setDistortion(idx:int):void
		{
			oswitch.index = idx;
			distort = oswitch.getOperatorAt(idx) as Layout;
		}
		
		private function updateMouse(evt:Event):void
		{
			// get current anchor, run update if changed
			var p1:Point = distort.layoutAnchor;
			distort.layoutAnchor = new Point(vis.mouseX, vis.mouseY);
			// distortion might snap the anchor to the layout bounds
			// so we need to re-retrieve the point to get an accurate point
			var p2:Point = distort.layoutAnchor;
			if (p1.x != p2.x || p1.y != p2.y) vis.update();
		}
		
		public override function play():void {
			addEventListener(Event.ENTER_FRAME, updateMouse, false, 0, true);
		}
		
		public override function stop():void {
			removeEventListener(Event.ENTER_FRAME, updateMouse);
		}

	}
}