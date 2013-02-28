package
{
	import flash.events.Event;
	
	import org.purepdf.colors.RGBColor;
	import org.purepdf.elements.Paragraph;
	import org.purepdf.elements.RectangleElement;
	import org.purepdf.pdf.PdfPCell;
	import org.purepdf.pdf.PdfPTable;

	public class PdfPTableColors extends DefaultBasicExample
	{
		public function PdfPTableColors(d_list:Array=null)
		{
			super(["Customize border and background color","of table cells"]);
		}
		
		override protected function execute(event:Event=null):void
		{
			super.execute();
			createDocument();
			document.open();
			
			registerDefaultFont();
			
			var table: PdfPTable = new PdfPTable(4);
			table.widthPercentage = 100;
			var cell: PdfPCell;
			cell = PdfPCell.fromPhrase(new Paragraph("test colors:"));
			table.addCell(cell);
			
			cell = PdfPCell.fromPhrase(new Paragraph("red / no borders"));
			cell.border = RectangleElement.NO_BORDER;
			cell.backgroundColor = RGBColor.RED;
			table.addCell(cell);
			
			cell = PdfPCell.fromPhrase(new Paragraph("green / magenta bottom border"));
			cell.border = RectangleElement.BOTTOM;
			cell.borderColorBottom = RGBColor.MAGENTA;
			cell.borderWidthBottom = 10;
			cell.backgroundColor = RGBColor.GREEN;
			table.addCell(cell);
			
			cell = PdfPCell.fromPhrase(new Paragraph("blue / cyan top border + padding"));
			cell.border = RectangleElement.TOP;
			cell.useBorderPadding = true;
			cell.borderWidthTop = 5;
			cell.borderColorTop = RGBColor.CYAN;
			cell.backgroundColor = RGBColor.BLUE;
			table.addCell(cell);
			
			cell = PdfPCell.fromPhrase(new Paragraph("test GrayFill:"));
			table.addCell(cell);
			
			cell = PdfPCell.fromPhrase(new Paragraph("0.25"));
			cell.border = RectangleElement.NO_BORDER;
			cell.grayFill = 0.25;
			table.addCell(cell);
			
			cell = PdfPCell.fromPhrase(new Paragraph("0.5"));
			cell.border = RectangleElement.NO_BORDER;
			cell.grayFill = 0.5;
			table.addCell(cell);
			
			cell = PdfPCell.fromPhrase(new Paragraph("0.75"));
			cell.border = RectangleElement.NO_BORDER;
			cell.grayFill = 0.75;
			table.addCell(cell);
			
			cell = PdfPCell.fromPhrase(new Paragraph("test bordercolors:"));
			table.addCell(cell);
			
			cell = PdfPCell.fromPhrase(new Paragraph("different borders"));
			cell.borderWidthLeft = 6;
			cell.borderWidthBottom = 5;
			cell.borderWidthRight = 4;
			cell.borderWidthTop = 2;
			cell.borderColorLeft = RGBColor.RED;
			cell.borderColorBottom = RGBColor.ORANGE;
			cell.borderColorRight = RGBColor.YELLOW;
			cell.borderColorTop = RGBColor.GREEN;
			table.addCell(cell);
			
			cell = PdfPCell.fromPhrase(new Paragraph("with correct padding"));
			cell.useBorderPadding = true;
			cell.borderWidthLeft = 6;
			cell.borderWidthBottom = 5;
			cell.borderWidthRight = 4;
			cell.borderWidthTop = 2;
			cell.borderColorLeft = RGBColor.RED;
			cell.borderColorBottom = RGBColor.ORANGE;
			cell.borderColorRight = RGBColor.YELLOW;
			cell.borderColorTop = RGBColor.GREEN;
			table.addCell(cell);
			
			cell = PdfPCell.fromPhrase(new Paragraph("orange border"));
			cell.borderWidth = 6;
			cell.borderColor = RGBColor.ORANGE;
			table.addCell(cell);
			
			document.add(table);
			document.close();
			save();
		}
	}
}