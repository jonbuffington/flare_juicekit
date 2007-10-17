package flare.vis.operator.encoder
{
	import flare.vis.scale.OrdinalScale;
	import flare.vis.scale.Scales;
	import flare.vis.scale.Scale;
	import flare.vis.palette.ShapePalette;
	import flare.vis.palette.Palette;
	
	/**
	 * Encodes a data field into shape values, using an ordinal scale.
	 * Shape values are integer indices that map into a shape palette, which
	 * provides drawing routines for shapes. See the
	 * <code>flare.palette.ShapePalette</code> and 
	 * <code>flare.data.render.ShapeRenderer</code> classes for more.
	 */
	public class ShapeEncoder extends Encoder
	{
		private var _palette:ShapePalette;
		
		/** @inheritDoc */
		public override function get palette():Palette { return _palette; }
		public override function set palette(p:Palette):void {
			_palette = p as ShapePalette;
		}
		/** The palette as a ShapePalette instance. */
		public function get shapes():ShapePalette { return _palette; }
		
		// --------------------------------------------------------------------
		
		/** @inheritDoc */
		public override function set scaleType(st:int):void {
			if (st != Scales.ORDINAL)
				throw new ArgumentError("Shape encoders only use ordinal scales");
		}
		
		/** @inheritDoc */
		public override function set scale(s:Scale):void {
			if (!(s is OrdinalScale))
				throw new ArgumentError("Shape encoders only use ordinal scales");
		}
		
		/**
		 * Creates a new ShapeEncoder.
		 * @param source the source property
		 * @param which flag indicating which group of visual object to process
		 */
		public function ShapeEncoder(field:String=null, which:int=1/*Data.NODES*/)
		{
			super(field, "shape", which);
			_palette = ShapePalette.defaultPalette();
			_scaleType = Scales.ORDINAL;
		}
		
		/** @inheritDoc */
		protected override function encode(val:Object):*
		{
			return (_scale as OrdinalScale).index(val);
		}
		
	} // end of class ShapeEncoder
}