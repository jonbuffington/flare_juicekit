package flare.vis.operator.layout
{
	import flare.animate.Transitioner;
	import flare.vis.data.DataSprite;
	import flare.vis.Visualization;
	import flare.vis.axis.CartesianAxes;
	import flare.vis.scale.LinearScale;
	import flare.vis.data.Data;
	import flash.utils.Dictionary;
	import flare.util.Property;
	
	/**
	 * Layout that places items according to data properties along the X and Y
	 * axes. The AxisLayout can also compute stacked layouts, in which elements
	 * that share the same data values along an axis can be consecutively
	 * stacked on top of each other.
	 */
	public class AxisLayout extends Layout
	{
		private var _initAxes:Boolean = true;
		private var _xStacks:Boolean = false;
		private var _yStacks:Boolean = false;		
		private var _xField:Property;
		private var _yField:Property;
		private var _t:Transitioner;
		
		/** The x-axis source property. */
		public function get xAxisField():String {
			return _xField==null ? null : _xField.name;
		}
		public function set xAxisField(f:String):void {
			_xField = Property.$(f); initializeAxes();
		}
		
		/** The y-axis source property. */
		public function get yAxisField():String {
			return _yField==null ? null : _yField.name;
		}
		public function set yAxisField(f:String):void {
			_yField = Property.$(f); initializeAxes();
		}
		
		/** Flag indicating if values should be stacked according to their
		 *  x-axis values. */
		public function get xStacked():Boolean { return _xStacks; }
		public function set xStacked(b:Boolean):void { _xStacks = b; }

		/** Flag indicating if values should be stacked according to their
		 *  y-axis values. */
		public function get yStacked():Boolean { return _yStacks; }
		public function set yStacked(b:Boolean):void { _yStacks = b; }
		
		// --------------------------------------------------------------------
		
		/**
		 * Creates a new AxisLayout
		 * @param xAxisField the x-axis source property
		 * @param yAxisField the y-axis source property
		 * @param xStacked indicates if values should be stacked according to
		 *  their x-axis values
		 * @param yStacked indicates if values should be stacked according to
		 *  their y-axis values
		 */		
		public function AxisLayout(xAxisField:String=null, yAxisField:String=null,
								   xStacked:Boolean=false, yStacked:Boolean=false)
		{
			_xField = Property.$(xAxisField);
			_yField = Property.$(yAxisField);
			_xStacks = xStacked;
			_yStacks = yStacked;
		}
		
		/** @inheritDoc */
		public override function setup():void
		{
			initializeAxes();
		}
		
		/**
		 * Initializes the axes prior to layout.
		 */
		public function initializeAxes():void
		{
			if (!_initAxes || visualization==null) return;
			
			// set axes
			var axes:CartesianAxes = super.xyAxes;
			var data:Data = visualization.data;
			axes.xAxis.axisScale = data.scale(_xField.name);
			axes.yAxis.axisScale = data.scale(_yField.name);
		}
		
		/** @inheritDoc */
		public override function operate(t:Transitioner=null):void
		{
			_t = (t != null ? t : Transitioner.DEFAULT);
			if (_xStacks || _yStacks) { rescale(); }
						
			var axes:CartesianAxes = super.xyAxes;
			var x0:Number = axes.originX;
			var y0:Number = axes.originY;

			var xmap:Object = _xStacks ? new Object() : null;
			var ymap:Object = _yStacks ? new Object() : null;
			
			visualization.data.nodes.visit(function(d:DataSprite):Boolean {
				var dx:Object, dy:Object, x:Number, y:Number, s:Number, z:Number;
				var o:Object = _t.$(d);
				dx = _xField.getValue(d); dy = _yField.getValue(d);
				
				if (_xField != null) {
					x = axes.xAxis.X(dx);
					if (_xStacks) {
						z = x - x0;
						s = z + (isNaN(s=xmap[dy]) ? 0 : s);
						o.x = x0 + s;
						o.w = z;
						xmap[dy] = s;
					} else {
						o.x = x;
						o.w = x - x0;
					}
				}
				if (_yField != null) {
					y = axes.yAxis.Y(dy);
					if (_yStacks) {
						z = y - y0;
						s = z + (isNaN(s=ymap[dx]) ? 0 : s);
						o.y = y0 + s;
						o.h = z;
						ymap[dx] = s;
					} else {
						o.y = y;
						o.h = y - y0;
					}
				}
				return true;
			});
			
			_t = null;
		}
		
		private function rescale():void {
			var xmap:Object = _xStacks ? new Object() : null;
			var ymap:Object = _yStacks ? new Object() : null;
			var xmax:Number = 0;
			var ymax:Number = 0;
			
			visualization.data.nodes.visit(function(d:DataSprite):Boolean {
					var x:Object = _xField.getValue(d);
					var y:Object = _yField.getValue(d);
					var v:Number;
					
					if (_xStacks) {
						v = isNaN(xmap[y]) ? 0 : xmap[y];
						xmap[y] = v = (Number(x) + v);
						if (v > xmax) xmax = v;
					}
					if (_yStacks) {
						v = isNaN(ymap[x]) ? 0 : ymap[x];
						ymap[x] = v = (Number(y) + v);
						if (v > ymax) ymax = v;
					}
					return true;
			});
			
			var axes:CartesianAxes = visualization.xyAxes;
			if (_xStacks) axes.xAxis.axisScale = new LinearScale(0, xmax);
			if (_yStacks) axes.yAxis.axisScale = new LinearScale(0, ymax);
		}
		
	} // end of class AxisLayout
}