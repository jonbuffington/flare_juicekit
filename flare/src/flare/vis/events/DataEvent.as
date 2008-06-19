package flare.vis.events
{
	import flare.vis.data.Data;
	import flare.vis.data.DataSprite;
	import flare.vis.data.EdgeSprite;
	import flare.vis.data.NodeSprite;
	
	import flash.events.Event;
	
	/**
	 * Event fired when a <code>Data</code> instance is modified.
	 */
	public class DataEvent extends Event
	{
		/** A data added event. */
		public static const DATA_ADDED:String   = "data added";
		/** A data removed event. */
		public static const DATA_REMOVED:String = "data removed";
		/** A data updated event. */
		public static const DATA_UPDATED:String = "data updated";
		
		private var _data:Data;
		private var _group:String;
		private var _item:DataSprite;
		
		/** The Data instance that was modified. */
		public function get data():Data { return _data; }
		/** The data group that was modified. */
		public function get group():String { return _group; }
		/** The DataSprite that was added/removed/updated. */
		public function get item():DataSprite { return _item; }
		/** The NodeSprite that was added/removed/updated. */
		public function get node():NodeSprite { return _item as NodeSprite; }
		/** The EdgeSprite that was added/removed/updated. */
		public function get edge():EdgeSprite { return _item as EdgeSprite; }
		
		/**
		 * Creates a new DataEvent.
		 * @param type the event type (DATA_ADDED, DATA_REMOVED, or
		 *  DATA_UPDATED)
		 * @param data the Data instance that was modified
		 * @param group the data group that was modified
		 * @param item the DataSprite that was added, removed, or updated
		 */
		public function DataEvent(type:String, data:Data,
			group:String, item:DataSprite)
		{
			super(type);
			_data = data;
			_group = group;
			_item = item;
		}
		
		/** @inheritDoc */
		public override function clone():Event
		{
			return new DataEvent(type, _data, _group, _item);
		}
		
	} // end of class DataEvent
}