package
{
	import flash.events.Event;
	
	import org.purepdf.elements.Element;
	import org.purepdf.elements.Paragraph;
	import org.purepdf.pdf.PdfPCell;
	import org.purepdf.pdf.PdfPTable;

	public class PdfPTableAligned extends DefaultBasicExample
	{
		public function PdfPTableAligned(d_list:Array=null)
		{
			super(["Create a pdf with 3 tables using different","alignment for them"]);
		}
		
		override protected function execute(event:Event=null):void
		{
			super.execute();
			createDocument();
			document.open();
			
			registerDefaultFont();
			
			var table: PdfPTable = new PdfPTable(3);
			var cell: PdfPCell = PdfPCell.fromPhrase(new Paragraph("header with colspan 3"));
			cell.colspan = 3;
			table.addCell(cell);
			table.addStringCell("1.1");
			table.addStringCell("2.1");
			table.addStringCell("3.1");
			table.addStringCell("1.2");
			table.addStringCell("2.2");
			table.addStringCell("3.2");
			table.widthPercentage = 100;
			document.add(table);
			
			table.widthPercentage = 50;
			table.horizontalAlignment = Element.ALIGN_RIGHT;
			document.add(table);
			
			table.horizontalAlignment = Element.ALIGN_LEFT;
			document.add(table);
			
			document.close();
			save();
		}
	}
}