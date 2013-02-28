package
{
	import flash.events.Event;
	
	import org.purepdf.Font;
	import org.purepdf.elements.Chunk;
	import org.purepdf.pdf.PdfAction;
	import org.purepdf.pdf.fonts.BaseFont;
	import org.purepdf.resources.BuiltinFonts;
	import org.purepdf.pdf.fonts.FontsResourceFactory;

	public class HelloWorldGoto extends DefaultBasicExample
	{
		public function HelloWorldGoto()
		{
			super(["Simple pdf document with one chunk","and an action assigned to it"]);
			registerDefaultFont();
		}
		
		override protected function execute(event:Event=null) : void
		{
			super.execute();
			
			createDocument();
			document.open();
			
			var font: Font = new Font();
			font.style = Font.UNDERLINE;
			
			var chunk: Chunk = new Chunk("http://www.google.com", font );
			chunk.setAction( PdfAction.fromURL("http://www.google.com") );
			document.add(chunk);
			
			document.close();
			save();
		}
	}
}