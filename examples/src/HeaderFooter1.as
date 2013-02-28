package
{
	import flash.events.Event;
	
	import org.purepdf.Font;
	import org.purepdf.colors.RGBColor;
	import org.purepdf.colors.SpotColor;
	import org.purepdf.elements.Element;
	import org.purepdf.elements.HeaderFooter;
	import org.purepdf.elements.Paragraph;
	import org.purepdf.elements.Phrase;
	import org.purepdf.elements.RectangleElement;
	import org.purepdf.events.PageEvent;
	import org.purepdf.pdf.fonts.BaseFont;
	import org.purepdf.resources.BuiltinFonts;
	import org.purepdf.pdf.fonts.FontsResourceFactory;

	public class HeaderFooter1 extends DefaultBasicExample
	{
		private var headerFont: Font;
		private var footerFont: Font;
		
		public function HeaderFooter1()
		{
			super(["This example shows how to add headers and footer","to a pdf document"]);
			registerDefaultFont();
			
			FontsResourceFactory.getInstance().registerFont( BaseFont.HELVETICA_BOLD, new BuiltinFonts.HELVETICA_BOLD() );
			FontsResourceFactory.getInstance().registerFont( BaseFont.TIMES_ITALIC, new BuiltinFonts.TIMES_ITALIC() );
			
			headerFont = new Font( Font.TIMES_ROMAN, 10, Font.ITALIC, new RGBColor(100, 100, 100) );
			footerFont = new Font( Font.HELVETICA, 10, Font.BOLD );
		}
		
		override protected function execute(event:Event=null):void
		{
			super.execute();
			
			createDocument();
			
			var header: HeaderFooter = new HeaderFooter( new Phrase( "http://code.google.com/p/purepdf", headerFont ), null, false );
			header.alignment = Element.ALIGN_RIGHT;
			header.borderColor = new RGBColor( 100, 100, 100 );
			header.border = RectangleElement.BOTTOM;
			header.borderWidth = 0.5;
			
			var footer: HeaderFooter = new HeaderFooter( new Phrase( "Page Number. ", footerFont ) );
			footer.alignment = Element.ALIGN_CENTER;
			footer.border = RectangleElement.NO_BORDER;
			footer.backgroundColor = new RGBColor( 180, 180, 180 );
			
			document.setHeader( header );
			document.setFooter( footer );
			
			document.open();
			document.add( new Paragraph("This is a single paragraph" ) );
			document.close();
			save();
		}
	}
}