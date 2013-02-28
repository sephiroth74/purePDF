package
{
	import flash.events.Event;
	
	import org.purepdf.elements.Paragraph;
	import org.purepdf.pdf.PdfPCell;
	import org.purepdf.pdf.PdfPTable;

	public class PdfPTableColumnWidths extends DefaultBasicExample
	{
		public function PdfPTableColumnWidths(d_list:Array=null)
		{
			super(["Create a pdf with PdfPTables with custom column widths"]);
		}
		
		override protected function execute(event:Event=null):void
		{
			super.execute();
			createDocument();
			document.open();
			
			registerDefaultFont();
			
			var cell: PdfPCell;
			var table: PdfPTable;
			
			table = new PdfPTable( Vector.<Number>([ 1, 1, 2 ]) );
			cell = PdfPCell.fromPhrase(new Paragraph("header with colspan 3"));
			cell.colspan = 3;
			table.addCell(cell);
			table.addStringCell("1.1");
			table.addStringCell("2.1");
			table.addStringCell("3.1");
			table.addStringCell("1.2");
			table.addStringCell("2.2");
			table.addStringCell("3.2");
			document.add(table);
			
			table.setNumberWidths( Vector.<Number>([2,1,1]) );
			document.add(table);
			
			document.close();
			save();
		}
	}
}