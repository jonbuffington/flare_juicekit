package flare.vis.controls
{
	import flash.display.InteractiveObject;
	import flash.events.MouseEvent;
	import flare.vis.data.NodeSprite;
	import flare.vis.Visualization;
	import flare.animate.Transitioner;
	import flare.vis.Visualization;

	/**
	 * Interactive control for expaning and collapsing graph or tree nodes
	 * by clicking them. This control will only work when applied to a
	 * Visualization instance.
	 */
	public class ExpandControl
	{
		private var _vis:Visualization;
		private var _cur:NodeSprite;
		
		/** The Visualization associated with this control. */
		public function get visualization():Visualization { return _vis; }
		/** Boolean-valued filter function for determining which items
		 *  this control will attempt to expand or collapse. */
		public var filter:Function;
		/** Update function invoked after expanding or collapsing an item.
		 *  By default, invokes the <code>update</code> method on the
		 *  visualization with a 1-second transitioner. */
		public var update:Function = function():void {
			_vis.update(new Transitioner(1)).play();
		}
		
		// --------------------------------------------------------------------
		
		/**
		 * Creates a new ExpandControl.
		 * @param vis the visualization to interact with
		 * @param filter a Boolean-valued filter function for determining which
		 *  item this control will expand or collapse
		 * @param update function invokde after expanding or collapsing an
		 *  item.
		 */		
		public function ExpandControl(vis:Visualization, filter:Function=null, 
									  update:Function=null)
		{
			_vis = vis;
			if (_vis != null) {
				_vis.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			}
			this.filter = filter;
			if (update != null) this.update = update;
		}
		
		/**
		 * Detach this control, removing all event listeners and clearing
		 * all internal state.
		 */
		public function detach():void
		{
			if (_vis == null) return;
			_vis.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			_vis = null;
		}
		
		private function onMouseDown(event:MouseEvent) : void {
			var s:NodeSprite = event.target as NodeSprite;
			if (s==null) return; // exit if not a NodeSprite
			
			if (filter==null || filter(s)) {
				_cur = s;
				_cur.stage.addEventListener(MouseEvent.MOUSE_MOVE, onDrag);
				_cur.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			}
			event.stopPropagation();
		}
		
		private function onDrag(event:MouseEvent) : void {
			_cur.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			_cur.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onDrag);
			_cur = null;
		}
		
		private function onMouseUp(event:MouseEvent) : void {
			_cur.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			_cur.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onDrag);
			_cur.expanded = !_cur.expanded;
			_cur = null;	
			event.stopPropagation();
			
			update();
		}
		
	} // end of class ExpandControl
}