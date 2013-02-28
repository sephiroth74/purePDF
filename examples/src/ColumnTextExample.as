package
{
	import flash.events.Event;
	
	import org.purepdf.elements.Element;
	import org.purepdf.elements.Paragraph;
	import org.purepdf.elements.Phrase;
	import org.purepdf.pdf.ColumnText;
	import org.purepdf.pdf.PageSize;
	import org.purepdf.pdf.PdfContentByte;

	public class ColumnTextExample extends DefaultBasicExample
	{
		public function ColumnTextExample()
		{
			super(["This example will show how to use the ColumnText class","for creating multi columns text"]);
			registerDefaultFont();
		}
		
		override protected function execute(event:Event=null):void
		{
			super.execute();
			createDocument();
			document.open();
			
			var cb: PdfContentByte = document.getDirectContent();
			cb.setRGBStrokeColor( 0xC0, 0xC0, 0xC0 );
			cb.moveTo(40, 36);
			cb.lineTo(40, PageSize.A4.height - 36);
			cb.moveTo(120, 36);
			cb.lineTo(120, PageSize.A4.height - 36);
			cb.moveTo(160, 36);
			cb.lineTo(160, PageSize.A4.height - 36);
			cb.moveTo(240, 36);
			cb.lineTo(240, PageSize.A4.height - 36);
			cb.moveTo(120, 36);
			cb.lineTo(120, PageSize.A4.height - 36);
			cb.moveTo(280, 36);
			cb.lineTo(280, PageSize.A4.height - 36);
			cb.moveTo(360, 36);
			cb.lineTo(360, PageSize.A4.height - 36);
			cb.moveTo(400, 36);
			cb.lineTo(400, PageSize.A4.height - 36);
			cb.moveTo(480, 36);
			cb.lineTo(480, PageSize.A4.height - 36);
			cb.stroke();
			
			var ct: ColumnText = new ColumnText(cb);
			
			// text mode: chunks and phrases only
			ct.addText(new Phrase("Quick brown fox jumps over the lazy dog", null));
			ct.setSimpleColumn2(40, 36, 120, PageSize.A4.height - 36, 18, Element.ALIGN_JUSTIFIED);
			ct.go();
			
			ct.addText(new Phrase("Quick brown fox jumps over the lazy dog", null));
			ct.setSimpleColumn2(160, 36, 240, PageSize.A4.height - 36, 18, Element.ALIGN_CENTER);
			ct.go();
			
			ct.addText(new Phrase("Quick brown fox jumps over the lazy dog", null));
			ct.setSimpleColumn2(280, 36, 360, PageSize.A4.height - 36, 18, Element.ALIGN_LEFT);
			ct.go();
			
			ct.addText(new Phrase("Quick brown fox jumps over the lazy dog", null));
			ct.setSimpleColumn2(400, 36, 480, PageSize.A4.height - 36, 18, Element.ALIGN_RIGHT);
			ct.go();
			
			// composite mode: any object
			
			var p: Paragraph = new Paragraph("Justified: Quick brown fox jumps over the lazy dog");
			p.alignment = Element.ALIGN_JUSTIFIED;
			ct.addElement(p);
			p = new Paragraph("Centered: Quick brown fox jumps over the lazy dog");
			p.alignment = Element.ALIGN_CENTER;
			ct.addElement(p);
			p = new Paragraph("Left: Quick brown fox jumps over the lazy dog");
			p.alignment = Element.ALIGN_LEFT;
			ct.addElement(p);
			p = new Paragraph("Right: Quick brown fox jumps over the lazy dog");
			p.alignment = Element.ALIGN_RIGHT;
			ct.addElement(p);
			ct.setSimpleColumn(40, 36, 120, PageSize.A4.height - 144);
			ct.go();
			
			document.close();
			save();
		}
	}
}