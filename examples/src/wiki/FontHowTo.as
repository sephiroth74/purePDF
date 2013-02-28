package wiki
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	
	import org.purepdf.Font;
	import org.purepdf.colors.RGBColor;
	import org.purepdf.elements.Paragraph;
	import org.purepdf.pdf.PageSize;
	import org.purepdf.pdf.PdfDocument;
	import org.purepdf.pdf.PdfWriter;
	import org.purepdf.pdf.fonts.BaseFont;
	import org.purepdf.pdf.fonts.FontsResourceFactory;
	import org.purepdf.resources.BuiltinFonts;

	public class FontHowTo extends Sprite
	{
		private var writer: PdfWriter;
		private var document: PdfDocument;
		private var buffer: ByteArray;
		
		public function FontHowTo()
		{
			buffer = new ByteArray();
			writer = PdfWriter.create( buffer, PageSize.A4 );
			document = writer.pdfDocument;

			// register 'Helvetica' font
			FontsResourceFactory.getInstance().registerFont( BaseFont.HELVETICA, new BuiltinFonts.HELVETICA() );
			
			document.open();
			
			// create a simple Paragraph using the default font
			// remember that the default font, if not specified is 'Helvetica'
			document.add( new Paragraph("Hello World" ) );
			
			// explicit declare the font
			var font: Font = new Font( Font.HELVETICA, 12, Font.NORMAL, RGBColor.DARK_GRAY, null );
			document.add( new Paragraph("Hello World", font ) );
			
			// create a new font using a BaseFont as source
			var baseFont: BaseFont = BaseFont.createFont( BaseFont.HELVETICA, BaseFont.WINANSI );
			font = new Font( Font.UNDEFINED, Font.UNDEFINED, Font.UNDEFINED, RGBColor.LIGHT_GRAY, baseFont );
			document.add( new Paragraph("Hello World", font ) );
			
			document.close();
			
			// create a simple button in order to let download
			// the created pdf file
			var button: Sprite = new Sprite();
			button.graphics.beginFill(0);
			button.graphics.drawRect( 0, 0, 100, 100 );
			button.addEventListener( MouseEvent.CLICK, onClick );
			addChild( button );
		}
		
		private function onClick( event: Event ): void
		{
			var file: FileReference = new FileReference();
			file.save( buffer, "font_example.pdf" );
		}
		
	}
}