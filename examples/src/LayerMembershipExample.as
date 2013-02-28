package
{
	import flash.events.Event;
	
	import org.purepdf.Font;
	import org.purepdf.colors.RGBColor;
	import org.purepdf.elements.Element;
	import org.purepdf.elements.Phrase;
	import org.purepdf.pdf.ColumnText;
	import org.purepdf.pdf.PageSize;
	import org.purepdf.pdf.PdfContentByte;
	import org.purepdf.pdf.PdfLayer;
	import org.purepdf.pdf.PdfLayerMembership;
	import org.purepdf.pdf.PdfVersion;
	import org.purepdf.pdf.fonts.BaseFont;
	import org.purepdf.pdf.fonts.FontsResourceFactory;

	public class LayerMembershipExample extends DefaultBasicExample
	{
		[Embed(source="assets/fonts/AshleyScriptMTStd.otf", mimeType="application/octet-stream")] private var cls1: Class;
		
		public function LayerMembershipExample(d_list:Array=null)
		{
			super(["Create a PDF with optional content","Try to change the layer's visibility to see the effect"]);
			registerDefaultFont();
			FontsResourceFactory.getInstance().registerFont("AshleyScriptMTStd.otf", new cls1() );
		}
		
		override protected function execute(event:Event=null):void
		{
			super.execute();
			
			var bf: BaseFont = BaseFont.createFont("AshleyScriptMTStd.otf", BaseFont.WINANSI, BaseFont.EMBEDDED );
			var font: Font = new Font( -1, 20, -1, null, bf );
			
			var font1: Font = new Font( -1, 20, -1, RGBColor.GREEN, bf );
			var font2: Font = new Font( -1, 20, -1, RGBColor.RED, bf );
			
			createDocument("Layer membership example", PageSize.A4 );
			document.setPdfVersion( PdfVersion.VERSION_1_5 );
			document.open();
			
			var cb: PdfContentByte = document.getDirectContent();
			
			var dog: PdfLayer = new PdfLayer("Layer 1", writer);
			var tiger: PdfLayer = new PdfLayer("Layer 2", writer);
			var lion: PdfLayer = new PdfLayer("Layer 3", writer);
			
			var cat: PdfLayerMembership = new PdfLayerMembership( writer );
			cat.addMember( tiger );
			cat.addMember( lion );
			
			var no_cat: PdfLayerMembership = new PdfLayerMembership( writer );
			no_cat.addMember( tiger );
			no_cat.addMember( lion );
			no_cat.visibilityPolicy = PdfLayerMembership.ALLOFF;
			
			cb.beginLayer( dog );
			ColumnText.showTextAligned( cb, Element.ALIGN_LEFT, new Phrase("Dog", font ), 50, 775, 0 );
			cb.endLayer();
			
			cb.beginLayer( tiger );
			ColumnText.showTextAligned( cb, Element.ALIGN_LEFT, new Phrase("Tiger", font ), 50, 750, 0 );
			cb.endLayer();
			
			cb.beginLayer( lion );
			ColumnText.showTextAligned( cb, Element.ALIGN_LEFT, new Phrase("Lion", font ), 50, 725, 0 );
			cb.endLayer();
			
			cb.beginLayer( cat );
			ColumnText.showTextAligned( cb, Element.ALIGN_LEFT, new Phrase("Cat", font1 ), 50, 700, 0 );
			cb.endLayer();
			
			cb.beginLayer( no_cat );
			ColumnText.showTextAligned( cb, Element.ALIGN_LEFT, new Phrase("No Cat", font2 ), 50, 700, 0 );
			cb.endLayer();
			
			document.close();
			save();
		}
	}
}