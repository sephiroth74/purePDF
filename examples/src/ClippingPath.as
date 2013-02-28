package
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.utils.getQualifiedClassName;
	
	import org.purepdf.colors.RGBColor;
	import org.purepdf.elements.images.ImageElement;
	import org.purepdf.pdf.PageSize;
	import org.purepdf.pdf.PdfContentByte;
	import org.purepdf.pdf.PdfDocument;
	import org.purepdf.pdf.PdfViewPreferences;
	import org.purepdf.pdf.PdfWriter;

	public class ClippingPath extends DefaultBasicExample
	{
		[Embed(source="assets/image1.jpg")]
		private var cls1: Class;
		
		public function ClippingPath()
		{
			super(["This Example shows how to create clipping path","for masking other elements (such as images or other paths)"]);
		}
		
		override protected function execute(event:Event=null) : void
		{
			super.execute();
			
			var bmp: BitmapData = Bitmap( new cls1() ).bitmapData;
			createDocument("Clipping Paths example");
			document.open();
			
			var cb: PdfContentByte = document.getDirectContent();
			var image: ImageElement;
			cb.setTransform( new Matrix( 1, 0, 0, -1, 0, document.pageSize.height ) );
			
			
			image = ImageElement.getBitmapDataInstance( bmp );
			var w: Number = image.scaledWidth;
			var h: Number = image.scaledHeight;
			
			
			cb.saveState();
			
			for( var y: int = 10; y < bmp.height - 10; y += 20 )
			{
				for( var x: int = 10; x < bmp.width - 10; x += 20 )
				{
					cb.circle( x, y, 8 );
				}
			}
			
			cb.clip();
			cb.newPath();
			
			cb.addImage3( image, w, 0, 0, -h, 20, h+20 );
			cb.restoreState();
			
			document.close();
			save();
		}
	}
}