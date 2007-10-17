package flare.vis.operator.layout
{
	import flare.physics.Simulation;
	import flare.animate.Transitioner;
	import flash.utils.Dictionary;
	import flare.vis.data.DataSprite;
	import flare.vis.data.EdgeSprite;
	import flash.filters.GradientBevelFilter;
	import flare.physics.Particle;
	import flare.physics.Spring;
	import flare.vis.data.Data;
	
	/**
	 * Layout that positions graph items based on a physics simulation of
	 * interacting forces; by default, nodes repel each other, edges act as
	 * springs, and drag forces (similar to air resistance) are applied. This
	 * algorithm can be run for multiple iterations for a run-once layout
	 * computation or repeatedly run in an animated fashion for a dynamic and
	 * interactive layout.
	 * 
	 * <p>The running time of this layout algorithm is the greater of O(N log N)
	 * and O(E), where N is the number of nodes and E the number of edges.
	 * The addition of custom forces to the simulation may affect this.</p>
	 * 
	 * <p>The force direction layout is implemented using the physics simulator
	 * provided by the <code>flare.physics</code> package. The
	 * <code>Simulation</code> used to drive this layout can be set explicitly,
	 * allowing any number of custom force directed layouts to be created
	 * through the selection of <code>IForce</code> modules. Each node in the
	 * layout is mapped to a <code>Particle</code> instance and each edge
	 * to a <code>Spring</code> in the simulation.</p>
	 * 
	 * @see flare.physics
	 */
	public class ForceDirectedLayout extends Layout
	{
		private var _lookup:Dictionary = new Dictionary();
		private var _sim:Simulation;
		private var _step:Number = 1;
		private var _iter:int = 1;
		private var _gen:uint = 0;
		
		// simlation defaults
		private var _mass:Number = 1;
		private var _restLength:Number = 30;
		private var _tension:Number = 0.1;
		private var _damping:Number = 0.1;
		
		private var _t:Transitioner;
		
		/** The default mass value for node/particles. */
		public function get defaultParticleMass():Number { return _mass; }
		public function set defaultParticleMass(v:Number):void { _mass = v; }
		
		/** The default spring rest length for edge/springs. */
		public function get defaultSpringLength():Number { return _restLength; }
		public function set defaultSpringLength(v:Number):void { _restLength = v; }
		
		/** The default spring tension for edge/springs. */
		public function get defaultSpringTension():Number { return _tension; }
		public function set defaultSpringTension(v:Number):void { _tension = v; }
		
		/** The default spring damping constant for edge/springs. */
		public function get defaultSpringDamping():Number { return _damping; }
		public function set defaultSpringDamping(v:Number):void { _damping = v; }
		
		/** The number of iterations to run the simulation per invocation. */
		public function get iterations():int { return _iter; }
		public function set iterations(iter:int):void { _iter = iter; }
		
		/** The number of time ticks to advance the simulation on each
		 *  iteration. */
		public function get ticksPerIteration():int { return _step; }
		public function set ticksPerIteration(ticks:int):void { _step = ticks; }
		
		/** The physics simulation driving this layout. */
		public function get simulation():Simulation { return _sim; }
		
		// --------------------------------------------------------------------
		
		/**
		 * Creates a new ForceDirectedLayout.
		 * @param iterations the number of iterations to run the simulation
		 *  per invocation
		 * @param sim the physics simulation to use for the layout. If null
		 *  (the default), default simulation settings will be used
		 */
		public function ForceDirectedLayout(iterations:int=1, sim:Simulation=null) {
			_iter = iterations;
			_sim = (sim==null ? new Simulation(0, 0, 0.05, -50) : sim);
		}
		
		/** @inheritDoc */
		public override function operate(t:Transitioner=null):void
		{
			_t = (t!=null ? t : Transitioner.DEFAULT);
			
			++_gen; // update generation counter
			
			// populate simulation
			var data:Data = visualization.data;
			data.visitNodes(populateNode);
			data.visitEdges(populateEdge);
			
			// clean-up unused items
			for each (var p:Particle in _sim.particles)
				if (p.tag != _gen) p.kill();
			for (var i:uint=0; i<_sim.springs.length; ++i)
				if (_sim.springs[i].tag != _gen) _sim.removeSpring(i);
			
			// run simulation
			for (i=0; i<_iter; ++i) {
				_sim.tick(_step);
			}
			
			// update positions
			data.visitNodes(update);
			
			updateEdgePoints(_t);
			_t = null;
		}
		
		// -- value transfer --------------------------------------------------
		
		/**
		 * Transfer the physics simulation results to an item's layout.
		 * @param d a DataSprite
		 * @return true, to signal a visitor to continue
		 */
		protected function update(d:DataSprite):Boolean
		{
			var p:Particle = d.props.particle;
			if (!p.fixed) {
				_t.$(d).x = p.x;
				_t.$(d).y = p.y;
			}
			return true;
		}
		
		// -- simulation management -------------------------------------------
		
		private function populateNode(d:DataSprite):Boolean
		{
			var p:Particle = d.props.particle;
			if (p == null) {
				d.props.particle = (p = _sim.addParticle(mass(d), d.x, d.y));
				p.fixed = d.fixed;
			} else {
				with (p) { x = d.x; y = d.y; fixed = d.fixed; }
			}
			p.tag = _gen;
			return true;
		}
		
		private function populateEdge(e:EdgeSprite):Boolean
		{
			var s:Spring = e.props.spring;
			if (s == null) {
				e.props.spring = (s = _sim.addSpring(
					e.source.props.particle,
					e.target.props.particle,
					restLength(e), tension(e), damping(e)));
			}
			s.tag = _gen;
			return true;
		}
		
		/**
		 * Function for assigning mass values to particles. By default, this
		 * simply returns the default mass value. This function can be replaced
		 * to perform custom mass assignment.
		 */
		public var mass:Function = function(d:DataSprite):Number {
			return _mass;
		}
		
		/**
		 * Function for assigning rest length values to springs. By default,
		 * this simply returns the default rest length value. This function can
		 * be replaced to perform custom rest length assignment.
		 */
		public var restLength:Function = function(d:DataSprite):Number {
			return _restLength;
		}
		
		/**
		 * Function for assigning tension values to springs. By default,
		 * this simply uses the default tension value. This function can
		 * be replaced to perform custom tension assignment.
		 */
		public var tension:Function = function(d:DataSprite):Number {
			return _tension;
		}
		
		/**
		 * Function for assigning damping constant values to springs. By
		 * default, this simply uses the default damping constant. This
		 * function can be replaced to perform custom damping assignment.
		 */
		public var damping:Function = function(d:DataSprite):Number {
			return _damping;
		}
		
	} // end of class ForceDirectedLayout
}