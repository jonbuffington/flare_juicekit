package flare.vis.util
{
	import flare.query.Expression;
	import flare.util.Property;
	import flare.vis.axis.AxisGridLine;
	import flare.vis.axis.AxisLabel;
	import flare.vis.data.DataSprite;
	import flare.vis.data.EdgeSprite;
	import flare.vis.data.NodeSprite;
	
	import flash.display.DisplayObject;
	
	/**
	 * Utility class providing a default set of filtering functions. Each
	 * filtering function returns a boolean value indicating if the input
	 * argument meets the filtering criterion.
	 */
	public class Filters
	{
		/**
		 * Constructor, throws an error if called, as this is an abstract class.
		 */
		public function Filters()
		{
			throw new Error("This is an abstract class.");
		}
		
		// -- Convenience Functions -------------------------------------------
		
		/**
		 * Convenience method that returns a filter function determined by the
		 * input object. If the input is null or of type function, it is simply
		 * returned. If the input is of type <code>Expression</code>, its
		 * predicate function is returned. In any other case, an error is
		 * thrown.
		 * @param f the input object providing a filter
		 * @return the filter function
		 */
		public static function instance(f:*):Function
		{
			if (f==null || f is Function) {
				return f;
			} else if (f is Expression) {
				return Expression(f).predicate;
			} else if (f is String) {
				return Property.$(f).getValue;
			} else {
				throw new ArgumentError("Unrecognized filter type");
			}
		}
		
		// -- Static Filters --------------------------------------------------
		
		/**
		 * Returns true if the input argument is a <code>DisplayObject</code>
		 * and is visible.
		 * @param x the input value
		 * @return true if the input is a <code>DataSprite</code>
		 */
		public static function isVisible(x:Object):Boolean
		{
			return x is DisplayObject && DisplayObject(x).visible;
		}
		
		/**
		 * Returns true if the input argument is a <code>DataSprite</code>,
		 * false otherwise.
		 * @param x the input value
		 * @return true if the input is a <code>DataSprite</code>
		 */
		public static function isDataSprite(x:Object):Boolean
		{
			return x is DataSprite;
		}
		
		/**
		 * Returns true if the input argument is a <code>NodeSprite</code>,
		 * false otherwise.
		 * @param x the input value
		 * @return true if the input is a <code>NodeSprite</code>
		 */
		public static function isNodeSprite(x:Object):Boolean
		{
			return x is NodeSprite;
		}
		
		/**
		 * Returns true if the input argument is an <code>EdgeSprite</code>,
		 * false otherwise.
		 * @param x the input value
		 * @return true if the input is an <code>EdgeSprite</code>
		 */
		public static function isEdgeSprite(x:Object):Boolean
		{
			return x is EdgeSprite;
		}
		
		/**
		 * Returns true if the input argument is an <code>AxisLabel</code>,
		 * false otherwise.
		 * @param x the input value
		 * @return true if the input is a <code>AxisLabel</code>
		 */
		public static function isAxisLabel(x:Object):Boolean
		{
			return x is AxisLabel;
		}
		
		/**
		 * Returns true if the input argument is an <code>AxisGridLine</code>,
		 * false otherwise.
		 * @param x the input value
		 * @return true if the input is an <code>AxisGridLine</code>
		 */
		public static function isAxisGridLine(x:Object):Boolean
		{
			return x is AxisGridLine;
		}
		
	} // end of class Filters
}