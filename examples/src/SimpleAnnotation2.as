package
{
	import flash.events.Event;
	
	import org.purepdf.elements.Annotation;
	import org.purepdf.elements.Paragraph;
	import org.purepdf.pdf.PdfAction;
	import org.purepdf.pdf.PdfContentByte;
	import org.purepdf.pdf.PdfVersion;

	public class SimpleAnnotation2 extends DefaultBasicExample
	{
		public function SimpleAnnotation2(d_list:Array=null)
		{
			super( ["Add different type of annotations"] );
			registerDefaultFont();
		}
		
		override protected function execute( event: Event = null ): void
		{
			super.execute();
			createDocument();
			document.setPdfVersion( PdfVersion.VERSION_1_5 );
			document.open();
			
			document.add( new Paragraph( "Each square on this page represents an annotation." ) );
			
			var cb1: PdfContentByte = writer.getDirectContent();
			var a1: Annotation = Annotation.createString( "authors", "bla bla bla...." );
			a1.setDimensions( 250, 700, 350, 800 );
			
			var a2: Annotation = Annotation.createUrl( "http://www.sephiroth.it" );
			a2.setDimensions( 250, 550, 350, 650 );
			
			var a4: Annotation = Annotation.createNamed( PdfAction.LASTPAGE );
			a4.setDimensions( 250, 250, 350, 350 );
			
			cb1.rectangle( 250, 700, 100, 100 );
			document.add( a1 );
			
			cb1.rectangle( 250, 550, 100, 100 );
			document.add( a2 );
			
			cb1.rectangle( 250, 250, 100, 100 );
			document.add( a4 );
			
			cb1.stroke();
			
			document.close();
			save();
		}
	}
}