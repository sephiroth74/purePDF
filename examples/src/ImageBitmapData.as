package
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import org.purepdf.elements.images.ImageElement;
	import org.purepdf.pdf.PageSize;
	import org.purepdf.pdf.PdfBlendMode;
	import org.purepdf.pdf.PdfContentByte;
	import org.purepdf.pdf.PdfGState;
	import org.purepdf.pdf.PdfViewPreferences;

	public class ImageBitmapData extends DefaultBasicExample
	{
		[Embed(source="assets/image1.jpg")] private var cls: Class;
		
		public function ImageBitmapData(d_list:Array=null)
		{
			super(["Load and put a bitmapdata into a pdf document","and apply some transformations to it"]);
		}
		
		override protected function execute(event:Event=null):void
		{
			super.execute();
			
			var bmp: Bitmap = Bitmap( new cls() );
			var bitmap: BitmapData = bmp.bitmapData;

			// Create a transformation matrix for the image
			var pos: Point = new Point( PageSize.A4.width/2 + bitmap.width/2, PageSize.A4.height/2 + bitmap.height/2 );
			
			createDocument("BitmapData example", PageSize.A4 );
			document.setViewerPreferences( PdfViewPreferences.CenterWindow );
			document.open();
			
			// Create the image element
			var image: ImageElement;
			image = ImageElement.getBitmapDataInstance( bitmap );
			image.scalePercent( 100, -100 );
			image.setAbsolutePosition( 0, bitmap.height );
			
			// Write the image to the document
			var cb: PdfContentByte = document.getDirectContent();
			cb.setTransform( new Matrix( 1, 0, 0, -1, 0, document.pageSize.height ) );
			
			var gstate: PdfGState;
			var m: Matrix;
			var rad: Number;
			for( var k: int = 0; k < 10; ++ k )
			{
				cb.saveState();
				rad = radians( k*36 );
				m = new Matrix( 1, 0, 0, 1, 0, 0 );
				m.translate( - bitmap.width / 2, - bitmap.height / 2 );
				m.rotate( rad );
				m.translate( PageSize.A4.width/2 + (Math.cos(rad)*200), PageSize.A4.height/2 + (Math.sin(rad)*200) );
				
				gstate = new PdfGState();
				gstate.setBlendMode( PdfBlendMode.COLORDODGE );
				gstate.setFillOpacity( 0.3 );
				cb.setGState( gstate );
			
				cb.concatMatrix( m );
				cb.addImage( image );
				
				cb.restoreState();
			}
			
			document.close();
			save();
		}
		
		static public function radians( degree: Number ): Number
		{
			return degree * ( Math.PI / 180 );
		}
	}
}