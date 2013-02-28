package
{
	import flash.events.Event;
	import flash.utils.getQualifiedClassName;
	
	import org.purepdf.colors.CMYKColor;
	import org.purepdf.colors.GrayColor;
	import org.purepdf.colors.RGBColor;
	import org.purepdf.colors.SpotColor;
	import org.purepdf.pdf.PageSize;
	import org.purepdf.pdf.PdfContentByte;
	import org.purepdf.pdf.PdfDocument;
	import org.purepdf.pdf.PdfSpotColor;
	import org.purepdf.pdf.PdfWriter;

	public class SeparationColors extends DefaultBasicExample
	{
		public function SeparationColors()
		{
			super(["This Example shows how to use the separation colorspace"]);
		}

		override protected function execute( event: Event=null ): void
		{
			super.execute();
			
			createDocument("Separation color example");
			document.open();

			var cb: PdfContentByte = document.getDirectContent();
			
			var psc_g: PdfSpotColor = new PdfSpotColor( "SpotColorGray", new GrayColor( 0.9 ) );
			var psc_rgb: PdfSpotColor = new PdfSpotColor("SpotColorRGB", new RGBColor(0x64, 0x95, 0xed));
			var psc_cmyk: PdfSpotColor = new PdfSpotColor("SpotColorCMYK", new CMYKColor( 0.3, .9, .3, .1) );
			
			var sc_g: SpotColor    = new SpotColor( psc_g, 0.5 );
			var sc_rgb1: SpotColor = new SpotColor(psc_rgb, 0.1);
			var sc_rgb2: SpotColor = new SpotColor(psc_rgb, 0.2);
			var sc_rgb3: SpotColor = new SpotColor(psc_rgb, 0.3);
			var sc_rgb4: SpotColor = new SpotColor(psc_rgb, 0.4);
			var sc_rgb5: SpotColor = new SpotColor(psc_rgb, 0.5);
			var sc_rgb6: SpotColor = new SpotColor(psc_rgb, 0.6);
			var sc_rgb7: SpotColor = new SpotColor(psc_rgb, 0.7);
			var sc_rgb8: SpotColor = new SpotColor(psc_rgb, 0.8);
			var sc_rgb9: SpotColor = new SpotColor(psc_rgb, 0.9);
			var sc_cmyk: SpotColor = new SpotColor(psc_cmyk, 0.25);

			cb.setColorFill( sc_g );
			cb.rectangle( 36, 770, 36, 36 );
			cb.fillStroke();
			cb.setSpotFillColor( psc_g, 0.5 );
			cb.rectangle( 90, 770, 36, 36 );
			cb.fillStroke();
			cb.setSpotFillColor( psc_g, 0.2 );
			cb.rectangle( 144, 770, 36, 36 );
			cb.fillStroke();
			cb.setSpotFillColor( psc_g, 0.5 );
			cb.rectangle( 198, 770, 36, 36 );
			cb.fillStroke();
			cb.setSpotFillColor( psc_g, 1 );
			cb.rectangle( 252, 770, 36, 36 );
			cb.fillStroke();

			cb.setColorFill(sc_rgb1);
			cb.rectangle(36, 716, 36, 36);
			cb.fillStroke();
			cb.setColorFill(sc_rgb2);
			cb.rectangle(90, 716, 36, 36);
			cb.fillStroke();
			cb.setColorFill(sc_rgb3);
			cb.rectangle(144, 716, 36, 36);
			cb.fillStroke();
			cb.setColorFill(sc_rgb4);
			cb.rectangle(198, 716, 36, 36);
			cb.fillStroke();
			cb.setColorFill(sc_rgb5);
			cb.rectangle(252, 716, 36, 36);
			cb.fillStroke();
			cb.setColorFill(sc_rgb6);
			cb.rectangle(306, 716, 36, 36);
			cb.fillStroke();
			cb.setColorFill(sc_rgb7);
			cb.rectangle(360, 716, 36, 36);
			cb.fillStroke();
			cb.setColorFill(sc_rgb8);
			cb.rectangle(416, 716, 36, 36);
			cb.fillStroke();
			cb.setColorFill(sc_rgb9);
			cb.rectangle(470, 716, 36, 36);
			cb.fillStroke();
			
			cb.setSpotFillColor(psc_rgb, 0.1);
			cb.rectangle(36, 662, 36, 36);
			cb.fillStroke();
			cb.setSpotFillColor(psc_rgb, 0.2);
			cb.rectangle(90, 662, 36, 36);
			cb.fillStroke();
			cb.setSpotFillColor(psc_rgb, 0.3);
			cb.rectangle(144, 662, 36, 36);
			cb.fillStroke();
			cb.setSpotFillColor(psc_rgb, 0.4);
			cb.rectangle(198, 662, 36, 36);
			cb.fillStroke();
			cb.setSpotFillColor(psc_rgb, 0.5);
			cb.rectangle(252, 662, 36, 36);
			cb.fillStroke();
			cb.setSpotFillColor(psc_rgb, 0.6);
			cb.rectangle(306, 662, 36, 36);
			cb.fillStroke();
			cb.setSpotFillColor(psc_rgb, 0.7);
			cb.rectangle(360, 662, 36, 36);
			cb.fillStroke();
			cb.setSpotFillColor(psc_rgb, 0.8);
			cb.rectangle(416, 662, 36, 36);
			cb.fillStroke();
			cb.setSpotFillColor(psc_rgb, 0.9);
			cb.rectangle(470, 662, 36, 36);
			cb.fillStroke();
			
			cb.setColorFill(sc_cmyk);
			cb.rectangle(36, 608, 36, 36);
			cb.fillStroke();
			cb.setSpotFillColor(psc_cmyk, 0.25);
			cb.rectangle(90, 608, 36, 36);
			cb.fillStroke();

			document.close();
			save();
		}
	}
}