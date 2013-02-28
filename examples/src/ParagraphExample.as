package
{
	import flash.events.Event;
	
	import org.purepdf.Font;
	import org.purepdf.elements.Chunk;
	import org.purepdf.elements.Element;
	import org.purepdf.elements.Paragraph;
	import org.purepdf.elements.Phrase;
	import org.purepdf.pdf.fonts.BaseFont;
	import org.purepdf.resources.BuiltinFonts;
	import org.purepdf.pdf.fonts.FontsResourceFactory;

	public class ParagraphExample extends DefaultBasicExample
	{
		public function ParagraphExample()
		{
			super(["Create a document adding some paragraph elements to it"]);
			registerDefaultFont();
			FontsResourceFactory.getInstance().registerFont( BaseFont.TIMES_ROMAN, new BuiltinFonts.TIMES_ROMAN() );
			FontsResourceFactory.getInstance().registerFont( BaseFont.COURIER, new BuiltinFonts.COURIER() );
		}
		
		override protected function execute(event:Event=null) : void
		{
			super.execute();
			
			createDocument();
			document.open();
			
			var space: Chunk = new Chunk(' ');
			var text: String = "Lorem ipsum dolor sit amet, consectetur adipiscing elit.";
			var phrase1: Phrase = new Phrase(text,null);
			var phrase2: Phrase = Phrase.fromChunk(new Chunk(text, new Font(Font.TIMES_ROMAN)));
			var phrase3: Phrase = new Phrase(text, new Font(Font.HELVETICA));
			var paragraph: Paragraph = new Paragraph(null);
			paragraph.add(phrase1);
			paragraph.add(space);
			paragraph.add(phrase2);
			paragraph.add(space);
			paragraph.add(phrase3);
			document.add(paragraph);
			document.add(paragraph);
			paragraph.alignment = Element.ALIGN_LEFT;
			document.add(paragraph);
			paragraph.alignment = Element.ALIGN_CENTER;
			document.add(paragraph);
			paragraph.alignment = Element.ALIGN_RIGHT;
			document.add(paragraph);
			paragraph.alignment = Element.ALIGN_JUSTIFIED;
			document.add(paragraph);
			paragraph.spacingBefore = 10;
			document.add(paragraph);
			paragraph.spacingBefore = 0;
			paragraph.spacingAfter = 10;
			document.add(paragraph);
			paragraph.indentationLeft = 20;
			document.add(paragraph);
			paragraph.indentationRight = 20;
			document.add(paragraph);
			
			document.close();
			save();
		}
	}
}