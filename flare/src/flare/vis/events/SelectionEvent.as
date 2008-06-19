package flare.vis.events
{
	import flare.vis.data.EdgeSprite;
	import flare.vis.data.NodeSprite;
	
	import flash.display.DisplayObject;
	import flash.events.Event;

	/**
	 * Event fired in response to interactive selection events. 
	 */
	public class SelectionEvent extends Event
	{
		/** An interface selection event. */
		public static const SELECT:String   = "select";
		/** An interface deselection event. */
		public static const DESELECT:String = "deselect";
		
		private var _object:DisplayObject;
		
		/** The affected interface object. */
		public function get object():DisplayObject { return _object; }
		/** The affected interface object, cast to a NodeSprite. */
		public function get node():NodeSprite { return _object as NodeSprite; }
		/** The affected interface object, cast to an EdgeSprite. */
		public function get edge():EdgeSprite { return _object as EdgeSprite; }
		
		/**
		 * Creates a new SelectionEvent.
		 * @param type the event type (SELECT or DESELECT)
		 * @param item the DisplayObject that was selected or deselected
		 */
		public function SelectionEvent(type:String, object:DisplayObject)
		{
			super(type);
			_object = object;
		}
		
		/** @inheritDoc */
		public override function clone():Event
		{
			return new SelectionEvent(type, _object);
		}
		
	} // end of class SelectionEvent
}