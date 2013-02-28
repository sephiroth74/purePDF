package
{
	import flash.events.Event;
	
	import org.purepdf.colors.GrayColor;
	import org.purepdf.elements.RectangleElement;
	import org.purepdf.pdf.PdfBorderDictionary;
	import org.purepdf.pdf.PdfContentByte;
	import org.purepdf.pdf.fonts.BaseFont;
	import org.purepdf.pdf.forms.FieldBase;
	import org.purepdf.pdf.forms.FieldText;

	public class SimpleTextField extends DefaultBasicExample
	{
		public function SimpleTextField(d_list:Array=null)
		{
			super(d_list);
			registerDefaultFont();
		}
		
		override protected function execute(event:Event=null) : void
		{
			super.execute();
			createDocument();
			document.open();
			
			var bf: BaseFont = BaseFont.createFont( BaseFont.HELVETICA, BaseFont.WINANSI, false, true );
			var cb: PdfContentByte = document.getDirectContent();
			cb.beginText();
			cb.setFontAndSize( bf, 12 );
			cb.moveText( 36, 800 );
			cb.showText("Hello World");
			cb.endText();
			
			var tf: FieldText = new FieldText( writer, new RectangleElement( 107, 785, 340, 830 ), "Who");
			tf.fontSize = 12;
			tf.font = bf;
			tf.text = "Who I am?";
			tf.textColor = new GrayColor( 0.5 );
			tf.borderColor = new GrayColor( 0.8 );
			tf.borderStyle = PdfBorderDictionary.STYLE_BEVELED;
			tf.borderWidth = FieldBase.BORDER_WIDTH_THICK;
			document.addAnnotation( tf.getTextField() );
			
			document.close();
			save();
		}
	}
}