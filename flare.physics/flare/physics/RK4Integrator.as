package flare.physics
{	
	/**
	 * Integrator that uses the 4th Order Runge-Kutta method for integrating
	 * force values. This approach can be time-consuming but typically results
	 * in a stable and smooth integration.
	 */
	public class RK4Integrator implements IIntegrator
	{
		private var xp:Array = new Array(10);
		private var yp:Array = new Array(10);
		private var xk:Array = new Array(40);
		private var yk:Array = new Array(40);
		private var xl:Array = new Array(40);
		private var yl:Array = new Array(40);
		
		/**
		 * Integrates an accumulated set of forces over a time interval.
		 * @param sim the simulation to integrate the force value for
		 * @param dt the time interval over which to integrate
		 */
		public function integrate(sim:Simulation, dt:Number):void {
			var particles:Array = sim.particles;
			var N:uint = particles.length, i:uint, ii:uint, a:Number, p:Particle;;
			
			// first, sanity check the array sizes
			if (xp.length < N) {
				xp = new Array(N); yp = new Array(N);
			}
			if (xk.length < 4*N) {
				xk = new Array(4*N); yk = new Array(4*N);
				xl = new Array(4*N); yl = new Array(4*N);
			}
			
			// run the integration using RK4
			sim.eval();
			for (i=0; i<N; ++i) {
				p = particles[i] as Particle;
				a = dt / p.mass;
				xp[i] = p.x;     yp[i] = p.y;
				xk[i] = dt*p.vx; yk[i] = dt*p.vy; 
				xl[i] =  a*p.fx; yl[i] =  a*p.fy;
				if (!p.fixed) {
					p.x += .5*xk[i]; p.y += .5*yk[i];
				}
			}
			
			sim.eval();
			for (i=0, ii=N; i<N; ++i, ++ii) {
				p = particles[i] as Particle;
				a = dt / p.mass;
				xk[ii] = dt*(p.vx + .5*xl[ii-N]);
				yk[ii] = dt*(p.vy + .5*yl[ii-N]);
				xl[ii] =  a*p.fx;
				yl[ii] =  a*p.fy;
				if (!p.fixed) {
					p.x = xp[i] + .5*xk[ii];
					p.y = yp[i] + .5*yk[ii];
				}
			}
			
			sim.eval();
			for (i=0; i<N; ++i, ++ii) {
				p = particles[i] as Particle;
				a = dt / p.mass;
				xk[ii] = dt*(p.vx + .5*xl[ii-N]);
				yk[ii] = dt*(p.vy + .5*yl[ii-N]);
				xl[ii] =  a*p.fx;
				yl[ii] =  a*p.fy;
				if (!p.fixed) {
					p.x = xp[i] + .5*xk[ii];
					p.y = yp[i] + .5*yk[ii];
				}
			}
			
			sim.eval();
			for (i=0; i<N; ++i, ++ii) {
				p = particles[i] as Particle;
				a = dt / p.mass;
				xk[ii] = dt*(p.vx + .5*xl[ii-N]);
				yk[ii] = dt*(p.vy + .5*yl[ii-N]);
				xl[ii] =  a*p.fx;
				yl[ii] =  a*p.fy;
				if (!p.fixed) {
					p.x = xp[i] + (xk[i] + 2*(xk[i+N] + xk[ii-N]) + xk[ii]) / 6;
					p.y = yp[i] + (yk[i] + 2*(yk[i+N] + yk[ii-N]) + yk[ii]) / 6;
					p.vx += (xl[i] + 2*(xl[i+N] + xl[ii-N]) + xl[ii]) / 6;
					p.vy += (yl[i] + 2*(yl[i+N] + yl[ii-N]) + yl[ii]) / 6;
				} else {
					p.vx = p.vy = 0;
				}
			}
		}

	} // end of class RK4Integrator
}