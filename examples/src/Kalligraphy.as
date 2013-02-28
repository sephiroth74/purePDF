package
{
	import flash.events.Event;
	import flash.geom.Matrix;
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
	import org.purepdf.pdf.PdfViewPreferences;
	import org.purepdf.utils.ShadingUtils;

	public class Kalligraphy extends DefaultBasicExample
	{
		public function Kalligraphy( d_list: Array = null )
		{
			super( [ "Remember school notebook?" ] );
		}

		override protected function execute( event: Event = null ): void
		{
			super.execute();
			createDocument();

			document.setViewerPreferences( PdfViewPreferences.PrintScalingNone );
			document.open();

			var cb: PdfContentByte = document.getDirectContent();
			var lines: Vector.<Number> = Vector.<Number>( [ mm2pt( 7 ), mm2pt( 3 ), mm2pt( 7 ) ] );
			var width: Number = PageSize.A4.width;
			var bottom: Number = mm2pt( 30 );
			var y: Number = PageSize.A4.height - mm2pt( 21 );
			cb.setRGBStrokeColor( 0xD0, 0xD0, 0xD0 );
			cb.moveTo( 0, y );
			cb.lineTo( width, y );
			while ( y > bottom )
			{
				for ( var i: int = 0; i < lines.length; i++ )
				{
					y -= lines[i];
					cb.moveTo( 0, y );
					cb.lineTo( width, y );
				}
			}
			cb.stroke();
			cb.setRGBStrokeColor( 0xFF, 0x00, 0x00 );
			cb.moveTo( mm2pt( 30 ), 0 );
			cb.lineTo( mm2pt( 30 ), PageSize.A4.height );
			cb.stroke();

			var colors: Vector.<RGBColor> = Vector.<RGBColor>( [ RGBColor.BLACK, RGBColor.BLACK, RGBColor.BLACK, RGBColor.BLACK ] );
			var ratios: Vector.<Number> = Vector.<Number>( [ 0, 0.2, 0.5, 1 ] );
			var alphas: Vector.<Number> = Vector.<Number>( [ 1, 0.5, 0.2, 0 ] );
			var matrix: Matrix;
			drawRectangleGradient( cb, 0, 0, 40, PageSize.A4.height, colors, ratios, alphas, matrix );

			document.close();
			save();
		}

		public static function drawRectangleGradient( cb: PdfContentByte, x: Number, y: Number, width: Number, height: Number, colors: Vector.<RGBColor>,
				ratios: Vector.<Number>, alpha: Vector.<Number>, matrix: Matrix = null, extendStart: Boolean = true, extendEnd: Boolean = true ): void
		{
			var shading: PdfShading;
			var template: PdfTemplate;
			var gState: PdfGState;

			cb.rectangle( x, y, width, height );
			template = cb.createTemplate( x + width, y + height );

			var transGroup: PdfTransparencyGroup = new PdfTransparencyGroup();
			transGroup.put( PdfName.CS, PdfName.DEVICERGB );
			transGroup.isolated = true;
			transGroup.knockout = false;
			template.group = transGroup;

			gState = new PdfGState();
			var maskDict: PdfDictionary = new PdfDictionary();
			maskDict.put( PdfName.TYPE, PdfName.MASK );
			maskDict.put( PdfName.S, new PdfName( "Luminosity" ) );
			maskDict.put( new PdfName( "G" ), template.indirectReference );
			gState.put( PdfName.SMASK, maskDict );
			cb.setGState( gState );

			var alphas: Vector.<GrayColor> = new Vector.<GrayColor>( alpha.length, true );
			for ( var k: int = 0; k < alpha.length; ++k )
				alphas[k] = new GrayColor( alpha[k] );

			shading = PdfShading.complexAxial( cb.writer, 0, 0, width, 0, Vector.<RGBColor>( alphas ), ratios );
			template.paintShading( shading );

			shading = PdfShading.complexAxial( cb.writer, 0, 0, width, 0, colors, ratios );
			var axialPattern: PdfShadingPattern = new PdfShadingPattern( shading );
			if ( matrix )
			{
				axialPattern.matrix = matrix;
				cb.setTransform( matrix );
			}
			cb.setShadingFill( axialPattern );
			cb.fill();
		}

		public static function radians( degree: Number ): Number
		{
			return degree * ( Math.PI / 180 );
		}

		private static function mm2pt( f: Number ): Number
		{
			return f * 72 / 25.4;
		}
	}
}