package
{
	import flash.events.Event;
	
	import org.purepdf.Font;
	import org.purepdf.pdf.fonts.BaseFont;
	import org.purepdf.elements.*;
	import org.purepdf.resources.BuiltinFonts;
	import org.purepdf.pdf.fonts.FontsResourceFactory;

	public class HelloWorldTTF extends DefaultBasicExample
	{
		[Embed(source="/Users/alessandro/Library/Fonts/CarolinaLTStd.otf", mimeType="application/octet-stream")] private var cls1: Class;
		[Embed(source="/Library/Fonts/Herculanum.ttf", mimeType="application/octet-stream")] private var cls2: Class;
		
		public function HelloWorldTTF()
		{
			super(["This example shows how to load and use .otf and  .ttf font files","and embed them to the output pdf document"]);
			registerDefaultFont();
			
			// register the 2 more fonts
			FontsResourceFactory.getInstance().registerFont("CarolinaLTStd.otf", new cls1());
			FontsResourceFactory.getInstance().registerFont("Herculanum.ttf", new cls2());
		}
		
		override protected function execute(event:Event=null) : void
		{
			super.execute();

			
			createDocument("Hello World Embedded fonts");
			document.open();
			
			// First font
			var bf: BaseFont = BaseFont.createFont("CarolinaLTStd.otf", BaseFont.CP1252, BaseFont.EMBEDDED );
			var font: Font = new Font( -1, 18, -1, null, bf );
			
			document.add( new Paragraph("Font: " + bf.getFamilyFontName().join(","), font ) );
			document.add( Chunk.NEWLINE );
			document.add( new Paragraph("Encoding: " + bf.encoding, font ) );
			document.add( Chunk.NEWLINE );
			
			document.add( new Paragraph("qwertyuiopasdfghjklzxcvbnm", font ) );
			document.add( new Paragraph("QWERTYUIOPASDFGHJKLZXCVBNM", font ) );
			document.add( new Paragraph("1234567890", font ) );
			document.add( new Paragraph("!\"£$%&/()=", font ) );
			document.add( new Paragraph("|\\?^'ìè+é*òàùç°§,.-;:_<>", font ) );
			document.add( new Paragraph("@#¶][", font ) );
			
			document.add( Chunk.NEWLINE );
			document.add( Chunk.NEWLINE );
			
			// Second Font
			bf = BaseFont.createFont("Herculanum.ttf", BaseFont.CP1252, BaseFont.EMBEDDED );
			font = new Font( -1, 18, -1, null, bf );
			
			document.add( new Paragraph("Font: " + bf.getFamilyFontName().join(","), font ) );
			document.add( Chunk.NEWLINE );
			document.add( new Paragraph("Encoding: " + bf.encoding, font ) );
			document.add( Chunk.NEWLINE );
			
			document.add( new Paragraph("qwertyuiopasdfghjklzxcvbnm", font ) );
			document.add( new Paragraph("QWERTYUIOPASDFGHJKLZXCVBNM", font ) );
			document.add( new Paragraph("1234567890", font ) );
			document.add( new Paragraph("!\"£$%&/()=", font ) );
			document.add( new Paragraph("|\\?^'ìè+é*òàùç°§,.-;:_<>", font ) );
			document.add( new Paragraph("@#¶][", font ) );
			
			
			
			document.close();
			save();
			
			
		}
	}
}