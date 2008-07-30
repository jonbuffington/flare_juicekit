package flare.vis.operator.encoder
{
	import flare.animate.Transitioner;
	import flare.scale.ScaleType;
	import flare.vis.data.Data;
	import flare.vis.palette.ColorPalette;
	import flare.vis.palette.Palette;
	
	/**
	 * Encodes a data field into color values, using a scale transform and
	 * color palette.
	 */
	public class ColorEncoder extends Encoder
	{
		private var _palette:ColorPalette;
		private var _ordinal:Boolean = false;
		
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
		 * @param group the data group to encode
		 * @param target the target property ("lineColor" by default)
		 * @param scaleType the type of scale to use (LINEAR by default)
		 * @param palette the color palette to use. If null, a default color
		 *  ramp will be used
		 */
		public function ColorEncoder(source:String=null,
			group:String=Data.NODES, target:String="lineColor",
			scaleType:String="linear", palette:ColorPalette=null)
		{
			super(source, target, group);
			_binding.scaleType = scaleType;
			_palette = palette;
		}
		
		/** @inheritDoc */
		public override function setup():void
		{
			if (visualization==null) return;
			super.setup();
		}
		
		/** @inheritDoc */
		public override function operate(t:Transitioner=null):void
		{
			_ordinal = _binding.scaleType==ScaleType.CATEGORIES ||
			           _binding.scaleType==ScaleType.ORDINAL;
			_binding.updateBinding();
			
			// create a default color palette if none explicitly set
			var setPalette:Boolean = (_palette == null);
			if (setPalette) _palette = getDefaultPalette();
			super.operate(t); // run encoder
			if (setPalette) _palette = null;
		}
		
		/** @inheritDoc */
		protected override function encode(val:Object):*
		{
			if (_ordinal) {
				return _palette.getColorByIndex(_binding.index(val));
			} else {
				return _palette.getColor(_binding.interpolate(val));
			}
		}
		
		/**
		 * Returns a default color palette based on the input scale.
		 * @param scale the scale of values to map to colors
		 * @return a default color palette for the input scale
		 */
		protected function getDefaultPalette():ColorPalette
		{
			/// TODO: more intelligent color palette selection?
			if (ScaleType.isOrdinal(_binding.scaleType))
			{
				return ColorPalette.category(_binding.length);
			}
			else if (ScaleType.isQuantitative(_binding.scaleType))
			{
				var min:Number = Number(_binding.min);
				var max:Number = Number(_binding.max);
				if (min < 0 && max > 0)
					return ColorPalette.diverging();
			}
			return ColorPalette.ramp();
		}
		
	} // end of class ColorEncoder
}