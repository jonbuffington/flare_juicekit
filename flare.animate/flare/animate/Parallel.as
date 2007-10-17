package flare.animate
{
	import flare.util.Arrays;
	
	/**
	 * Transition that runs multiple transitions simultaneously (in parallel).
	 * The delay settings for sub-transitions are ignored, and the total 
	 * duration determined for this parallel transition can potentially
	 * override sub-transition's duration settings.
	 * 
	 * <p>The exception to these rules is when a parallel transition is in
	 * <code>launchOnly</code> mode, in which case this transition launches
	 * each sub-transition independently with the <code>Scheduler</code>,
	 * rather than overseeing the entire duration of the transition. When in
	 * <code>launchOnly</code> mode, calling the <code>pause</code> or
	 * <code>stop</code> methods will result in an error being thrown.</p>
	 */
	public class Parallel extends Transition
	{
		// -- Properties ------------------------------------------------------
		
		/** Array of parallel transitions */
		protected var _trans:/*Transition*/Array = new Array();
		
		private var _launch:Boolean = false;
		private var _autodur:Boolean = true;
		
		/** Launch only mode causes sub-transitions to be independently
		 *  launched with the <code>Scheduler</code>, rather than managed by
		 *  this class throughout the transition. */
		public function get launchOnly():Boolean { return _launch; }
		public function set launchOnly(b:Boolean):void
		{
			_launch = b;
		}

		/**
		 * If true, the duration of this sequence is automatically determined
		 * by the longest sub-transition transition. This is the default
		 * behavior.
		 */
		public function get autoDuration():Boolean { return _autodur; }
		public function set autoDuration(b:Boolean):void {
			_autodur = b;
			computeDuration();
		}
		
		/**
		 * Sets the total duration for the sequence. The durations of
		 * sub-transitions will be automatically scaled to match the
		 * new duration. When this happens, the <code>autoDuration</code>
		 * property will be set to true.
		 */
		public override function set duration(dur:Number):void {
			_autodur = false;
			super.duration = dur;
		}
		
		// -- Methods ---------------------------------------------------------
		
		/**
		 * Creates a new Parallel transition.
		 * @param transitions a list of sub-transitions
		 */
		public function Parallel(...transitions) {
			easing = Easing.none;
			for each (var t:Transition in transitions) {
				_trans.push(t);
			}
			computeDuration();
		}
		
		/**
		 * Adds a new sub-transition to this parallel transition.
		 * @param t the transition to add
		 */
		public function add(t:Transition):void {
			if (running) throw new Error("Transition is running!");
			_trans.push(t);
			computeDuration();
		}
		
		/**
		 * Removes a sub-transition from this parallel transition.
		 * @param t the transition to remove
		 * @return true if the transition was found and removed, false
		 *  otherwise
		 */
		public function remove(t:Transition):Boolean {
			if (running) throw new Error("Transition is running!");
			var rem:Boolean = Arrays.remove(_trans, t) >= 0;
			if (rem) computeDuration();
			return rem;
		}
		
		/**
		 * Computes the duration of this parallel transition.
		 */
		protected function computeDuration():void {
			var d:Number = 0;
			for each (var t:Transition in _trans) {
				if (t.duration > d) {
					d = t.duration + (_launch? t.delay : 0);
				}
			}
			duration = d;
		}
		
		/** @inheritDoc */
		public override function dispose():void {
			while (_trans.length > 0) { _trans.pop().dispose(); }
		}
		
		// -- Transition Handlers ---------------------------------------------
		
		/**
		 * Starts running the transition. If the <code>launchOnly</code>
		 * property is true, each sub-transition is launched indepdently.
		 * Otherwise, this parallel instance oversees the entire transition.
		 * @param reverse if true, the transition is played in reverse,
		 *  if false (the default), it is played normally.
		 */
		public override function play(reverse:Boolean = false):void
		{
			if (_launch) {
				for each (var t:Transition in _trans)
					t.play(reverse);
			} else {
				super.play(reverse);
			}
		}
		
		/**
		 * Stops the transition and completes it.
		 * Any end-of-transition actions will still be taken.
		 * Calling play() after stop() will result in the transition
		 * starting over from the beginning.
		 * 
		 * <p>This method only applies if <code>launchOnly</code> is false.
		 * Otherwise, this method will throw an error.</p>
		 */
		public override function stop():void
		{
			if (_launch) throw new Error("Can't stop when in launchOnly mode.");
			super.stop();
		}
		
		/**
		 * Pauses the transition at its current position.
		 * Calling play() after pause() will resume the transition.
		 * 
		 * <p>This method only applies if <code>launchOnly</code> is false.
		 * Otherwise, this method will throw an error.</p>
		 */
		public override function pause():void
		{
			if (_launch) throw new Error("Can't pause when in launchOnly mode.");
			super.pause();
		}
		
		/**
		 * Sets up each sub-transition.
		 */
		protected override function setup():void
		{
			for each (var t:Transition in _trans) { t.doSetup(); }
		}
		
		/**
		 * Starts each sub-transition.
		 */
		protected override function start():void
		{
			for each (var t:Transition in _trans) { t.doStart(_reverse); }
		}
		
		/**
		 * Steps each sub-transition.
		 * @param ef the current progress fraction.
		 */
		internal override function step(ef:Number):void
		{
			for each (var t:Transition in _trans) { t.doStep(ef); }
		}
		
		/**
		 * Ends each sub-transition.
		 */
		protected override function end():void
		{
			for each (var t:Transition in _trans) { t.doEnd(); }
		}
		
	} // end of class Parallel
}