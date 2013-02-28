package
{
	import flash.events.Event;
	
	import org.purepdf.Font;
	import org.purepdf.colors.RGBColor;
	import org.purepdf.elements.Anchor;
	import org.purepdf.elements.Chunk;
	import org.purepdf.pdf.fonts.BaseFont;
	import org.purepdf.resources.BuiltinFonts;
	import org.purepdf.pdf.fonts.FontsResourceFactory;

	public class HelloWorldAnchor extends DefaultBasicExample
	{
		[Embed(source="assets/fonts/Helvetica-Bold.afm", mimeType="application/octet-stream")] private var _font1: Class;
		[Embed(source="assets/fonts/Helvetica-BoldOblique.afm", mimeType="application/octet-stream")] private var _font2: Class;
		[Embed(source="assets/fonts/Helvetica-Oblique.afm", mimeType="application/octet-stream")] private var _font3: Class;
		
		public function HelloWorldAnchor()
		{
			super(["This example shows how to add external links using anchors","and creates links with different styles"]);
			registerDefaultFont();
		}
		
		override protected function execute(event:Event=null) : void
		{
			super.execute();
			
			FontsResourceFactory.getInstance().registerFont( BaseFont.HELVETICA_BOLD, new _font1() );
			FontsResourceFactory.getInstance().registerFont( BaseFont.HELVETICA_BOLDOBLIQUE, new _font2() );
			FontsResourceFactory.getInstance().registerFont( BaseFont.HELVETICA_OBLIQUE, new _font3() );
			
			createDocument("Hello World Anchor");
			document.open();
			
			var font: Font = new Font( Font.HELVETICA, 18, -1, RGBColor.BLACK );
			var link: Anchor = new Anchor("http://code.google.com/p/pdfcore", font );
			link.reference = "http://code.google.com/p/purepdf";
			document.add( link );
			
			font.style = Font.UNDERLINE;
			font.color = RGBColor.BLUE;
			link = new Anchor("http://code.google.com/p/pdfcore", font );
			link.reference = "http://code.google.com/p/purepdf";
			document.add( link );
			
			font.style = Font.UNDERLINE | Font.STRIKETHRU;
			font.color = RGBColor.RED;
			link = new Anchor("http://code.google.com/p/pdfcore", font );
			link.reference = "http://code.google.com/p/purepdf";
			document.add( link );
			
			font.style = Font.UNDERLINE | Font.STRIKETHRU | Font.BOLD;
			font.color = RGBColor.YELLOW;
			link = new Anchor("http://code.google.com/p/pdfcore", font );
			link.reference = "http://code.google.com/p/purepdf";
			document.add( link );
			
			font.style = Font.UNDERLINE | Font.ITALIC;
			font.color = RGBColor.MAGENTA;
			link = new Anchor("http://code.google.com/p/pdfcore", font );
			link.reference = "http://code.google.com/p/purepdf";
			document.add( link );
			
			font.style = Font.BOLDITALIC;
			font.color = RGBColor.GRAY;
			
			var chunk: Chunk = new Chunk( "http://code.google.com/p/purepdf", font );
			chunk.setBackground( RGBColor.DARK_GRAY, 5, 5, 5, 5 );
			
			link = Anchor.fromChunk( chunk );
			link.reference = "http://code.google.com/p/purepdf";
			document.add( link );
			
			
			document.close();
			save();
		}
	}
}