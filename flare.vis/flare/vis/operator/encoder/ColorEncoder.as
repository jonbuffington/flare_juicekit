package flare.vis.operator.encoder
{
	import flare.vis.palette.ColorPalette;
	import flare.vis.scale.Scales;
	import flare.vis.palette.Palette;
	
	/**
	 * Encodes a data field into color values, using a scale transform and
	 * color palette.
	 */
	public class ColorEncoder extends Encoder
	{
		private var _palette:ColorPalette;
		
		/** @inheritDoc */
		public override function get palette():Palette { return _palette; }
		public override function set palette(p:Palette):void {
			_palette = p as ColorPalette;
		}
		/** The palette as a ColorPalette instance. */
		public function get colors():ColorPalette { return _palette; }
		
		// --------------------------------------------------------------------
		
		/**
		 * Creates a new ColorEncoder.
		 * @param source the source property
		 * @param which flag indicating which group of visual object to process
		 * @param target the target property ("lineColor" by default)
		 * @param palette the color palette to use. If null, a default color
		 *  ramp will be used
		 * @param scaleType the type of scale to use (LINEAR by default)
		 * @param scaleParam a parameter for creating the scale (10 by default)
		 */
		public function ColorEncoder(source:String=null, which:int=1/*Data.NODES*/,
			target:String="lineColor", palette:ColorPalette=null,
			scaleType:int=Scales.LINEAR, scaleParam:Number=10)
		{
			super(source, target, which);
			_scaleType = scaleType;
			_scaleParam = scaleParam;
			_palette = (palette!=null ? palette : ColorPalette.ramp());
		}
		
		/** @inheritDoc */
		protected override function encode(val:Object):*
		{
			return _palette.getColor(_scale.interpolate(val));
		}
		
	} // end of class ColorEncoder
}