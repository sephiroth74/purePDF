package
{
	import flash.events.Event;
	
	import org.purepdf.elements.Paragraph;
	import org.purepdf.pdf.PdfPCell;
	import org.purepdf.pdf.PdfPTable;

	public class PdfPTableAbsoluteColumns extends DefaultBasicExample
	{
		public function PdfPTableAbsoluteColumns(d_list:Array=null)
		{
			super(["This example shows how to create a PDFPtable","with absolute width for columns"]);
		}
		
		override protected function execute(event:Event=null):void
		{
			super.execute();
			createDocument();
			document.open();
			
			registerDefaultFont();
			
			var cell: PdfPCell;
			var table: PdfPTable;
			
			table = new PdfPTable(3);
			cell = PdfPCell.fromPhrase( new Paragraph("header with colspan 3"));
			cell.colspan = (3);
			table.addCell(cell);
			table.addStringCell("1.1");
			table.addStringCell("2.1");
			table.addStringCell("3.1");
			table.addStringCell("1.2");
			table.addStringCell("2.2");
			table.addStringCell("3.2");
			var widths: Vector.<Number> = Vector.<Number>([ 72, 72, 144 ]);
			table.setTotalWidths( widths );
			table.lockedWidth = true;
			document.add(table);
			
			
			document.close();
			save();
		}
	}
}