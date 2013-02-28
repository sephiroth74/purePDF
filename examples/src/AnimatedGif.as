package
{
	
	import flash.events.Event;
	import flash.utils.ByteArray;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getTimer;
	
	import org.purepdf.pdf.ByteBuffer;
	import org.purepdf.pdf.PageSize;
	import org.purepdf.pdf.PdfDocument;
	import org.purepdf.pdf.PdfWriter;
	import org.purepdf.pdf.codec.GifImage;
	
	/**
	 * Example of animated gif.
	 * Open a gif and write to the PDF document
	 * all the frames of the animated gif
	 * 
	 */
	public class AnimatedGif extends DefaultBasicExample
	{
		[Embed(source="assets/animated_gif.gif", mimeType="application/octet-stream")]
		private var cls1: Class;
		
		public function AnimatedGif()
		{
			super(["This example loads an animated gif file as ByteArray","and place into the PdfDocument each frame of the","gif image as single image"]);
		}
		
		override protected function execute(event:Event=null) : void
		{
			super.execute(event);
			
			createDocument("Animated GIF Image Example");
			document.open();
			
			var byte: ByteArray = new cls1();
			var image: GifImage  = new GifImage( byte );
			
			for( var k: int = 0; k < image.framesCount; k++ )
			{
				document.add( image.getImage( k+1 ) );
			}
			
			document.close();
			save();
		}
	}
}