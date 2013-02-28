package
{
	import flash.events.Event;
	
	import org.purepdf.elements.Paragraph;
	import org.purepdf.pdf.PdfAction;
	import org.purepdf.pdf.PdfDocument;

	public class Javascript1 extends DefaultBasicExample
	{
		public function Javascript1(d_list:Array=null)
		{
			super(["Add custom javascript commands"]);
			registerDefaultFont();
		}
		
		override protected function execute(event:Event=null) : void
		{
			super.execute();
			
			createDocument();
			document.open();
			
			document.addJavaScript( "function saySomething(s){ app.alert('JS says: ' + s)}", false );
			document.addAdditionalAction( PdfDocument.DOCUMENT_CLOSE, PdfAction.javaScript("saySomething('Thank you for reading the document.');\r", writer ));
			document.add( new Paragraph("PDF document with a Javascript function. A dialog will appear when the document will be closed..."));
			
			document.close();
			save();
		}
	}
}