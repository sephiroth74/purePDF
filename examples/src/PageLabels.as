package
{
	import flash.events.Event;
	
	import org.purepdf.elements.Paragraph;
	import org.purepdf.pdf.PdfPageLabels;
	import org.purepdf.pdf.PdfViewPreferences;

	public class PageLabels extends DefaultBasicExample
	{
		public function PageLabels()
		{
			super(["PDF document with page labels","(under the page thumbnail)"]);
			registerDefaultFont();
		}
		
		override protected function execute(event:Event=null):void
		{
			super.execute();
			
			createDocument();
			document.setViewerPreferences( PdfViewPreferences.PageModeUseThumbs );
			document.open();

			for( var k: int = 0; k < 20; ++k )
			{
				document.add( new Paragraph("Hello page " + (k+1) ) );
				document.newPage();
			}
			
			var labels: PdfPageLabels = new PdfPageLabels();
			labels.addPageLabel( 1, PdfPageLabels.LOWERCASE_LETTERS );
			labels.addPageLabel( 8, PdfPageLabels.UPPERCASE_ROMAN_NUMERALS );
			labels.addPageLabel( 12, PdfPageLabels.DECIMAL_ARABIC_NUMERALS );
			labels.addPageLabel( 15, PdfPageLabels.DECIMAL_ARABIC_NUMERALS, "A-", 15 );
			
			document.setPageLabels( labels );
			
			document.close();
			save();
		}
	}
}