package flare.vis.operator.encoder
{
	import flare.vis.operator.Operator;
	import flare.animate.Transitioner;
	import flare.vis.data.DataSprite;

	/**
	 * A property encoder simply sets a group of properties to static
	 * values for all data sprites. An input object determines which
	 * properties to set and what their values are.
	 * 
	 * For example, a PropertyEncoder created with this call:
	 * <code>new PropertyEncoder({size:1, lineColor:0xff0000ff{);</code>
	 * will set the size to 1 and the line color to blue for all
	 * data sprites processed by the encoder.
	 */
	public class PropertyEncoder extends Operator
	{
		/** Flag indicating which data group (NODES, EDGES, or ALL) should
		 *  be processed by this encoder. */
		protected var _which:int;
		/** The properties to set on each invocation. */
		protected var _props:Object;
		/** A transitioner for collecting value updates. */
		protected var _t:Transitioner;
		
		/** Flag indicating which data group (NODES, EDGES, or ALL) should
		 *  be processed by this encoder. */
		public function get which():int { return _which; }
		public function set which(w:int):void { _which = w; }
		
		/** The properties to set on each invocation. */
		public function get props():Object { return _props; }
		public function set props(o:Object):void { _props = o; }
		
		// --------------------------------------------------------------------
		
		/**
		 * Creates a new PropertyEncoder
		 * @param props The properties to set on each invocation
		 * @param which Flag indicating which data group (NODES, EDGES, or ALL)
		 *  should be processed by this encoder.
		 */		
		public function PropertyEncoder(props:Object=null, which:int=1)
		{
			_props = props==null ? {} : props;
			_which = which;
		}
		
		/** @inheritDoc */
		public override function operate(t:Transitioner=null):void
		{
			t = (t==null ? Transitioner.DEFAULT : t);
			if (_props == null) return;
			
			visualization.data.visit(function(d:DataSprite):Boolean {
				var obj:Object = t.$(d);
				for (var p:String in _props)
					obj[p] = _props[p];
				return true;
			}, _which);
		}
		
	} // end of class PropertyEncoder
}