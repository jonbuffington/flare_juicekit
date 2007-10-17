package flare.vis.data.render
{
	import flare.vis.data.DataSprite;
	import flare.vis.data.EdgeSprite;
	import flare.vis.data.NodeSprite;
	import flash.display.Graphics;
	import flash.geom.Point;
	import flare.vis.util.graphics.GraphicsUtil;
	import flare.vis.util.graphics.Shapes;

	/**
	 * Renderer that draws edges as lines. The EdgeRenderer supports straight
	 * lines, poly lines, and curves as Bezier or cardinal splines. The type
	 * of edge drawn is determined from an EdgeSprite's <code>shape</code>
	 * property and control points found in the <code>points</code> property.
	 */
	public class EdgeRenderer implements IRenderer
	{
		private static var _instance:EdgeRenderer = new EdgeRenderer();
		/** Static EdgeRenderer instance. */
		public static function get instance():EdgeRenderer { return _instance; }
		
		/** @inheritDoc */
		public function render(d:DataSprite):void
		{
			var e:EdgeSprite = d as EdgeSprite;
			if (e == null) { return; } // TODO: throw exception?
			var s:NodeSprite = e.source;
			var t:NodeSprite = e.target;
			var g:Graphics = e.graphics;
			
			if (s==null || t==null) { g.clear(); return; }
			
			var ctrls:Array = e.points as Array;
				
			g.clear(); // clear it out
			setLineStyle(e, g); // set the line style
			
			if (e.shape == Shapes.BEZIER && ctrls != null && ctrls.length > 1) {
				if (ctrls.length < 4)
				{
					g.moveTo(e.x1, e.y1);
					g.curveTo(ctrls[0], ctrls[1], e.x2, e.y2);
				}
				else
				{
					GraphicsUtil.drawCubic(g, e.x1, e.y1, ctrls[0], ctrls[1],
										   ctrls[2], ctrls[3], e.x2, e.y2);
				}
			} else if (e.shape == Shapes.CARDINAL) {
				GraphicsUtil.drawCardinal2(g, e.x1, e.y1, ctrls, e.x2, e.y2);
			} else {
				g.moveTo(e.x1, e.y1);
				if (ctrls != null) {
					for (var i:uint=0; i<ctrls.length; i+=2)
						g.lineTo(ctrls[i], ctrls[i+1]);
				}
				g.lineTo(e.x2, e.y2);
			}
		}
		
		/**
		 * Sets the line style for edge rendering.
		 * @param e the EdgeSprite to render
		 * @param g the Graphics context to draw with
		 */
		protected function setLineStyle(e:EdgeSprite, g:Graphics):void
		{
			var lineAlpha:Number = e.lineAlpha;
			if (lineAlpha == 0) return;
			
			var sm:String = e.props.scaleMode;
			if (sm == null) sm = "normal";
			g.lineStyle(e.lineWidth, e.lineColor, lineAlpha, e.props.pixelHinting, sm);
		}

	} // end of class EdgeRenderer
}