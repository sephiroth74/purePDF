package
{
	import flash.events.Event;
	
	import org.purepdf.Font;
	import org.purepdf.elements.Chunk;
	import org.purepdf.elements.Paragraph;
	import org.purepdf.pdf.fonts.BaseFont;
	import org.purepdf.resources.BuiltinFonts;
	import org.purepdf.pdf.fonts.FontsResourceFactory;

	public class ChunkSkew extends DefaultBasicExample
	{
		public function ChunkSkew(d_list:Array=null)
		{
			super(["Adds chunks and set different skew factors"]);
			registerDefaultFont();
		}
		
		override protected function execute(event:Event=null) : void
		{
			super.execute();
			
			createDocument();
			document.open();
			
			var chunk: Chunk;
			var p: Paragraph = new Paragraph( null );
			
			chunk = new Chunk("1. Test chunk skew" );
			chunk.setSkew( 15, -30 );
			p.add( chunk );
			
			chunk = new Chunk("2. Test chunk skew" );
			chunk.setSkew( 15, 15 );
			p.add( chunk );
			
			chunk = new Chunk("3. Test chunk skew" );
			chunk.setSkew( -30, 15 );
			p.add( chunk );
			
			document.add( p );
			
			p = new Paragraph( null );
			document.add(Chunk.NEWLINE);
			document.add(Chunk.NEWLINE);
			document.add(Chunk.NEWLINE);
			p = new Paragraph( null );
			chunk = new Chunk("4. Test chunk skew");
			chunk.setSkew(45, 0);
			p.add(chunk);
			chunk = new Chunk("5. Test chunk skew");
			p.add(chunk);
			chunk = new Chunk("6. Test chunk skew");
			chunk.setSkew(-45, 0);
			p.add(chunk);
			document.add(p);
			
			document.add(Chunk.NEWLINE);
			document.add(Chunk.NEWLINE);
			document.add(Chunk.NEWLINE);
			p = new Paragraph( null );
			chunk = new Chunk("7. Test chunk skew");
			chunk.setSkew(0, 25);
			p.add(chunk);
			chunk = new Chunk("8. Test chunk skew");
			p.add(chunk);
			chunk = new Chunk("9. Test chunk skew");
			chunk.setSkew(0, -25);
			p.add(chunk);
			document.add(p);
			
			document.close();
			save();
		}
	}
}