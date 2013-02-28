package
{
	import flash.events.Event;
	
	import org.purepdf.Font;
	import org.purepdf.elements.Paragraph;
	import org.purepdf.pdf.fonts.BaseFont;
	import org.purepdf.resources.BuiltinFonts;
	import org.purepdf.pdf.fonts.FontsResourceFactory;
	
	public class HelloWorld2 extends DefaultBasicExample
	{
		public function HelloWorld2()
		{
			super(["This example shows how to add a simple text to the document","using a new registered font"]);
		}
		
		override protected function execute(event:Event=null) : void
		{
			super.execute();
			
			FontsResourceFactory.getInstance().registerFont( BaseFont.HELVETICA_BOLD, new BuiltinFonts.HELVETICA_BOLD() );
			FontsResourceFactory.getInstance().registerFont( BaseFont.HELVETICA_OBLIQUE, new BuiltinFonts.HELVETICA_OBLIQUE() );
			FontsResourceFactory.getInstance().registerFont( BaseFont.TIMES_BOLDITALIC, new BuiltinFonts.TIMES_BOLDITALIC() );
			FontsResourceFactory.getInstance().registerFont( BaseFont.COURIER, new BuiltinFonts.COURIER() );
			FontsResourceFactory.getInstance().registerFont( BaseFont.ZAPFDINGBATS, new BuiltinFonts.ZAPFDINGBATS() );
			
			createDocument( "Hello World" );
			document.open();
			
			var font: Font = new Font( Font.HELVETICA, 18, Font.BOLD );
			document.add( new Paragraph("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent vel lectus lorem. ", font) );
			
			font = new Font( Font.HELVETICA, 18, Font.ITALIC );
			document.add( new Paragraph("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent vel lectus lorem. ", font) );

			font = new Font( Font.TIMES_ROMAN, 18, Font.BOLDITALIC );
			document.add( new Paragraph("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent vel lectus lorem. ", font) );

			font = new Font( Font.COURIER, 18, Font.NORMAL );
			document.add( new Paragraph("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent vel lectus lorem. ", font) );

			font = new Font( Font.ZAPFDINGBATS, 18, Font.NORMAL );
			document.add( new Paragraph("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent vel lectus lorem. ", font) );

			
			document.close();
			save();
		}
	}
}