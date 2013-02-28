package
{
    import flash.events.Event;
    import flash.utils.ByteArray;
    
    import org.purepdf.elements.Paragraph;
    import org.purepdf.elements.images.ImageElement;
    import org.purepdf.io.RandomAccessFileOrArray;
    import org.purepdf.pdf.PdfDocument;
    import org.purepdf.pdf.codec.TiffImage;

    public class MultiPageTiff extends DefaultBasicExample
    {

        [Embed( source="assets/foxdog_multiplepages.tif", mimeType="application/octet-stream" )]
        private var cls1: Class;

        public function MultiPageTiff( d_list: Array = null )
        {
            super( [ "Creates a PDF file with images extracted from a mutipage tiff image" ] );
            registerDefaultFont();
        }

        override protected function execute( event: Event = null ): void
        {
            super.execute( event );
			PdfDocument.compress = false;
            var byte: ByteArray = new cls1();
            var ra: RandomAccessFileOrArray = new RandomAccessFileOrArray( byte );
            createDocument( "Multi page TIFF Image Example" );
            document.open();
            document.add( new Paragraph( "This is the tiff added with Image.getInstance:" ) );
            document.add( ImageElement.getInstance( byte ) );
            var pages: int = TiffImage.getNumberOfPages( ra );
            document.add( new Paragraph( "There are " + pages + " pages in the tiff file." ) );

            for ( var i: int = 0; i < pages;  )
            {
                ++i;
                document.add( TiffImage.getTiffImage( ra, i ) );
            }
            document.close();
            save();
        }
    }
}