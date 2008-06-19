package flare.vis.data
{
	import flash.utils.flash_proxy;
	import flash.utils.Proxy;

	/**
	 * Manages DataGroup instances associated with a Data instance.
	 */
	public dynamic class DataGroups extends Proxy
	{
		private var _map:Object = {};
		private var _data:Data;
		
		/**
		 * Creates a new DataGroups instance. 
		 * @param data the associated Data instance
		 */
		public function DataGroups(data:Data) {
			_data = data;
			_map.nodes = _data.nodes;
			_map.edges = _data.edges;
		}
		
		/**
		 * Adds a new data group. If a group of the same name already exists,
		 * it will be replaced, except for the groups "nodes" and "edges",
		 * which can not be replaced. 
		 * @param name the name of the group to add
		 * @param group the data group instance to add, if null a new,
		 *  empty <code>DataGroup</code> instance will be created.
		 * @return the added data group
		 */
		public function add(name:String, group:DataGroup=null):DataGroup
		{
			if (name=="nodes" || name=="edges") {
				throw new ArgumentError("Illegal group name. "
					+ "\"nodes\" and \"edges\" are reserved names.");
			}
			if (group==null) group = new DataGroup();
			_map[name] = group;
			return group;
		}
		
		/**
		 * Removes a new data group. An error will be thrown if the caller
		 * attempts to remove the groups "nodes" or "edges". 
		 * @param name the name of the group to remove
		 * @return the removed data group
		 */
		public function remove(name:String):DataGroup
		{
			if (name=="nodes" || name=="edges") {
				throw new ArgumentError("Illegal group name. "
					+ "\"nodes\" and \"edges\" are reserved names.");
			}
			var group:DataGroup = _map[name];
			if (group) delete _map[name];
			return group;
		}
		
		// -- Proxy Methods ---------------------------------------------------
		
		/** @private */
		flash_proxy override function getProperty(name:*):*
		{
        	return _map[name];
    	}
		
	} // end of class DataGroups
}