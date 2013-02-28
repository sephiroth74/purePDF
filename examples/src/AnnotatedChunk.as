package
{
	import flash.events.Event;
	
	import org.purepdf.Font;
	import org.purepdf.elements.Chunk;
	import org.purepdf.elements.RectangleElement;
	import org.purepdf.pdf.PdfAction;
	import org.purepdf.pdf.PdfAnnotation;
	import org.purepdf.pdf.fonts.BaseFont;
	import org.purepdf.pdf.fonts.FontsResourceFactory;
	import org.purepdf.resources.BuiltinFonts;

	public class AnnotatedChunk extends DefaultBasicExample
	{
		[Embed(source="assets/foxdog.jpg", mimeType="application/octet-stream")]
		private var file: Class;
		
		public function AnnotatedChunk()
		{
			super(["Simple example with a single chunk","with one javascript annotation,","one comment annotation and","one file attachment annotation"]);
			registerDefaultFont();
		}
		
		override protected function execute(event:Event=null) : void
		{
			super.execute();
			
			createDocument();
			document.open();
			
			var text: PdfAnnotation = PdfAnnotation.createText( writer, new RectangleElement( 200, 150, 300, 350 ), "Hello Annotation", "Some fake contents inside...", true, "Comment" );
			var javascript: PdfAnnotation = new PdfAnnotation ( writer, new RectangleElement( 200, 550, 300, 650 ), PdfAction.javaScript("app.alert('Wake up dog!');\r", writer ) );
			var attachment: PdfAnnotation = PdfAnnotation.createFileAttachment( writer, new RectangleElement( 100, 650, 150, 700 ), "Image of the dog and the fox", new file(), "foxdog.jpg" );
			
			var chunk1: Chunk = new Chunk("quick brown fox").setAnnotation( text );
			var chunk2: Chunk = new Chunk(" jumps over ").setAnnotation( attachment );
			var chunk3: Chunk = new Chunk("the lazy dog").setAnnotation( javascript );
			
			document.add( chunk1 );
			document.add( chunk2 );
			document.add( chunk3 );
			
			document.close();
			save();
		}
	}
}