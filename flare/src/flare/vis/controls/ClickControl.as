package flare.vis.controls
{
	import flare.vis.events.SelectionEvent;
	
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	[Event(name="select", type="flare.vis.events.SelectionEvent")]
	
	/**
	 * Interactive control for responding to mouse clicks events. Select event
	 * listeners can be added to respond to the mouse clicks. This control
	 * also allows the number of mouse-clicks (single, double, triple, etc) and
	 * maximum delay time between clicks to be configured.
	 * @see flare.vis.events.SelectionEvent
	 */
	public class ClickControl extends Control
	{
		private var _timer:Timer;
		private var _cur:DisplayObject;
		private var _clicks:uint = 0;
		
		/** The number of clicks needed to trigger a click event. Setting this
		 *  value to zero effectively disables the click control. */
		public var numClicks:uint;
		
		/** The maximum allowed delay (in milliseconds) between clicks. */
		public function get clickDelay():Number { return _timer.delay; }
		public function set clickDelay(d:Number):void { _timer.delay = d; }
		
		// --------------------------------------------------------------------
		
		/**
		 * Creates a new ClickControl.
		 * @param filter a Boolean-valued filter function indicating which
		 *  items should trigger hover processing
		 * @param numClicks the number of clicks
		 * @param onClick an optional SelectionEvent listener for click events
		 */
		public function ClickControl(filter:*=null, numClicks:uint=1,
			onClick:Function=null)
		{
			this.filter = filter;
			this.numClicks = numClicks;
			_timer = new Timer(300);
			_timer.addEventListener(TimerEvent.TIMER, reset);
			if (onClick != null)
				addEventListener(SelectionEvent.SELECT, onClick);
		}
		
		/** @inheritDoc */
		public override function attach(obj:InteractiveObject):void
		{
			super.attach(obj);
			if (obj != null) {
				obj.addEventListener(MouseEvent.CLICK, onClick);
			}
		}
		
		/** @inheritDoc */
		public override function detach():InteractiveObject
		{
			if (_object != null) {
				_object.removeEventListener(MouseEvent.CLICK, onClick);
			}
			return super.detach();
		}
		
		private function onClick(evt:MouseEvent):void
		{
			_timer.stop();
			
			var n:DisplayObject = evt.target as DisplayObject;
			if (n==null || (_filter!=null && !_filter(n))) {
				_cur = null;
				reset();
				return;
			} else if (_cur != n) {
				_clicks = 1;
				_cur = n;
			} else {
				_clicks++;
			}
			
			_timer.start();
		}
		
		private function reset(evt:Event=null):void
		{
			if (_clicks == numClicks && _cur) {
				if (hasEventListener(SelectionEvent.SELECT)) {
					dispatchEvent(
						new SelectionEvent(SelectionEvent.SELECT, _cur));
				}
			}
			_timer.stop();
			_cur = null;
			_clicks = 0;
		}
		
	} // end of class ClickControl
}