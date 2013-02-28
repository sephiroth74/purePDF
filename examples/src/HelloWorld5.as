package
{
	import flash.events.Event;
	
	import org.purepdf.pdf.PdfContentByte;
	import org.purepdf.pdf.PdfTemplate;
	import org.purepdf.pdf.fonts.BaseFont;
	import org.purepdf.resources.BuiltinFonts;
	import org.purepdf.pdf.fonts.FontsResourceFactory;

	public class HelloWorld5 extends DefaultBasicExample
	{
		public function HelloWorld5()
		{
			super(["Write some text and move it","Then create a template and write text on it"]);
			registerDefaultFont();
		}
		
		override protected function execute(event:Event=null) : void
		{
			super.execute();
			
			createDocument("HelloWorld5");
			document.open();
			
			var cb: PdfContentByte = document.getDirectContent();
			
			var bf: BaseFont = BaseFont.createFont( BaseFont.HELVETICA, BaseFont.CP1252, BaseFont.NOT_EMBEDDED );
			cb.beginText();
			cb.setFontAndSize(bf, 12);
			cb.moveText(88.66, 778);
			cb.showText("ld");
			cb.moveText(-22, -10); 
			cb.showText("Wor");
			cb.moveText(-15.33, -20); 
			cb.showText("llo");
			cb.endText();
			
			var tmp: PdfTemplate = cb.createTemplate( 250, 25 );
			tmp.beginText();
			tmp.setFontAndSize(bf, 12);
			tmp.moveText(0, 7);
			tmp.showText("He");
			tmp.endText();
			cb.addTemplate(tmp, 1, 0, 0, 1, 36, 781);
			
			document.close();
			save();
		}
	}
}