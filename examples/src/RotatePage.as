package
{
	import flash.events.Event;
	
	import org.purepdf.colors.RGBColor;
	import org.purepdf.elements.Paragraph;
	import org.purepdf.elements.RectangleElement;
	import org.purepdf.pdf.PageSize;
	import org.purepdf.pdf.PdfViewPreferences;

	public class RotatePage extends DefaultBasicExample
	{
		public function RotatePage()
		{
			super(["Create a document with 3 pages","with different size and rotations"]);
			registerDefaultFont();
		}
		
		override protected function execute(event:Event=null):void
		{
			super.execute();
			
			var r0: RectangleElement = RectangleElement.clone(PageSize.A4);
			var r1: RectangleElement = PageSize.A6.rotate();
			var r2: RectangleElement = RectangleElement.clone(PageSize.A8);
			
			r0.backgroundColor = RGBColor.WHITE;
			r1.backgroundColor = RGBColor.LIGHT_GRAY;
			r2.backgroundColor = RGBColor.YELLOW;
			
			createDocument("", r0 );
			document.setViewerPreferences( PdfViewPreferences.PageLayoutTwoPageLeft | PdfViewPreferences.FitWindow );
			
			document.open();
			document.add( new Paragraph("Hello page 1!") );
			
			document.pageSize = r1;
			document.newPage();
			document.add( new Paragraph("Hello page 2!"));
			
			
			document.pageSize = r2;
			document.newPage();
			document.add( new Paragraph("Hello page 3!"));
			
			document.close();
			
			save();
		}
	}
}