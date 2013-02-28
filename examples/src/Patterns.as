package
{
	import com.adobe.images.JPGEncoder;
	
	import flash.display.Bitmap;
	import flash.events.Event;
	
	import org.purepdf.colors.PatternColor;
	import org.purepdf.colors.RGBColor;
	import org.purepdf.elements.images.ImageElement;
	import org.purepdf.pdf.PdfContentByte;
	import org.purepdf.pdf.PdfPatternPainter;

	public class Patterns extends DefaultBasicExample
	{
		[Embed(source="assets/image1.jpg")]
		private var cls: Class;
		
		public function Patterns()
		{
			super(["This Example will show how to draw simple patterns"]);
		}
		
		override protected function execute(event:Event=null) : void
		{
			super.execute();
			
			createDocument("Drawing patterns example");
			document.open();
			
			var cb: PdfContentByte = document.getDirectContent();
			
			// define the patterns
			var square: PdfPatternPainter = cb.createPattern( 15, 15 );
			square.setColorFill( new RGBColor( 0xff, 0xff, 0x00 ) );
			square.setColorStroke( new RGBColor( 0xff, 0x00, 0x00 ) );
			square.rectangle( 5, 5, 5, 5 );
			square.fillStroke();
			
			var line: PdfPatternPainter = cb.createPatternColor( 5, 10, 5, 10, RGBColor.GRAY );
			line.setLineWidth( 1 );
			line.moveTo( 3, -1 );
			line.lineTo( 3, 11 );
			line.stroke( );
			
			var image: ImageElement = ImageElement.getInstance( new JPGEncoder().encode( ( new cls() as Bitmap ).bitmapData ) );
			var img_pattern: PdfPatternPainter = cb.createPattern( image.scaledWidth, image.scaledHeight );
			img_pattern.addImage3( image, image.scaledWidth, 0, 0, image.scaledHeight, 0, 0 );
			img_pattern.setMatrixValues( 1, 0, 0, 1, 60, 60 );
			
			// create the pattern colors
			var squares: PatternColor = new PatternColor( square );
			var lines: PatternColor = new PatternColor( line );
			
			// draw to content
			cb.setColorFill( squares );
			cb.rectangle( 30, 700, 80, 80 );
			cb.fillStroke();
			
			cb.setColorFill( lines );
			cb.rectangle( 360, 716, 72, 72 );
			cb.fillStroke();
			
			cb.setPatternFill2(line, RGBColor.RED );
			cb.rectangle(36, 608, 72, 72);
			cb.fillStroke();
			cb.setPatternFill2(line, RGBColor.GREEN );
			cb.rectangle(144, 608, 72, 72);
			cb.fillStroke();
			cb.setPatternFill2(line, RGBColor.BLUE );
			cb.rectangle(252, 608, 72, 72);
			cb.fillStroke();
			cb.setPatternFill2(line, RGBColor.YELLOW );
			cb.rectangle(360, 608, 72, 72);
			cb.fillStroke();
			cb.setPatternFill2(line, RGBColor.BLACK );
			cb.rectangle(470, 608, 72, 72);
			cb.fillStroke();
			
			cb.setPatternFill( img_pattern );
			cb.ellipse(36, 520, 360, 590);
			cb.fillStroke();
			
			document.close();
			save();
		}
	}
}