package
{
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.events.TimerEvent;
    import flash.net.FileReference;
    import flash.utils.ByteArray;
    import flash.utils.Timer;
    import flash.utils.getQualifiedClassName;
    
    import org.purepdf.elements.RectangleElement;
    import org.purepdf.elements.images.ImageElement;
    import org.purepdf.io.RandomAccessFileOrArray;
    import org.purepdf.pdf.PageSize;
    import org.purepdf.pdf.PdfDocument;
    import org.purepdf.pdf.PdfViewPreferences;
    import org.purepdf.pdf.PdfWriter;
    import org.purepdf.pdf.codec.TiffImage;

    public class TestTIF extends Sprite
    {
        [Embed( source="assets/20080143380-010.tif", mimeType="application/octet-stream" )]
        private var cls1: Class;
		
        private var document: PdfDocument;
        private var writer: PdfWriter;
        private var buffer: ByteArray;
        private var filename: String;
        private var index: int;
        private var pages: int;
        private var stream: RandomAccessFileOrArray;

        public function TestTIF()
        {
            super();
			addEventListener( Event.ADDED_TO_STAGE, onAdded );
		}
		
		private function onAdded( event: Event ): void
		{
            stage.addEventListener( MouseEvent.CLICK, onClick );
        }

        private function createDocument( subject: String = null, rect: RectangleElement = null ): void
        {
            buffer = new ByteArray();

            if ( rect == null )
                rect = PageSize.A4;
            writer = PdfWriter.create( buffer, rect );
            document = writer.pdfDocument;
            document.addTitle( getQualifiedClassName( this ) );

            if ( subject )
                document.addSubject( subject );
            document.setViewerPreferences( PdfViewPreferences.FitWindow );
        }

        private function onClick( event: Event ): void
        {
            filename = getQualifiedClassName( this ).split( "::" ).pop() + ".pdf";
            var byte: ByteArray = new cls1();
            stream = new RandomAccessFileOrArray( byte );
            var image: ImageElement = ImageElement.getInstance( byte );
            createDocument( "Multi page TIFF Image Example", new RectangleElement( 0, 0, image.width, image.height ) );
            document.open();
            // add the first page to the document
            document.add( image );
            // get the total number of pages
            pages = TiffImage.getNumberOfPages( stream );
			trace("number of pages: " + pages );
            // next page index to add to document (first page is 1)
            index = 2;
            var timer: Timer = new Timer( 100, 1 );
            timer.addEventListener( TimerEvent.TIMER, onTimerComplete );
            timer.start();
        }

        private function onComplete(): void
        {
            stream.close();
            document.close();
            save();
        }

        private function onTimerComplete( event: TimerEvent ): void
        {
            if ( index > pages )
            {
                onComplete();
                return;
            }
            document.add( TiffImage.getTiffImage( stream, index ) );
            index++;
            Timer( event.target ).reset();
            Timer( event.target ).start();
        }

        private function save( e: * = null ): void
        {
            var f: FileReference = new FileReference();
            f.save( buffer, filename );
        }
    }
}