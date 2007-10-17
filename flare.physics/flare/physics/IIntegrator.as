package flare.physics
{
	/**
	 * Interface representing a numerical integrator for force simulations.
	 * Integrators update velocity and position values based on the forces
	 * applied and the time interval elapsed.
	 */
	public interface IIntegrator
	{
		/**
		 * Integrates an accumulated set of forces over a time interval.
		 * @param sim the simulation to integrate the force value for
		 * @param dt the time interval over which to integrate
		 */
		function integrate(sim:Simulation, dt:Number):void;	
		
	} // end of interface IIntegrator
}