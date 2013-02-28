package
{
	import flash.events.Event;
	
	import org.purepdf.elements.Chunk;
	import org.purepdf.elements.Element;
	import org.purepdf.elements.Paragraph;
	import org.purepdf.pdf.PageSize;
	import org.purepdf.pdf.PdfPCell;
	import org.purepdf.pdf.PdfPTable;

	public class PdfPTableCompare extends DefaultBasicExample
	{
		public function PdfPTableCompare(d_list:Array=null)
		{
			super(["This shows how to add a table to the document","using document.add or writeSelectedRows","This example also shows how to modify the default table cell"]);
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
			table.defaultCell.horizontalAlignment = Element.ALIGN_CENTER;
			table.defaultCell.borderWidth = 2;
			table.defaultCell.padding = 12;
			table.addStringCell("the quick brown fox");
			table.addStringCell("jumps over");
			table.addStringCell("the lazy dog");
			table.addStringCell("the lazy dog");
			table.addStringCell("jumps over");
			table.addStringCell("the quick brown fox");
			
			document.add(new Paragraph("The table below is added with document.add():"));
			document.add(Chunk.NEWLINE);
			document.add(table);
			document.add(new Paragraph("The table below is added with writeSelectedRows() at position (x = 50; y =" + PageSize.A4.height * 0.75 + "):"));
			table.writeSelectedRows2(0, -1, 50, PageSize.A4.height * 0.75, document.getDirectContent());
			
			document.close();
			save();
		}
	}
}