package
{
	import flash.events.Event;
	
	import org.purepdf.elements.RectangleElement;
	import org.purepdf.pdf.PdfPCell;
	import org.purepdf.pdf.PdfPTable;
	import org.purepdf.pdf.PdfWriter;
	import org.purepdf.pdf.forms.FieldText;
	import org.purepdf.pdf.forms.PdfFormField;

	public class FormWithTooltip extends DefaultBasicExample
	{
		public function FormWithTooltip(d_list:Array=null)
		{
			super(d_list);
			registerDefaultFont()
		}
		
		override protected function execute(event:Event=null):void
		{
			super.execute();
			createDocument();
			document.open();
			
			var person: PdfFormField = PdfFormField.createEmpty( writer );
			person.fieldName = "person";
			document.add( createTable( writer, person ) );
			document.addAnnotation( person );
			
			document.close();
			save();
		}
		
		
		private static function createTable( writer: PdfWriter, parent: PdfFormField ): PdfPTable
		{
			var table: PdfPTable = new PdfPTable(2);
			var cell: PdfPCell;
			var field: FieldText;
			table.defaultCell.padding = 5;
			
			table.addStringCell("Your name:");
			cell = new PdfPCell();
			field = new FieldText( writer, new RectangleElement(0, 0,0,0), "name");
			field.fontSize = 12;
			cell.cellEvent = new CustomCellEvent(parent, field.getTextField(), 1, "Your name");
			table.addCell(cell);
			
			table.addStringCell("Your home address:");
			cell = new PdfPCell();
			field = new FieldText(writer, new RectangleElement(0, 0,0,0), "address");
			field.fontSize = 12;
			cell.cellEvent = new CustomCellEvent(parent, field.getTextField(), 1, "Street and number");
			table.addCell(cell);
			
			table.addStringCell("Postal code:");
			cell = new PdfPCell();
			field = new FieldText(writer, new RectangleElement(0, 0,0,0), "postal_code");
			field.fontSize = 12;
			cell.cellEvent = new CustomCellEvent(parent, field.getTextField(), 1, "Postal code");
			table.addCell(cell);
			
			table.addStringCell("City:");
			cell = new PdfPCell();
			field = new FieldText(writer, new RectangleElement(0, 0,0,0), "city");
			field.fontSize = 12;
			cell.cellEvent = new CustomCellEvent(parent, field.getTextField(), 1, "City");
			table.addCell(cell);
			
			table.addStringCell("Country:");
			cell = new PdfPCell();
			field = new FieldText(writer, new RectangleElement(0, 0,0,0), "country");
			field.fontSize = 12;
			cell.cellEvent = new CustomCellEvent(parent, field.getTextField(), 1, "Country");
			table.addCell(cell);
			
			table.addStringCell("Your email address:");
			cell = new PdfPCell();
			field = new FieldText(writer, new RectangleElement(0, 0,0,0), "email");
			field.fontSize = 12;
			cell.cellEvent = new CustomCellEvent(parent, field.getTextField(), 1, "mail address");
			table.addCell(cell);
			return table;
		}
	}
}
import org.purepdf.elements.RectangleElement;
import org.purepdf.errors.ConversionError;
import org.purepdf.pdf.PdfAnnotation;
import org.purepdf.pdf.PdfContentByte;
import org.purepdf.pdf.PdfPCell;
import org.purepdf.pdf.events.PdfPCellEventForwarder;
import org.purepdf.pdf.forms.PdfFormField;

class CustomCellEvent extends PdfPCellEventForwarder
{
	protected var parent: PdfFormField;
	protected var kid: PdfFormField;
	protected var padding: Number;
	protected var tooltip: String;
	
	public function CustomCellEvent( parent: PdfFormField, kid: PdfFormField, padding: Number, tooltip: String )
	{
		this.parent = parent;
		this.kid = kid;
		this.padding = padding;
		this.tooltip = tooltip;
	}
	
	/**
	 * @see com.lowagie.text.pdf.PdfPCellEvent#cellLayout(com.lowagie.text.pdf.PdfPCell,
	 *      com.lowagie.text.Rectangle, com.lowagie.text.pdf.PdfContentByte[])
	 */
	override public function cellLayout( cell:PdfPCell, position: RectangleElement, canvases:Vector.<PdfContentByte>):void
	{
		kid.setWidget( new RectangleElement( position.getLeft(padding), position.getBottom(padding), position.getRight(padding), position.getTop(padding)), PdfAnnotation.HIGHLIGHT_INVERT);
		kid.userName = tooltip;
		try
		{
			parent.addKid( kid );
		} catch (e: Error ) {
			throw new ConversionError( e );
		}
	}
}