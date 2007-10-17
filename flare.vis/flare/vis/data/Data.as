package flare.vis.data
{
	import flash.utils.Dictionary;
	import flash.events.EventDispatcher;
	import flare.animate.Transitioner;
	import flare.util.Arrays;
	import flare.util.Sort;
	import flare.util.Property;
	import flare.util.Stats;
	import flare.vis.events.DataEvent;
	import flare.vis.scale.Scale;
	import flare.vis.scale.Scales;
	import flare.vis.util.TreeUtil;
	
	/**
	 * Data structure for managing a collection of visual data objects. The
	 * Data class manages both unstructured data and data organized in a
	 * general graph (or network structure), maintaining collections of both
	 * nodes and edges. Default property values can be defined that are set
	 * on all new nodes or edges added to the data collection. Furthermore,
	 * the Data class supports sorting of node and edges, generation and
	 * caching of data value statistics, creation of data scales for
	 * data properties, and spanning tree calculation.
	 * 
	 * <p>While Data objects maintain a collection of visual DataSprites,
	 * they are not themselves visual object containers. Instead a Data
	 * instance is used as input to a <code>Visualization</code> that
	 * is responsible for processing the DataSprite instances and adding
	 * them to the Flash display list.</p>
	 */
	public class Data extends EventDispatcher
	{
		/** Flag indicating the nodes in a Data object. */
		public static const NODES:int = 1;
		/** Flag indicating the edges in a Data object. */
		public static const EDGES:int = 2;
		/** Flag indicating all items (nodes and edges) in a Data object. */
		public static const ALL:int = 3;
		/** Flag indicating a reverse traversal should be performed. */
		public static const REVERSE:int = 4;
		
		/** Hashed set of nodes in the data set. */
		protected var _nmap:Dictionary = new Dictionary();
		/** Hashed set of edges in the data set. */
		protected var _emap:Dictionary = new Dictionary();
		/** Array of nodes in the data set. */
		protected var _nodes:Array = new Array();
		/** Array of edges in the data set. */
		protected var _edges:Array = new Array();
		/** Default property values to be applied to new nodes. */
		protected var _ndefs:Object = null;
		/** Default property values to be applied to new edges. */
		protected var _edefs:Object = null;
		/** The default directedness of new edges. */
		protected var _directed:Boolean = false;
		
		/** Cache of Stats objects for nodes. */
		protected var _nstats:Object = new Object();
		/** Cache of Stats objects for edges. */
		protected var _estats:Object = new Object();
		
		private var _visiting:int = 0; // which visitors are running
		
		/** The total number of items (nodes and edges) in the data. */
		public function get numItems():uint { return _nodes.length + _edges.length; }
		/** The total number of nodes in the data. */
		public function get numNodes():uint { return _nodes.length; }
		/** The total number of edges in the data. */
		public function get numEdges():uint { return _edges.length; }
		
		/** The default directedness of new edges. */
		public function get directedEdges():Boolean { return _directed; }
		public function set directedEdges(b:Boolean):void { _directed = b; }
		
		
		// -- Methods ---------------------------------------------------------

		/**
		 * Creates a new Data object.
		 * @param directedEdges the default directedness of new edges
		 */
		public function Data(directedEdges:Boolean=false) {
			_directed = directedEdges;
		}

		// -- Operations ---------------------------------------
		
		/**
		 * Sort DataSprites according to their properties.
		 * <ul>
		 * <li><code>sort("val")</code> sorts nodes in ascending order
		 *     according to the field "val"</li>
		 * <li><code>sort("val1", "val2")</code> sorts nodes in ascending
		 *     order according to the fields "val1" and "val2". "val2" is only
		 *     used when data values for field "val1" are equal</li>
		 * <li><code>sort("val1", false", "val2")</code> sorts nodes in
		 *     descending order according to field "val1" and in ascending
		 *     order by field "val2" when data values for field "val1" are
		 *     equal</li>
		 * </ul>
		 * @param a the sort arguments.
		 * 	If a String is provided, the data will be sorted in ascending order
		 *   according to the data field named by the string.
		 *  If an Array is provided, the data will be sorted according to the
		 *   fields in the array. In addition, field names can optionally
		 *   be followed by a boolean value. If true, the data is sorted in
		 *   ascending order (the default). If false, the data is sorted in
		 *   descending order.
		 * @param which the data group(s) to sort (e.g., NODES or EDGES).
		 *  The default is NODES.
		 */
		public function sort(a:*, which:int=NODES):void
		{
			var args:Array;
			if (a is String) args = [a];
			else if (a is Array)  args = a;
			else throw new ArgumentError("Illegal input: "+a);
			
			var f:Function = Sort.sorter(args);
			if (which & NODES) _nodes.sort(f);
			if (which & EDGES) _edges.sort(f);
		}
		
		/**
		 * Sets a default property value for newly created nodes and/or edges.
		 * @param name the name of the property
		 * @param value the value of the property
		 * @param which the data group(s) the default applies to
		 * (e.g., NODES or EDGES). The default is NODES.
		 */
		public function setDefault(name:String, value:*, which:int=NODES):void
		{
			if (which & NODES) {
				if (_ndefs == null) _ndefs = new Object();
				_ndefs[name] = value;
			}
			if (which & EDGES) {
				if (_edefs == null) _edefs = new Object();
				_edefs[name] = value;
			}
		}
		
		/**
		 * Removes a default value for newly created nodes and/or edges.
		 * @param name the name of the property
		 * @param which the data group(s) the default applies to
		 * (e.g., NODES or EDGES). The default is NODES.
		 */
		public function removeDefault(name:String, which:int=NODES):void
		{
			if (which & NODES && _ndefs != null) {
				delete _ndefs[name];
			}
			if (which & EDGES && _edefs != null) {
				delete _edefs[name];
			}
		}
		
		/**
		 * Sets default values for newly created nodes and/or edges.
		 * @param values the default properties to set
		 * @param which the data group(s) the defaults apply to
		 * (e.g., NODES or EDGES). The default is NODES.
		 */
		public function setDefaults(values:Object, which:int=NODES):void
		{
			var name:String;
			if (which & NODES) {
				if (_ndefs == null) _ndefs = new Object();
				for (name in values) _ndefs[name] = values[name];
			}
			if (which & EDGES) {
				if (_edefs == null) _edefs = new Object();
				for (name in values) _edefs[name] = values[name];
			}
		}
		
		/**
		 * Clears all default value settings for the specified group.
		 * @param which the data group(s) for which the defaults should be
		 *  cleared (e.g., NODES or EDGES). The default is NODES.
		 */
		public function clearDefaults(which:int=NODES):void
		{
			if (which & NODES) _ndefs = null;
			if (which & EDGES) _edefs = null;
		}
		
		/**
		 * Sets a property value on all sprites in a given group.
		 * @param name the name of the property
		 * @param value the value of the property
		 * @param which the data group(s) the default applies to
		 * (e.g., NODES or EDGES). The default is NODES.
		 * @param trans an optional Transitioner for collecting value updates
		 * @return the input transitioner
		 */
		public function setProperty(name:String, value:*, which:int=NODES,
			trans:Transitioner=null):Transitioner
		{
			var t:Transitioner = (trans==null ? Transitioner.DEFAULT : trans);
			var i:uint;
			if (which & NODES) {
				for (i=0; i<_nodes.length; ++i)
					t.setValue(_nodes[i], name, value);
			}
			if (which & EDGES) {
				for (i=0; i<_edges.length; ++i)
					t.setValue(_edges[i], name, value);
			}
			return trans;
		}
		
		/**
		 * Sets property values on all sprites in a given group.
		 * @param vals an object containing the properties and values to set.
		 * @param which the data group(s) the default applies to
		 * (e.g., NODES or EDGES). The default is NODES.
		 * @param trans an optional Transitioner for collecting value updates
		 * @return the input transitioner
		 */
		public function setProperties(vals:Object, which:int=NODES,
			trans:Transitioner=null):Transitioner
		{
			var t:Transitioner = (trans==null ? Transitioner.DEFAULT : trans);
			for (var name:String in vals) {
				if (which & NODES) setProperty(name, vals[name], NODES, t);
				if (which & EDGES) setProperty(name, vals[name], EDGES, t);
			}
			return trans;
		}

		// -- Containment --------------------------------------
		
		/**
		 * Indicates if this Data object contains the input DataSprite.
		 * @param d the DataSprite to check for containment
		 * @return true if the sprite is in this data collection, false
		 *  otherwise.
		 */
		public function contains(d:DataSprite):Boolean
		{
			if (d is NodeSprite) return containsNode(d as NodeSprite);
			if (d is EdgeSprite) return containsEdge(d as EdgeSprite);
			return false;
		}
		
		/**
		 * Indicates if this Data object contains the input NodeSprite.
		 * @param n the NodeSprite to check for containment
		 * @return true if the node is in this data collection, false
		 *  otherwise.
		 */
		public function containsNode(n:NodeSprite):Boolean
		{
			return _nmap[n] != undefined;
		}
		
		/**
		 * Indicates if this Data object contains the input EdgeSprite.
		 * @param e the EdgeSprite to check for containment
		 * @return true if the edge is in this data collection, false
		 *  otherwise.
		 */
		public function containsEdge(e:EdgeSprite):Boolean
		{
			return _emap[e] != undefined;
		}
		
		// -- Access -------------------------------------------
		
		/**
		 * Retreives the node at the given position in the node list.
		 * @param idx the position in the node list
		 * @return the node at the given position
		 */
		public function getNodeAt(idx:int):NodeSprite
		{
			return _nodes[idx];
		}
		
		/**
		 * Retreives the edge at the given position in the edge list.
		 * @param idx the position in the edge list
		 * @return the node at the given position
		 */
		public function getEdgeAt(idx:int):EdgeSprite
		{
			return _edges[idx];
		}
		
		// -- Add ----------------------------------------------
		
		/**
		 * Adds a node to this data collection.
		 * @param d either a data tuple or NodeSprite object. If the input is
		 *  a non-null data tuple, this will become the new node's
		 *  <code>data</code> property. If the input is a NodeSprite, it will
		 *  be directly added to the collection.
		 * @return the newly added NodeSprite
		 */
		public function addNode(d:Object=null):NodeSprite
		{
			var ns:NodeSprite;
			if (d is NodeSprite) {
				ns = d as NodeSprite;
			} else {
				ns = newNode(d);
			}
			_nodes.push(ns);
			_nmap[ns] = _nodes.length - 1;
			fireEvent(DataEvent.DATA_ADDED, ns);
			return ns;
		}
		
		/**
		 * Add an edge to this data set. The input must be of type EdgeSprite,
		 * and must have both source and target nodes that are already in
		 * this data set. If any of these conditions are not met, this method
		 * will return null. Note that no exception will be thrown on failures.
		 * @param e the EdgeSprite to add
		 * @return the newly added EdgeSprite
		 */
		public function addEdge(e:EdgeSprite):EdgeSprite
		{
			if (containsNode(e.source) && containsNode(e.target)) {
				_edges.push(e);
				_emap[e] = _edges.length - 1;
				fireEvent(DataEvent.DATA_ADDED, e);
				return e;
			} else {
				return null;
			}
		}
		
		/**
		 * Generates edges for this data collection that connect the nodes
		 * according to the input properties. The nodes are sorted by the
		 * sort argument and grouped by the group-by argument. All nodes
		 * with the same group are sequentially connected to each other in
		 * sorted order by new edges. This method is useful for generating
		 * line charts from a plot of nodes.
		 * @param sortBy the criteria for sorting the nodes, using the format
		 *  of <code>flare.util.Sort</code>. The input can either be a string
		 *  with a single property name, or an array of property names, with
		 *  optional boolean sort order parameters (true for ascending, false
		 *  for descending) following each name.
		 * @param groupBy the criteria for grouping the nodes, using the format
		 *  of <code>flare.util.Sort</code>. The input can either be a string
		 *  with a single property name, or an array of property names, with
		 *  optional boolean sort order parameters (true for ascending, false
		 *  for descending) following each name.
		 */
		public function createEdges(sortBy:*=null, groupBy:*=null):void
		{
			// create arrays and sort criteria
			var a:Array = Arrays.copy(_nodes);
			var g:Array = groupBy is Array ? groupBy as Array : [groupBy];
			var len:int = g.length;
			if (sortBy is Array) {
				var s:Array = sortBy as Array;
				for (var i:uint=0; i<s.length; ++i)
					g.push(s[i]);
			} else {
				g.push(sortBy);
			}
			
			// sort to group by, then ordering
			a.sort(Sort.sorter(g));
			
			// get property instances for value operations
			var p:Array = new Array();
			for (i=0; i<len; ++i) {
				if (g[i] is String)
					p.push(Property.$(g[i]));
			}
			var f:Property = p[p.length-1];
			
			// connect all items who match on the last group by field
			for (i=1; i<a.length; ++i) {
				if (f.getValue(a[i-1]) == f.getValue(a[i])) {
					var e:EdgeSprite = addEdgeFor(a[i-1], a[i], _directed);
					// add data values from nodes
					for (var j:uint=0; j<p.length; ++j) {
						p[j].setValue(e, p[j].getValue(a[i]));
					}
				}
			}
		}
		
		/**
		 * Creates a new edge between the given nodes and adds it to the
		 * data collection.
		 * @param source the source node (must already be in this data set)
		 * @param target the target node (must already be in this data set)
		 * @param directed indicates the directedness of the edge (null to
		 *  use this Data's default, true for directed, false for undirected)
		 * @param data a data tuple containing data values for the edge
		 *  instance. If non-null, this will become the EdgeSprite's
		 *  <code>data</code> property.
		 * @return the newly added EdgeSprite
 		 */
		public function addEdgeFor(source:NodeSprite, target:NodeSprite,
			directed:Object=null, data:Object=null):EdgeSprite
		{
			if (!containsNode(source) || !containsNode(target)) {
				return null;
			}
			var d:Boolean = directed==null ? _directed : Boolean(directed);
			var e:EdgeSprite = newEdge(source, target, d, data);
			if (data != null) e.data = data;
			source.addOutEdge(e);
			target.addInEdge(e);
			return addEdge(e);
		}
		
		/**
		 * Internal function for creating a new node. Creates a NodeSprite,
		 * sets its data property, and applies default values.
		 * @param data the new node's data property
		 * @return the newly created node
		 */
		protected function newNode(data:Object):NodeSprite
		{
			var ns:NodeSprite = new NodeSprite();
			if (data != null) { ns.data = data; }
			applyDefaults(ns, _ndefs);
			return ns;
		}
		
		/**
		 * Internal function for creating a new edge. Creates an EdgeSprite,
		 * sets its data property, and applies default values.
		 * @param s the source node
		 * @param t the target node
		 * @param d the edge's directedness
		 * @param data the new edge's data property
		 * @return the newly created node
		 */		
		protected function newEdge(s:NodeSprite, t:NodeSprite,
								   d:Boolean, data:Object):EdgeSprite
		{
			var es:EdgeSprite = new EdgeSprite(s,t,d);
			if (data != null) { es.data = data; }
			applyDefaults(es, _edefs);
			return es;
		}
		
		/**
		 * Internal function for applying default values to a DataSprite.
		 * @param d the DataSprite on which to set the default values
		 * @param vals the set of default property values
		 */
		protected function applyDefaults(d:DataSprite, vals:Object):void
		{
			if (vals == null) return;
			for (var name:String in vals) {
				Property.$(name).setValue(d, vals[name]);
			}
		}
		
		// -- Remove -------------------------------------------
		
		/**
		 * Clears this data set, removing all nodes and edges.
		 */
		public function clear():void
		{
			// first, remove all the edges
			clearEdges();
			
			// now remove all the nodes
			var na:Array = _nodes, i:uint;
			_nodes = new Array();
			_nmap = new Dictionary();
			_nstats = new Object();
			
			for (i=0; i<na.length; ++i) {
				fireEvent(DataEvent.DATA_REMOVED, na[i], false);
			}
		}
		
		/**
		 * Removes all edges from this data set; updates all incident nodes.
		 */
		public function clearEdges():void
		{
			var ea:Array = _edges, i:uint;
			_edges = new Array();
			_emap = new Dictionary();
			_estats = new Object();
			
			for (i=0; i<ea.length; ++i) {
				fireEvent(DataEvent.DATA_REMOVED, ea[i], false);
				ea[i].source = null;
				ea[i].target = null;
			}
			for (i=0; i<_nodes.length; ++i) {
				_nodes[i].removeAllEdges();
			}
		}
		
		/**
		 * Internal method for removing a node from the node list. Removes the
		 * node in an iteration-safe fashion and fires a removal event.
		 * @param n the node to remove
		 * @return true if removed successfully, false if the node is not found
		 */
		protected function removeNodeInternal(n:NodeSprite):Boolean
		{
			if (_nmap[n] == undefined) return false;
			
			// remove from array and index map
			delete _nmap[n];
			if (_visiting & NODES) {
				// if called from a visitor, use a copy-on-write strategy
				_nodes = Arrays.copy(_nodes);	
				_visiting &= ~NODES;	
			}
			Arrays.remove(_nodes, n);
			
			// fire event and return
			fireEvent(DataEvent.DATA_REMOVED, n);
			return true;
		}
		
		/**
		 * Internal method for removing an edge from the edge list. Removes the
		 * edge in an iteration-safe fashion and fires a removal event.
		 * @param e the edge to remove
		 * @return true if removed successfully, false if the edge is not found
		 */
		protected function removeEdgeInternal(e:EdgeSprite):Boolean
		{
			if (_emap[e] == undefined) return false;
			
			// remove from array and index map
			delete _emap[e];
			if (_visiting & EDGES) {
				// if called from a visitor, use a copy-on-write strategy
				_edges = Arrays.copy(_edges);	
				_visiting &= ~EDGES;	
			}
			Arrays.remove(_edges, e);

			// fire event and return
			fireEvent(DataEvent.DATA_REMOVED, e);
			return true;
		}
		
		/**
		 * Removes a DataSprite (node or edge) from this data collection.
		 * @param d the DataSprite to remove
		 * @return true if removed successfully, false if not found
		 */
		public function remove(d:DataSprite):Boolean
		{
			if (d is NodeSprite) return removeNode(d as NodeSprite);
			if (d is EdgeSprite) return removeEdge(d as EdgeSprite);
			return false;
		}
				
		/**
		 * Removes a node from this data set. All edges incident on this
		 * node will also be removed. If the node is not found in this
		 * data set, the method returns null.
		 * @param n the node to remove
		 * @returns true if sucessfully removed, false if not found in the data
		 */
		public function removeNode(n:NodeSprite):Boolean
		{
			if (_nmap[n] == undefined) return false;
			
			var base:Data = this;
			n.visitEdges(function(e:EdgeSprite):Boolean {
				removeEdge(e);
				return true;
			}, NodeSprite.GRAPH_LINKS | NodeSprite.REVERSE);
			
			// finally, remove this node from the data set
			return removeNodeInternal(n);
		}
		
		/**
		 * Removes an edge from this data set. The nodes connected to
		 * this edge will have the edge removed from their edge lists.
		 * @param e the edge to remove
		 * @returns true if sucessfully removed, false if not found in the data
		 */
		public function removeEdge(e:EdgeSprite):Boolean
		{
			if (_emap[e] == undefined) return false;
			e.source.removeOutEdge(e);
			e.target.removeInEdge(e);
			return removeEdgeInternal(e);
		}
				
		// -- Events -------------------------------------------
		
		/**
		 * Internal method for firing a data event.
		 * @param type the event type
		 * @param d the DataSprite for which the event is being fired
		 * @param clearCache flag indicating if the statistics cache
		 *  should be cleared in response to the update
		 */
		protected function fireEvent(type:String, d:DataSprite,
									 clearCache:Boolean=true):void
		{
			// clear appropriate stats cache
			// TODO: incremental stats update?
			if (clearCache) {
				if (d is EdgeSprite) {
					_estats = new Object();
				} else {
					_nstats = new Object();
				}
			}
			
			// reset the spanning tree on adds and removals
			if (type != DataEvent.DATA_UPDATED)
				_tree = null;
			
			// fire event, if anyone is listening
			if (hasEventListener(type)) {
				dispatchEvent(new DataEvent(type, this, d));
			}
		}
		
		// -- Visitors -----------------------------------------
		
		/**
		 * Visit items, invoking a function on all visited elements.
		 * @param f the function to invoke on each element. If the function
		 *  return false, the visitation is ended with an early exit
		 * @param opt visit options flag, indicating the data group(s) to visit
		 *  (e.g., NODES or EDGES) and if the visitation traversal should be
		 *  done in reverse (the REVERSE flag). The default is a forwards
		 *  traversal over both nodes and edges.
		 * @return true if the visitation ended without an early exit
		 */
		public function visit(f:Function, opt:int=ALL):Boolean
		{
			_visiting = opt;
			var b:Boolean=true, rev:uint = opt & REVERSE;
			if (opt & EDGES && _edges.length > 0) {
				b = visitArray(f, _edges, rev);
			}
			if (b && opt & NODES && _nodes.length > 0) {
				b = visitArray(f, _nodes, rev);
			}
			_visiting = 0;
			return b;
		}
		
		private function visitArray(f:Function, a:Array, rev:uint):Boolean
		{
			var i:uint;
			if (rev) {
				for (i=a.length; --i>=0;)
					if (!f(a[i])) return false;
			} else {
				for (i=0; i<a.length; ++i)
					if (!f(a[i])) return false;
			}
			return true;
		}
		
		/**
		 * Visit nodes, invoking a function on all visited elements.
		 * @param f the function to invoke on each element. If the function
		 *  return false, the visitation is ended with an early exit
		 * @param opt visit options flag, indicating if the visitation
		 *  traversal should be done in reverse (the REVERSE flag). The default
		 *  is a forwards traversal.
		 * @return true if the visitation ended without an early exit
		 */
		public function visitNodes(f:Function, opt:int=0):Boolean
		{
			return visit(f, NODES|opt);
		}
		
		/**
		 * Visit edges, invoking a function on all visited elements.
		 * @param f the function to invoke on each element. If the function
		 *  return false, the visitation is ended with an early exit
		 * @param opt visit options flag, indicating if the visitation
		 *  traversal should be done in reverse (the REVERSE flag). The default
		 *  is a forwards traversal.
		 * @return true if the visitation ended without an early exit
		 */
		public function visitEdges(f:Function, opt:int=0):Boolean
		{
			return visit(f, EDGES|opt);	
		}
		
		
		// -- Spanning Tree ---------------------------------------------------
		
		/** Tree builder function for generating a spanning tree.
		 *  @see flare.vis.util.TreeUtil */
		protected var _treeBuilder:Function = TreeUtil.breadthFirstTree;
		/** The root node of the spanning tree. */
		protected var _root:NodeSprite = null;
		/** The generated spanning tree for this data set's graph. */
		protected var _tree:Tree = null; // cached spanning tree
		
		/** Tree builder function for generating a spanning tree.
		 *  @see flare.vis.util.TreeUtil */
		public function get treeBuilder():Function { return _treeBuilder; }
		public function set treeBuilder(f:Function):void {
			if (_treeBuilder != f) {
				_tree = null;
				_treeBuilder = f;
			}
		}
		
		/** The root node of the spanning tree. */
		public function get root():NodeSprite { return _root; }
		public function set root(n:NodeSprite):void {
			if (n != null && !containsNode(n))
				throw new ArgumentError("Spanning tree root must be within the graph.");
			if (_root != n) {
				_tree = null;
				_root = n;
			}
		}
		
		/**
		 * A spanning tree for this graph. The spanning tree generated is
		 * determined by the <code>root</code> and <code>treeBuilder</code>
		 * properties. By default, the tree is built using a breadth first
		 * spanning tree using the first node in the graph as the root.
		 */
		public function get tree():Tree
		{
			if (_tree == null) {
				// build tree if necessary
				var root:NodeSprite = _root == null ? _nodes[0] : _root;
				_tree = _treeBuilder(root, this);	
			}
			return _tree;	
		}
		
		/**
		 * Sets the spanning tree used by this graph.
		 * This tree must include only nodes and edges also in this graph.
		 */
		public function set tree(t:Tree):void
		{
			if (t==null) { _tree = null; return; }
			
			var ok:Boolean;
			ok = t.root.visitTreeDepthFirst(function(n:NodeSprite):Boolean {
				if (n.parentEdge != null) {
					if (!containsEdge(n.parentEdge)) return false;
				}
				return containsNode(n);
			});
			if (ok) _tree = t;
		}
		
		// -- Statistics ------------------------------------------------------
				
		/**
		 * Computes and caches statistics for a data field. The resulting
		 * <code>Stats</code> object is cached, so that later access does not
		 * require any re-calculation. The cache of statistics objects may be
		 * cleared, however, if changes to the data set are made.
		 * @param field the property name
		 * @param which the data group (either NODES or EDGES) in which to look
		 * @return a <code>Stats</code> object with the computed statistics
		 */
		public function stats(field:String, which:int=NODES):Stats
		{
			if (which != NODES && which != EDGES)
				throw new ArgumentError("NODES and EDGES are the only allowed types");
			
			var comparator:Function = null; // TODO allow this to be set externally
			if (comparator != null) {
				// currently no caching with custom comparators
				return new Stats((which==NODES?_nodes:_edges), field, comparator);	
			}
			
			// check cache for stats
			var cache:Object = which==NODES ? _nstats : _estats;
			if (cache[field] != undefined) {
				return cache[field] as Stats;
			} else {
				var a:Array = which==NODES ? _nodes : _edges;
				var s:Stats = new Stats(a, field, comparator);
				cache[field] = s;
				return s;
			}
		}
		
		// -- Scale Factory ---------------------------------------------------
		
		/**
		 * Create a new Scale instance for the given data field.
		 * @param field the data property name to compute the scale for
		 * @param which the data group (either NODES or EDGES) in which to look
		 * @param scaleType the type of scale instance to generate
		 * @return a Scale instance for the given data field
		 * @see flare.vis.scale.Scales
		 */
		public function scale(field:String, which:int=NODES, 
							  scaleType:int=1, ...rest):Scale
		{
			var stats:Stats = stats(field, which);
			var scale:Scale = Scales.scale(stats, scaleType);
			// TODO: lookup formatting info (?)
			return scale;
		}
		
	} // end of class Data
}