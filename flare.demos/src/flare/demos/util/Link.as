package flare.demos.util
{
	import flare.display.TextSprite;
	
	import flash.events.MouseEvent;
	import flash.text.TextFormat;

	public class Link extends TextSprite
	{
		public var textColor:uint = 0x000000;
		public var hoverColor:uint = 0xff0000;
		
		public function Link(text:String=null, size:int=20)
		{
			super(text, new TextFormat("Calibri,Arial",size,textColor));
			name = text;
			buttonMode = true;
			mouseChildren = false;
			
			addEventListener(MouseEvent.ROLL_OVER, function(event:MouseEvent):void {
				color = hoverColor;
			});
			addEventListener(MouseEvent.ROLL_OUT, function(event:MouseEvent):void {
				color = textColor;
			});
		}
		
	}
}