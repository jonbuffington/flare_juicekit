package {
	import flash.display.Sprite;
	import flare.demos.Smoke;
	import flare.util.Button;
	import flash.utils.getQualifiedClassName;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.display.DisplayObject;
	import flare.demos.Graph;
	import flash.text.TextFormat;
	import flash.text.TextFieldAutoSize;
	import flare.demos.Animation;
	import flare.demos.TreeMap;
	import flash.utils.Dictionary;
	import flare.demos.GraphView;
	import flash.display.Shape;
	import flare.vis.util.graphics.GraphicsUtil;
	import flare.vis.data.DataSprite;
	import flare.animate.Transitioner;
	import flare.animate.Tween;
	import flare.demos.Stacks;
	import flare.demos.Chart;
	import flare.display.TextSprite;
	import flare.demos.Timeline;
	import flare.demos.Pie;
	import flare.demos.Bars;
	import flare.vis.data.Data;
	import flare.util.Strings;
	import flare.demos.Distortion;
	import flash.filters.GlowFilter;
	import flare.animate.Transition;
	import flare.animate.Sequence;
	import flare.animate.Easing;

	[SWF(width="800", height="600", backgroundColor="#ffffff", frameRate="30")]
	public class demos extends Sprite
	{
		public static const WIDTH:Number = 800;
		public static const HEIGHT:Number = 600;
		
		//[Embed(fontFamily="Verdana",source="c:\\windows\\fonts\\verdana.ttf")]
		//private var _verdana_str:String;
		
		private var _demos:Array;
		private var _cancel:Button;
		private var _buttons:Sprite;
		private var _demo:Sprite;
		private var _logo:FlareLogo;
		private var _cur:uint;
		
		public function demos()
		{
			// create logo
			_logo = createLogo();
			_logo.x = stage.stageWidth / 2;
			_logo.y = stage.stageHeight/2 - _logo.height / 2;
			addChild(_logo);
				
			// create demos
			_demo = new Sprite();
			addChild(_demo);
			_buttons = createDemos();
			_buttons.x = (stage.stageWidth - _buttons.width) / 2;
			_buttons.y = 7*stage.stageHeight/8 - _buttons.height / 2;
			addChild(_buttons);
			
			// create cancel button
			_cancel = new Button("Back");
			_cancel.visible = false;
			_cancel.x = stage.stageWidth - 10 - _cancel.width;
			_cancel.y = stage.stageHeight - 10 - _cancel.height;
			_cancel.addEventListener(MouseEvent.CLICK, cancel);
			addChild(_cancel);
		}
		
		private function createDemos():Sprite
		{
			_demos = new Array();
			_demos.push(new Animation());
			_demos.push(new Smoke());
			//_demos.push(new Graph());
			_demos.push(new Distortion());
			_demos.push(new GraphView());
			_demos.push(new TreeMap());
			_demos.push(new Stacks());
			_demos.push(new Timeline());
			_demos.push(new Chart());
			_demos.push(new Bars());
			_demos.push(new Pie());
			
			var s:Sprite = new Sprite();
			var w:Number = 0;
			
			for (var i:uint=0; i<_demos.length; ++i) {
				var b:Button = new Button(_demos[i].name);
				b.addEventListener(MouseEvent.CLICK, showDemo);
				b.x = w;
				w += b.width + 4;
				s.addChild(b);
			}
			return s;
		}
		
		private function createLogo():FlareLogo
		{
			/*
			var fmt:TextFormat = new TextFormat("Sydnie",92,0,true,false);
			var ts:TextSprite = new TextSprite("flare", fmt);
			ts.filters = [new GlowFilter(0xff0000, 0.5, 0, 0, 2)];
			
			var t1:Tween = new Tween(ts, 5, 0, {"filters[0].blurX":16, "filters[0].blurY":16});
			var t2:Tween = new Tween(ts, 5, 0, {"filters[0].blurX":0, "filters[0].blurY":0});
			t1.easing = t2.easing = Easing.none;
			_logoAnim = new Sequence(t1, t2);
			_logoAnim.easing = Easing.easeInOutPoly(2);
			_logoAnim.onEnd = function():void { _logoAnim.play(); }
			_logoAnim.play();
			
			return ts;
			*/
			var logo:FlareLogo = new FlareLogo();
			logo.play();
			return logo;
		}
		
		private function showDemo(event:MouseEvent):void
		{
			var tgt:DisplayObject = event.target as DisplayObject;
			_cur = _buttons.getChildIndex(tgt);
			_demo.alpha = 0;
			_demo.addChild(_demos[_cur] as Sprite);
			_cancel.alpha = 0;
			_cancel.visible = true;
			
			var t:Transitioner = new Transitioner(1);
			t.$(_buttons).alpha = 0;
			t.$(_logo).alpha = 0;
			t.onEnd = function():void {
				_buttons.visible = false;
			};
			t.play();
						
			t = new Transitioner(1);
			t.delay = 0.5;
			t.onStart = function():void {
				_demos[_cur].play();
			}
			t.$(_cancel).alpha = 1;
			t.$(_demo).alpha = 1;
			t.play();
			_logo.pause();
		}
		
		private function cancel(event:MouseEvent):void
		{
			_buttons.visible = true;
			
			var t:Transitioner = new Transitioner(1);
			t.$(_demo).alpha = 0;
			t.$(_cancel).alpha = 0;
			t.onEnd = function():void {
				_demos[_cur].stop();
				_demo.removeChild(_demos[_cur] as Sprite);
				_cur = 0;
				_cancel.visible = false;
			}
			t.play();
			
			t = new Transitioner(1);
			t.delay = 0.5;
			t.$(_buttons).alpha = 1;
			t.$(_logo).alpha = 1;
			t.play();
			_logo.play();
		}
		
	}
}