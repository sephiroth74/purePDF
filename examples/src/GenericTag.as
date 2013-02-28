package
{
	import flash.events.Event;
	
	import org.purepdf.colors.RGBColor;
	import org.purepdf.elements.Chunk;
	import org.purepdf.elements.Paragraph;
	import org.purepdf.events.ChunkEvent;
	import org.purepdf.pdf.PdfContentByte;
	import org.purepdf.pdf.fonts.BaseFont;
	import org.purepdf.resources.BuiltinFonts;
	import org.purepdf.pdf.fonts.FontsResourceFactory;

	public class GenericTag extends DefaultBasicExample
	{
		public function GenericTag(d_list:Array=null)
		{
			super(["Create chunks with custom tags associated to them","then use event listeners to manage the chunks creation"]);
			registerDefaultFont();
		}
		
		override protected function execute(event:Event=null) : void
		{
			super.execute();
			
			createDocument();
			document.addEventListener( ChunkEvent.GENERIC_TAG, onGenericTag );
			document.open();
			
			var p: Paragraph = new Paragraph( null );
			var fox: Chunk = new Chunk( "Quick brown fox" );
			fox.setGenericTag( "box" );
			p.add( fox );
			p.add( " jumps over " );
			var dog: Chunk = new Chunk( "the lazy dog." );
			dog.setGenericTag( "ellipse" );
			p.add( dog );
			document.add( p );
			
			document.close();
			save();
		}
		
		private function onGenericTag( event: ChunkEvent ): void
		{
			var cb: PdfContentByte;
			if( event.tag == 'ellipse' )
			{
				cb = document.getDirectContent();
				cb.setColorStroke( RGBColor.RED );
				cb.ellipse( event.rect.getLeft(), event.rect.getBottom() - 5, event.rect.getRight(), event.rect.getTop() );
				cb.stroke();
				cb.resetStroke();
			} else if( event.tag == 'box' )
			{
				cb = document.getDirectContentUnder();
				event.rect.backgroundColor = RGBColor.CYAN;
				event.rect.setBottom( event.rect.getBottom() - 5 );
				cb.rectangle( event.rect );
			}
		}
	}
}