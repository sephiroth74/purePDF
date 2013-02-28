package
{
	import flash.events.Event;
	import flash.utils.ByteArray;
	
	import org.purepdf.elements.RectangleElement;
	import org.purepdf.elements.images.ImageElement;
	import org.purepdf.events.PageEvent;
	import org.purepdf.pdf.PdfTransition;
	import org.purepdf.pdf.PdfVersion;
	import org.purepdf.pdf.PdfViewPreferences;
	import org.purepdf.pdf.codec.GifImage;

	public class SlideShow extends DefaultBasicExample
	{
		[Embed(source="assets/animated_gif.gif", mimeType="application/octet-stream")]
		private var cls: Class;
		
		public function SlideShow()
		{
			super(["This Example will show how to create","page transitions and page durations"]);
		}
		
		private function onStartPage( event: PageEvent ): void
		{
			var transition: PdfTransition = PdfTransition.RANDOM;
			document.transition = transition;
			document.duration = 2;
		}
		
		override protected function execute(event:Event=null) : void
		{
			super.execute();
			
			var rect: RectangleElement = new RectangleElement( 0, 0, 144, 115 );
			
			createDocument("SlideShow Example", rect );
			document.addEventListener( PageEvent.PAGE_START, onStartPage );
			document.setPdfVersion( PdfVersion.VERSION_1_5 );
			
			document.open();
			document.setViewerPreferences( PdfViewPreferences.PageModeFullScreen );
			
			var image: GifImage  = new GifImage( new cls() as ByteArray );
			for( var a: int = 0; a < GifImage(image).framesCount; a++ )
			{
				var img: ImageElement = GifImage( image ).getImage( a + 1 );
				img.setAbsolutePosition( 0, 0 );
				document.add( img );
				document.newPage();
			}
			
			document.close();
			save();
		}
	}
}