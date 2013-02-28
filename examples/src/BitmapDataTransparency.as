package
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.utils.ByteArray;
	
	import org.purepdf.colors.RGBColor;
	import org.purepdf.elements.images.ImageElement;
	import org.purepdf.pdf.PageSize;
	import org.purepdf.pdf.PdfContentByte;
	import org.purepdf.utils.ShadingUtils;

	public class BitmapDataTransparency extends DefaultBasicExample
	{
		[Embed(source="assets/chart.png")]
		private var cls: Class;
		
		public function BitmapDataTransparency(d_list:Array=null)
		{
			super(["How to insert a BitmapData with transparency into a pdf document"]);
		}
		
		
		override protected function execute( event: Event = null ): void
		{
			super.execute();
			var bitmap: BitmapData = Bitmap( new cls() ).bitmapData;
			
			createDocument("BitmapData transparent example", PageSize.A4 );
			document.open();
			
			// drawing a custom PDF background
			var cb: PdfContentByte = document.getDirectContent();
			
			
			var colors: Vector.<RGBColor> = Vector.<RGBColor>( [ RGBColor.BLACK, RGBColor.WHITE ] );
			var ratios: Vector.<Number> = Vector.<Number>( [ 0, 1 ] );
			var alphas: Vector.<Number> = Vector.<Number>( [ 1, 1 ] );
			
			cb.saveState();
			ShadingUtils.drawRectangleGradient( cb, 0, 0, PageSize.A4.width, PageSize.A4.height, colors, ratios, alphas );
			cb.restoreState();
			
			
			var image: ImageElement = createTransparentImageElement( bitmap );
			image.setAbsolutePosition( 0, bitmap.height );
			cb.addImage( image );

			document.close();
			save();
		}
		
		
		/**
		 * Create a transparent ImageElement
		 * 
		 * An ImageElement with the input bitmapdata RGB informations will be
		 * created and an ImageElement will be used as mask ( using the alpha info from the bitmapdata )
		 * If the input bitmapdata is not transparent a regular ImageElement will be returned. 
		 */
		protected function createTransparentImageElement( bitmap: BitmapData ): ImageElement
		{
			var output: ByteArray = new ByteArray();
			var transparency: ByteArray = new ByteArray();
			var input: ByteArray = bitmap.getPixels( bitmap.rect );
			input.position = 0;
			
			while( input.bytesAvailable ){
				const pixel: uint = input.readInt();
				
				// write the RGB informations
				output.writeByte( (pixel >> 16) & 0xff );
				output.writeByte( (pixel >> 8) & 0xff );
				output.writeByte( (pixel >> 0) & 0xff );
				
				// write the alpha informations
				transparency.writeByte( (pixel >> 24) & 0xff );
			}
			
			output.position = 0;
			transparency.position = 0;
			
			var mask: ImageElement = ImageElement.getRawInstance( bitmap.width, bitmap.height, 1, 8, transparency, null );
			var image: ImageElement = ImageElement.getRawInstance( bitmap.width, bitmap.height, 3, 8, output, null );
			
			if( bitmap.transparent )
			{
				mask.makeMask();
				image.imageMask = mask;
			}
			return image;
		}
	}
}