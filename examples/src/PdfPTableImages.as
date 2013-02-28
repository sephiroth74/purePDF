package
{
	import com.adobe.images.JPGEncoder;
	import com.adobe.images.PNGEncoder;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	
	import org.purepdf.elements.images.ImageElement;
	import org.purepdf.pdf.PdfPCell;
	import org.purepdf.pdf.PdfPTable;

	public class PdfPTableImages extends DefaultBasicExample
	{
		
		[Embed(source="assets/appicondocsec.png")]
		private var cls1: Class;
		
		public function PdfPTableImages(d_list:Array=null)
		{
			super(["This example shows how to add images into a table"]);
		}
		
		override protected function execute(event:Event=null):void
		{
			super.execute();
			createDocument();
			document.open();
			
			registerDefaultFont();
			
			var cell: PdfPCell;
			var table: PdfPTable;
			var bmp: BitmapData = ( new cls1() as Bitmap ).bitmapData;
			
			//var img: ImageElement = ImageElement.getInstance( new JPGEncoder(90).encode( bmp ) );
			var img: ImageElement = ImageElement.getInstance( PNGEncoder.encode( bmp ) );
			
			table = new PdfPTable(1);
			table.addStringCell("This image was added with addCell(Image); the image is scaled + there is the default padding of getDefaultCell.");
			table.addImageCell(img);

			table.addStringCell("This image was added with addCell(PdfPCell); scaled, no padding");
			table.addCell( PdfPCell.fromImage(img, true));
			
			table.addStringCell("This image was added with addCell(PdfPCell); not scaled");
			table.addCell( PdfPCell.fromImage(img, false) );
			
			
			
			document.add(table);
			document.close();
			save();
		}
	}
}