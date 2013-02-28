package
{
	import flash.events.Event;
	
	import org.purepdf.colors.RGBColor;
	import org.purepdf.elements.Element;
	import org.purepdf.elements.RectangleElement;
	import org.purepdf.pdf.PageSize;
	import org.purepdf.pdf.PdfAction;
	import org.purepdf.pdf.PdfAnnotation;
	import org.purepdf.pdf.PdfAppearance;
	import org.purepdf.pdf.PdfContentByte;
	import org.purepdf.pdf.PdfName;
	import org.purepdf.pdf.fonts.BaseFont;
	import org.purepdf.pdf.forms.PdfFormField;

	public class Calculator extends DefaultBasicExample
	{
		private var BF: BaseFont;
		
		public function Calculator( d_list: Array = null )
		{
			super( ["Create a calculator using javascript"] );
			registerDefaultFont();
			
			BF = BaseFont.createFont( BaseFont.HELVETICA, BaseFont.WINANSI, BaseFont.NOT_EMBEDDED );
		}
		
		override protected function execute(event:Event=null) : void
		{
			super.execute();
			
			createDocument("calculator", PageSize.create( 200, 200 ) );
			document.open();
			
			var digits: Vector.<RectangleElement> = new Vector.<RectangleElement>(10);
			digits[0] = createRectangle(3, 1, 2, 2);
			digits[1] = createRectangle(1, 3, 2, 2);
			digits[2] = createRectangle(3, 3, 2, 2);
			digits[3] = createRectangle(5, 3, 2, 2);
			digits[4] = createRectangle(1, 5, 2, 2);
			digits[5] = createRectangle(3, 5, 2, 2);
			digits[6] = createRectangle(5, 5, 2, 2);
			digits[7] = createRectangle(1, 7, 2, 2);
			digits[8] = createRectangle(3, 7, 2, 2);
			digits[9] = createRectangle(5, 7, 2, 2);
			var plus: RectangleElement = createRectangle(7, 7, 2, 2);
			var minus: RectangleElement = createRectangle(9, 7, 2, 2);
			var mult: RectangleElement = createRectangle(7, 5, 2, 2);
			var div: RectangleElement = createRectangle(9, 5, 2, 2);
			var equals: RectangleElement = createRectangle(7, 1, 3, 2);
			var clearEntry: RectangleElement = createRectangle(7, 9, 2, 2);
			var clear: RectangleElement = createRectangle(9, 9, 2, 2);
			var result: RectangleElement = createRectangle(1, 9, 6, 2);
			var move: RectangleElement = createRectangle(8, 3, 2, 2);
			
			document.addJavaScript("var previous = 0; var current = 0; var operation = '';\n"
					+ "function showCurrent() { this.getField('result').value = current; }\n"
					+ "function showMove(s) { this.getField('move').value = s; }\n"
					+ "function augment(digit) {\n"
					+ "current = current * 10 + digit;\n"
					+ "showCurrent();\n"
					+ "}\n"
					+ "function register(op) { previous = current; current = 0; operation = op; showCurrent(); }\n"
					+ "function calculate_result() {\n"
					+ "if (operation == '+') current = previous + current;\n"
					+ "else if (operation == '-') current = previous - current;\n"
					+ "else if (operation == '*') current = previous * current;\n"
					+ "else if (operation == '/') current = previous / current;\n"
					+ "showCurrent();\n"
					+ "}\n"
					+ "function reset(all) { current = 0; if(all) previous = 0; showCurrent(); }\n"
					+ "showCurrent();");
			
			for( var i: int = 0; i < 10; i++ )
			{
				addPushButton( digits[i], i.toString(), "this.augment(" + i + ")");
			}
			addPushButton( plus, "+", "this.register('+')");
			addPushButton( minus, "-", "this.register('-')");
			addPushButton( mult, "x", "this.register('*')");
			addPushButton( div, "/", "this.register('/')");
			addPushButton( equals, "=", "this.calculate_result()");
			addPushButton( clearEntry, "CE", "this.reset(false)");
			addPushButton( clear, "C", "this.reset(true)");
			addTextField( result, "result");
			addTextField( move, "move");
			
			document.close();
			save();
		}
		
		private function addTextField( rect: RectangleElement, name: String ): void
		{
			var field: PdfFormField = PdfFormField.createTextField(writer, false, false, 0);
			field.setWidget(rect, PdfAnnotation.HIGHLIGHT_NONE);
			field.mkBackgroundColor = RGBColor.CYAN;
			field.quadding = PdfFormField.Q_RIGHT;
			field.fieldName = name;
			field.fieldFlags = PdfFormField.FF_READ_ONLY;
			document.addAnnotation(field);
		}

		private function addPushButton( rect: RectangleElement, btn: String, script: String ): void
		{
			var w: Number = rect.width;
			var h: Number = rect.height;
			var pushbutton: PdfFormField = PdfFormField.createPushButton( writer );
			
			pushbutton.fieldName = "btn_" + btn;
			pushbutton.setAdditionalActions( PdfName.U, PdfAction.javaScript( script, writer ) );
			pushbutton.setAdditionalActions( PdfName.E, PdfAction.javaScript( "this.showMove('" + btn + "');", writer ) );
			pushbutton.setAdditionalActions( PdfName.X, PdfAction.javaScript( "this.showMove(' ');", writer ) );
			
			var cb: PdfContentByte = document.getDirectContent();
			
			pushbutton.setAppearance( PdfAnnotation.APPEARANCE_NORMAL, createAppearance( cb, btn, RGBColor.BLACK, w, h ) );
			pushbutton.setAppearance( PdfAnnotation.APPEARANCE_ROLLOVER, createAppearance( cb, btn, RGBColor.DARK_GRAY, w, h ) );
			pushbutton.setAppearance( PdfAnnotation.APPEARANCE_DOWN, createAppearance( cb, btn, RGBColor.BLUE, w, h ) );
			pushbutton.setWidget( rect, PdfAnnotation.HIGHLIGHT_PUSH );
			document.addAnnotation( pushbutton );
		}

		private function createAppearance( cb: PdfContentByte, btn: String, color: RGBColor, w: Number, h: Number ): PdfAppearance
		{
			var app: PdfAppearance = cb.createAppearance( w, h );
			app.setColorFill( color );
			app.roundRectangle( 2, 2, w - 4, h - 4, 2 );
			app.fill();
			app.beginText();
			app.setColorFill( RGBColor.WHITE );
			app.setFontAndSize( BF, h / 2 );
			app.showTextAligned( Element.ALIGN_CENTER, btn, w / 2, h / 4, 0 );
			app.endText();
			return app;
		}

		private function createRectangle( column: int, row: int, width: int, height: int ): RectangleElement
		{
			column = column * 18;
			row = row * 18;
			return new RectangleElement( column, row, column + width * 18, row + height * 18 );
		}
	}
}