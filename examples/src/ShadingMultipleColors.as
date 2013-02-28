package
{
	import flash.events.Event;
	
	import org.purepdf.colors.RGBColor;
	import org.purepdf.colors.ShadingColor;
	import org.purepdf.pdf.PageSize;
	import org.purepdf.pdf.PdfContentByte;
	import org.purepdf.pdf.PdfShading;
	import org.purepdf.pdf.PdfShadingPattern;

	public class ShadingMultipleColors extends DefaultBasicExample
	{
		public function ShadingMultipleColors(d_list:Array=null)
		{
			super(["Create a rectangle box with a multiple colors linear gradient fill"]);
		}
		
		override protected function execute( event: Event = null ) : void
		{
			super.execute();
			
			createDocument("Shading Patterns", PageSize.A6 );
			document.open();
			
			var cb: PdfContentByte = document.getDirectContent();
			var axial: PdfShading = PdfShading.complexAxial( 
						writer, 0, 0, 297, 210, 
						Vector.<RGBColor>([ RGBColor.BLACK, RGBColor.BLUE, RGBColor.CYAN, RGBColor.DARK_GRAY, RGBColor.GRAY, RGBColor.GREEN, RGBColor.LIGHT_GRAY, RGBColor.MAGENTA, RGBColor.ORANGE, RGBColor.PINK, RGBColor.RED, RGBColor.WHITE, RGBColor.YELLOW ]),
						null, false, false
			);
			
			var axialPattern: PdfShadingPattern = new PdfShadingPattern( axial );
			cb.setShadingFill( axialPattern );
			cb.rectangle( 0, 0, 297, 210 );
			cb.fill();

			
			var radial: PdfShading = PdfShading.complexRadial( 
				writer, 150, 315, 150, 315, 0, 90, 
				Vector.<RGBColor>([ RGBColor.BLACK, RGBColor.BLUE, RGBColor.CYAN, RGBColor.DARK_GRAY, RGBColor.GRAY, RGBColor.GREEN, RGBColor.LIGHT_GRAY, RGBColor.MAGENTA, RGBColor.ORANGE, RGBColor.PINK, RGBColor.RED, RGBColor.WHITE, RGBColor.YELLOW ]),
				null, false, false
			);
			
			var radialPattern: PdfShadingPattern = new PdfShadingPattern( radial );
			cb.setShadingFill( radialPattern );
			cb.rectangle( 0, 210, 297, 210 );
			cb.fill();
			
			document.close();
			save();
		}
	}
}