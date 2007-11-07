package flare.flex
{
	import flare.vis.Visualization;
	import flare.vis.axis.Axes;
	import flare.vis.axis.CartesianAxes;
	import flare.vis.data.Data;
	
	import flash.geom.Rectangle;
	
	import mx.core.UIComponent;

	/**
	 * Flex component that wraps a Flare visualization instance. This class can
	 * be used to create Flare visualizations within an MXML file. The
	 * underlying Flare <code>Visualization</code> instance can always be
	 * accessed using the <code>visualization</code> property.
	 */
	public class FlareVis extends UIComponent
	{
		private var _vis:Visualization;
		
		/** The bounds for the data display area of this visualization. */
		public function get bounds():Rectangle { return _vis.bounds; }
		public function set bounds(b:Rectangle):void { _vis.bounds = b; }
		
		/** The visualization operators used by this visualization. This
		 *  should be an array of IOperator instances. */
		public function set operators(a:Array):void {
			_vis.operators.list = a;
			_vis.update();
		}
		
		/** Sets the data visualized by this instance. Any existing data will
		 *  be removed and new NodeSprite instances will be created for each
		 *  object in the input arrary. */
		public function set data(d:Array):void {
			if (_vis.data == null) {
				_vis.data = new Data();
			} else {
				_vis.data.clear();
			}
			for each (var tuple:Object in d) {
				_vis.data.addNode(tuple);
			}
			_vis.operators.setup();
			_vis.update();
		}
		
		/** Returns the axes for the backing visualization instance. */
		public function get axes():Axes { return _vis.axes; }
		
		/** Returns the CartesianAxes for the backing visualization instance. */
		public function get xyAxes():CartesianAxes { return _vis.xyAxes; }
		
		/** Returns the backing Flare visualization instance. */
		public function get visualization():Visualization {
			return _vis;
		}
		
		// --------------------------------------------------------------------
		
		/**
		 * Creates a new FlareVis component. By default, a new visualization
		 * with an empty data set is created.
		 * @param data the data to visualize. If this value is null, a new
		 *  empty data instance will be used.
		 */
		public function FlareVis(data:Data=null) {
			addChild(_vis = new Visualization(data==null ? new Data() : data));
		}
		
		// -- UIComponent Overrides -------------------------------------------
		
		/** @private */
		public override function setActualSize(w:Number, h:Number):void
		{
			_vis.bounds.width = w;
			_vis.bounds.height = h;
		}
		
		/** @private */
		public override function get explicitWidth():Number
		{
			return _vis.bounds.width;
		}
		
		/** @private */
		public override function set explicitWidth(value:Number):void
		{
			_vis.bounds.width = value;
		}
		
		/** @private */
		public override function get explicitHeight():Number
		{
			return _vis.bounds.height;
		}
		
		/** @private */
		public override function set explicitHeight(value:Number):void
		{
			_vis.bounds.height = value;
		}
		
		/** @private */
		public override function get measuredHeight():Number
		{
			return _vis.bounds.height;
		}
		
		/** @private */
		public override function get measuredWidth():Number
		{
			return _vis.bounds.width;
		}
		
	} // end of class FlareVis
}