package flare.demos
{
	import flare.animate.TransitionEvent;
	import flare.animate.Transitioner;
	import flare.demos.util.Link;
	import flare.display.TextSprite;
	import flare.scale.ScaleType;
	import flare.util.Strings;
	import flare.vis.Visualization;
	import flare.vis.controls.HoverControl;
	import flare.vis.controls.SelectionControl;
	import flare.vis.controls.TooltipControl;
	import flare.vis.data.Data;
	import flare.vis.data.DataSprite;
	import flare.vis.data.ScaleBinding;
	import flare.vis.events.SelectionEvent;
	import flare.vis.events.TooltipEvent;
	import flare.vis.operator.distortion.BifocalDistortion;
	import flare.vis.operator.distortion.Distortion;
	import flare.vis.operator.encoder.ColorEncoder;
	import flare.vis.operator.encoder.ShapeEncoder;
	import flare.vis.operator.encoder.SizeEncoder;
	import flare.vis.operator.layout.AxisLayout;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	
	/**
	 * Demo showcasing a scatter plot layout, changing axis scales, and
	 * interactive selection.
	 */
	public class Scatter extends Demo
	{
		/** The tooltip format string. */
		private static const _tipText:String =
			"<b>Value 1</b>: {0}<br/>" + 
			"<b>Value 2</b>: {1}";
		
		private var vis:Visualization;
		private var distort:Distortion;
		
		public function Scatter() {
			name = "Scatter";
		}
		
		public override function init():void
		{
			// create the visualization
			vis = new Visualization(getData(200));
			vis.bounds = bounds;
			vis.x = 45;
			vis.y = 15;
			addChild(vis);
			
			// define the visual encodings
			vis.data.nodes.setProperties({
				fillColor: 0x018888ff, // transparent fill to catch mouse hits
				lineWidth: 3
			});
			vis.operators.add(new AxisLayout("data.value1", "data.value2"));
			vis.operators.add(new SizeEncoder("data.value2"));
			vis.operators.add(new ShapeEncoder("data.value1"));
			vis.operators.add(new ColorEncoder("data.value1", Data.NODES,
				"lineColor", ScaleType.CATEGORIES));
			vis.xyAxes.xAxis.fixLabelOverlap = false; // let labels overlap
			vis.update();
			
			// add a new data group to house selected items
			vis.data.addGroup("selected");
			
			
			// -- add controls ------------------------------------------------
			
			// add rubber-band selection
			vis.controls.add(new SelectionControl(DataSprite,
				// highlight nodes and add to focus group on select
				function(e:SelectionEvent):void {
					for each (var d:DataSprite in e.items) {
						vis.data.group("selected").add(d);
						d.filters = [new GlowFilter(0xFFFF55, 0.8, 6, 6, 10)];
					}
				},
				// remove higlight and remove from focus group on deselect
				function(e:SelectionEvent):void {
					for each (var d:DataSprite in e.items) {
						vis.data.group("selected").remove(d);
						d.filters = null;
					}
				}, vis));
			
			// add mouse-over highlight
			vis.controls.add(new HoverControl(DataSprite, 0,
				// highlight on mouse over
				function(e:SelectionEvent):void {
					e.item.filters = [new GlowFilter(0xFFFF55, 0.8, 6, 6, 10)];
				},
				// remove higlight on mouse out, unless item is in focus group
				function(e:SelectionEvent):void {
					if (!vis.data.group("selected").contains(e.item))
						e.item.filters = null
				}
			));
			
			// add tooltip showing data values
			vis.controls.add(new TooltipControl(DataSprite, null,
				function(e:TooltipEvent):void {
					var data:Object = e.node.data;
					TextSprite(e.tooltip).htmlText = Strings.format(
						_tipText, data.value1, data.value2);
				}
			));
			
			// -- add links ---------------------------------------------------
			
			// listener function for chaging the x-axis scale
			var setScale:Function = function(evt:MouseEvent):void {
				var type:String = evt.target==linear ? "linear" : "log";
				var xb:ScaleBinding = AxisLayout(vis.operators[0]).xScale;
				if (xb.scaleType != type) {
					xb.scaleType = type;
					vis.update(new Transitioner(2)).play();
				}
			};
			
			// create link for linear scale
			var linear:Link = new Link("Linear Scale");
			linear.addEventListener(MouseEvent.CLICK, setScale);
			links.add(linear);
			links.select(linear);
			
			// create link for logarithmic scale
			var log:Link = new Link("Log Scale");
			log.addEventListener(MouseEvent.CLICK, setScale);
			links.add(log);
			
			// create toggle link for bifocal distortion
			var ld:Link = new Link("Distortion");
			links.addChild(ld);
			ld.x += 12;
			ld.addEventListener(MouseEvent.CLICK, function(evt:MouseEvent):void {
				if (distort != null) {
					ld.bold = false;
					// remove distortion operator and frame listener
					vis.operators.remove(distort);
					distort = null;
					removeEventListener(Event.ENTER_FRAME, mouseUpdate);
					// animate back to non-distorted view
					vis.update(new Transitioner(1)).play();
				} else {
					ld.bold = true;
					// add and initialize distortion operator 
					vis.operators.add(distort=new BifocalDistortion());
					distort.distortSize = false;
					distort.layoutAnchor = new Point(vis.mouseX, vis.mouseY);
					// animate into distorted view, add frame listener
					var t:Transitioner = vis.update(new Transitioner(1));
					t.addEventListener(TransitionEvent.END,
						function(evt:Event):void {
							addEventListener(Event.ENTER_FRAME, mouseUpdate);
						}
					);
					t.play();
				}
			});
		}
		
		public override function resize():void
		{
			bounds.width -= 65;
			bounds.height -= 50;
			if (vis) {
				vis.bounds = bounds;
				vis.update();
			}
		}
		
		private function mouseUpdate(evt:Event):void
		{
			// get current anchor, run update if changed
			var p1:Point = distort.layoutAnchor;
			distort.layoutAnchor = new Point(vis.mouseX, vis.mouseY);
			// distortion might snap the anchor to the layout bounds
			// so we need to re-retrieve the point to get an accurate point
			var p2:Point = distort.layoutAnchor;
			// compare the old and new points to prevent unneeded updates
			if (p1.x != p2.x || p1.y != p2.y) vis.update();
		}
		
		public static function getData(n:int):Data
		{
			var data:Data = new Data();
			var d:DataSprite;
			var i:uint = 0;
			
			for (; i<10 && i<n; ++i) {
				d = data.addNode({
					value1: int(1 + 9*Math.random()),
					value2: int(200*(Math.random()-0.5))
				});
			}
			for (; i<n; ++i) {
				d = data.addNode({
					value1: int(1 + 99*Math.random()),
					value2: int(200*(Math.random()-0.5))
				});
			}
			return data;
		}
		
	} // end of class Scatter
}