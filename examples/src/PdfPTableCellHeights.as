package
{
	import flash.events.Event;
	
	import org.purepdf.elements.Paragraph;
	import org.purepdf.pdf.PdfPCell;
	import org.purepdf.pdf.PdfPTable;

	public class PdfPTableCellHeights extends DefaultBasicExample
	{
		public function PdfPTableCellHeights(d_list:Array=null)
		{
			super(["This example show how to use wrap/nowrap in PdfPCell(s),","how to set fixed heights for cells and","how to extend last table row to fit in the page"]);
		}
		
		override protected function execute(event:Event=null):void
		{
			super.execute();
			createDocument();
			document.open();
			
			registerDefaultFont();
			
			var table: PdfPTable = new PdfPTable(2);
			table.extendLastRow = true;
			var cell: PdfPCell;
			
			// wrap / nowrap
			cell = PdfPCell.fromPhrase(
				new Paragraph(
					"blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah blah"));
			table.addStringCell("wrap");
			cell.noWrap = false;
			table.addCell(cell);
			table.addStringCell("no wrap");
			cell.noWrap = true;
			table.addCell(cell);
			
			// height
			cell = PdfPCell.fromPhrase(new Paragraph(
				"1. blah blah\n2. blah blah blah\n3. blah blah"));
			table.addStringCell("fixed height (more than sufficient)");
			
			cell.fixedHeight = 72;
			table.addCell(cell);
			table.addStringCell("fixed height (not sufficient)");
			cell.fixedHeight = 36;
			table.addCell(cell);
			table.addStringCell("minimum height");
			cell = PdfPCell.fromPhrase(new Paragraph("blah blah"));
			cell.minimumHeight = 36;
			table.addCell(cell);
			table.addStringCell("extend last row");
			cell = PdfPCell.fromPhrase(new Paragraph(
				"almost no content, but the row is extended"));
			table.addCell(cell);
			document.add(table);
			
			document.close();
			save();
		}
	}
}