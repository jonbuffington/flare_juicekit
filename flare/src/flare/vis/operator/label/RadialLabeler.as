package flare.vis.operator.label
{
	import flare.animate.Transitioner;
	import flare.display.TextSprite;
	import flare.vis.data.Data;
	import flare.vis.data.DataList;
	import flare.vis.data.DataSprite;
	
	import flash.text.TextFormat;

	/**
	 * Labeler that orients labels placed on a circle. Labels are rotated
	 * such that they align radially.
	 */
	public class RadialLabeler extends Labeler
	{
		/**
		 * Creates a new RadialLabeler. 
		 * @param source the property from which to retrieve the label text.
		 *  If this value is a string or property instance, the label text will
		 *  be pulled directly from the named property. If this value is a
		 *  Function or Expression instance, the value will be used to set the
		 *  <code>textFunction<code> property and the label text will be
		 *  determined by evaluating that function.
		 * @param format optional text formatting information for labels
		 * @param policy the label creation policy. One of LAYER (for adding a
		 *  separate label layer) or CHILD (for adding labels as children of
		 *  data objects)
		 * @param filter a Boolean-valued filter function determining which
		 *  items will be given labels
		 */
		public function RadialLabeler(source:*,
			format:TextFormat=null, policy:String=CHILD, filter:*=null)
		{
			super(source, Data.NODES, format, policy, filter);
		}
		
		/** @inheritDoc */
		public override function operate(t:Transitioner=null):void
		{
			t = (t ? t : Transitioner.DEFAULT);
			super.operate(t);
			
			var list:DataList = visualization.data.groups[group];
			list.visit(function(d:DataSprite):void {
				var label:TextSprite = d.props.label as TextSprite;
				if (!label) return;
				
				var a:Number = t.$(d).angle;
				while (a >  Math.PI) a -= 2*Math.PI;
				while (a < -Math.PI) a += 2*Math.PI;
				
				var o:Object = t.$(label);
				if (a > -Math.PI/2 && a <= Math.PI/2) {
					o.rotation = -(180/Math.PI) * a;
					o.horizontalAnchor = TextSprite.LEFT;
				} else {
					o.rotation = -(180/Math.PI) * (a + Math.PI);
					o.horizontalAnchor = TextSprite.RIGHT;
				}
			}, false, filter);
		}
		
	} // end of class RadialLabeler
}