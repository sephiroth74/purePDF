package
{
	import flash.events.Event;
	
	import org.purepdf.Font;
	import org.purepdf.colors.RGBColor;
	import org.purepdf.elements.Chunk;
	import org.purepdf.elements.Element;
	import org.purepdf.elements.Phrase;
	import org.purepdf.elements.RectangleElement;
	import org.purepdf.events.PageEvent;
	import org.purepdf.pdf.ColumnText;
	import org.purepdf.pdf.PdfAction;
	import org.purepdf.pdf.PdfContentByte;
	import org.purepdf.pdf.PdfPTable;
	import org.purepdf.pdf.fonts.BaseFont;
	import org.purepdf.pdf.fonts.FontsResourceFactory;
	import org.purepdf.resources.BuiltinFonts;

	public class HeaderFooter2 extends DefaultBasicExample
	{
		private var footer: PdfPTable;
		private var header: Phrase;
		
		private var font1: Font;
		private var font2: Font;
		private var font3: Font;

		public function HeaderFooter2()
		{
			super( ["This example will show how to create custom header/footer","and add actions to the footer element"] );
			
			registerDefaultFont();
			
			FontsResourceFactory.getInstance().registerFont( BaseFont.HELVETICA_BOLD, new BuiltinFonts.HELVETICA_BOLD() );
			
			var bf: BaseFont = BaseFont.createFont( BaseFont.HELVETICA, BaseFont.WINANSI, false, true );
			font3 = new Font( Font.HELVETICA, 12, Font.NORMAL, null, bf );
			font1 = new Font( Font.HELVETICA, 12, Font.NORMAL, RGBColor.LIGHT_GRAY, bf );
			font2 = new Font( Font.HELVETICA, 12, Font.BOLD, null, bf );
			
			header = new Phrase( "This is the header of the document.", font1 );
			footer = new PdfPTable( 4 );
			footer.totalWidth = 300;
			footer.defaultCell.horizontalAlignment = Element.ALIGN_CENTER;
			footer.defaultCell.border = RectangleElement.NO_BORDER;
			footer.addPhraseCell( Phrase.fromChunk( new Chunk( "First Page", font2 ).setAction( PdfAction.fromNamed( PdfAction.
							FIRSTPAGE ) ) ) );
			footer.addPhraseCell( Phrase.fromChunk( new Chunk( "Prev Page", font2 ).setAction( PdfAction.fromNamed( PdfAction.
							PREVPAGE ) ) ) );
			footer.addPhraseCell( Phrase.fromChunk( new Chunk( "Next Page", font2 ).setAction( PdfAction.fromNamed( PdfAction.
							NEXTPAGE ) ) ) );
			footer.addPhraseCell( Phrase.fromChunk( new Chunk( "Last Page", font2 ).setAction( PdfAction.fromNamed( PdfAction.
							LASTPAGE ) ) ) );
		}

		override protected function execute( event: Event = null ): void
		{
			super.execute();
			createDocument();
			document.addEventListener( PageEvent.PAGE_END, onEndPage );
			document.setMargins( 36, 36, 54, 72 );
			document.open();

			for ( var k: int = 0; k < 300; ++k )
			{
				document.add( new Phrase( "Quick brown fox jumps over the lazy dog. ", font3 ) );
			}
			document.close();
			save();
		}

		private function onEndPage( event: PageEvent ): void
		{
			var cb: PdfContentByte = writer.getDirectContent();

			if ( document.pageNumber > 1 )
			{
				ColumnText.showTextAligned( cb, Element.ALIGN_CENTER, header,
								( document.right() - document.left() ) / 2 + document.marginLeft,
								document.top() + 10,
								0 );
			}
			footer.writeSelectedRows2( 0, -1, ( document.right() - document.left() - 300 ) / 2 + document.marginLeft, document.
							bottom() - 10, cb );
		}
	}
}