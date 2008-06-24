package flare.vis.operator
{
	import flare.animate.Transitioner;
	import flare.vis.Visualization;
	
	import flash.utils.flash_proxy;
	import flash.utils.Proxy;

	/**
	 * An OperatorMap is a special operator that acts both as a stand-alone
	 * OperatorList and as a collection of separate, named operators. It is
	 * intended to manage a collection of operators for a visualization.
	 * @see flare.vis.Visualization#operators
	 */
	public dynamic class OperatorMap extends Proxy implements IOperator
	{
		private var _map:Object = {};
		private var _list:OperatorList = new OperatorList();
		
		/** The visualization processed by this operator. */
		public function get visualization():Visualization {
			return _list.visualization;
		}
		public function set visualization(v:Visualization):void {
			_list.visualization = v;
		}
		
		/** Indicates if the operator is enabled or disabled. */
		public function get enabled():Boolean { return _list.enabled; }
		public function set enabled(b:Boolean):void { _list.enabled = b; }
		
		/** An array of the operators contained in the operator list. */
		public function set list(ops:Array):void {
			_list.list = ops;
		}
		
		/** The number of operators in the list. */
		public function get length():uint { return _list.length; }
		
		/** Returns the first operator in the list. */
		public function get first():Object { return _list[0]; }
		/** Returns the last operator in the list. */
		public function get last():Object { return _list[_list.length-1]; }
		
		// --------------------------------------------------------------------

		/** @inheritDoc */
		public function setup():void
		{
			_list.setup();
		}
		
		/**
		 * Proxy method for retrieving operators from the internal array.
		 */
		flash_proxy override function getProperty(name:*):*
		{
			var num:Number = Number(name);
			if (isNaN(num)) {
				var op:IOperator = IOperator(_map[name]);
				if (op == null) {
					op = new OperatorList();
					op.visualization = _list.visualization;
					_map[name] = op;
				}
				return op;
			} else {
				return _list.getOperatorAt(uint(num));
			}
    	}

		/**
		 * Proxy method for setting operators in the internal array.
		 */
    	flash_proxy override function setProperty(name:*, value:*):void
    	{
        	if (value is IOperator) {
        		var num:Number = Number(name);
        		var op:IOperator = IOperator(value);
        		if (isNaN(num)) {
        			_map[name] = op;
        			op.visualization = _list.visualization;
        		} else {
        			_list.setOperatorAt(uint(num), op);
        		}
        	} else {
        		throw new ArgumentError("Input value must be an IOperator.");
        	}
    	}
		
		/**
		 * Returns the operator at the specified position in the list
		 * @param i the index into the operator list
		 * @return the requested operator
		 */
		public function getOperatorAt(i:uint):IOperator
		{
			return _list.getOperatorAt(i);
		}
		
		/**
		 * Removes the operator at the specified position in the list
		 * @param i the index into the operator list
		 * @return the removed operator
		 */
		public function removeOperatorAt(i:uint):IOperator
		{
			return _list.removeOperatorAt(i);
		}
		
		/**
		 * Set the operator at the specified position in the list
		 * @param i the index into the operator list
		 * @param op the operator to place in the list
		 * @return the operator previously at the index
		 */
		public function setOperatorAt(i:uint, op:IOperator):IOperator
		{
			return _list.setOperatorAt(i, op);
		}
		
		/**
		 * Adds an operator to the end of this list.
		 * @param op the operator to add
		 */
		public function add(op:IOperator):void
		{
			_list.add(op);
		}
		
		/**
		 * Removes an operator from this list.
		 * @param op the operator to remove
		 * @return true if the operator was found and removed, false otherwise
		 */
		public function remove(op:IOperator):Boolean
		{
			return _list.remove(op);
		}
		
		/**
		 * Removes all operators from this list.
		 */
		public function clear():void
		{
			_list.clear();
		}
		
		/** @inheritDoc */
		public function operate(t:Transitioner=null):void
		{
			_list.operate(t);
		}
		
		// -- MXML ------------------------------------------------------------
		
		/** @private */
		public function initialized(document:Object, id:String):void
		{
			// do nothing
		}
		
	} // end of class OperatorMap
}