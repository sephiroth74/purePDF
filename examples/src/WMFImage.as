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
	public class WMFImage extends DefaultBasicExample
	{
		[Embed(source="assets/woodwork.wmf", mimeType="application/octet-stream")]
		private var cls3: Class;
		
		public function WMFImage()
		{
			super(["This example show how you can Windows meta files","WMF into purePDF"]);
		}
		
		override protected function execute(event:Event=null) : void
		{
			super.execute();
			
			createDocument("Place a Windows WMF image file");
			
			document.open();
			
			// ---------------
			// WMF Image
			// ---------------
			var bytes: ByteArray = new cls3() as ByteArray;
			var image: ImageElement = ImageElement.getInstance( bytes );
			document.add( image );
			
			// close and save the document
			document.close();
			save();
		}
	}
}