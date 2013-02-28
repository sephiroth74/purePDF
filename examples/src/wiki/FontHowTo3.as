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
	
	public class FontHowTo3 extends Sprite
	{
		private var writer: PdfWriter;
		private var document: PdfDocument;
		private var buffer: ByteArray;
		
		// embed the otf font file
		[Embed(source="assets/fonts/AoyagiKouzanFont2.ttf", mimeType="application/octet-stream")] private var cls1: Class;
		
		public function FontHowTo3()
		{
			buffer = new ByteArray();
			writer = PdfWriter.create( buffer, PageSize.A4 );
			document = writer.pdfDocument;
			
			// register 'CarolinaLTStd' font
			FontsResourceFactory.getInstance().registerFont("japanese_unicode.otf", new cls1());
			
			document.open();
			
			var bf: BaseFont = BaseFont.createFont("japanese_unicode.otf", BaseFont.IDENTITY_H, BaseFont.EMBEDDED );
			var font: Font = new Font( -1, 24, -1, RGBColor.BLACK, bf );
			
			document.add( new Paragraph("\u7121\u540d\u540e\u540f\u5410\u5421\u5413", font ) );
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
			file.save( buffer, "font_example3.pdf" );
		}
		
	}
}