package flare.query
{
	import flare.util.Sort;
	import flare.util.Property;
	
	/**
	 * Performs query processing over a collection of ActionScript objects.
	 */
	public class Query
	{
		private var _select:Array;
		private var _orderby:Array;
		private var _groupby:Array;
		private var _where:Expression;
		
		private var _sorter:Function;
		private var _aggrs:Array;
		
		/**
		 * Creates a new Query.
		 * @param select an array of select clauses. Each array element should
		 *  be an object with a String-valued <code>name</code> property (the
		 *  name of the selection property in the query results) and an
		 *  Expression-valued <code>expression</code> property. Expressions can
		 *  be any legal expression, including aggregate operators.
		 * @param where a where expression for filtering an object collection
		 * @param orderby directives for sorting query results, using the
		 *  format of the <code>flare.util.Sort</code> class methods.
		 * @param orderby directives for grouping query results, using the
		 *  format of the <code>flare.util.Sort</code> class methods.
		 * @see flare.util.Sort
		 */
		public function Query(select:Array, where:Expression,
							  orderby:Array=null, groupby:Array=null)
		{
			_select = select;
			_where = where;
			_orderby = orderby;
			_groupby = groupby;
			_sorter = sorter();
			_aggrs = aggregates();
		}
		
		private function sorter():Function
		{
			var s:Array = [], i:int;
			if (_groupby != null) {
				for (i=0; i<_groupby.length; ++i)
					s.push(_groupby[i]);
			}
			if (_orderby != null) {
				for (i=0; i<_orderby.length; ++i)
					s.push(_orderby[i]);
			}
			return s.length==0 ? null : Sort.sorter(s);
		}
		
		private function aggregates():Array
		{
			var aggrs:Array = [];
			for each (var pair:Object in _select) {
				var expr:Expression = pair.expression;
				expr.visit(function(e:Expression):Boolean {
					if (e is AggregateExpression)
						aggrs.push(e);
					return true;
				});
			}
			return aggrs.length==0 ? null : aggrs;
		}
		
		// -- query processing ------------------------------------------------
		
		/**
		 * Evaluates this query on an object collection. The input argument can
		 * either be an array of objects or a visitor function that takes 
		 * another function as input and applies it to all items in a
		 * collection.
		 * @param input either an array of objects of a visitor function
		 * @return an array of processed query results
		 */
		public function evaluate(input:*):Array
		{
			// TODO -- evaluate any sub-queries in WHERE clause
			var results:Array = [];
			var visitor:Function;
			if (input is Array) {
				visitor = (input as Array).forEach;
			} else if (input is Function) {
				visitor = input as Function;
			} else {
				throw new ArgumentError("Illegal input argument: "+input);
			}
			
			// filter
			if (_where != null) {
				visitor(function(item:Object, ...rest):void {
					if (_where.predicate(item)) {
						results.push(item);
					}
				});
			}
			// sort the result set
			if (_sorter != null) {
				Sort.sort(results, _sorter);
			}
			
			if (_select == null) return results;
			if (_aggrs == null && _groupby==null) return project(results);
			return group(results);
		}
		
		/**
		 * Performs a projection of query results, removing any properties
		 * not specified by the select clause.
		 * @param results the filtered query results array
		 * @return query results array of projected objects
		 */
		protected function project(results:Array):Array
		{			
			for (var i:int=0; i<results.length; ++i) {
				var item:Object = {};
				for each (var pair:Object in _select) {
					var name:String = pair.name;
					var expr:Expression = pair.expression;
					item[name] = expr.eval(results[i]);
				}
				results[i] = item;
			}
			return results;
		}
		
		// -- group-by and aggregation ----------------------------------------
		
		/**
		 * Performs grouping and aggregation of query results.
		 * @param items the filtered query results array
		 * @return aggregated query results array
		 */
		protected function group(items:Array):Array
		{
			var i:int, item:Object;
			var results:Array = [], props:Array = [];
			
			// get group-by properties as key
			if (_groupby != null) {
				for (i=_groupby.length; --i>=0;) {
					if (_groupby[i] is String) {
						props.push(Property.$(_groupby[i]));
					}
				}
			}
			
			// process all groups
			reset(_aggrs);
			for (i=1, item=items[0]; i<=items.length; ++i) {
				// update the aggregate functions
				for each (var aggr:AggregateExpression in _aggrs) {
					aggr.aggregate(item);
				}
				// handle change of group
				if (i==items.length || !sameGroup(props, item, items[i])) {
					results.push(endGroup(item));
					item = items[i];
					reset(_aggrs);
				}
			}
			
			return results;
		}
		
		private function reset(aggrs:Array):void
		{
			for each (var aggr:AggregateExpression in aggrs) {
				aggr.reset();
			}
		}
		
		private function endGroup(item:Object):Object
		{
			var result:Object = {};
			for each (var pair:Object in _select) {
				var name:String = pair.name;
				var expr:Expression = pair.expression;
				result[name] = expr.eval(item);
			}
			return result;
		}
		
		private static function sameGroup(props:Array, x:Object, y:Object):Boolean
		{
			var a:*, b:*;
			for each (var p:Property in props) {
				a = p.getValue(x);
				b = p.getValue(y);
				
				if (a is Date && b is Date) {
					if ((a as Date).time != (b as Date).time)
						return false;
				} else if (a != b) {
					return false;
				}
			}
			return true;
		}
		
	} // end of class Query
}