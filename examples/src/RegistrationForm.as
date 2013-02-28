package
{
	import flash.events.Event;
	
	import org.purepdf.elements.RectangleElement;
	import org.purepdf.pdf.PdfAnnotation;
	import org.purepdf.pdf.PdfAppearance;
	import org.purepdf.pdf.PdfContentByte;
	import org.purepdf.pdf.PdfPCell;
	import org.purepdf.pdf.PdfPTable;
	import org.purepdf.pdf.PdfWriter;
	import org.purepdf.pdf.fonts.StreamFont;
	import org.purepdf.pdf.forms.FieldText;
	import org.purepdf.pdf.forms.PdfFormField;

	public class RegistrationForm extends DefaultBasicExample
	{
		public function RegistrationForm( d_list: Array = null )
		{
			super( ["This example will create a PDF with a form filled with","text fields, combo boxes and lists","PDF with forms can be filled by users"] );
			registerDefaultFont();
		}

		override protected function execute( event: Event = null ): void
		{
			super.execute();
			createDocument();
			document.open();
			var form: PdfFormField = PdfFormField.createEmpty( writer );
			form.fieldName = "person";
			document.add( createTable( writer, form ) );
			document.addAnnotation( form );
			document.close();
			save();
		}

		static private function createTable( writer: PdfWriter, parent: PdfFormField ): PdfPTable
		{
			var cb: PdfContentByte = writer.getDirectContent();
			var buttonStates: Vector.<PdfAppearance> = new Vector.<PdfAppearance>( 2 );
			buttonStates[0] = cb.createAppearance( 20, 20 );
			buttonStates[1] = cb.createAppearance( 20, 20 );
			buttonStates[1].moveTo( 0, 0 );
			buttonStates[1].lineTo( 20, 20 );
			buttonStates[1].moveTo( 0, 20 );
			buttonStates[1].lineTo( 20, 0 );
			buttonStates[1].stroke();
			var table: PdfPTable = new PdfPTable( 2 );
			var cell: PdfPCell;
			var field: FieldText;
			table.defaultCell.padding = 5;
			// first field
			table.addStringCell( "Your name:" );
			cell = new PdfPCell();
			field = new FieldText( writer, new RectangleElement( 0, 0, 0, 0 ), "name" );
			field.fontSize = 12;
			cell.cellEvent = new Layout( parent, field.getTextField(), 1 );
			table.addCell( cell );
			// second field
			table.addStringCell( "Your home address:" );
			cell = new PdfPCell();
			field = new FieldText( writer, new RectangleElement( 0, 0, 0, 0 ), "address" );
			field.fontSize = 12;
			cell.cellEvent = new Layout( parent, field.getTextField(), 1 );
			table.addCell( cell );
			table.addStringCell( "Postal code:" );
			cell = new PdfPCell();
			field = new FieldText( writer, new RectangleElement( 0, 0, 0, 0 ), "postal_code" );
			field.fontSize = 12;
			cell.cellEvent = new Layout( parent, field.getTextField(), 1 );
			table.addCell( cell );
			table.addStringCell( "Your email address:" );
			cell = new PdfPCell();
			field = new FieldText( writer, new RectangleElement( 0, 0, 0, 0 ), "email" );
			field.fontSize = 12;
			cell.cellEvent = new Layout( parent, field.getTextField(), 1 );
			table.addCell( cell );
			table.addStringCell( "Programming skills:" );
			cell = new PdfPCell();
			field = new FieldText( writer, new RectangleElement( 0, 0, 0, 0 ), "programming" );
			field.fontSize = 9;
			var list_options: Vector.<String> = Vector.<String>( ["AS", "C", "Python", "Java"] );
			field.choicesExport = list_options;
			var list_values: Vector.<String> = Vector.<String>( ["Actionscript", "C/C++", "Python", "Java"] );
			field.choices = list_values;
			var f: PdfFormField = field.getListField();
			f.fieldFlags = PdfFormField.FF_MULTISELECT;
			cell.cellEvent = new Layout( parent, f, 0 );
			cell.minimumHeight = 50;
			table.addCell( cell );
			table.addStringCell( "Mother tongue:" );
			cell = new PdfPCell();
			field = new FieldText( writer, new RectangleElement( 0, 0, 0, 0 ), "language" );
			field.fontSize = 9;
			var combo_options: Vector.<String> = Vector.<String>( ["IT", "EN", "FR" ] );
			field.choicesExport = combo_options;
			var combo_values: Vector.<String> = Vector.<String>( ["Italian", "English", "French" ] );
			field.choices = combo_values;
			f = field.getComboField();
			cell.cellEvent = new Layout( parent, f, 0 );
			table.addCell( cell );
			
			
			   var f1: PdfFormField = PdfFormField.createRadioButton(writer, true);
			   f1.fieldName = "preferred";
			   parent.addKid(f1);
			   table.addStringCell("Preferred Language:");
			   var widths: Vector.<Number> = Vector.<Number>([ 1, 10 ]);
			   
			   var subtable: PdfPTable = new PdfPTable(widths);
			   cell = new PdfPCell();
			   
			   var checkbox: PdfFormField = PdfFormField.createEmpty(writer);
			   checkbox.valueAsName = "EN";
			   checkbox.appearanceState = "EN";
			   checkbox.setAppearanceState(PdfAnnotation.APPEARANCE_NORMAL, "Off", buttonStates[0]);
			   checkbox.setAppearanceState(PdfAnnotation.APPEARANCE_NORMAL, "EN", buttonStates[1]);
			   cell.cellEvent = new Layout(f1, checkbox, 0);
			   subtable.addCell(cell);
			   
			   subtable.addStringCell("English");
			   cell = new PdfPCell();
			   checkbox = PdfFormField.createEmpty(writer);
			   checkbox.valueAsName = "Off";
			   checkbox.appearanceState = "Off";
			   checkbox.setAppearanceState(PdfAnnotation.APPEARANCE_NORMAL, "Off", buttonStates[0]);
			   checkbox.setAppearanceState(PdfAnnotation.APPEARANCE_NORMAL, "FR", buttonStates[1]);
			   cell.cellEvent = new Layout(f1, checkbox, 0);
			   subtable.addCell(cell);
			   
			   subtable.addStringCell("French");
			   cell = new PdfPCell();
			   checkbox = PdfFormField.createEmpty(writer);
			   checkbox.valueAsName = "Off";
			   checkbox.appearanceState = "Off";
			   checkbox.setAppearanceState(PdfAnnotation.APPEARANCE_NORMAL, "Off", buttonStates[0]);
			   checkbox.setAppearanceState(PdfAnnotation.APPEARANCE_NORMAL, "NL", buttonStates[1]);
			   cell.cellEvent = new Layout(f1, checkbox, 0);
			   subtable.addCell(cell);
			   
			   subtable.addStringCell("Italian");
			   table.addCell( PdfPCell.fromTable( subtable ) );

			   var f2: PdfFormField = PdfFormField.createEmpty(writer);
			   f2.fieldName = "knowledge";
			   parent.addKid(f2);
			   table.addStringCell("Knowledge of:");
			   subtable = new PdfPTable(widths);
			   cell = new PdfPCell();
			   checkbox = PdfFormField.createCheckBox(writer);
			   checkbox.fieldName = "English";
			   checkbox.valueAsName = "Off";
			   checkbox.appearanceState = "Off";
			   checkbox.setAppearanceState(PdfAnnotation.APPEARANCE_NORMAL, "Off", buttonStates[0]);
			   checkbox.setAppearanceState(PdfAnnotation.APPEARANCE_NORMAL, "On", buttonStates[1]);
			   cell.cellEvent = new Layout(f2, checkbox, 0);
			   subtable.addCell(cell);
			   
			   subtable.addStringCell("English");
			   cell = new PdfPCell();
			   checkbox = PdfFormField.createCheckBox(writer);
			   checkbox.fieldName = "French";
			   checkbox.valueAsName = "Off";
			   checkbox.appearanceState = "Off";
			   checkbox.setAppearanceState(PdfAnnotation.APPEARANCE_NORMAL, "Off", buttonStates[0]);
			   checkbox.setAppearanceState(PdfAnnotation.APPEARANCE_NORMAL, "On", buttonStates[1]);
			   cell.cellEvent = new Layout(f2, checkbox, 0);
			   subtable.addCell(cell);
			   
			   subtable.addStringCell("French");
			   cell = new PdfPCell();
			   checkbox = PdfFormField.createCheckBox(writer);
			   checkbox.fieldName = "Italian";
			   checkbox.valueAsName = "Off";
			   checkbox.appearanceState = "Off";
			   checkbox.setAppearanceState(PdfAnnotation.APPEARANCE_NORMAL, "Off", buttonStates[0]);
			   checkbox.setAppearanceState(PdfAnnotation.APPEARANCE_NORMAL, "On", buttonStates[1]);
			   cell.cellEvent = new Layout(f2, checkbox, 0);
			   subtable.addCell(cell);
			   
			   subtable.addStringCell("Italian");
			   table.addCell( PdfPCell.fromTable(subtable));

			return table;
		}
	}
}
import org.purepdf.elements.RectangleElement;
import org.purepdf.errors.ConversionError;
import org.purepdf.pdf.PdfAnnotation;
import org.purepdf.pdf.PdfContentByte;
import org.purepdf.pdf.PdfPCell;
import org.purepdf.pdf.forms.PdfFormField;
import org.purepdf.pdf.interfaces.IPdfPCellEvent;

class Layout implements IPdfPCellEvent
{
	protected var kid: PdfFormField;
	protected var padding: Number;
	protected var parent: PdfFormField;

	public function Layout( parent: PdfFormField, kid: PdfFormField, padding: Number )
	{
		this.parent = parent;
		this.kid = kid;
		this.padding = padding;
	}

	public function cellLayout( cell: PdfPCell, position: RectangleElement, canvases: Vector.<PdfContentByte> ): void
	{
		kid.setWidget( new RectangleElement( position.getLeft( padding ), position.getBottom( padding ), position.
						getRight( padding ), position.getTop( padding ) ), PdfAnnotation.HIGHLIGHT_INVERT );

		try
		{
			parent.addKid( kid );
		} catch ( e: Error )
		{
			throw new ConversionError( e );
		}
	}
}