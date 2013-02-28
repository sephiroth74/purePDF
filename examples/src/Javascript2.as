package
{
	import flash.events.Event;
	
	import org.purepdf.colors.RGBColor;
	import org.purepdf.elements.Element;
	import org.purepdf.elements.RectangleElement;
	import org.purepdf.pdf.PdfAction;
	import org.purepdf.pdf.PdfAnnotation;
	import org.purepdf.pdf.PdfAppearance;
	import org.purepdf.pdf.PdfContentByte;
	import org.purepdf.pdf.fonts.BaseFont;
	import org.purepdf.pdf.forms.PdfFormField;

	public class Javascript2 extends DefaultBasicExample
	{
		public function Javascript2(d_list:Array=null)
		{
			super(["Add actions to pdf elements"]);
			registerDefaultFont();
		}
		
		override protected function execute(event:Event=null) : void
		{
			super.execute();
			
			createDocument();
			document.open();

			document.addJavaScript("function showButtonState() {\n"
				+ "app.alert('Checkboxes:"
				+ " English: ' + this.getField('English').value + "
				+ "' Spanish: ' + this.getField('Spanish').value + "
				+ "' Italian: ' + this.getField('Italian').value + "
				+ "' Radioboxes: ' + this.getField('language').value);"
				+ "\n}");
			
			var cb: PdfContentByte = document.getDirectContent();
			var bf: BaseFont = BaseFont.createFont(BaseFont.HELVETICA, BaseFont.WINANSI, BaseFont.NOT_EMBEDDED);
			var languages: Vector.<String> = Vector.<String>([ "Italian", "English", "Spanish" ]);
			var rect: RectangleElement;
			
			var radiobuttonStates: Vector.<PdfAppearance> = new Vector.<PdfAppearance>(2);
			radiobuttonStates[0] = cb.createAppearance(20, 20);
			radiobuttonStates[0].circle(10, 10, 9);
			radiobuttonStates[0].stroke();
			radiobuttonStates[1] = cb.createAppearance(20, 20);
			radiobuttonStates[1].circle(10, 10, 9);
			radiobuttonStates[1].stroke();
			radiobuttonStates[1].circle(10, 10, 3);
			radiobuttonStates[1].fillStroke();
			
			var language: PdfFormField = PdfFormField.createRadioButton(writer, true);
			language.fieldName = "language";
			language.valueAsName = languages[0];
			
			var i: int;
			for ( i = 0; i < languages.length; i++) 
			{
				rect = new RectangleElement(40, 806 - i * 40, 60, 788 - i * 40);
				addRadioButton(rect, language, languages[i], radiobuttonStates, i == 0);
				cb.beginText();
				cb.setFontAndSize(bf, 18);
				cb.showTextAligned(Element.ALIGN_LEFT, languages[i], 70, 790 - i * 40, 0);
				cb.endText();
			}
			
			document.addAnnotation(language);
			
			var checkboxStates: Vector.<PdfAppearance> = new Vector.<PdfAppearance>(2);
			checkboxStates[0] = cb.createAppearance(20, 20);
			checkboxStates[0].rectangle(1, 1, 18, 18);
			checkboxStates[0].stroke();
			checkboxStates[1] = cb.createAppearance(20, 20);
			checkboxStates[1].setColorFill( new RGBColor( 255, 128, 128 ) );
			checkboxStates[1].rectangle(1, 1, 18, 18);
			checkboxStates[1].fillStroke();
			checkboxStates[1].moveTo(1, 1);
			checkboxStates[1].lineTo(19, 19);
			checkboxStates[1].moveTo(1, 19);
			checkboxStates[1].lineTo(19, 1);
			checkboxStates[1].stroke();
			
			for ( i = 0; i < languages.length; i++) {
				rect = new RectangleElement(260, 806 - i * 40, 280, 788 - i * 40);
				createCheckbox( rect, languages[i], checkboxStates);
				cb.beginText();
				cb.setFontAndSize(bf, 18);
				cb.showTextAligned(Element.ALIGN_LEFT, languages[i], 290, 790 - i * 40, 0);
				cb.endText();
			}
			
			var normal: PdfAppearance = cb.createAppearance(100, 50);
			normal.setColorFill( RGBColor.GRAY );
			normal.rectangle(5, 5, 90, 40);
			normal.fill();
			
			var rollover: PdfAppearance = cb.createAppearance(100, 50);
			rollover.setColorFill(RGBColor.RED);
			rollover.rectangle(5, 5, 90, 40);
			rollover.fill();
			
			var down: PdfAppearance = cb.createAppearance(100, 50);
			down.setColorFill( RGBColor.BLUE );
			down.rectangle(5, 5, 90, 40);
			down.fill();
			
			var pushbutton: PdfFormField = PdfFormField.createPushButton(writer);
			pushbutton.fieldName = "PushAction";
			pushbutton.setAppearance(PdfAnnotation.APPEARANCE_NORMAL, normal);
			pushbutton.setAppearance(PdfAnnotation.APPEARANCE_ROLLOVER, rollover);
			pushbutton.setAppearance(PdfAnnotation.APPEARANCE_DOWN, down);
			pushbutton.setWidget(new RectangleElement(40, 650, 150, 680), PdfAnnotation.HIGHLIGHT_PUSH);
			
			pushbutton.action = PdfAction.javaScript("this.showButtonState()", writer);
			document.addAnnotation(pushbutton);
			
			document.close();
			save();
		}
		
		private function addRadioButton( rect: RectangleElement, radio: PdfFormField, name: String, onOff: Vector.<PdfAppearance>, on: Boolean ): void
		{
			var field: PdfFormField = PdfFormField.createEmpty( writer );
			field.setWidget( rect, PdfAnnotation.HIGHLIGHT_INVERT );
			if(on)
				field.appearanceState = name;
			else
				field.appearanceState = "Off";
			
			field.setAppearanceState(PdfAnnotation.APPEARANCE_NORMAL, "Off", onOff[0]);
			field.setAppearanceState(PdfAnnotation.APPEARANCE_NORMAL, name, onOff[1]);
			radio.addKid(field);
		}
		
		private function createCheckbox( rect: RectangleElement, name: String, onOff: Vector.<PdfAppearance> ): void
		{
			var field: PdfFormField = PdfFormField.createCheckBox(writer);
			field.setWidget(rect, PdfAnnotation.HIGHLIGHT_INVERT);
			field.fieldName = name;
			field.valueAsName = "Off";
			field.appearanceState = "Off";
			field.setAppearanceState(PdfAnnotation.APPEARANCE_NORMAL, "Off", onOff[0]);
			field.setAppearanceState(PdfAnnotation.APPEARANCE_NORMAL, "On", onOff[1]);
			document.addAnnotation(field);
		}
	}
}