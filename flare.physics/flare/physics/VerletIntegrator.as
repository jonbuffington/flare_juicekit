package flare.physics
{
	/**
	 * Integrator that uses Verlet's method for numerical integration.
	 */
	public class VerletIntegrator implements IIntegrator
	{
		/**
		 * Integrates an accumulated set of forces over a time interval.
		 * @param sim the simulation to integrate the force value for
		 * @param dt the time interval over which to integrate
		 */
		public function integrate(sim:Simulation, dt:Number):void
		{
			var particles:Array = sim.particles, p:Particle, i:uint;
			var ax:Number, ay:Number, dt1:Number = dt/2, dt2:Number = dt*dt/2;
			
			for (i=0; i<particles.length; ++i) {
				p = Particle(particles[i]);
				ax = p.fx / p.mass; ay = p.fy / p.mass;
				p.x  += p.vx*dt + ax*dt2;
				p.y  += p.vy*dt + ay*dt2;
				p.vx += ax*dt1;
				p.vy += ay*dt1;
			}
			sim.eval();
			for (i=0; i<particles.length; ++i) {
				p = Particle(particles[i]);
				ax = dt1 / p.mass;
				p.vx += p.fx * ax;
				p.vy += p.fy * ax;
			}
		}
		
	} // end of class VerletIntegrator
}