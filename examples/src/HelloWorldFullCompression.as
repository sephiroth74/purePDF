package
{
	import flash.events.Event;
	
	import org.purepdf.elements.Paragraph;

	public class HelloWorldFullCompression extends DefaultBasicExample
	{
		public function HelloWorldFullCompression(d_list:Array=null)
		{
			super(["Use PdfWriter fullcompression"]);
			registerDefaultFont();
		}
		
		override protected function execute(event:Event=null):void
		{
			super.execute();
			
			createDocument();

			writer.setFullCompression();
			document.open();
			document.add( new Paragraph("Hello Full Compression") );
			document.close();
			save();
		}
			
	}
}