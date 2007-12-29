package flare.query
{	
	/**
	 * Base class for query expression operators. Expressions are organized
	 * into a tree of operators that perform data processing or predicate
	 * testing on input <code>Object</code> instances.
	 */
	public class Expression {
		
		/**
		 * Evaluates this expression with the given input object.
		 * @param o the input object to this expression
		 * @return the result of evaluating the expression
		 */
		public function eval(o:Object=null):Object
		{
			return o;
		}
		
		/**
		 * Boolean predicate that tests the output of evaluating this
		 * expression. Returns true if the expression evaluates to true, or
		 * a non-null or non-zero value. Returns false if the expression
		 * evaluates to false, or a null or zero value.
		 * @param o the input object to this expression
		 * @return the Boolean result of evaluating the expression
		 */
		public function predicate(o:Object):Boolean
		{
			return Boolean(eval(o));
		}
		
		/**
		 * The number of sub-expressions that are children of this expression.
		 * @return the number of child expressions.
		 */
		public function get numChildren():int
		{
			return 0;
		}
		
		/**
		 * Returns the sub-expression at the given index.
		 * @param idx the index of the child sub-expression
		 * @return the requested sub-expression.
		 */
		public function getChildAt(idx:int):Expression
		{
			return null;
		}
		
		/**
		 * Set the sub-expression at the given index.
		 * @param idx the index of the child sub-expression
		 * @param expr the sub-expression to set
		 * @return true if the the sub-expression was successfully set,
		 *  false otherwise
		 */
		public function setChildAt(idx:int, expr:Expression):Boolean
		{
			return false;
		}
		
		/**
		 * Returns a string representation of the expression.
		 * @return this expression as a string value
		 */
		public function toString():String
		{
			return null;
		}
		
		/**
		 * Creates a cloned copy of the expression. Recursively clones any
		 * sub-expressions.
		 * @return the cloned expression.
		 */
		public function clone():Expression
		{
			throw new Error("This is an abstract method");
		}
		
		/**
		 * Sequentially invokes the input function on this expression and all
		 * sub-expressions. Complete either when all expressions have been
		 * visited or the input function returns false, thereby signalling an
		 * early exit.
		 * @param f the visiting function to invoke on this expression
		 * @return true if all sub-expressions were visited, false if the
		 *  input function signalled an early exit
		 */
		public function visit(f:Function):Boolean
		{
			var iter:ExpressionIterator = new ExpressionIterator(this);
			return visitHelper(iter, f);
		}
		
		private function visitHelper(iter:ExpressionIterator, f:Function):Boolean
		{
			if (!f(iter.current)) return false;
			if (iter.down() != null)
			{
				do {
					if (!visitHelper(iter, f)) return false
				} while (iter.next() != null);
				iter.up();	
			}
			return true;
		}
		
		// --------------------------------------------------------------------
		
		private static const _LBRACKET:Number = "[".charCodeAt(0);
		private static const _RBRACKET:Number = "]".charCodeAt(0);
		
		/**
		 * Utility method that maps an input value into an Expression. If the
		 * input value is already an Expression, it is simply returned. If the
		 * input value is a String with square brackets for the first ("[") and
		 * last ("]") characters, the characters between the brackets are used
		 * as the property name of a new Variable. In all other cases, a new
		 * Literal expression for the input value is returned.
		 * @param o the input value
		 * @return an Expression corresponding to the input value
		 */
		public static function expr(o:*):Expression
		{
			if (o is Expression) {
				return o as Expression;
			} else if (o is String) {
				var s:String = o as String;
				if (s.charCodeAt(0) == _LBRACKET &&
					s.charCodeAt(s.length-1) == _RBRACKET)
				{
					return new Variable(s.substr(1, s.length-2));
				}
			}
			return new Literal(o);
		}
		
	} // end of class Expression
}