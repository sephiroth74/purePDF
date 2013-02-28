package
{
	import flash.events.Event;
	import flash.utils.setTimeout;
	
	import org.purepdf.elements.Paragraph;
	import org.purepdf.pdf.PdfContentByte;
	import org.purepdf.pdf.PdfPCell;
	import org.purepdf.pdf.PdfPRow;
	import org.purepdf.pdf.PdfPTable;

	public class PdfPTableAbsolutePositions extends DefaultBasicExample
	{
		public function PdfPTableAbsolutePositions(d_list:Array=null)
		{
			super(["This example shows how to create a PdfPTable and","print its rows using the method writeSelectedRows","the resulting table will be splitted accross pages"]);
			
			registerDefaultFont();
		}
		
		override protected function execute(event:Event=null):void
		{
			super.execute();

			createDocument();
			document.open();
			
			var cb: PdfContentByte = document.getDirectContent();
			
			var table: PdfPTable = new PdfPTable(2);
			var rows: Vector.<Number> = Vector.<Number>([ 50, 250 ] );
			
			table.setTotalWidths( rows );

			for( var k: int = 0; k < 200; ++k )
			{
				table.addStringCell("row" + k );
				table.addStringCell("bla bla bla..." + k );
			}
			
			document.add( new Paragraph("row 0 - 50") );
			table.writeSelectedRows2( 0, 50, 150, 820, cb );
			document.newPage();
			
			document.add( new Paragraph("row 50 - 100") );
			table.writeSelectedRows2(50, 100, 150, 820, cb);
			document.newPage();
			
			document.add(new Paragraph( "row 100 - 150 DOESN'T FIT ON THE PAGE!!!"));
			table.writeSelectedRows2(100, 150, 150, 200, cb);
			document.newPage();
			document.add(new Paragraph("row 150 - 200"));
			table.writeSelectedRows2(150, -1, 150, 820, cb);
			var rowheight: Number = 0;
			for (var i: int = 0; i < 50; i++) {
				rowheight += table.getRowHeight(i);
			}
			
			document.close();
			save();
		}
	}
}