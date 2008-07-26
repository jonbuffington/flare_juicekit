package flare.demos
{
	import flash.display.Sprite;
	import flare.physics.Simulation;
	import flash.utils.Dictionary;
	import flare.physics.Particle;
	import flash.events.Event;
	import flash.display.Shape;
	import flare.animate.ISchedulable;
	import flare.animate.Scheduler;

	/**
	 * Demo showcasing use of the physics engine to simulate smoke.
	 * Based on the smoke example from the traer physics library
	 * for processing (http://www.cs.princeton.edu/~traer/physics/).
	 */
	public class Smoke extends Demo implements ISchedulable
	{
		private var _shapes:Array = new Array();
		private var _spool:Array = new Array();
		private var _sim:Simulation;
		private var _dict:Dictionary;
		private var _last:Particle;
		private var _life:Number = 62;
		
		public function Smoke()
		{
			name = "Smoke";
			_shapes = new Array();
			_dict = new Dictionary();
			_last = null;
			
			// a simulation with slight upward gravity
			_sim = new Simulation(0, -0.1, 0.001, 0);
		}

		override public function play():void
		{
			// add to scheduler, which will call the evaluate method
			Scheduler.instance.add(this);
		}
		
		override public function stop():void
		{
			// remove from the scheduler
			Scheduler.instance.remove(this);
		}

		public function evaluate(t:Number) : Boolean
		{
			// update smoke simulation on scheduler callback
			drawSmoke();
			return false;
		}

		private function getShape():Shape
		{
			// get a new shape, check object pool before allocating a new one
			var s:Shape;
			if (_spool.length > 0) {
				s = _spool.pop();
				s.alpha = 1;
			} else {
				s = new Shape();
				s.graphics.beginFill(0x0);
				s.graphics.drawEllipse(-10,-10,20,20);
				s.graphics.endFill();
			}
			return s;
		}
		
		private function reclaim(s:Shape):void
		{
			// reclaim shape in object pool for reuse
			_spool.push(s);
		}

		private function drawSmoke():void
		{
			// create five new smoke particles on each simulation tick	
			for (var i:uint = 0; i<5; ++i) {
				var p:Particle = _sim.addParticle(1, root.mouseX, root.mouseY-10);
				
				var s:Shape = getShape();
				_dict[s] = p;
				_shapes.push(s);
				addChild(s);
					
				p.vx = 2 * (Math.random()-0.5);
				p.vy = (3 * Math.random()) - 5;
				if (_last != null) {
					_sim.addSpring(p, _last, 10, 0.1, 0.1);
				}
				_last = p;
			}
			
			// run the simulation one timestep
			_sim.tick();

			// update positions, handle removal of dead particles
			for (i = _shapes.length; --i >= 0; ) {
				s = _shapes[i] as Shape;
				p = _dict[s] as Particle;
				
				if (p.die) {
					_shapes.splice(i, 1);
					reclaim(s);
					removeChild(s);
				} else {
					if (p.age > _life) p.kill();
					s.x = p.x;
					s.y = p.y;
					s.alpha = 1/(p.age+1);
				}
			}
  		}
  		
	} // end of class Smoke
}