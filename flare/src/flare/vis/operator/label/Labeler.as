package flare.vis.operator.label
{
	import flare.animate.Transitioner;
	import flare.display.TextSprite;
	import flare.query.Expression;
	import flare.util.Filter;
	import flare.util.Property;
	import flare.vis.data.Data;
	import flare.vis.data.DataSprite;
	import flare.vis.operator.Operator;
	import flare.vis.util.Shapes;
	
	import flash.display.Sprite;
	import flash.text.TextFormat;

	/**
	 * Labeler that adds labels for items in a visualization. By default, this
	 * operator adds labels that are centered on each data sprite; this can be
	 * changed by configuring the offset and anchor settings. For later access
	 * and manipulation, all created labels are stored in the
	 * <code>props.label</code> property of the labeled data sprites. This
	 * property can be changed by setting the <code>access</code> property of
	 * this class.
	 */
	public class Labeler extends Operator
	{
		/** Constant indicating that labels be placed in their own layer. */
		public static const LAYER:String = "layer";
		/** Constant indicating that labels be added as children. */
		public static const CHILD:String = "child";
		
		/** @private */
		protected var _policy:String;
		/** @private */
		protected var _labels:Sprite;
		/** @private */
		protected var _group:String;
		/** @private */
		protected var _filter:Function;
		/** @private */
		protected var _source:Property;
		/** @private */
		protected var _access:Property = Property.$("props.label");
		
		/** @private */
		protected var _t:Transitioner;
		
		/** The name of the property in which to store created labels.
		 *  The default is "props.label". */
		public function get access():String { return _access.name; }
		public function set access(s:String):void { _access = Property.$(s); }
		
		/** The name of the data group to label. */
		public function get group():String { return _group; }
		public function set group(g:String):void { _group = g; setup(); }
		
		/** The source property that provides the label text. This
		 *  property will be ignored if the <code>textFunction<code>
		 *  property is non-null. */
		public function get source():String { return _source.name; }
		public function set source(s:String):void { _source = Property.$(s); }
		
		/** Boolean function indicating which items to process. Only items
		 *  for which this function return true will be considered by the
		 *  labeler. If the function is null, all items will be considered.
		 *  @see flare.util.Filter */
		public function get filter():Function { return _filter; }
		public function set filter(f:*):void { _filter = Filter.$(f); }
		
		/** A sprite containing the labels, if a layer policy is used. */
		public function get labels():Sprite { return _labels; }
		
		/** The policy for how labels should be applied.
		 *  One of LAYER (for adding a separate label layer) or
		 *  CHILD (for adding labels as children of data objects). */
		public function get labelPolicy():String { return _policy; }
		
		/** Optional function for determining label text. */
		public var textFunction:Function = null;
		
		/** The text format to apply to labels. */
		public var textFormat:TextFormat;
		/** The text mode to use for the TextSprite labels.
		 *  @see flare.display.TextSprite */
		public var textMode:int = TextSprite.BITMAP;
		/** The horizontal alignment for labels.
		 *  @see flare.display.TextSprite */
		public var horizontalAnchor:int = TextSprite.CENTER;
		/** The vertical alignment for labels.
		 *  @see flare.display.TextSprite */
		public var verticalAnchor:int = TextSprite.MIDDLE;
		/** The default <code>x</code> value for labels. */
		public var xOffset:Number = 0;
		/** The default <code>y</code> value for labels. */
		public var yOffset:Number = 0;
		
		// --------------------------------------------------------------------
		
		/**
		 * Creates a new Labeler. 
		 * @param source the property from which to retrieve the label text.
		 *  If this value is a string or property instance, the label text will
		 *  be pulled directly from the named property. If this value is a
		 *  Function or Expression instance, the value will be used to set the
		 *  <code>textFunction<code> property and the label text will be
		 *  determined by evaluating that function.
		 * @param group the data group to process
		 * @param format optional text formatting information for labels
		 * @param filter a Boolean-valued filter function determining which
		 *  items will be given labels
		 * @param policy the label creation policy. One of LAYER (for adding a
		 *  separate label layer) or CHILD (for adding labels as children of
		 *  data objects)
		 */
		public function Labeler(source:*, group:String=Data.NODES,
			format:TextFormat=null, filter:*=null, policy:String=CHILD)
		{
			if (source is String) {
				_source = Property.$(source);
			} else if (source is Property) {
				_source = source;
			} else if (source is Function) {
				textFunction = source;
			} else if (source is Expression) {
				textFunction = source.eval;
			}
			_group = group;
			textFormat = format ? format : new TextFormat("Arial",12);
			this.filter = filter;
			
			_policy = policy;
		}
		
		/** @inheritDoc */
		public override function setup():void
		{
			if (_policy == LAYER) {
				_labels = visualization.labels;
				if (_labels == null) {
					_labels = new Sprite();
					_labels.mouseChildren = false;
					_labels.mouseEnabled = false;
					visualization.labels = _labels;
				}
			}
		}
		
		/** @inheritDoc */
		public override function operate(t:Transitioner=null):void
		{
			_t = (t ? t : Transitioner.DEFAULT);
			visualization.data.group(group).visit(process, false, filter);
			_t = null;
		}
		
		/**
		 * Performs label creation and layout for the given data sprite.
		 * Subclasses should override this method to perform custom labeling. 
		 * @param d the data sprite to process
		 */
		protected function process(d:DataSprite):void
		{
			var label:TextSprite = getLabel(d, true);
			var o:Object, x:Number, y:Number, a:Number, v:Boolean;
			if (_policy == LAYER) {
				o = _t.$(d);
				if (o.shape == Shapes.BLOCK) {
					x = o.u + o.w/2;
					y = o.v + o.h/2;
				} else {
					x = o.x;
					y = o.y;
				}
				a = o.alpha;
				v = o.visible;
				o = _t.$(label);
				o.x = x + xOffset;
				o.y = y + yOffset;
				o.alpha = a;
				o.visible = v;
			} else {
				o = _t.$(label);
				o.x = xOffset;
				o.y = yOffset;
			}
		}
		
		/**
		 * Computes the label text for a given sprite.
		 * @param d the data sprite for which to produce label text
		 * @return the label text
		 */
		protected function getLabelText(d:DataSprite):String
		{
			if (textFunction != null) {
				return textFunction(d);
			} else {
				return _source.getValue(d);
			}
		}
		
		/**
		 * Retrives and optionally creates a label TextSprite for the given
		 *  data sprite. 
		 * @param d the data sprite to process
		 * @param create if true, a new label will be created as needed
		 * @param visible indicates if new labels should be visible by default
		 * @return the label
		 */
		protected function getLabel(d:DataSprite,
			create:Boolean=false, visible:Boolean=true):TextSprite
		{
			var label:TextSprite = _access.getValue(d);
			if (!label && !create) {
				return null;
			} else if (!label) {
				label = new TextSprite("", null, textMode);
				label.text = getLabelText(d);
				label.visible = visible;
				label.applyFormat(textFormat);
				
				_access.setValue(d, label);
				if (_policy == LAYER) {
					_labels.addChild(label);
					label.x = d.x + xOffset;
					label.y = d.y + yOffset;
				} else {
					d.addChild(label);
					label.mouseEnabled = false;
					label.mouseChildren = false;
					label.x = xOffset;
					label.y = yOffset;
				}
			}
			label.textMode = textMode;
			label.horizontalAnchor = horizontalAnchor;
			label.verticalAnchor = verticalAnchor;
			return label;
		}
		
	} // end of class Labeler
}