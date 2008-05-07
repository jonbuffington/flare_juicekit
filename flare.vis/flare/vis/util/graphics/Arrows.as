package flare.vis.util.graphics
{
	import flash.display.Graphics;
	
	/**
	 * Utility class for helping draw arrow heads on connecting edges.
	 */
	public class Arrows
	{
		/** Indicates that no arrows should be drawn. */
		public static const NONE:String = "none";
		/** Indicates that a closed triangular arrow head should be drawn. */
		public static const TRIANGLE:String = "triangle";
		/** Indicates that two lines should be used to draw the arrow head. */
		public static const LINES:String = "lines";
		
		/**
		 * This constructor will throw an error, as this is an abstract class. 
		 */
		public function Arrows()
		{
			throw new Error("This is an abstract class.");
		}

	} // end of class Arrows
}