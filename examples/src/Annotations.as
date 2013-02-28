package
{
	import flash.events.Event;
	import flash.utils.ByteArray;
	
	import org.purepdf.colors.RGBColor;
	import org.purepdf.elements.Chunk;
	import org.purepdf.elements.RectangleElement;
	import org.purepdf.pdf.PdfAction;
	import org.purepdf.pdf.PdfAnnotation;
	import org.purepdf.pdf.PdfArray;
	import org.purepdf.pdf.PdfBoolean;
	import org.purepdf.pdf.PdfBorderDictionary;
	import org.purepdf.pdf.PdfContentByte;
	import org.purepdf.pdf.PdfDestination;
	import org.purepdf.pdf.PdfFileSpecification;
	import org.purepdf.pdf.PdfName;
	import org.purepdf.pdf.PdfString;
	import org.purepdf.pdf.PdfVersion;

	public class Annotations extends DefaultBasicExample
	{
		[Embed( source="assets/foxdog.jpg", mimeType="application/octet-stream" )]
		private var image: Class;
		[Embed( source="assets/foxdog.mpg", mimeType="application/octet-stream" )]
		private var movie: Class;

		public function Annotations( d_list: Array = null )
		{
			super( ["This example shows how to use annotations"] );
			registerDefaultFont();
		}
		
		public static function getBytes( input: String, enc: String = "windows-1252" ): ByteArray
		{
			var b: ByteArray = new ByteArray();
			b.writeMultiByte( input, enc );
			return b;
		}

		override protected function execute( event: Event = null ): void
		{
			super.execute();
			createDocument();
			document.setPdfVersion( PdfVersion.VERSION_1_5 );
			document.open();

			document.add( new Chunk( "top of the page" ).setLocalDestination( "top" ) );
			var cb: PdfContentByte = document.getDirectContent();

			// page 1
			var annotation: PdfAnnotation = new PdfAnnotation( writer, new RectangleElement( 100, 750, 150, 800 ) );
			document.addAnnotation( annotation );
			annotation.put( PdfName.SUBTYPE, PdfName.TEXT );
			annotation.put( PdfName.OPEN, PdfBoolean.PDF_TRUE );
			annotation.put( PdfName.T, new PdfString( "custom" ) );
			annotation.put( PdfName.CONTENTS, new PdfString( "This is a custom built text annotation." ) );
			cb.rectangle( 100, 750, 50, 50 );
			cb.stroke();

			// embed a mpeg movie
			var fs: PdfFileSpecification = PdfFileSpecification.fileEmbedded( writer, "foxdog.mpg", new movie(), true );
			document.addAnnotation( PdfAnnotation.createScreen( writer, new RectangleElement( 200, 700, 300, 800 ), "Fox and Dog", fs, "video/mpeg", true ) );
			var a: PdfAnnotation = new PdfAnnotation( writer, new RectangleElement( 200, 550, 300, 650 ), PdfAction.javaScript( "app.alert('Hello');\r",
					writer ) );
			document.addAnnotation( a );
			document.addAnnotation( PdfAnnotation.createFileAttachment( writer, new RectangleElement( 100, 650, 150, 700 ), "This is some text", getBytes("some text"), "some.txt" ) );
			document.addAnnotation( PdfAnnotation.createText( writer, new RectangleElement( 200, 400, 300, 500 ), "Help", "This Help annotation was made with 'createText'",
					false, "Help" ) );
			document.addAnnotation( PdfAnnotation.createText( writer, new RectangleElement( 200, 250, 300, 350 ), "Help", "This Comment annotation was made with 'createText'",
					true, "Comment" ) );
			cb.rectangle( 200, 700, 100, 100 );
			cb.rectangle( 200, 550, 100, 100 );
			cb.rectangle( 200, 400, 100, 100 );
			cb.rectangle( 200, 250, 100, 100 );
			cb.stroke();
			document.newPage();

			// page 2
			document.addAnnotation( PdfAnnotation.createLink( writer, new RectangleElement( 200, 700, 300, 800 ), PdfAnnotation.HIGHLIGHT_INVERT, PdfAction.
					javaScript( "app.alert('Hello');\r", writer ) ) );
			document.addAnnotation( PdfAnnotation.createLink2( writer, new RectangleElement( 200, 550, 300, 650 ), PdfAnnotation.HIGHLIGHT_OUTLINE, "top" ) );
			document.addAnnotation( PdfAnnotation.createLink3( writer, new RectangleElement( 400, 700, 500, 800 ), PdfAnnotation.HIGHLIGHT_PUSH, 1, new PdfDestination( PdfDestination.FIT ) ) );
			document.addAnnotation( PdfAnnotation.createPopup( writer, new RectangleElement( 400, 550, 500, 650 ), "Hello, I'm a popup!", true ) );

			var shape1: PdfAnnotation = PdfAnnotation.createSquareCircle( writer, new RectangleElement( 200, 400, 300, 500 ), "This Comment annotation was made with 'createSquareCircle'",
					false );
			var red: Vector.<Number> = Vector.<Number>( [ 1, 0, 0 ] );
			shape1.put( new PdfName( "IC" ), new PdfArray( red ) );
			document.addAnnotation( shape1 );

			// line annotation
			var shape2: PdfAnnotation = PdfAnnotation.createLine( writer, new RectangleElement( 200, 250, 300, 350 ), "this is a line", 200, 250, 300,	350 );
			shape2.color = RGBColor.BLUE;
			var lineEndingStyles: PdfArray = new PdfArray();
			lineEndingStyles.add( new PdfName( "Diamond" ) );
			lineEndingStyles.add( new PdfName( "OpenArrow" ) );
			shape2.put( new PdfName( "LE" ), lineEndingStyles );
			shape2.put( PdfName.BS, new PdfBorderDictionary( 5, PdfBorderDictionary.STYLE_SOLID, null ) );
			document.addAnnotation( shape2 );
			var pcb: PdfContentByte = new PdfContentByte( writer );
			pcb.setColorFill( new RGBColor( 0xFF, 0x00, 0x00 ) );

			// free text
			var freeText: PdfAnnotation = PdfAnnotation.createFreeText( writer, new RectangleElement( 400, 400, 500, 500 ), "This is some free text, blah blah blah", pcb );
			document.addAnnotation( freeText );

			// file attachment
			var attachment: PdfAnnotation = PdfAnnotation.createFileAttachment( writer, new RectangleElement( 400, 250, 500, 350 ), "Image of the fox and the dog", new image(), "foxdog.jpg" );
			attachment.put( PdfName.NAME, new PdfString( "Paperclip" ) );
			document.addAnnotation( attachment );

			document.close();
			save();
		}
	}
}