package
{
	import flash.events.Event;
	
	import org.purepdf.colors.RGBColor;
	import org.purepdf.colors.ShadingColor;
	import org.purepdf.pdf.PageSize;
	import org.purepdf.pdf.PdfContentByte;
	import org.purepdf.pdf.PdfShading;
	import org.purepdf.pdf.PdfShadingPattern;
	import org.purepdf.pdf.PdfViewPreferences;

	public class ShadingPatterns extends DefaultBasicExample
	{
		public function ShadingPatterns()
		{
			super(["This Example shows how to draw using","shading patterns (aka gradients)"]);
		}
		
		override protected function execute(event:Event=null) : void
		{
			super.execute();
			
			createDocument("Shading Patterns example", PageSize.A6 );
			document.setViewerPreferences( PdfViewPreferences.PageLayoutTwoColumnLeft );
			document.open();
			
			var cb: PdfContentByte = document.getDirectContent();
			var axial: PdfShading = PdfShading.simpleAxial( writer, 0, 0, 297, 420, RGBColor.MAGENTA, RGBColor.YELLOW );
			cb.paintShading(axial);
			
			var radial: PdfShading = PdfShading.simpleRadial( writer, 100, 300, 60, 140, 200, 100, new RGBColor(0, 247, 201), new RGBColor(245, 55, 144), false, false);
			cb.paintShading(radial);
			document.newPage();
			
			var axialPattern: PdfShadingPattern = new PdfShadingPattern( axial );
			cb.setShadingFill( axialPattern );
			cb.rectangle( 10, 316, 50, 50 );
			cb.rectangle( 70, 316, 50, 50 );
			cb.rectangle( 130, 316, 50, 50 );
			cb.rectangle( 190, 316, 50, 50 );
			cb.fillStroke();
			
			var axialColor: ShadingColor = new ShadingColor( axialPattern );
			cb.setColorFill( axialColor );
			cb.rectangle( 10, 200, 50, 50 );
			cb.rectangle( 70, 200, 50, 50 );
			cb.rectangle( 130, 200, 50, 50 );
			cb.rectangle( 190, 200, 50, 50 );
			cb.fillStroke();
			
			var radialPattern: PdfShadingPattern = new PdfShadingPattern( radial );
			var radialColor: ShadingColor = new ShadingColor( radialPattern );
			cb.setColorFill( radialColor );
			cb.rectangle( 10, 100, 50, 50 );
			cb.rectangle( 70, 100, 50, 50 );
			cb.rectangle( 130, 100, 50, 50 );
			cb.rectangle( 190, 100, 50, 50 );
			cb.fillStroke();
			
			document.close();
			save();
		}
	}
}