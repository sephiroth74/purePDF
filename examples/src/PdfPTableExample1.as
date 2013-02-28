package 
{
	import flash.events.Event;
	
	import org.purepdf.elements.Paragraph;
	import org.purepdf.pdf.PdfPCell;
	import org.purepdf.pdf.PdfPTable;
	import org.purepdf.pdf.fonts.BaseFont;
	import org.purepdf.resources.BuiltinFonts;
	import org.purepdf.pdf.fonts.FontsResourceFactory;

	public class PdfPTableExample1 extends DefaultBasicExample
	{
		public function PdfPTableExample1(d_list:Array=null)
		{
			super(["This example will create a siple table","with a header row created using column span"]);
			registerDefaultFont();
		}
		
		override protected function execute(event:Event=null):void
		{
			super.execute();
			createDocument("Simple pdfptable");
			document.open();
			
			var table: PdfPTable = new PdfPTable( 3 );
			var cell: PdfPCell = PdfPCell.fromPhrase( new Paragraph( "header with colspan 3" ) );
			cell.colspan = 3;
			table.addCell( cell );
			table.addStringCell( "1.1" );
			table.addStringCell( "2.1" );
			table.addStringCell( "3.1" );
			table.addStringCell( "1.2" );
			table.addStringCell( "2.2" );
			table.addStringCell( "3.2" );
			document.add(table);			
			
			document.close();
			save();
		}
	}
}