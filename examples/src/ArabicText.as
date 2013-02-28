package
{
	import flash.events.Event;
	
	import org.purepdf.Font;
	import org.purepdf.elements.Element;
	import org.purepdf.elements.Paragraph;
	import org.purepdf.pdf.ColumnText;
	import org.purepdf.pdf.PdfContentByte;
	import org.purepdf.pdf.PdfWriter;
	import org.purepdf.pdf.fonts.BaseFont;
	import org.purepdf.pdf.fonts.FontsResourceFactory;

	public class ArabicText extends DefaultBasicExample
	{
		[Embed(source="assets/fonts/XB Roya.ttf", mimeType="application/octet-stream")]
		private var cls: Class;
		
		public function ArabicText(d_list:Array=null)
		{
			super(d_list);
			registerDefaultFont();
			FontsResourceFactory.getInstance().registerFont( "arialuni.ttf", new cls() );
		}
		
		override protected function execute(event:Event=null) : void
		{
			super.execute();
			createDocument();
			document.open();
			
			var bf: BaseFont = BaseFont.createFont( "arialuni.ttf", BaseFont.IDENTITY_H, true);
			var font: Font = new Font( -1, 24, -1, null, bf );
			var cb: PdfContentByte = writer.getDirectContent();
			var p: Paragraph = new Paragraph("Sorry, I don't know what I'm going to write:");
			ColumnText.showTextAligned( cb, Element.ALIGN_LEFT, p, 36, document.pageSize.height - 36, 0, PdfWriter.RUN_DIRECTION_DEFAULT, 0);
			
			p = new Paragraph("\u0646\u0642\u0644\u0643 \u0632\u0631 \u0636\u0631\u0628\u0629\u062D\u0638", font );
			p.alignment = Element.ALIGN_LEFT;
			
			ColumnText.showTextAligned( cb, Element.ALIGN_RIGHT, p, document.pageSize.width - 36, document.pageSize.height - 72, 0, PdfWriter.RUN_DIRECTION_RTL, 0);
			
			document.close();
			save();
		}
	}
}