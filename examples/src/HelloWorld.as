package
{
	import flash.events.Event;
	
	import org.purepdf.elements.Paragraph;
	import org.purepdf.pdf.PdfDocument;
	import org.purepdf.pdf.PdfStream;
	import org.purepdf.pdf.fonts.BaseFont;
	import org.purepdf.pdf.fonts.FontsResourceFactory;
	import org.purepdf.resources.BuiltinFonts;

	public class HelloWorld extends DefaultBasicExample
	{
		public function HelloWorld(d_list:Array=null)
		{
			super(["This example shows how to add a simple text to the document","using a Paragraph element"]);
			registerDefaultFont();
		}
		
		override protected function execute(event:Event=null) : void
		{
			super.execute();
		
			createDocument( "Hello World" );
			document.open();
			document.add( new Paragraph("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent vel lectus lorem. Phasellus convallis, tortor a venenatis mattis, erat mi euismod tellus, in fermentum sapien nibh sit amet urna. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Praesent tellus libero, lacinia ac egestas eget, interdum quis purus. Donec ut nisl metus, sit amet viverra turpis. Mauris ultrices dapibus lacus non ultrices. Cras elementum luctus mauris, vitae eleifend diam accumsan ut. Aliquam erat volutpat. Suspendisse placerat nibh in libero tincidunt a elementum mi vehicula. Donec lobortis magna vel nibh mollis tempor. Maecenas et elit nunc. Nam non auctor orci. Aliquam vel velit vel mi adipiscing semper in ac orci. Vestibulum commodo sem eget tortor lobortis semper. Ut sit amet sapien non velit rutrum egestas sollicitudin in elit. Fusce laoreet leo a sem mattis iaculis") );
			document.close();
			save();
		}
	}
}