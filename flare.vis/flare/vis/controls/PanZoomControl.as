package flare.vis.controls
{
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flare.vis.util.graphics.Transforms;
	
	/**
	 * Interactive control for panning and zooming a "camera". Any sprite can
	 * be treated as a camera onto its drawing content and display list
	 * children. The PanZoomControl allows you to manipulate a sprite's
	 * transformation matrix (the <code>transform.matrix</code> property) to
	 * simulate camera movements such as panning and zooming. To pan and
	 * zoom over a collection of objects, simply add a PanZoomControl for
	 * the sprite holding the collection.
	 * 
	 * <pre>
	 * var s:Sprite; // a sprite holding a collection of items
	 * new PanZoomControl(s); // attach pan and zoom controls to the sprite
	 * </pre>
	 * <p>Once a PanZoomControl has been created, panning is performed by
	 * clicking and dragging. Zooming is performed either by scrolling the
	 * mouse wheel or by clicking and dragging vertically while the control key
	 * is pressed.</p>
	 * 
	 * <p>By default, the PanZoomControl attaches itself to the
	 * <code>stage</code> to listen for mouse events. This works fine if there
	 * is only one collection of objects in the display lists, but can cause
	 * trouble if you want to have multiple collections that can be separately
	 * panned and zoomed. The PanZoomControl constructor takes a second
	 * argument that specifies a "hit area", a shape in the display list that
	 * should be used to listen to the mouse events for panning and zooming.
	 * For example, this could be a background sprite behind the zoomable
	 * content, to which the "camera" sprite could be added. One can then set
	 * the <code>scrollRect</code> property to add clipping bounds to the 
	 * panning and zooming region.</p>
	 */
	public class PanZoomControl
	{
		private var px:Number, py:Number;
		private var mx:Number, my:Number;
		private var _drag:Boolean = false;
		
		private var _cam:DisplayObject;
		private var _hit:InteractiveObject;
		private var _stage:Stage;
				
		/**
		 * Creates a new PanZoomControl.
		 * @param camera a display object to treat as the camera
		 * @param hitArea a display object to use as the hit area for mouse
		 *  events. For example, this could be a background region over which
		 *  the panning and zooming should be done. If this argument is null,
		 *  the stage will be used.
		 */
		public function PanZoomControl(camera:DisplayObject,
			hitArea:InteractiveObject=null):void
		{
			_cam = camera; if (_cam == null) return;
			_hit = hitArea;			
			_cam.addEventListener(Event.ADDED_TO_STAGE, onAdd);
			_cam.addEventListener(Event.REMOVED_FROM_STAGE, onRemove);
			if (_cam.stage != null) onAdd();
		}
		
		private function onAdd(evt:Event=null):void
		{
			_stage = _cam.stage;
			if (_hit == null) _hit = _stage;
			_hit.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			_hit.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
		}
		
		private function onRemove(evt:Event=null):void
		{
			_hit.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			_hit.removeEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
		}
		
		/**
		 * Detach this control, removing all event listeners and clearing
		 * all internal state.
		 */
		public function detach():void
		{
			onRemove();
			_cam.removeEventListener(Event.ADDED_TO_STAGE, onAdd);
			_cam.removeEventListener(Event.REMOVED_FROM_STAGE, onRemove);
			_hit = null;
			_cam = null;
		}
		
		private function onMouseDown(event:MouseEvent) : void
		{
			if (_stage == null) return;
			_stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			_stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			
			px = mx = event.stageX;
			py = my = event.stageY;
			_drag = true;
		}
			
		private function onMouseMove(event:MouseEvent) : void
		{
			if (!_drag) return;
			
			var x:Number = event.stageX;
			var y:Number = event.stageY;
			
			if (!event.ctrlKey) {
				Transforms.panBy(_cam, x-mx, y-my);
			} else {
				var dz:Number = 1 + (y-my)/100;
				Transforms.zoomBy(_cam, dz, px, py);
			}
			mx = x;
			my = y;
		}
		
		private function onMouseUp(event:MouseEvent) : void
		{
			_drag = false;
			_stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			_stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		}
		
		private function onMouseWheel(event:MouseEvent) : void
		{
			var dw:Number = 1.1 * event.delta;
			var dz:Number = dw < 0 ? 1/Math.abs(dw) : dw;
			Transforms.zoomBy(_cam, dz);
		}
		
	} // end of class PanZoomControl
}