package 
{
	import cmodule.as3_jpeg_wrapper.CLibInit;
	
	import com.adobe.images.PNGEncoder;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.utils.ByteArray;
	
	import org.purepdf.colors.RGBColor;
	import org.purepdf.elements.RectangleElement;
	import org.purepdf.elements.images.ImageElement;

	/**
	 * This example create a PDF document with
	 * a Windows WMF image file
	 * 
	 */
	public class BitmapImageSample extends DefaultBasicExample
	{
		[Embed(source="assets/foxdog.bmp", mimeType="application/octet-stream")]
		private var cls3: Class;
		
		public function BitmapImageSample()
		{
			super(["This example shows how to import a BMP image into purePDF"]);
		}
		
		override protected function execute(event:Event=null) : void
		{
			super.execute();
			
			createDocument("Bitmap Test");
			
			document.open();
			
			var bytes: ByteArray = new cls3() as ByteArray;
			var image: ImageElement = ImageElement.getInstance( bytes );
			trace( image.width, image.height );
			trace( image.scaledWidth, image.scaledHeight );
			image.scaleAbsolute( image.width * (72 / 96), image.height * (72 / 96) );
			document.add( image );
			
			// close and save the document
			document.close();
			save();
		}
	}
}