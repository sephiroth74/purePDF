package
{
	import flash.events.Event;
	
	import org.purepdf.Font;
	import org.purepdf.colors.*;
	import org.purepdf.elements.*;
	import org.purepdf.pdf.*;
	import org.purepdf.pdf.fonts.*;
	import org.purepdf.resources.BuiltinFonts;

	public class HelloChunk extends DefaultBasicExample
	{
		public function HelloChunk(d_list:Array=null)
		{
			super(["Create a document using single chunks","set underline, color and superscript attributes to the chunks"]);
			FontsResourceFactory.getInstance().registerFont( BaseFont.COURIER_BOLD, new BuiltinFonts.COURIER_BOLD() );
		}
		
		override protected function execute(event:Event=null) : void
		{
			super.execute();
			
			createDocument("Hello world chunk");
			document.open();
			
			var font: Font = new Font( Font.COURIER, -1, Font.BOLD );
			font.color = RGBColor.BLUE;
			
			var fox: Chunk = new Chunk("quick brown fox", font);
			fox.setTextRise( 8 );
			fox.setBackground( RGBColor.RED );
			
			var jumps: Chunk = new Chunk(" jumps over ", font );
			var dog: Chunk = new Chunk("the lazy dog", font );
			dog.setTextRise(-8);
			
			dog.setUnderline( RGBColor.BLACK, 3, 0, -13, 0, PdfContentByte.LINE_CAP_ROUND );
			document.add(fox);
			document.add(jumps);
			document.add(dog);
			
			document.close();
			save();
		}
	}
}