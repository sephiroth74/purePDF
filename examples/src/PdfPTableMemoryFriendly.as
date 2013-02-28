package
{
	import flash.events.Event;
	
	import org.purepdf.Font;
	import org.purepdf.colors.RGBColor;
	import org.purepdf.elements.Paragraph;
	import org.purepdf.pdf.PdfPCell;
	import org.purepdf.pdf.PdfPTable;
	import org.purepdf.pdf.fonts.BaseFont;

	public class PdfPTableMemoryFriendly extends DefaultBasicExample
	{
		public function PdfPTableMemoryFriendly(d_list:Array=null)
		{
			super(d_list);
			
		}
		
		override protected function execute(event:Event=null):void
		{
			super.execute();
			createDocument();
			document.open();
			
			registerDefaultFont();
			
			var cell: PdfPCell;
			var table: PdfPTable;
			
			table = new PdfPTable(2);

			table.widthPercentage = 100;
			table.defaultCell.padding = 5;
			table.defaultCell.borderWidth = 2;
			table.defaultCell.borderColor = RGBColor.LIGHT_GRAY;
			
			table.headerRows = 1;
			
			var bf: BaseFont = BaseFont.createFont( BaseFont.HELVETICA, BaseFont.WINANSI, false, true );
			var font: Font = new Font( Font.HELVETICA, 12, Font.NORMAL, null, bf );
			
			var h1: PdfPCell = PdfPCell.fromPhrase(new Paragraph("Header 1", font ));
			h1.grayFill = 0.7;
			table.addCell(h1);
			
			var h2: PdfPCell = PdfPCell.fromPhrase(new Paragraph("Header 2", font ));
			h2.grayFill = 0.7;
			table.addCell(h2);
			
			for( var row: int = 1; row <= 200; row++ )
			{
				if (row % 50 == 50 - 1)
				{
					document.add(table);
					//table.deleteBodyRows();
					table.skipFirstHeader = true;
				}
				
				cell = PdfPCell.fromPhrase(new Paragraph( row.toString(), font ));
				table.addCell(cell);
				cell = PdfPCell.fromPhrase(new Paragraph("Quick brown fox jumps over the lazy dog.", font ));
				table.addCell(cell);
			}
			
			document.add(table);
			
			document.close();
			save();
		}
	}
}