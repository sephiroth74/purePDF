package
{
	import flash.events.Event;
	
	import org.purepdf.elements.Paragraph;

	public class FileAttachment1 extends DefaultBasicExample
	{
		[Embed(source="assets/caesar.txt", mimeType="application/octet-stream")]
		private var file: Class;
		
		public function FileAttachment1()
		{
			super(["Creates a pdf with a txt file attachment"]);
			registerDefaultFont();
		}
		
		override protected function execute(event:Event=null):void
		{
			super.execute();
			
			createDocument();
			document.open();
			
			document.add( new Paragraph("Hello World") );
			document.addFileAttachment( "This is a simple txt file", new file(), "caesar.txt" );
			document.close();
			save();
		}
	}
}