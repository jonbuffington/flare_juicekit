package flare.physics
{
	import flash.geom.Rectangle;
	
	/**
	 * A physical simulation involving particles, springs, and forces.
	 * Useful for simulating a range of physical effects or layouts.
	 */
	public class Simulation
	{
		private var _particles:Array = new Array();
		private var _springs:Array = new Array();
		private var _forces:Array = new Array();
		private var _integrator:IIntegrator = new VerletIntegrator();
		private var _bounds:Rectangle = null;
		
		/** The default gravity force for this simulation. */
		public function get gravityForce():GravityForce {
			return _forces[0] as GravityForce;
		}
		
		/** The default n-body force for this simulation. */
		public function get nbodyForce():NBodyForce {
			return _forces[1] as NBodyForce;
		}
		
		/** The default drag force for this simulation. */
		public function get dragForce():DragForce {
			return _forces[2] as DragForce;
		}
		
		/** The default spring force for this simulation. */
		public function get springForce():SpringForce {
			return _forces[3] as SpringForce;
		}
		
		/** Sets a bounding box for particles in this simulation.
		 *  Null (the default) indicates no boundaries. */
		public function get bounds():Rectangle { return _bounds; }
		public function set bounds(b:Rectangle):void {
			if (_bounds == b) return;
			if (_bounds == null) { _bounds = new Rectangle(); }
			// ensure x is left-most and y is top-most
			_bounds.x = b.x + (b.width < 0 ? b.width : 0);
			_bounds.width = (b.width < 0 ? -1 : 1) * b.width;
			_bounds.y = b.y + (b.width < 0 ? b.height : 0);
			_bounds.height = (b.height < 0 ? -1 : 1) * b.height;
		}
		
		/**
		 * Creates a new physics simulation.
		 * @param gx the gravitational acceleration along the x dimension
		 * @param gy the gravitational acceleration along the y dimension
		 * @param drag the default drag (viscosity) co-efficient
		 * @param attraction the gravitational attraction (or repulsion, for
		 *  negative values) between particles.
		 */
		public function Simulation(gx:Number, gy:Number,
			drag:Number=0.001, attraction:Number=0)
		{
			_forces.push(new GravityForce(gx, gy));
			_forces.push(new NBodyForce(attraction));
			_forces.push(new DragForce(drag));
			_forces.push(new SpringForce());
		}
		
		// -- Init Simulation -------------------------------------------------
		
		/**
		 * Adds a custom force to the force simulation.
		 * @param force the force to add
		 */
		public function addForce(force:IForce):void
		{
			_forces.push(force);
		}
		
		/**
		 * Returns the force at the given index.
		 * @param idx the index of the force to look up
		 * @return the force at the specified index
		 */ 
		public function getForceAt(idx:int):IForce
		{
			return _forces[idx];
		}
		
		/**
		 * Adds a new particle to the simulation.
		 * @param mass the mass (charge) of the particle
		 * @param x the particle's starting x position
		 * @param y the particle's starting y position
		 * @return the added particle
		 */
		public function addParticle(mass:Number, x:Number, y:Number):Particle
		{
			var p:Particle = getParticle(mass, x, y);
			_particles.push(p);
			return p;
		}
		
		/**
		 * Removes a particle from the simulation. Any springs attached to
		 * the particle will also be removed.
		 * @param idx the index of the particle in the particle list
		 * @return true if removed, false otherwise.
		 */
		public function removeParticle(idx:uint):Boolean
		{
			var p:Particle = _particles[idx];
			if (p == null) return false;
			
			// remove springs
			for (var i:uint = _springs.length; --i >= 0; ) {
				var s:Spring = _springs[i];
				if (s.p1 == p || s.p2 == p) {
					removeSpring(i);
				}
			}
			// remove from particles
			reclaimParticle(p);
			_particles.splice(idx, 1);
			return true;
		}
		
		/**
		 * Adds a spring to the simulation
		 * @param p1 the first particle attached to the spring
		 * @param p2 the second particle attached to the spring
		 * @param restLength the rest length of the spring
		 * @param tension the tension of the spring
		 * @param damping the damping (friction) co-efficient of the spring
		 * @return the added spring
		 */
		public function addSpring(p1:Particle, p2:Particle, restLength:Number,
							      tension:Number, damping:Number):Spring
		{
			var s:Spring = getSpring(p1, p2, restLength, tension, damping);
			_springs.push(s);
			return s;
		}
		
		
		/**
		 * Removes a spring from the simulation.
		 * @param idx the index of the spring in the spring list
		 * @return true if removed, false otherwise
		 */
		public function removeSpring(idx:uint):Boolean
		{
			if (idx >= _springs.length) return false;
			reclaimSpring(_springs[idx]);
			_springs.splice(idx, 1);
			return true;
		}
		
		/**
		 * Returns the particle list. This is the same array instance backing
		 * the simulation, so edit the array with caution.
		 * @return the particle list
		 */
		public function get particles():Array {
			return _particles;
		}
		
		/**
		 * Returns the spring list. This is the same array instance backing
		 * the simulation, so edit the array with caution.
		 * @return the spring list
		 */
		public function get springs():Array {
			return _springs;
		}
		
		// -- Run Simulation --------------------------------------------------
		
		/**
		 * Advance the simulation for the specified time interval.
		 * @param dt the time interval to step the simulation (default 1)
		 */
		public function tick(dt:Number=1):void {
			// father time and the grim reaper
			var p:Particle;
			for (var i:uint=0; i<_particles.length; ++i) {
				p = _particles[i];
				p.age += dt;
				if (p.die) removeParticle(i);
			}
			
			// update
			_integrator.integrate(this, dt);
			if (_bounds) enforceBounds();
		}
		
		private function enforceBounds():void {
			var minX:Number = _bounds.x;
			var maxX:Number = _bounds.x + _bounds.width;
			var minY:Number = _bounds.y;
			var maxY:Number = _bounds.y + _bounds.height;
			
			for each (var p:Particle in _particles) {
				if (p.x < minX) p.x = minX;
				else if (p.x > maxX) p.x = maxX;
				
				if (p.y < minY) p.y = minY;
				else if (p.y > maxY) p.y = maxY;
			}
		}
		
		/**
		 * Evaluates the set of forces in the simulation.
		 */
		public function eval():void {
			var i:uint, p:Particle;
			// reset forces
			for (i = _particles.length; --i >= 0; ) {
				p = _particles[i];
				p.fx = p.fy = 0;
			}
			// collect forces
			for (i = 0; i<_forces.length; ++i) {
				(_forces[i] as IForce).apply(this);
			}
		}
		
		// -- Particle Pool ---------------------------------------------------
		
		/** The maximum number of items stored in a simulation object pool. */
		public static var objectPoolLimit:int = 5000;
		protected static var _ppool:Array = new Array();
		protected static var _spool:Array = new Array();
		
		/**
		 * Returns a particle instance, pulling a recycled particle from the
		 * object pool if available.
		 * @param mass the mass (charge) of the particle
		 * @param x the particle's starting x position
		 * @param y the particle's starting y position
		 * @return a particle instance
		 */
		protected static function getParticle(mass:Number, x:Number, y:Number):Particle
		{
			if (_ppool.length > 0) {
				var p:Particle = _ppool.pop();
				p.init(mass, x, y);
				return p;
			} else {
				return new Particle(mass, x, y);
			}
		}
		
		/**
		 * Returns a spring instance, pulling a recycled spring from the
		 * object pool if available.
		 * @param p1 the first particle attached to the spring
		 * @param p2 the second particle attached to the spring
		 * @param restLength the rest length of the spring
		 * @param tension the tension of the spring
		 * @param damping the damping (friction) co-efficient of the spring
		 * @return a spring instance
		 */
		protected static function getSpring(p1:Particle, p2:Particle,
			restLength:Number, tension:Number, damping:Number):Spring
		{
			if (_spool.length > 0) {
				var s:Spring = _spool.pop();
				s.init(p1, p2, restLength, tension, damping);
				return s;
			} else {
				return new Spring(p1, p2, restLength, tension, damping);
			}
		}
		
		/**
		 * Reclaims a particle, adding it to the object pool for recycling
		 * @param p the particle to reclaim
		 */
		protected static function reclaimParticle(p:Particle):void
		{
			if (_ppool.length < objectPoolLimit) {
				_ppool.push(p);
			}
		}
		
		/**
		 * Reclaims a spring, adding it to the object pool for recycling
		 * @param s the spring to reclaim
		 */
		protected static function reclaimSpring(s:Spring):void
		{
			if (_spool.length < objectPoolLimit) {
				_spool.push(s);
			}
		}
		
	} // end of class Simulation
}