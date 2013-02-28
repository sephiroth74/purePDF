package
{
	import flash.events.Event;
	
	import org.purepdf.Font;
	import org.purepdf.elements.Chunk;
	import org.purepdf.elements.Paragraph;
	import org.purepdf.pdf.fonts.BaseFont;
	import org.purepdf.resources.BuiltinFonts;
	import org.purepdf.pdf.fonts.FontsResourceFactory;

	public class HelloSplitCharacter extends DefaultBasicExample
	{
		public function HelloSplitCharacter(d_list:Array=null)
		{
			super(["This example will show how to create your own","custom ISplitCharacter class in order to use","custom newline split behaviors"]);
			registerDefaultFont();
		}
		
		override protected function execute(event:Event=null) : void
		{
			super.execute();
			
			createDocument("Split character");
			document.open();
			
			var urlChunk: Chunk;
			var p: Paragraph;
			var font: Font = new Font( Font.HELVETICA, 18 );
			var text: String = "This is the link that explains the sentence 'Quick brown fox jumps over the lazy dog: ";
			var url: String = "http://en.wikipedia.org/wiki/The_quick_brown_fox_jumps_over_the_lazy_dog";
			
			document.add( new Paragraph("Default split character", font ) );
			p = Paragraph.fromChunk( new Chunk( text, font ), 24 );
			urlChunk = new Chunk( url, font );
			p.add( urlChunk );
			document.add( p );
			
			document.add( Chunk.NEWLINE );
			
			document.add( new Paragraph("Space and forward slash are split characters" ) );
			p = Paragraph.fromChunk( new Chunk( text, font ), 24 );
			urlChunk = new Chunk( url, font );
			urlChunk.setSplitCharacter( new TestSplit() );
			p.add( urlChunk );
			document.add( p );
			
			document.close();
			save();
		}
	}
}
import org.purepdf.ISplitCharacter;
import org.purepdf.pdf.PdfChunk;


class TestSplit implements ISplitCharacter
{
	public function isSplitCharacter( start: int, current: int, end: int, cc: Vector.<int>, ck: Vector.<PdfChunk> ): Boolean
	{
		var c: int;
		if( ck == null )
			c = cc[current];
		else
			c = ck[Math.min( current, ck.length - 1 )].getUnicodeEquivalent( cc[current] );
		return c == '/'.charCodeAt(0) || c == ' '.charCodeAt(0);
		
		
	}
}