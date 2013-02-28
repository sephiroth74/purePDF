package
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.utils.ByteArray;
	
	import org.purepdf.colors.RGBColor;
	import org.purepdf.elements.images.ImageElement;
	import org.purepdf.pdf.PdfContentByte;

	public class Transparency extends DefaultBasicExample
	{
		[Embed(source="assets/image1.jpg")]
		private var cls1: Class;
		
		public function Transparency()
		{
			super(["Create an image and apply a mask to emulate transparency"]);
		}
		
		
		override protected function execute(event:Event=null) : void
		{
			super.execute();
			
			var bmp: BitmapData = ( new cls1() as Bitmap ).bitmapData;
			createDocument("Transparency Example");
			
			document.open();
			
			var cb: PdfContentByte = document.getDirectContent();
			
			cb.setColorFill( RGBColor.BLUE );
			cb.circle( 390, 350, 100 );
			cb.fill();
			cb.resetFill();
			
			// create the jpeg image
			var baSource: ByteArray = bmp.getPixels( bmp.rect );
			var bytes: ByteArray = jpegLib.write_jpeg_file( baSource, bmp.width, bmp.height, 3, 2, 90 );
			
			var img: ImageElement = ImageElement.getInstance( bytes );
			img.setAbsolutePosition( 100, 350 );
			
			// create the image mask
			var gradient: ByteArray = new ByteArray();
			
			for( var k: int = 0; k < 256; ++k )
				gradient.writeByte( k );
			
			var mask: ImageElement = ImageElement.getRawInstance( 256, 1, 1, 8, gradient, null ); 
			mask.makeMask();
			img.imageMask = mask;
			
			cb.addImage( img );
			
			
			document.close();
			save();
		}
	}
}