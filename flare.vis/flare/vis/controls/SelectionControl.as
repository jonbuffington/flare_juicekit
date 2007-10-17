package flare.vis.controls
{
	import flash.display.InteractiveObject;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Graphics;
	import flash.display.DisplayObjectContainer;

	/**
	 * Interactive control for selecting a group of objects by "rubber-banding"
	 * them with a rectangular section region.
	 */
	public class SelectionControl
	{
		private var _con:DisplayObjectContainer;
		private var _r:Rectangle = new Rectangle();
		private var _drag:Boolean = false;
		private var _shape:Shape = new Shape();
		
		/** Boolean-valued filter function determining which items are eligible
		 *  for selection. */
		public var filter:Function = null;
		
		/** Function invoked when an item is added to the selection. */
		public var onSelect:Function;
		/** Function invokde when an item is removed from the selection. */
		public var onDeselect:Function;
		
		/**
		 * Creates a new SelectionControl.
		 * @param container the container object to monitor for selections
		 * @param filter an optional Boolean-valued filter determining which
		 *  items are eligible for selection.
		 */
		public function SelectionControl(container:DisplayObjectContainer,
										 filter:Function = null)
		{
			_con = container;
			this.filter = filter;
			if (_con != null) {
				_con.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
				_con.addEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
				_con.addEventListener(MouseEvent.MOUSE_UP, mouseUp);
				_con.addChild(_shape);
			}
		}
		
		/**
		 * Detach this control, removing all event listeners and clearing
		 * all internal state.
		 */
		public function detach():void
		{
			if (_con != null) {
				_con.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
				_con.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
				_con.removeEventListener(MouseEvent.MOUSE_UP, mouseUp);
				_con.removeChild(_shape);
			}
		}
		
		private function mouseDown(evt:MouseEvent):void
		{
			_r.x = _con.mouseX;
			_r.y = _con.mouseY;
			_r.width = 0;
			_r.height = 1;
			_drag = true;
			renderShape();
			selectionTest();
		}
		
		private function mouseMove(evt:MouseEvent):void
		{
			if (!_drag) return;
			_r.width = _con.mouseX - _r.x;
			_r.height = _con.mouseY - _r.y;
			renderShape();
			selectionTest();
		}
		
		private function mouseUp(evt:MouseEvent):void
		{
			_drag = false;
			_shape.graphics.clear();
		}
		
		private function renderShape():void {
			var g:Graphics = _shape.graphics;
			g.clear();
			
			g.beginFill(0x8888FF, 0.2);
			g.lineStyle(2, 0x8888FF, 0.4, true, "none");
			g.drawRect(_r.x, _r.y, _r.width, _r.height);
			g.endFill();
		}
		
		private function selectionTest():void {
			for (var i:uint=0; i<_con.numChildren; ++i) {
				walkTree(_con.getChildAt(i), selTest);
			}
		}
		
		private static function walkTree(obj:DisplayObject, func:Function):void
		{
			func(obj);
			if (obj is DisplayObjectContainer) {
				var con:DisplayObjectContainer = obj as DisplayObjectContainer;
				for (var i:int=0; i<con.numChildren; ++i) {
					walkTree(con.getChildAt(i), func);
				}
			}
		}
		
		private function selTest(d:DisplayObject):void
		{
			if (filter!=null && !filter(d)) return;
			
			if (d.hitTestObject(_shape)) {
				if (onSelect != null) onSelect(d);
			} else {
				if (onDeselect != null) onDeselect(d);
			}
		}
		
	} // end of class SelectionControl
}