package
{
	import flash.events.Event;
	
	import org.purepdf.elements.Chunk;
	import org.purepdf.elements.Paragraph;
	import org.purepdf.pdf.fonts.BaseFont;
	import org.purepdf.resources.BuiltinFonts;
	import org.purepdf.pdf.fonts.FontsResourceFactory;
	
	public class ChunkHorizontalScale extends DefaultBasicExample
	{
		public function ChunkHorizontalScale(d_list:Array=null)
		{
			super(["This example shows how to horizontal scale a text chunk"]);
			registerDefaultFont();
		}
		
		override protected function execute(event:Event=null) : void
		{
			super.execute();
			
			createDocument();
			document.open();
			
			var c: Chunk = new Chunk("quick brown fox jumps over the lazy dog");
			var w: Number = c.getWidthPoint();
			var p: Paragraph = new Paragraph("The width of the chunk: '");
			p.add(c);
			p.add("' is ");
			p.add( w.toString() );
			p.add(" pt or ");
			p.add((w / 72).toString());
			p.add(" in or ");
			p.add((w / 72 * 2.54).toString());
			p.add(" cm");
			
			document.add(p);
			document.add(c);
			document.add(Chunk.NEWLINE);
			c.setHorizontalScaling(0.5);
			document.add(c);
			document.add(c);
			
			document.close();
			save();
		}
	}
}