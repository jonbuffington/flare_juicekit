package flare.vis.controls
{
	import flare.vis.data.DataSprite;
	
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	/**
	 * Interactive control for dragging items. A DragControl will enable
	 * dragging of all Sprites in a container object by clicking and dragging
	 * them.
	 */
	public class DragControl extends Control
	{
		private var _cur:Sprite;
		
		/** Filter function for limiting the items available for dragging. */
		public var filter:Function;
		
		/** The active item currently being dragged. */
		public function get activeItem():Sprite { return _cur; }
		
		/**
		 * Creates a new DragControl.
		 * @param container the container object containing the items to drag
		 * @param filter a Boolean-valued filter function determining which
		 *  items should be draggable.
		 */		
		public function DragControl(container:InteractiveObject=null,
									filter:Function=null) {
			if (container!=null) attach(container);
			this.filter = filter;
		}
		
		/** @inheritDoc */
		public override function attach(obj:InteractiveObject):void
		{
			super.attach(obj);
			obj.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		}
		
		/** @inheritDoc */
		public override function detach() : InteractiveObject
		{
			if (_object != null) {
				_object.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			}
			return super.detach();
		}
		
		private function onMouseDown(event:MouseEvent) : void {
			var s:Sprite = event.target as Sprite;
			if (s==null) return; // exit if not a sprite
			
			if (filter==null || filter(s)) {
				_cur = s;
				if (_cur is DataSprite) (_cur as DataSprite).fix();
				_cur.startDrag();
				_cur.stage.addEventListener(MouseEvent.MOUSE_MOVE, onDrag);
				_cur.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			}
			event.stopPropagation();
		}
		
		private function onDrag(event:MouseEvent) : void {
			// ensure that position updates are handled correctly
			// we hack this in because flash isn't invoking x,y overrides
			// TODO: find cleaner fix? ie, a public position update method?
			_cur.x = _cur.x + 1e-12;
			_cur.y = _cur.y + 1e-12;
			// ensure that render event is made for the next frame
			event.updateAfterEvent();
		}
		
		private function onMouseUp(event:MouseEvent) : void {
			if (_cur != null) {
				_cur.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
				_cur.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onDrag);
				_cur.stopDrag();
				
				if (_cur is DataSprite) (_cur as DataSprite).unfix();
				event.stopPropagation();
			}
			_cur = null;
		}
		
	} // end of class DragControl
}