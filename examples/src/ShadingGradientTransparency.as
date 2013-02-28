package
{
	import flash.events.Event;
	
	import org.purepdf.colors.GrayColor;
	import org.purepdf.colors.RGBColor;
	import org.purepdf.pdf.PageSize;
	import org.purepdf.pdf.PdfContentByte;
	import org.purepdf.pdf.PdfDictionary;
	import org.purepdf.pdf.PdfGState;
	import org.purepdf.pdf.PdfName;
	import org.purepdf.pdf.PdfShading;
	import org.purepdf.pdf.PdfShadingPattern;
	import org.purepdf.pdf.PdfTemplate;
	import org.purepdf.pdf.PdfTransparencyGroup;
	import org.purepdf.utils.ShadingUtils;
	import org.purepdf.utils.assert_true;

	public class ShadingGradientTransparency extends DefaultBasicExample
	{
		public function ShadingGradientTransparency()
		{
			super( [ "This example will show how to create a gradient", "box and circle with transparent colors" ] );
		}

		override protected function execute( event: Event = null ): void
		{
			super.execute();

			createDocument();
			document.open();

			var cb: PdfContentByte = document.getDirectContent();

			cb.saveState();
			cb.setColorFill( RGBColor.RED );
			cb.circle( 230, PageSize.A4.height / 2 - 60, 100 );
			cb.fill();
			cb.resetFill();
			cb.restoreState();

			var colors: Vector.<RGBColor> = Vector.<RGBColor>( [ RGBColor.BLACK, RGBColor.YELLOW, RGBColor.BLUE, RGBColor.RED, RGBColor.CYAN ] );
			var ratios: Vector.<Number> = Vector.<Number>( [ 0, 0.5, 0.6, 0.8, 1 ] );
			var alphas: Vector.<Number> = Vector.<Number>( [ 0.2, 1, 0.4, 0.7, 0 ] );

			cb.saveState();
			ShadingUtils.drawRectangleGradient( cb, 100, 100, 100, PageSize.A4.height - 200, colors, ratios, alphas );
			cb.restoreState();
			
			cb.saveState();
			ShadingUtils.drawRadialGradient( cb, PageSize.A4.width/2, PageSize.A4.height/2, 0, 100, colors, ratios, alphas );
			cb.restoreState();

			/*cb.saveState();
			cb.setColorFill( RGBColor.BLUE );
			cb.circle( 110, PageSize.A4.height / 2 + 120, 100 );
			cb.fill();
			cb.restoreState();
			*/
			document.close();
			save();
		}
	}
}
