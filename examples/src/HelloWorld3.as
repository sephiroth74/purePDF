package
{
	import flash.events.Event;
	
	import org.purepdf.pdf.PdfContentByte;
	import org.purepdf.pdf.fonts.BaseFont;
	import org.purepdf.resources.BuiltinFonts;
	import org.purepdf.pdf.fonts.FontsResourceFactory;

	public class HelloWorld3 extends DefaultBasicExample
	{
		public function HelloWorld3()
		{
			super(["Write text directly on the graphics content", "and assign a custom matrix to it"]);
			registerDefaultFont();
		}
		
		override protected function execute(event:Event=null) : void
		{
			super.execute();
			
			createDocument("Hello World 3");
			document.open();
			
			// contents
			var cb: PdfContentByte = document.getDirectContent();
			var bf: BaseFont = BaseFont.createFont( BaseFont.HELVETICA, BaseFont.CP1252, BaseFont.NOT_EMBEDDED );
			cb.saveState();
			cb.beginText();
			cb.moveText(36, 806);
			cb.moveText(0, -18);
			
			cb.setTextMatrix( 2, 0.912, 0.883, 2, 66, 588);
			cb.setFontAndSize(bf, 24);
			cb.showText("Hello World");
			cb.endText();
			cb.restoreState();
			
			document.close();
			save();
		}
	}
}