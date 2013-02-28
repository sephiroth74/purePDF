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
	
	public class FontHowTo2 extends Sprite
	{
		private var writer: PdfWriter;
		private var document: PdfDocument;
		private var buffer: ByteArray;
		
		// embed the otf font file
		[Embed(source="/Users/alessandro/Library/Fonts/CarolinaLTStd.otf", mimeType="application/octet-stream")] private var cls1: Class;
		
		public function FontHowTo2()
		{
			buffer = new ByteArray();
			writer = PdfWriter.create( buffer, PageSize.A4 );
			document = writer.pdfDocument;
			
			// register 'CarolinaLTStd' font
			FontsResourceFactory.getInstance().registerFont("CarolinaLTStd.otf", new cls1());
			
			document.open();
			
			var bf: BaseFont = BaseFont.createFont("CarolinaLTStd.otf", BaseFont.CP1252, BaseFont.EMBEDDED );
			var font: Font = new Font( -1, -1, -1, RGBColor.BLACK, bf );
			
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
			file.save( buffer, "font_example2.pdf" );
		}
		
	}
}