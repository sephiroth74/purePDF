package
{
	import flash.events.Event;
	
	import org.purepdf.Font;
	import org.purepdf.colors.RGBColor;
	import org.purepdf.elements.Chunk;
	import org.purepdf.elements.Element;
	import org.purepdf.elements.Paragraph;
	import org.purepdf.elements.Phrase;
	import org.purepdf.pdf.PdfContentByte;
	import org.purepdf.pdf.fonts.BaseFont;
	import org.purepdf.resources.BuiltinFonts;
	import org.purepdf.pdf.fonts.FontsResourceFactory;
	
	public class PhraseExample extends DefaultBasicExample
	{
		public function PhraseExample(d_list:Array=null)
		{
			super(["Create a document adding some phrase elements"]);

			registerDefaultFont();
			FontsResourceFactory.getInstance().registerFont( BaseFont.TIMES_ITALIC, new BuiltinFonts.TIMES_ITALIC() );
			FontsResourceFactory.getInstance().registerFont( BaseFont.COURIER_BOLD, new BuiltinFonts.COURIER_BOLD() );
		}
		
		override protected function execute(event:Event=null) : void
		{
			super.execute();
			
			
			createDocument();
			document.open();
			
			var font: Font = new Font(Font.COURIER, 10, Font.BOLD);
			font.color = RGBColor.WHITE;
			var fox: Chunk = new Chunk("Quick brown fox", font);
			var superscript: Number = 8.0;
			fox.setTextRise( superscript );
			fox.setBackground( new RGBColor(0xa5, 0x2a, 0x2a));
			var jumps: Chunk = new Chunk(" jumps over ", new Font());
			var dog: Chunk = new Chunk("the lazy dog.", new Font(Font.TIMES_ROMAN, 14, Font.ITALIC));
			var subscript: Number = -8.0;
			dog.setTextRise(subscript);
			dog.setUnderline( new RGBColor(0xFF, 0x00, 0x00), 3.0, 0.0, -5.0 + subscript, 0.0, PdfContentByte.LINE_CAP_ROUND );
			var space: Chunk = new Chunk(' ');
			var phrase: Phrase = new Phrase(null,null,30);
			phrase.add(fox);
			phrase.add(jumps);
			phrase.add(dog);
			phrase.add(space);
			
			var i: int;
			for (i = 0; i < 10; i++)
				document.add(phrase);
			document.add(Chunk.NEWLINE);
			document.add(phrase);
			phrase.add("\n");
			for ( i = 0; i < 3; i++) {
				document.add(phrase);
			}
			
			document.close();
			save();
		}
	}
}