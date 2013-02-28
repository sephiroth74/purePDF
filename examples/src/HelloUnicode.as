package
{
	import flash.events.Event;
	
	import org.purepdf.pdf.PdfContentByte;
	import org.purepdf.pdf.fonts.BaseFont;
	import org.purepdf.pdf.fonts.FontsResourceFactory;

	public class HelloUnicode extends DefaultBasicExample
	{
		[Embed(source="assets/fonts/AoyagiKouzanFont2.ttf", mimeType="application/octet-stream")] private var arialu: Class;
		
		public function HelloUnicode()
		{
			super(["Embed a japanese font and write","some unicode chars"]);
			FontsResourceFactory.getInstance().registerFont("japanese_unicode.ttf", new arialu() );
		}
		
		override protected function execute(event:Event=null) : void
		{
			super.execute();
			createDocument();
			document.open();
			
			
			var bf: BaseFont = BaseFont.createFont( "japanese_unicode.ttf", BaseFont.IDENTITY_H, true, true );
			var cb: PdfContentByte = document.getDirectContent();
			cb.beginText();
			cb.setFontAndSize( bf, 32 );
			cb.moveText( 36, 800 );
			cb.showText( "\u7121\u540d\u540e\u540f\u5410\u5421\u5413" );
			cb.endText();
			
			document.close();
			save();
		}
	}
}