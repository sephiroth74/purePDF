package
{
	import flash.events.Event;
	
	import org.purepdf.Font;
	import org.purepdf.colors.RGBColor;
	import org.purepdf.elements.Paragraph;
	import org.purepdf.pdf.PdfDocument;
	import org.purepdf.pdf.fonts.BaseFont;
	import org.purepdf.pdf.fonts.FontsResourceFactory;
	import org.purepdf.pdf.fonts.cmaps.CJKFontResourceFactory;
	import org.purepdf.pdf.fonts.cmaps.CMapResourceFactory;
	import org.purepdf.resources.BuiltinCJKFonts;
	import org.purepdf.resources.CMap;
	import org.purepdf.resources.ICMap;
	import org.purepdf.utils.IProperties;
	import org.purepdf.utils.Properties;

	public class ChineseEmbedFont extends DefaultBasicExample
	{
		
		[Embed(source="assets/fonts/HDZB_24.ttf", mimeType="application/octet-stream")] 
		private var cls1: Class;
		
		public function ChineseEmbedFont()
		{
			super(["This example will show how to load cmaps and properties","in order to write some CJK chars"]);
		}
		
		override protected function execute(event:Event=null) : void
		{
			super.execute();
			createDocument();
			
			FontsResourceFactory.getInstance().registerFont("HDZB_24.ttf", new cls1());
			
			PdfDocument.compress = false;
			document.open();
			
			var bf: BaseFont = BaseFont.createFont("HDZB_24.ttf", BaseFont.UniGB_UCS2_H, BaseFont.EMBEDDED );
			var font: Font = new Font( -1, 32, -1, RGBColor.BLACK, bf );
			
			document.add( new Paragraph("\u5341\u950a\u57cb\u4f0f", font));
			
			document.close();
			save();
		}
	}
}