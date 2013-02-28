package
{
    import flash.events.Event;
    import org.purepdf.Font;
    import org.purepdf.colors.RGBColor;
    import org.purepdf.colors.SpotColor;
    import org.purepdf.elements.Element;
    import org.purepdf.elements.HeaderFooter;
    import org.purepdf.elements.Paragraph;
    import org.purepdf.elements.Phrase;
    import org.purepdf.elements.RectangleElement;
    import org.purepdf.events.PageEvent;
    import org.purepdf.pdf.PdfContentByte;
    import org.purepdf.pdf.PdfTemplate;
    import org.purepdf.pdf.fonts.BaseFont;
    import org.purepdf.pdf.fonts.FontsResourceFactory;
    import org.purepdf.resources.BuiltinFonts;

    public class HeaderFooter3 extends DefaultBasicExample
    {
        private var cb: PdfContentByte;
        private var font3: Font;
        private var footerBaseFont: BaseFont;
        private var footerFontSize: int = 11;
        private var headerFont: Font;
        private var template: PdfTemplate;

        public function HeaderFooter3()
        {
            super( [ "This example shows how to add a custom footer", "to display page x of y" ] );
            
			registerDefaultFont();
            FontsResourceFactory.getInstance().registerFont( BaseFont.HELVETICA_BOLD, new BuiltinFonts.HELVETICA_BOLD() );
            FontsResourceFactory.getInstance().registerFont( BaseFont.TIMES_ITALIC, new BuiltinFonts.TIMES_ITALIC() );
			
            headerFont = new Font( Font.TIMES_ROMAN, 10, Font.ITALIC, new RGBColor( 100, 100, 100 ) );
            footerBaseFont = BaseFont.createFont( BaseFont.HELVETICA, BaseFont.WINANSI, false, true );
            
			var bf: BaseFont = BaseFont.createFont( BaseFont.HELVETICA, BaseFont.WINANSI, false, true );
            font3 = new Font( Font.HELVETICA, 10, Font.NORMAL, null, bf );
        }

        public function onPageEnd( event: PageEvent ): void
        {
            var pageN: int = writer.pageNumber;
            var text: String = "Page " + pageN + " of ";
            var len: Number = footerBaseFont.getWidthPoint( text, footerFontSize );
            cb.beginText();
            cb.setFontAndSize( footerBaseFont, footerFontSize );
            cb.setTextMatrix( 1, 0, 0, 1, 280, 30 );
            cb.showText( text );
            cb.endText();
            cb.addTemplate( template, 1, 0, 0, 1, 280 + len, 30 );
            cb.beginText();
            cb.setFontAndSize( footerBaseFont, footerFontSize );
            cb.setTextMatrix( 1, 0, 0, 1, 280, 820 );
            cb.endText();
        }

        override protected function execute( event: Event = null ): void
        {
            super.execute();
            createDocument();
            var header: HeaderFooter = new HeaderFooter( new Phrase( "http://code.google.com/p/purepdf", headerFont ), null, false );
            header.alignment = Element.ALIGN_RIGHT;
            header.borderColor = new RGBColor( 100, 100, 100 );
            header.border = RectangleElement.BOTTOM;
            header.borderWidth = 0.5;
            document.setHeader( header );
            //document.setFooter( footer );
            document.addEventListener( PageEvent.DOCUMENT_OPEN, onDocumentOpen );
            document.addEventListener( PageEvent.DOCUMENT_CLOSE, onDocumentClose );
            document.addEventListener( PageEvent.PAGE_END, onPageEnd );
            document.setMargins( 36, 36, 54, 72 );
            document.open();

            for ( var k: int = 0; k < 300; ++k )
            {
                document.add( new Phrase( "Quick brown fox jumps over the lazy dog.\n", font3 ) );
            }
            document.close();
            save();
        }

        private function onDocumentClose( event: PageEvent ): void
        {
            trace( "onDocumentClose" );
            template.beginText();
            template.setFontAndSize( footerBaseFont, footerFontSize );
            template.showText( "" + ( writer.pageNumber - 1 ) );
            template.endText();
        }

        private function onDocumentOpen( event: PageEvent ): void
        {
            trace( "onDocumentOpen" );
            cb = writer.getDirectContent();
            template = cb.createTemplate( 150, 50 );
        }
    }
}