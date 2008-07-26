package flare.util
{
	import flash.utils.Dictionary;
	
	/**
	 * Utility class for creating filter functions. Filter functions are
	 * functions that take one argument and return a Boolean value. The input
	 * argument passes the filter if the function returns true and fails the
	 * filter if the function returns false. The static <code>$</code> method
	 * takes an arbitrary object as input and returns a corresponding filter
	 * function.
	 */
	public class Filter
	{
		/**
		 * Constructor, throws an error if called, as this is an abstract class.
		 */
		public function Filter()
		{
			throw new Error("This is an abstract class.");
		}
		
		/**
		 * Convenience method that returns a filter function determined by the
		 * input object. If the input is null or of type function, it is simply
		 * returned. If the input is of type <code>Expression</code>, its
		 * predicate function is returned. In any other case, an error is
		 * thrown.
		 * @param f the input object providing a filter
		 * @return the filter function
		 */
		public static function $(f:*):Function
		{
			if (f==null || f is Function) {
				return f;
			} else if (f is IPredicate) {
				return IPredicate(f).predicate;
			} else if (f is String) {
				return Property.$(f).predicate;
			} else if (f is Class) {
				return typeChecker(Class(f));
			} else {
				throw new ArgumentError("Unrecognized filter type");
			}
		}
		
		/**
		 * Returns a filter function that performs type-checking. 
		 * @param type the class type to check for
		 * @return a Boolean-valued type checking filter function
		 */
		public static function typeChecker(type:Class):Function
		{
			return function(o:Object):Boolean { return o is type; }
		}

	} // end of class Filter
}