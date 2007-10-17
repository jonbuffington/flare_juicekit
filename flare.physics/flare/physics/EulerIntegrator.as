package flare.physics
{
	/**
	 * Integrator that uses Euler's method for numerical integration. This
	 * approach is quick but can suffer from instability.
	 */
	public class EulerIntegrator implements IIntegrator
	{
		/**
		 * Integrates an accumulated set of forces over a time interval.
		 * @param sim the simulation to integrate the force value for
		 * @param dt the time interval over which to integrate
		 */
		public function integrate(sim:Simulation, dt:Number):void
		{
			var particles:Array = sim.particles, p:Particle, i:uint;
			
			sim.eval();
			for (i=0; i<particles.length; ++i) {
				p = particles[i] as Particle;
				p.x += dt * p.vx;
				p.y += dt * p.vy;
				p.vx += dt * p.mass * p.fx;
				p.vy += dt * p.mass * p.fy;
			}
		}
		
	} // end of class EulerIntegrator
}