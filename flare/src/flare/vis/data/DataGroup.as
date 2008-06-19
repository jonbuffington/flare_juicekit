package flare.vis.data
{
	import flash.utils.Proxy;

	/**
	 * A data list for managing a subset of nodes or edges. Data group
	 * instances are used to manage a collection of instances that can
	 * be addressed and processed by operators using a given group name.
	 * @see flare.vis.Visualization#groups
	 * @see flare.vis.data.DataGroups
	 */
	public class DataGroup extends DataList
	{	
		/**
		 * Add an object to the group.
		 * @param o the object to add
		 * @return the added object
		 */
		public function add(o:Object):Object
		{
			return super._add(o);
		}
		
		/**
		 * Remove an object from the group.
		 * @param ds the DataSprite to remove
		 * @return true if the object was found and removed, false otherwise
		 */
		public function remove(o:Object):Boolean
		{
			return super._remove(o);
		}
		
		/**
		 * Remove an object from the group.
		 * @param idx the index of the object to remove
		 * @return the removed object
		 */
		public function removeAt(idx:int):Object
		{
			return super._removeAt(idx);
		}
		
		/**
		 * Remove all objects from this group.
		 */
		public function clear():void
		{
			super._clear();
		}
		
	} // end of class DataGroup
}