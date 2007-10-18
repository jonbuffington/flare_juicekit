package flare.util
{
	import flash.display.DisplayObjectContainer;
		
	/**
	 * Utility methods for sorting and creating sorting functions.
	 */
	public class Sort
	{
		/**
		 * Constructor, throws an error if called, as this is an abstract class.
		 */
		public function Sort() {
			throw new Error("This is an abstract class.");
		}
		
		/**
		 * Sorts the input array using an optional comparator function. This
		 * method attempts to use optimized sorting routines based on the
		 * choice of comparators.
		 * @param list the array to sort
		 * @param cmp an optional comparator Function or comparison
		 *  specification. A specification is an array containing a set of data
		 *  field names to sort on, in priority order. In addition, an optional
		 *  boolean argument can follow each name, indicating whether sorting
		 *  on the preceding field should be done in ascending (true) or
		 *  descending (false) order.
		 */
		public static function sort(list:Array, cmp:*=null):void
		{
			mergeSort(list, getComparator(cmp), 0, list.length-1);
		}
		
		/**
		 * Sorts the children of the given DisplayObjectContainer using
		 * an optional comparator function.
		 * @param d a display object container to sort. The sort may change the
		 *  rendering order in which the contained display objects are drawn.
		 * @param cmp an optional comparator Function or comparison
		 *  specification. A specification is an array containing a set of data
		 *  field names to sort on, in priority order. In addition, an optional
		 *  boolean argument can follow each name, indicating whether sorting
		 *  on the preceding field should be done in ascending (true) or
		 *  descending (false) order.
		 */
		public static function sortChildren(
			d:DisplayObjectContainer, cmp:*=null):void
		{
			if (d==null) return;
			var a:Array = new Array(d.numChildren);
			for (var i:int=0; i<a.length; ++i) {
				a[i] = d.getChildAt(i);
			}
			if (cmp==null) a.sort() else a.sort(getComparator(cmp));
			for (i=0; i<a.length; ++i) {
				d.setChildIndex(a[i], i);
			}
		}
		
		private static function getComparator(cmp:*):Function
		{
			var c:Function;
			if (cmp is Function) {
				c = cmp as Function;
			} else if (cmp is Array) {
				c = sorter(cmp as Array);
			} else if (cmp == null) {
				c = function(a:*, b:*):int { return a<b ? -1 : a>b ? 1 : 0; }
			} else {
				throw new ArgumentError("Unknown parameter type: "+cmp);	
			}
			return c;
		}
		
		/**
		 * Creates a set of sorting functions using the specification given
		 * in the input array. The resulting sorting functions can be used
		 * to sort objects based on their properties.
		 * @param a An array containing a set of data field
		 * names to sort on, in priority order. In addition, an optional boolean
		 * argument can follow each name, indicating whether sorting on the
		 * preceding field should be done in ascending (true) or descending
		 * (false) order.
		 * @return a comparison function for use in sorting objects.
		 */
		public static function sorter(a:Array):Function
		{
			if (a.length < 1) {
				throw new ArgumentError("Bad input.");	
			} else if (a.length == 1) {
				return sortOn(a[0], true);
			} else if (a.length == 2 && a[1] is Boolean) {
				return sortOn(a[0], a[1]);
			} else {
				var sorts:Array = new Array();
				var field:String, asc:Boolean;
				for (var i:uint=0; i<a.length; ++i) {
					field = a[i];
					asc = a[i+1] is Boolean ? a[++i] : true;
					sorts.push(sortOn(field, asc));
				}
				return multisort(sorts);
			}
		}
		
		/**
		 * Given an array of comparison functions, returns a combined
		 * chain of comparison functions. If a comparison results in
		 * a tie (i.e., the function returns 0), the next comparison
		 * function in the array will be used.
		 * @param f an array of comparison functions
		 * @return a combined comparison function
		 */
		public static function multisort(f:Array):Function
		{
			return function(a:Object, b:Object):int {
				var c:int;
				for (var i:uint=0; i<f.length; ++i) {
					if ((c = f[i](a, b)) != 0) return c;
				}
				return 0;
			}
		}
		
		/**
		 * Given a property name and an ascending/descending flag,
		 * returns a comparison function for sorting objects.
		 * @param field the property name. This can be nested (e.g., "a.b.c").
		 * @param asc true for an ascending sort order, false for descending.
		 * @return a comparison function for objects
		 */
		public static function sortOn(field:String, asc:Boolean):Function
		{
			var p:Property = Property.$(field);
			return function(a:Object, b:Object):int {
				var da:* = p.getValue(a);
				var db:* = p.getValue(b);
				return (asc?1:-1)*(da > db ? 1 : da < db ? -1 : 0);
			}
		}

		// --------------------------------------------------------------------

		private static const SORT_THRESHOLD:int = 16;

		private static function insertionSort(a:Array, cmp:Function, p:int, r:int):void
		{
			var i:int, j:int, key:Object;
	        for (j = p+1; j<=r; ++j) {
	        	key = a[j];
	            i = j - 1;
	            while (i >= p && cmp(a[i], key) > 0) {
	                a[i+1] = a[i];
	                i--;
	            }
	            a[i+1] = key;
	        }
    	}
    	
    	private static function mergeSort(a:Array, cmp:Function, p:int, r:int):void
    	{
	        if (p >= r) {
	            return;
	        }
	        if (r-p+1 < SORT_THRESHOLD) {
	            insertionSort(a, cmp, p, r);
	        } else {
	            var q:int = (p+r)/2;
	            mergeSort(a, cmp, p, q);
	            mergeSort(a, cmp, q+1, r);
	            merge(a, cmp, p, q, r);
	        }
    	}

	    private static function merge(a:Array, cmp:Function, p:int, q:int, r:int):void
	    {
	    	var t:Array = new Array(r-p+1);
	    	var i:int, p1:int = p, p2:int = q+1;
	    	
	        for (i=0; p1<=q && p2<=r; ++i)
	        	t[i] = cmp(a[p2], a[p1]) > 0 ? a[p1++] : a[p2++];
	        for (; p1<=q; ++p1, ++i)
	            t[i] = a[p1];
	        for (; p2<=r; ++p2, ++i)
	            t[i] = a[p2];
	        for (i=0, p1=p; i<t.length; ++i, ++p1)
	            a[p1] = t[i];
	    }

	} // end of class Sort
}