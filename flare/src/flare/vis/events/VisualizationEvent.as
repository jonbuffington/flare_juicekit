package flare.vis.events
{
	import flare.animate.Transitioner;
	
	import flash.events.Event;

	/**
	 * Event fired in response to visualization updates.
	 */
	public class VisualizationEvent extends Event
	{
		/** A visualization update event. */
		public static const UPDATE:String = "update";
		
		private var _trans:Transitioner;
		private var _param:String;
		
		/** Transitioner used in the visualization update. */
		public function get transitioner():Transitioner { return _trans; }
		
		/** Parameter provided to the visualization update. If not null,
		 *  this string indicates the named operator that was run. */
		public function get param():String { return _param; }
		
		/**
		 * Creates a new VisualizationEvent.
		 * @param type the event type
		 * @param trans the Transitioner used in the visualization update
		 */		
		public function VisualizationEvent(type:String,
			trans:Transitioner=null, param:String=null)
		{
			super(type);
			_param = param;
			_trans = trans==null ? Transitioner.DEFAULT : trans;
		}
		
	} // end of class VisualizationEvent
}