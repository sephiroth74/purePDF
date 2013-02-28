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
	 * different type of images ( png, jpeg, bitmapdata )
	 * 
	 * Test also image scaling, alignment, absolute positioning..
	 * 
	 */
	public class ImageTypes extends DefaultBasicExample
	{
		[Embed(source="assets/image1.jpg")]
		private var cls1: Class;
		
		[Embed(source="assets/appicondocsec.png")]
		private var cls2: Class;
		
		[Embed(source="assets/hitchcock.gif", mimeType="application/octet-stream")]
		private var cls3: Class;
		
		public function ImageTypes()
		{
			super();
		}
		
		override protected function execute(event:Event=null) : void
		{
			super.execute();
			
			var bmp: BitmapData = ( new cls1() as Bitmap ).bitmapData;
			createDocument("Image Types Example");
			
			document.open();
			
			// ---------------
			// JPEG image
			// ---------------
			var baSource: ByteArray = bmp.getPixels( bmp.rect );
			var bytes: ByteArray = jpegLib.write_jpeg_file( baSource, bmp.width, bmp.height, 3, 2, 90 );
						
			var image1: ImageElement = ImageElement.getInstance( bytes );
			image1.alignment = ImageElement.RIGHT;	// set the image alignment
			image1.borderWidth = 5;
			image1.borderSides = RectangleElement.LEFT | RectangleElement.TOP | RectangleElement.RIGHT | RectangleElement.BOTTOM;
			image1.borderColor = new RGBColor( 255, 255, 255 );
			document.add( image1 );
			
			// test image scaling
			image1.scaleToFit( 50, 50 );
			image1.alignment = ImageElement.LEFT;
			document.add( image1 );
			
			image1.scalePercent( 100, 100 );
			image1.scaleAbsolute( 100, 100 );
			document.add( image1 );
			
			// ---------------
			// PNG image
			// ---------------
			bytes = PNGEncoder.encode( ( new cls2() as Bitmap ).bitmapData );
			var image: ImageElement = ImageElement.getInstance( bytes );
			image.alignment = ImageElement.MIDDLE;
			document.add( image );
			
			image.scaleToFit( 300, 300 );
			image.alignment = ImageElement.LEFT;
			document.add( image );
			
			// ---------------
			// GIF Image
			// ---------------
			bytes = new cls3() as ByteArray;
			image = ImageElement.getInstance( bytes );
			document.add( image );
			
			
			// ---------------
			// BitmapData image
			// ---------------
			bmp = new BitmapData( 100, 100 );
			bmp.lock();
			
			for( var k: int = 0; k < 100; ++k )
			{
				for( var j: int = 0; j < 100; ++j )
				{
					var c: uint = ((255 * Math.sin(j * .5 * Math.PI / 100)) << 16 ) | ((256 - j * 256 / 100) << 8 ) | (255 * Math.cos(k * .5 * Math.PI / 100));
					bmp.setPixel( k, j, c );
				}
			}
			
			bmp.unlock();
			
			image = ImageElement.getRawInstance( 100, 100, 4, 8, bmp.getPixels( bmp.rect ) );
			image.setAbsolutePosition( 100, 200 );
			image.setRotation( Math.PI / 4 );
			
			document.add( image );
			
			
			// close and save the document
			document.close();
			save();
		}
	}
}