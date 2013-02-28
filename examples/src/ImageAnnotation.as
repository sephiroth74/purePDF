package
{
	import flash.events.Event;
	import flash.utils.ByteArray;
	
	import org.purepdf.colors.RGBColor;
	import org.purepdf.elements.Annotation;
	import org.purepdf.elements.RectangleElement;
	import org.purepdf.elements.images.ImageElement;

	public class ImageAnnotation extends DefaultBasicExample
	{
		[Embed(source="assets/image1.jpg", mimeType="application/octet-stream")]
		private var cls1: Class;
		
		public function ImageAnnotation(d_list:Array=null)
		{
			super(["Insert an image with an associated url annotation"]);
			registerDefaultFont();
		}
		
		override protected function execute(event:Event=null) : void
		{
			super.execute();
			
			createDocument( "Hello World" );
			document.open();
			
			var image: ImageElement = ImageElement.getInstance( new cls1() as ByteArray );
			var annot: Annotation = Annotation.createUrl( "http://blog.sephiroth.it" );
			annot.setDimensions( 0, 0, 100, 100 );
			
			image.annotation = annot;
			image.borderWidth = 5;
			image.borderSides = RectangleElement.LEFT | RectangleElement.TOP | RectangleElement.RIGHT | RectangleElement.BOTTOM;
			image.borderColor = new RGBColor( 201, 201, 201 );
			document.add( image );
			
			document.close();
			save();
		}
	}
}