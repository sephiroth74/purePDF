package
{
	import flash.events.Event;
	
	import org.purepdf.elements.Element;
	import org.purepdf.pdf.PdfContentByte;
	import org.purepdf.pdf.fonts.BaseFont;
	import org.purepdf.resources.BuiltinFonts;
	import org.purepdf.pdf.fonts.FontsResourceFactory;

	public class HelloWorld4 extends DefaultBasicExample
	{
		public function HelloWorld4()
		{
			super(["Example of text alignment"]);
			registerDefaultFont();
		}
		
		override protected function execute(event:Event=null) : void
		{
			super.execute();

			createDocument("Hello World 4");
			document.open();
			
			var cb: PdfContentByte = document.getDirectContent();
			var font: BaseFont = BaseFont.createFont( BaseFont.HELVETICA, BaseFont.WINANSI );
			
			cb.beginText();
			cb.setFontAndSize( font, 24 );
			cb.showTextAligned( Element.ALIGN_LEFT, "Hello spammed world!", 36, 788, 0 );
			cb.endText();
			
			document.close();
			save();
		}
	}
}