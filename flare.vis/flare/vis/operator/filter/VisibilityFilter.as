package flare.vis.operator.filter
{
	import flare.vis.operator.Operator;
	import flare.animate.Transitioner;
	import flare.vis.data.Data;
	import flare.vis.data.DataSprite;

	/**
	 * Filter operator that sets item visibility based on a filtering
	 * condition. Filtering conditions are specified using Boolean-valued
	 * predicate functions that return true if the item meets the filtering
	 * criteria and false if it does not. For items which meet the criteria,
	 * this class sets the <code>visibility</code> property to true and
	 * the <code>alpha</code> value to 1. For those items that do not meet
	 * the criteria, this class sets the <code>visibility</code> property to
	 * false and the <code>alpha</code> value to 0.
	 * 
	 * <p>Predicate functions can either be arbitrary functions that take
	 * a single argument and return a Boolean value, or can be systematically
	 * constructed using the <code>Expression</code> language provided by the
	 * <code>flare.query</code> package.</p>
	 * 
	 * @see flare.query
	 */
	public class VisibilityFilter extends Operator
	{
		/** Predicate function for filtering items. */
		public var predicate:Function;
		/** Flag indicating which data group (NODES, EDGES, or ALL) should
		 *  be processed by this filter. */
		public var which:int;
		
		/**
		 * Creates a new VisibilityFilter.
		 * @param predicate the predicate function for filtering items. This
		 *  should be a Boolean-valued function that returns true for items
		 *  that pass the filtering criteria and false for those that do not.
		 * @param which flag indicating which data group (NODES, EDGES, or ALL)
		 *  should be processed by this filter.
		 */
		public function VisibilityFilter(predicate:Function,
										 which:int=1/*Data.NODES*/)
		{
			this.predicate = predicate;
			this.which = which;
		}

		/** @inheritDoc */
		public override function operate(t:Transitioner=null):void
		{
			t = (t==null ? Transitioner.DEFAULT : t);
			
			visualization.data.visit(function(d:DataSprite):Boolean {
				var visible:Boolean = predicate(d);
				t.$(d).alpha = visible ? 1 : 0;
				t.$(d).visible = visible;
				return true;
			}, which);
		}
		
	} // end of class VisibilityFilter
}