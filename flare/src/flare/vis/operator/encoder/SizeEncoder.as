package flare.vis.operator.encoder
{
	import flare.scale.ScaleType;
	import flare.vis.data.Data;
	import flare.vis.palette.Palette;
	import flare.vis.palette.SizePalette;
	
	/**
	 * Encodes a data field into size values, using a scale transform and a
	 * size palette to determines an item's scale. The target property of a
	 * SizeEncoder is assumed to be the <code>DataSprite.size</code> property.
	 */
	public class SizeEncoder extends Encoder
	{
		private var _palette:SizePalette;
		
		/** @inheritDoc */
		public override function get palette():Palette { return _palette; }
		public override function set palette(p:Palette):void {
			_palette = p as SizePalette;
		}
		/** The palette as a SizePalette instance. */
		public function get sizes():SizePalette { return _palette; }
		
		// --------------------------------------------------------------------
		
		/**
		 * Creates a new SizeEncoder.
		 * @param source the source property
		 * @param group the data group to process
		 */
		public function SizeEncoder(source:String=null, group:String=Data.NODES)
		{
			super(source, "size", group);
			_binding.scaleType = ScaleType.QUANTILE;
			_binding.bins = 5;
			_palette = new SizePalette();
			_palette.is2D = (group != Data.EDGES);
		}
		
		/** @inheritDoc */
		protected override function encode(val:Object):*
		{
			return _palette.getSize(_binding.interpolate(val));
		}
		
	} // end of class SizeEncoder
}